import 'dart:convert';

import '../../../core/ai_platform/ai_policy_registry.dart';
import '../../../core/ai_platform/ai_request_pipeline.dart';
import '../../../core/ai_platform/rag_context_builder.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_chat_quota.dart';
import '../../../core/services/llm_manager.dart';
import '../../local/models/chat_message.dart';
import '../../local/repositories/chat_repository.dart';
import '../../local/repositories/quiz_repository.dart';
import 'ai_output_gate.dart';
import 'chat_reply_result.dart';

/// Most-recent chat turns folded into the prompt for conversational continuity.
const int kChatHistoryWindow = 10;

/// Builds a RAG-grounded reply for the single continuous chat thread (B1).
///
/// Reuses the existing JSON-forcing completion path
/// ([LlmManager.completeJson]) instead of adding a new plain-text call: the
/// model is instructed to answer with `{"reply": "..."}` only, and [parseReply]
/// pulls the text back out. Consent gating, token budget, RAG retrieval, and
/// audit logging are all delegated to [AiRequestPipeline] — not reimplemented
/// here. Quota is gated separately by [BuiltInChatQuota], which is fully
/// independent from the generation quota (`BuiltInAiQuota`).
class ChatService {
  ChatService({
    required LlmManager llmManager,
    required AiRequestPipeline aiPipeline,
    required ChatRepository chatRepository,
    required QuizRepository quizRepository,
  })  : _llm = llmManager,
        _pipeline = aiPipeline,
        _chatRepository = chatRepository,
        _quizRepository = quizRepository;

  final LlmManager _llm;
  final AiRequestPipeline _pipeline;
  final ChatRepository _chatRepository;
  final QuizRepository _quizRepository;

  /// Most-recent completed quizzes folded into learning-history context.
  static const int kLearningHistoryRecentQuizzes = 5;

  /// Most-recent wrong answers folded into learning-history context.
  static const int kLearningHistoryWrongAnswers = 8;

  static const String _systemPrompt =
      'You are a friendly, encouraging learning assistant inside a study app. '
      'The learner is asking a follow-up question about their modules, quizzes, '
      'or library content. Use the conversation history, their recent quiz '
      'history/mistakes, and any reference material below when relevant; do '
      'not invent facts that contradict them. If they ask what they got wrong, '
      'how they\'re doing on a topic, or similar, answer from the "Recent quiz '
      'history" section below rather than saying you don\'t have access to it. '
      'Keep replies concise (a few sentences, more only if truly needed). '
      '\n\n'
      'You can only answer questions with text — you cannot create, add, '
      'enable, generate, download, or modify anything in the app (no library '
      'modules, quizzes, learning paths, flashcards, or settings). Never say '
      'or imply that you have done, made, added, enabled, or set up anything '
      'for the learner, even if they say "yes" or ask you to. If a request '
      'needs an action instead of an answer, say plainly that you can\'t do '
      'that yourself and tell them where in the app they can do it (e.g. '
      '"you can search for that in the Library tab"). '
      '\n\n'
      'The one exception: you may PROPOSE — but never perform — generating a '
      'quiz or a learning path on a topic. Proposing costs nothing and starts '
      'nothing; only the learner tapping a button in the app actually starts '
      'it. When you propose one, phrase it as a suggestion or question in '
      '"reply" (e.g. "Want me to generate a quiz on AWS?") and separately set '
      'the "action" field so the app can show a button — never say the quiz '
      'or path has been created, started, generated, or is ready; only that '
      'you are suggesting it. Only propose an action when the learner\'s '
      'intent is reasonably clear (they explicitly asked for a quiz, '
      'practice, a test, a learning path, or a study plan on an identifiable '
      'topic) — not on every message, and not as a guess when they are just '
      'asking a question or chatting.'
      '\n\n'
      'Respond with a single valid JSON object only, in this exact shape: '
      '{"reply": "...", "action": "none"|"proposeQuiz"|"proposePath", '
      '"quizTopic": "...", "quizQuestionCount": 15, "quizDifficulty": '
      '"easy"|"medium"|"hard", "pathTopic": "...", "pathModuleCount": 6}. '
      'Use "action":"none" and omit the quiz*/path* fields for ordinary '
      'answers. Omit whichever quiz*/path* fields do not apply to your '
      'chosen action. No markdown, no extra keys, no text outside the JSON.';

  /// Sends the learner's latest turn (already persisted by the caller — this
  /// service only reads history, it does not write messages) and returns the
  /// assistant's reply text plus any proposed quiz/path action.
  Future<ChatReplyResult> sendMessage({
    required String latestUserMessage,
    required String goalMode,
    Set<String>? enabledSourceUuids,
    Map<String, String>? sourceTypes,
  }) async {
    final resolved = await _llm.resolve();
    final isBuiltin = resolved.providerKey == BuiltInAiConfig.uuid;
    // Independent chat quota — never reads/writes BuiltInAiQuota's (generation) state.
    if (isBuiltin) {
      await BuiltInChatQuota.instance.ensureCanSend();
    }

    final firewallResult = await _pipeline.sanitizeTopic(latestUserMessage);
    if (firewallResult.blocked) {
      throw TopicNotAllowedException(firewallResult.reason ?? 'Message not allowed.');
    }

    await _pipeline.ensureTokenBudget();

    final ctx = AiRequestContext(
      task: 'chat',
      providerKey: resolved.providerKey,
      goalMode: goalMode,
      topic: firewallResult.sanitized,
      enabledSourceUuids: enabledSourceUuids,
      sourceTypes: sourceTypes,
    );

    final history = await _chatRepository.getHistory(limit: kChatHistoryWindow);
    final policyVersion = (await AiPolicyRegistry.load()).version;

    final sw = Stopwatch()..start();
    var rag = RagContext.empty;
    try {
      rag = await _pipeline.buildRag(ctx);
      final learningHistory = await _buildLearningHistorySummary();
      final basePrompt = _buildUserPrompt(history, learningHistory);
      final promptWithRag = RagContextBuilder.prependToPrompt(basePrompt, rag);

      final raw = await _llm.completeJson(
        userPrompt: promptWithRag,
        systemPrompt: _systemPrompt,
        // This service already gated on BuiltInChatQuota above; skip the
        // shared generation quota entirely so chat never touches it.
        skipQuota: true,
        recordBuiltinQuota: false,
      );
      final result = parseReplyWithAction(raw);
      sw.stop();

      await _pipeline.auditLog.record(
        task: ctx.task,
        providerKey: ctx.providerKey,
        latencyMs: sw.elapsedMilliseconds,
        success: true,
        policyVersion: policyVersion,
        ragChunkIds: rag.chunkIds,
      );
      if (isBuiltin) {
        await BuiltInChatQuota.instance.recordSent();
      }
      return result;
    } catch (e) {
      sw.stop();
      await _pipeline.auditLog.record(
        task: ctx.task,
        providerKey: ctx.providerKey,
        latencyMs: sw.elapsedMilliseconds,
        success: false,
        policyVersion: policyVersion,
        ragChunkIds: rag.chunkIds,
        errorMessage: '$e',
      );
      rethrow;
    }
  }

  static String _buildUserPrompt(List<ChatMessage> history, String? learningHistory) {
    final buffer = StringBuffer();
    if (learningHistory != null && learningHistory.isNotEmpty) {
      buffer.writeln(learningHistory);
      buffer.writeln();
    }
    if (history.isEmpty) {
      buffer.write('Respond to the learner.');
      return buffer.toString();
    }
    buffer.writeln('Conversation so far (oldest first):');
    for (final m in history) {
      final label = m.role == 'user' ? 'User' : 'Assistant';
      buffer.writeln('$label: ${m.text}');
    }
    buffer.writeln();
    buffer.writeln('Respond to the last User message above.');
    return buffer.toString();
  }

  /// A compact summary of the learner's recent quiz performance and recent
  /// mistakes — folded into the prompt so chat can answer questions like
  /// "what did I get wrong?" or "how am I doing on X?" without needing the
  /// learner to paste anything in. Best-effort: any failure here (e.g. an
  /// empty history) just means an empty/absent section, never an error.
  Future<String?> _buildLearningHistorySummary() async {
    try {
      final recent = await _quizRepository.getRecent(limit: kLearningHistoryRecentQuizzes);
      final wrong = await _quizRepository.getWrongQuestions(limit: kLearningHistoryWrongAnswers);
      if (recent.isEmpty && wrong.isEmpty) return null;

      final buffer = StringBuffer('Recent quiz history (for context, not to be quoted verbatim):');
      if (recent.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Recently completed quizzes (most recent first):');
        for (final s in recent) {
          final pct = s.accuracy != null ? '${s.accuracy!.round()}%' : 'unscored';
          buffer.writeln('- "${s.topic}" (${s.difficulty}): $pct accuracy');
        }
      }
      if (wrong.isNotEmpty) {
        buffer.writeln();
        buffer.writeln('Recently missed questions (most recent first):');
        for (final q in wrong) {
          buffer.writeln('- ${q.text}');
        }
      }
      return buffer.toString();
    } catch (_) {
      return null;
    }
  }

  /// Extracts the `reply` field from the model's `{"reply": "..."}` output.
  /// Pure and unit-testable without a network call.
  static String parseReply(String raw) {
    final normalized = AiOutputGate.normalizeJsonText(raw);
    if (normalized != null) {
      try {
        final decoded = jsonDecode(normalized);
        if (decoded is Map) {
          final reply = decoded['reply']?.toString().trim();
          if (reply != null && reply.isNotEmpty) return reply;
        }
      } catch (_) {}
    }
    final trimmed = raw.trim();
    if (trimmed.isEmpty) {
      throw const InvalidJsonException('AI returned an empty reply. Try again.');
    }
    // Defensive fallback (matches ai_study_pulse_service / interview_rubric_scorer
    // precedent): surface usable text rather than discarding a non-JSON answer.
    return trimmed;
  }

  /// Extracts both the reply text and an optional proposed quiz/path action.
  /// Reuses [parseReply] unchanged for the reply/fallback/error behavior —
  /// action extraction is independent and any failure (missing/malformed/
  /// unrecognized "action", missing required topic) silently degrades to
  /// `action: null`. This must never throw on account of the action fields
  /// alone, and never blocks returning a usable reply.
  static ChatReplyResult parseReplyWithAction(String raw) {
    final reply = parseReply(raw);
    ChatProposedAction? action;
    try {
      final normalized = AiOutputGate.normalizeJsonText(raw);
      if (normalized != null) {
        final decoded = jsonDecode(normalized);
        if (decoded is Map) {
          final kind = decoded['action']?.toString();
          if (kind == 'proposeQuiz') {
            final topic = decoded['quizTopic']?.toString().trim();
            if (topic != null && topic.isNotEmpty) {
              action = ChatProposedAction.quiz(
                topic: topic,
                questionCount: (decoded['quizQuestionCount'] as num?)?.toInt(),
                difficulty: decoded['quizDifficulty']?.toString(),
              );
            }
          } else if (kind == 'proposePath') {
            final topic = decoded['pathTopic']?.toString().trim();
            if (topic != null && topic.isNotEmpty) {
              action = ChatProposedAction.path(
                topic: topic,
                pathModuleCount: (decoded['pathModuleCount'] as num?)?.toInt(),
              );
            }
          }
        }
      }
    } catch (_) {
      action = null;
    }
    return ChatReplyResult(reply: reply, action: action);
  }
}
