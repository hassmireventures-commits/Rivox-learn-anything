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
import 'ai_output_gate.dart';

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
  })  : _llm = llmManager,
        _pipeline = aiPipeline,
        _chatRepository = chatRepository;

  final LlmManager _llm;
  final AiRequestPipeline _pipeline;
  final ChatRepository _chatRepository;

  static const String _systemPrompt =
      'You are a friendly, encouraging learning assistant inside a study app. '
      'The learner is asking a follow-up question about their modules, quizzes, '
      'or library content. Use the conversation history and any reference '
      'material below when relevant; do not invent facts that contradict them. '
      'Keep replies concise (a few sentences, more only if truly needed). '
      'Respond with a single valid JSON object only, in this exact shape: '
      '{"reply": "..."}. No markdown, no extra keys, no text outside the JSON.';

  /// Sends the learner's latest turn (already persisted by the caller — this
  /// service only reads history, it does not write messages) and returns the
  /// assistant's reply text.
  Future<String> sendMessage({
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
      final basePrompt = _buildUserPrompt(history);
      final promptWithRag = RagContextBuilder.prependToPrompt(basePrompt, rag);

      final raw = await _llm.completeJson(
        userPrompt: promptWithRag,
        systemPrompt: _systemPrompt,
        // This service already gated on BuiltInChatQuota above; skip the
        // shared generation quota entirely so chat never touches it.
        skipQuota: true,
        recordBuiltinQuota: false,
      );
      final reply = parseReply(raw);
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
      return reply;
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

  static String _buildUserPrompt(List<ChatMessage> history) {
    if (history.isEmpty) return 'Respond to the learner.';
    final buffer = StringBuffer('Conversation so far (oldest first):\n');
    for (final m in history) {
      final label = m.role == 'user' ? 'User' : 'Assistant';
      buffer.writeln('$label: ${m.text}');
    }
    buffer.writeln();
    buffer.writeln('Respond to the last User message above.');
    return buffer.toString();
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
}
