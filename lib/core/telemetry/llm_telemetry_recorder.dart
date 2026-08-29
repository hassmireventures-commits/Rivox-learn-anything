import '../ai_platform/ai_audit_log.dart';
import '../ai_platform/ai_policy_registry.dart';
import '../models/provider_usage.dart';
import '../telemetry/telemetry_service.dart';
import '../services/usage_tracker.dart';

/// Unified entry point for LLM usage telemetry.
class LlmTelemetryRecorder {
  LlmTelemetryRecorder({
    required UsageTracker usageTracker,
    required AiAuditLog auditLog,
    required TelemetryService telemetry,
  })  : _usageTracker = usageTracker,
        _auditLog = auditLog,
        _telemetry = telemetry;

  final UsageTracker _usageTracker;
  final AiAuditLog _auditLog;
  final TelemetryService _telemetry;

  UsageTracker get usageTracker => _usageTracker;

  Future<void> recordCall({
    required String providerKey,
    required String task,
    required bool success,
    required int latencyMs,
    int promptTokens = 0,
    int completionTokens = 0,
    String? errorKind,
    List<String>? ragChunkIds,
  }) async {
    await _usageTracker.recordCall(
      providerKey: providerKey,
      latencyMs: latencyMs,
      success: success,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
    );

    final policy = AiPolicyRegistry.current;
    await _auditLog.record(
      task: task,
      providerKey: providerKey,
      promptTokens: promptTokens,
      completionTokens: completionTokens,
      latencyMs: latencyMs,
      success: success,
      policyVersion: policy.version,
      ragChunkIds: ragChunkIds,
      errorMessage: errorKind,
    );

    await _telemetry.emit(success ? 'llm_call' : 'llm_call_failed', {
      'task': task,
      'provider_hash': providerKey.hashCode.toString(),
      'latency_ms': latencyMs,
      if (errorKind != null) 'error': errorKind,
    });
  }

  Future<void> recordRateLimit({
    required String providerKey,
    Duration? retryAfter,
  }) async {
    await _usageTracker.recordRateLimit(
      providerKey: providerKey,
      retryAfter: retryAfter,
    );
    await _telemetry.emit('llm_rate_limit', {
      'provider_hash': providerKey.hashCode.toString(),
    });
  }

  Future<List<ProviderUsage>> allUsage() => _usageTracker.allUsage();

  Future<LlmUsageSummary> todaySummary() {
    final now = DateTime.now();
    return _usageTracker.summaryForDay(now);
  }

  Future<LlmUsageSummary> monthSummary() => _usageTracker.summaryForCurrentMonth();

  Future<int> totalTokensToday() => _usageTracker.totalTokensToday();
}
