import '../../core/error/app_exception.dart';
import '../../core/models/ai_usage_result.dart';
import '../../core/services/built_in_ai_config.dart';
import '../../core/services/built_in_ai_quota.dart';
import 'ai_audit_log.dart';
import 'ai_consent_gate.dart';
import 'ai_policy_registry.dart';
import 'prompt_firewall.dart';
import 'rag_context_builder.dart';

class AiRequestContext {
  const AiRequestContext({
    required this.task,
    required this.providerKey,
    this.strategyId = 'standard',
    this.goalMode = 'learning',
    this.topic = '',
    this.enabledSourceUuids,
    this.sourceTypes,
    this.generationMode,
  });

  final String task;
  final String providerKey;
  final String strategyId;
  final String goalMode;
  final String topic;
  final Set<String>? enabledSourceUuids;
  final Map<String, String>? sourceTypes;
  final String? generationMode;
}

class AiRequestPipeline {
  AiRequestPipeline({
    required this.auditLog,
    required this.consentGate,
    required this.firewall,
    required this.ragBuilder,
  });

  final AiAuditLog auditLog;
  final AiConsentGate consentGate;
  final PromptFirewall firewall;
  final RagContextBuilder ragBuilder;

  Future<void> ensureTokenBudget() async {
    final policy = await AiPolicyRegistry.load();
    final used = await auditLog.totalTokensToday();
    // Soft cap is telemetry-only. Hard block only at a very high BYOK-friendly ceiling
    // so a single Gemini quiz (or noisy usage metadata) cannot lock the user out.
    if (used >= policy.dailyTokenHardCap) {
      throw const TokenBudgetExceededException();
    }
  }

  Future<PromptFirewallResult> sanitizeTopic(String topic) async {
    final policy = await AiPolicyRegistry.load();
    return firewall.sanitize(topic, policy: policy);
  }

  Future<RagContext> buildRag(AiRequestContext ctx) async {
    if (ctx.topic.trim().isEmpty) return RagContext.empty;
    return ragBuilder.build(
      query: ctx.topic,
      goalMode: ctx.goalMode,
      enabledSourceUuids: ctx.enabledSourceUuids,
      sourceTypes: ctx.sourceTypes,
      modeOverride: ctx.generationMode,
    );
  }

  Future<T> execute<T>({
    required AiRequestContext ctx,
    required Future<T> Function(RagContext rag) run,
    required T Function() onSimplifiedRetry,
    bool allowSimplifiedRetry = false,
  }) async {
    await consentGate.load();
    await ensureTokenBudget();
    final isBuiltin = ctx.providerKey == BuiltInAiConfig.uuid;
    if (isBuiltin) {
      await BuiltInAiQuota.instance.ensureCanGenerate();
    }
    final policy = await AiPolicyRegistry.load();
    final sw = Stopwatch()..start();
    RagContext rag = RagContext.empty;
    try {
      rag = await buildRag(ctx);
      final result = await run(rag);
      sw.stop();
      if (isBuiltin) {
        await BuiltInAiQuota.instance.recordGeneration();
      }
      final usage = LastAiUsage.consume();
      await auditLog.record(
        task: ctx.task,
        providerKey: ctx.providerKey,
        strategyId: ctx.strategyId,
        promptTokens: usage?.promptTokens ?? 0,
        completionTokens: usage?.completionTokens ?? 0,
        latencyMs: sw.elapsedMilliseconds,
        success: true,
        policyVersion: policy.version,
        ragChunkIds: rag.chunkIds,
      );
      return result;
    } catch (e) {
      sw.stop();
      await auditLog.record(
        task: ctx.task,
        providerKey: ctx.providerKey,
        strategyId: ctx.strategyId,
        latencyMs: sw.elapsedMilliseconds,
        success: false,
        policyVersion: policy.version,
        ragChunkIds: rag.chunkIds,
        errorMessage: '$e',
      );
      if (allowSimplifiedRetry) {
        return onSimplifiedRetry();
      }
      rethrow;
    }
  }
}
