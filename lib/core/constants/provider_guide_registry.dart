import '../../data/remote/ai/ai_provider.dart';

class ProviderGuide {
  const ProviderGuide({
    required this.type,
    required this.summaryKey,
    required this.stepKeys,
    required this.apiKeyUrl,
    this.docsUrl,
  });

  final AiProviderType type;
  final String summaryKey;
  final List<String> stepKeys;
  final Uri apiKeyUrl;
  final Uri? docsUrl;
}

/// Central registry for API key acquisition guidance (scalable for new providers).
class ProviderGuideRegistry {
  const ProviderGuideRegistry._();

  static ProviderGuide? forType(AiProviderType type) {
    return _guides[type];
  }

  static final _guides = <AiProviderType, ProviderGuide>{
    AiProviderType.openai: ProviderGuide(
      type: AiProviderType.openai,
      summaryKey: 'providerGuideOpenAiSummary',
      stepKeys: [
        'providerGuideStepSignUp',
        'providerGuideStepBilling',
        'providerGuideStepCreateKey',
        'providerGuideStepPaste',
      ],
      apiKeyUrl: Uri.parse('https://platform.openai.com/api-keys'),
      docsUrl: Uri.parse('https://platform.openai.com/docs'),
    ),
    AiProviderType.gemini: ProviderGuide(
      type: AiProviderType.gemini,
      summaryKey: 'providerGuideGeminiSummary',
      stepKeys: [
        'providerGuideStepGoogleAccount',
        'providerGuideStepCreateKey',
        'providerGuideStepPaste',
      ],
      apiKeyUrl: Uri.parse('https://aistudio.google.com/apikey'),
      docsUrl: Uri.parse('https://ai.google.dev/gemini-api/docs'),
    ),
    AiProviderType.claude: ProviderGuide(
      type: AiProviderType.claude,
      summaryKey: 'providerGuideClaudeSummary',
      stepKeys: [
        'providerGuideStepSignUp',
        'providerGuideStepBilling',
        'providerGuideStepCreateKey',
        'providerGuideStepPaste',
      ],
      apiKeyUrl: Uri.parse('https://console.anthropic.com/settings/keys'),
      docsUrl: Uri.parse('https://docs.anthropic.com'),
    ),
    AiProviderType.grok: ProviderGuide(
      type: AiProviderType.grok,
      summaryKey: 'providerGuideGrokSummary',
      stepKeys: [
        'providerGuideStepSignUp',
        'providerGuideStepCreateKey',
        'providerGuideStepPaste',
      ],
      apiKeyUrl: Uri.parse('https://console.x.ai/'),
    ),
    AiProviderType.deepseek: ProviderGuide(
      type: AiProviderType.deepseek,
      summaryKey: 'providerGuideDeepSeekSummary',
      stepKeys: [
        'providerGuideStepSignUp',
        'providerGuideStepCreateKey',
        'providerGuideStepPaste',
      ],
      apiKeyUrl: Uri.parse('https://platform.deepseek.com/api_keys'),
    ),
    AiProviderType.openrouter: ProviderGuide(
      type: AiProviderType.openrouter,
      summaryKey: 'providerGuideOpenRouterSummary',
      stepKeys: [
        'providerGuideStepSignUp',
        'providerGuideStepCreateKey',
        'providerGuideStepPaste',
      ],
      apiKeyUrl: Uri.parse('https://openrouter.ai/keys'),
      docsUrl: Uri.parse('https://openrouter.ai/docs'),
    ),
    AiProviderType.custom: ProviderGuide(
      type: AiProviderType.custom,
      summaryKey: 'providerGuideCustomSummary',
      stepKeys: [
        'providerGuideStepCustomEndpoint',
        'providerGuideStepCreateKey',
        'providerGuideStepPaste',
      ],
      apiKeyUrl: Uri.parse('https://platform.openai.com/docs/api-reference'),
    ),
  };
}
