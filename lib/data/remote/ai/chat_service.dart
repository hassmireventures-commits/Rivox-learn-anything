import 'dart:convert';

import '../../../core/ai_platform/ai_policy_registry.dart';
import '../../../core/ai_platform/ai_request_pipeline.dart';
import '../../../core/ai_platform/rag_context_builder.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_chat_quota.dart';
import '../../../core/services/llm_manager.dart';
import '../../../core/services/open_knowledge/open_knowledge_models.dart';
import '../../../core/services/open_knowledge/open_knowledge_service.dart';
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

  static String get _navigationTargetList =>
      ChatNavigationTargets.routes.keys.join(', ');

  static String get _systemPrompt =>
      'You are a friendly, encouraging learning assistant inside a study app. '
      'The learner is asking a follow-up question about their modules, quizzes, '
      'or library content. Use the conversation history, their recent quiz '
      'history/mistakes, and any reference material below when relevant; do '
      'not invent facts that contradict them, and never state something as '
      'fact unless you are genuinely confident it is accurate. Say you are '
      'not sure rather than guessing with confidence. If they ask what they '
      'got wrong, how they\'re doing on a topic, or similar, answer from the '
      '"Recent quiz history" section below rather than saying you don\'t have '
      'access to it. If an OPEN KNOWLEDGE section is provided below, those '
      'are real sources the app already shows as tappable links under your '
      'reply, so when the learner asks for article or reading suggestions '
      'and that section is present, introduce what you found there instead '
      'of telling them to check their library (their own uploaded library is '
      'a separate, often-empty thing from these public sources). Only say '
      'you have nothing to suggest if that section is genuinely absent or '
      'empty. Keep replies concise (a few sentences, more only if truly '
      'needed). '
      '\n\n'
      'You can only answer questions with text — you cannot create, add, '
      'enable, generate, download, or modify anything in the app (no library '
      'modules, quizzes, learning paths, flashcards, or settings). Never say '
      'or imply that you have done, made, added, enabled, or set up anything '
      'for the learner, even if they say "yes" or ask you to. '
      '\n\n'
      'Four exceptions, none of them performed by you, only proposed: '
      'generating a quiz on a topic; generating a learning path on a topic; '
      'a video suggestion on a topic; and navigating to one specific screen '
      'in the app, chosen only from this exact list (use one of these names '
      'exactly, nothing else): $_navigationTargetList. Prefer navigate over a '
      'video/quiz/path proposal whenever the learner is really just asking '
      '"where do I do X" or "take me to X", for example asking about their '
      'saved articles, their quiz history, adding library content, or '
      'changing a setting. Proposing costs nothing and starts nothing, only '
      'the learner tapping a button in the app actually does anything, and '
      'that button is the ONLY clickable thing (a bare word or phrase in '
      '"reply" is never clickable, never write a URL, never write "search '
      'YouTube for ...", "check out this video", "go to the X tab", or any '
      'instruction to go somewhere yourself, since the learner cannot tap '
      'plain text). For every one of these four proposals, "reply" is only '
      'ever a short suggestion or question (e.g. "Want me to generate a quiz '
      'on AWS?", "Want a video on binary search trees?", "Want to open your '
      'Saved Articles?") and the actual proposal lives entirely in the '
      'separate "action" field so the app can render a real button, never '
      'inside "reply" itself. Never say a quiz, path, or video has been '
      'created, started, generated, found, or is ready in "reply", and never '
      'say you have opened or navigated anywhere, only that you are '
      'suggesting it. Only propose one when the learner\'s intent is '
      'reasonably clear (they explicitly asked for a quiz, practice, a test, '
      'a learning path, a study plan, a video on an identifiable topic, or '
      'to go to a specific place in the app), not on every message, and not '
      'as a guess when they are just asking a question or chatting. For a '
      'video specifically, never name a specific video or write any link '
      'yourself, you cannot verify a specific video exists. Set "videoTopic" '
      'only, and the app builds a real, working YouTube search link from it.'
      '\n\n'
      'Respond with a single valid JSON object only, in this exact shape: '
      '{"reply": "...", "action": "none"|"proposeQuiz"|"proposePath"|'
      '"suggestVideo"|"navigate", "quizTopic": "...", "quizQuestionCount": 15, '
      '"quizDifficulty": "easy"|"medium"|"hard", "pathTopic": "...", '
      '"pathModuleCount": 6, "videoTopic": "...", "navigateTo": "..."}. '
      'Use "action":"none" and omit the quiz*/path*/video*/navigateTo fields '
      'for ordinary answers. Omit whichever fields do not apply to your '
      'chosen action. No markdown, no extra keys, no text outside the JSON.';

  /// Sends the learner's latest turn (already persisted by the caller — this
  /// service only reads history, it does not write messages) and returns the
  /// assistant's reply text plus any proposed quiz/path action.
  Future<ChatReplyResult> sendMessage({
    required String latestUserMessage,
    required String goalMode,
    Set<String>? enabledSourceUuids,
    Map<String, String>? sourceTypes,
    String? learnerMemory,
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
      // Run independently instead of sequentially, none of these three
      // depend on each other, so awaiting them one at a time was pure added
      // latency for no reason. A short/conversational turn ("yes", "thanks")
      // skips the open-knowledge fetch entirely rather than spending a
      // network round-trip on a topic that isn't really a topic.
      final ragFuture = _pipeline.buildRag(ctx);
      final learningHistoryFuture = _buildLearningHistorySummary();
      final looksLikeTopic = ctx.topic.trim().split(RegExp(r'\s+')).length >= 3;
      final openKnowledgeFuture = looksLikeTopic
          ? OpenKnowledgeService()
              .gatherHits(ctx.topic)
              .timeout(const Duration(seconds: 6), onTimeout: () => const <OpenKnowledgeHit>[])
              .catchError((_) => const <OpenKnowledgeHit>[])
          : Future.value(const <OpenKnowledgeHit>[]);

      rag = await ragFuture;
      final learningHistory = await learningHistoryFuture;
      final openKnowledgeHits = await openKnowledgeFuture;
      final openKnowledgeBlock = openKnowledgeHits.isEmpty
          ? ''
          : 'OPEN KNOWLEDGE (verified public sources, already shown to the '
              'learner as real tappable links below your reply, so introduce '
              'them naturally rather than repeating their URLs or titles '
              'verbatim):\n${openKnowledgeHits.map((h) => h.promptLine).join('\n')}\n';

      final basePrompt = _buildUserPrompt(history, learningHistory, learnerMemory, openKnowledgeBlock);
      final promptWithRag = RagContextBuilder.prependToPrompt(basePrompt, rag);

      final raw = await _llm.completeJson(
        userPrompt: promptWithRag,
        systemPrompt: _systemPrompt,
        // This service already gated on BuiltInChatQuota above; skip the
        // shared generation quota entirely so chat never touches it.
        skipQuota: true,
        recordBuiltinQuota: false,
      );
      final result = parseReplyWithAction(
        raw,
        sources: openKnowledgeHits
            .map((h) => ChatSourceSuggestion(title: h.title, url: h.url ?? '', source: h.source))
            .where((s) => s.url.isNotEmpty)
            .toList(),
      );
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

  static String _buildUserPrompt(
    List<ChatMessage> history,
    String? learningHistory,
    String? learnerMemory, [
    String? openKnowledgeBlock,
  ]) {
    final buffer = StringBuffer();
    if (learnerMemory != null && learnerMemory.isNotEmpty) {
      buffer.writeln(learnerMemory);
      buffer.writeln();
    }
    if (learningHistory != null && learningHistory.isNotEmpty) {
      buffer.writeln(learningHistory);
      buffer.writeln();
    }
    if (openKnowledgeBlock != null && openKnowledgeBlock.isNotEmpty) {
      buffer.writeln(openKnowledgeBlock);
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

  /// Extracts the reply text plus an optional proposed action. Reuses
  /// [parseReply] unchanged for the reply/fallback/error behavior, action
  /// extraction is independent and any failure (missing/malformed/
  /// unrecognized "action", missing required topic, unrecognized navigate
  /// target) silently degrades to `action: null`. This must never throw on
  /// account of the action fields alone, and never blocks returning a usable
  /// reply. [sources] passes through untouched, real open-knowledge links
  /// gathered before the model call, never derived from its output.
  static ChatReplyResult parseReplyWithAction(
    String raw, {
    List<ChatSourceSuggestion> sources = const [],
  }) {
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
          } else if (kind == 'suggestVideo') {
            final topic = decoded['videoTopic']?.toString().trim();
            if (topic != null && topic.isNotEmpty) {
              action = ChatProposedAction.video(topic: topic);
            }
          } else if (kind == 'navigate') {
            final name = decoded['navigateTo']?.toString().trim();
            if (name != null && name.isNotEmpty) {
              final match = ChatNavigationTargets.match(name);
              if (match != null) {
                action = ChatProposedAction.navigate(topic: match.$1, route: match.$2);
              }
            }
          }
        }
      }
    } catch (_) {
      action = null;
    }
    return ChatReplyResult(reply: reply, action: action, sources: sources);
  }
}
