/// Silent default cloud AI (OpenAI-compatible NIM endpoint).
///
/// Key is injected at build time: `--dart-define=BUILT_IN_AI_API_KEY=...`
/// Do not commit secrets. Treat APK embedding as obfuscation only.
class BuiltInAiConfig {
  BuiltInAiConfig._();

  static const String uuid = 'built-in-ai';
  static const String providerTypeId = 'builtin';
  static const String displayName = 'Built-in AI';

  static const String baseUrl = 'https://integrate.api.nvidia.com/v1';
  static const String defaultModel = 'meta/llama-3.2-11b-vision-instruct';
  /// Fallback when primary NIM model fails or returns unusable output.
  static const String fallbackModel = 'nvidia/nemotron-3-nano-30b-a3b';

  static const String _apiKeyDefine = String.fromEnvironment('BUILT_IN_AI_API_KEY');

  static String get apiKey => _apiKeyDefine.trim();

  static bool get hasApiKey => apiKey.isNotEmpty;

  /// Sampling aligned with classic BYOK quiz path (lower temp = shorter, stabler JSON).
  static const double temperature = 0.4;
  static const double topP = 0.9;
  static const double frequencyPenalty = 0;
  static const double presencePenalty = 0;

  /// Dio receive/connect timeout for Built-in calls (match BYOK 90s).
  static const Duration requestTimeout = Duration(seconds: 90);

  /// Cap quiz completion tokens - keep lean for latency.
  static int quizMaxTokens(int questionCount) {
    final scaled = 280 * questionCount.clamp(1, 20);
    return scaled.clamp(800, 3072);
  }

  /// Cap for path / JSON complete calls (4-6 modules).
  static const int jsonMaxTokens = 3072;

  /// Reasoning-channel models (Nemotron) need more tokens; JSON often lands in reasoning.
  static int jsonMaxTokensForModel(String modelId) {
    final id = modelId.toLowerCase();
    if (id.contains('nemotron') || id.contains('-nano-')) return 4096;
    return jsonMaxTokens;
  }

  static int quizMaxTokensForModel(String modelId, int questionCount) {
    final base = quizMaxTokens(questionCount);
    final id = modelId.toLowerCase();
    if (id.contains('nemotron') || id.contains('-nano-')) {
      return (base * 1.35).round().clamp(base, 4096);
    }
    return base;
  }

  /// Tiny completion for Home “study pulse” connection probe.
  static const int pulseMaxTokens = 256;

  /// Faster timeout for the study-pulse probe (not full quiz generation).
  static const Duration pulseTimeout = Duration(seconds: 45);

  /// Daily free generations before ads.
  static const int freeGenerationsPerDay = 5;

  /// Generations granted per successful rewarded ad.
  static const int bonusPerRewardedAd = 2;

  /// Max rewarded ads that grant bonus per calendar day.
  static const int maxRewardedAdsPerDay = 3;
}
