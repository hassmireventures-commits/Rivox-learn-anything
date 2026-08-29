class AiUsageResult {
  const AiUsageResult({
    this.promptTokens = 0,
    this.completionTokens = 0,
  });

  final int promptTokens;
  final int completionTokens;

  int get totalTokens => promptTokens + completionTokens;

  /// Caps absurd parser values so bad API metadata cannot blow daily budgets.
  static const int maxReasonableField = 50000;

  AiUsageResult clamped() {
    return AiUsageResult(
      promptTokens: promptTokens.clamp(0, maxReasonableField),
      completionTokens: completionTokens.clamp(0, maxReasonableField),
    );
  }
}

/// Holds token usage from the most recent AI HTTP response for downstream persistence.
class LastAiUsage {
  LastAiUsage._();

  static AiUsageResult? _last;

  static void set(AiUsageResult? usage) => _last = usage?.clamped();

  static AiUsageResult? consume() {
    final value = _last;
    _last = null;
    return value;
  }
}
