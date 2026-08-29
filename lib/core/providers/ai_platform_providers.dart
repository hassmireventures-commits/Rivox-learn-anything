import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/models/knowledge_source.dart';
import '../../data/local/repositories/knowledge_repository.dart';
import '../ai_platform/ai_audit_log.dart';
import '../ai_platform/ai_consent_gate.dart';
import '../ai_platform/ai_policy_registry.dart';
import '../ai_platform/ai_request_pipeline.dart';
import '../ai_platform/prompt_firewall.dart';
import '../ai_platform/rag_context_builder.dart';
import '../models/provider_usage.dart';
import '../telemetry/llm_telemetry_recorder.dart';
import 'app_providers.dart';

final aiAuditLogProvider = Provider<AiAuditLog>((ref) {
  return AiAuditLog(ref.watch(isarServiceProvider));
});

final aiConsentGateProvider = Provider<AiConsentGate>((ref) => AiConsentGate.instance);

final aiRequestPipelineProvider = Provider<AiRequestPipeline>((ref) {
  return AiRequestPipeline(
    auditLog: ref.watch(aiAuditLogProvider),
    consentGate: ref.watch(aiConsentGateProvider),
    firewall: const PromptFirewall(),
    ragBuilder: RagContextBuilder(
      vectorStore: ref.watch(vectorStoreProvider),
      consentGate: ref.watch(aiConsentGateProvider),
    ),
  );
});

final knowledgeRepositoryProvider = Provider<KnowledgeRepository>((ref) {
  return KnowledgeRepository(
    ref.watch(isarServiceProvider),
    ref.watch(vectorStoreProvider),
  );
});

final aiPolicyProvider = FutureProvider((ref) async => AiPolicyRegistry.load());

final totalAiTokensTodayProvider = FutureProvider<int>((ref) async {
  final telemetry = ref.watch(llmTelemetryProvider);
  return telemetry.totalTokensToday();
});

final llmUsageTodayProvider = FutureProvider<LlmUsageSummary>((ref) async {
  final telemetry = ref.watch(llmTelemetryProvider);
  return telemetry.todaySummary();
});

final llmUsageMonthProvider = FutureProvider<LlmUsageSummary>((ref) async {
  final telemetry = ref.watch(llmTelemetryProvider);
  return telemetry.monthSummary();
});

final llmTelemetryProvider = Provider<LlmTelemetryRecorder>((ref) {
  return LlmTelemetryRecorder(
    usageTracker: ref.watch(usageTrackerProvider),
    auditLog: ref.watch(aiAuditLogProvider),
    telemetry: ref.watch(telemetryServiceProvider),
  );
});

final knowledgeSourcesProvider =
    FutureProvider.family<List<KnowledgeSource>, String>((ref, goalMode) async {
  return ref.watch(knowledgeRepositoryProvider).sourcesForGoal(goalMode);
});
