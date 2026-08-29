class ProviderUsage {
  ProviderUsage({
    required this.providerKey,
    this.callCountToday = 0,
    this.successCountToday = 0,
    this.failureCountToday = 0,
    this.rateLimitCountToday = 0,
    DateTime? dayStartedAt,
    this.lastCallAt,
    this.lastRateLimitAt,
    this.retryAfterUntil,
    this.lastLatencyMs = 0,
  }) : dayStartedAt = dayStartedAt ?? DateTime.now();

  String providerKey;
  int callCountToday;
  int successCountToday;
  int failureCountToday;
  int rateLimitCountToday;
  DateTime dayStartedAt;
  DateTime? lastCallAt;
  DateTime? lastRateLimitAt;
  DateTime? retryAfterUntil;
  int lastLatencyMs;
  int promptTokensToday = 0;
  int completionTokensToday = 0;
  int lastPromptTokens = 0;
  int lastCompletionTokens = 0;
}

/// Aggregated LLM usage across providers for a time window.
class LlmUsageSummary {
  const LlmUsageSummary({
    required this.requestCount,
    required this.successCount,
    required this.failureCount,
    required this.rateLimitCount,
    required this.totalTokens,
    required this.avgLatencyMs,
  });

  final int requestCount;
  final int successCount;
  final int failureCount;
  final int rateLimitCount;
  final int totalTokens;
  final int avgLatencyMs;

  static const empty = LlmUsageSummary(
    requestCount: 0,
    successCount: 0,
    failureCount: 0,
    rateLimitCount: 0,
    totalTokens: 0,
    avgLatencyMs: 0,
  );
}
