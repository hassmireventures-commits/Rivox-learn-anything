import '../../local/models/ai_provider_config.dart';
import 'ai_provider.dart';
import 'providers/claude_provider.dart';
import 'providers/gemini_provider.dart';
import 'providers/openai_compatible_provider.dart';

class AiProviderFactory {
  static AiProvider create({
    required AiProviderConfig config,
    required String apiKey,
  }) {
    final type = AiProviderType.fromId(config.providerType);
    final model = config.defaultModel.trim();
    final baseUrl = config.baseUrl?.trim();
    final key = apiKey.trim();

    if (key.isEmpty) {
      throw ArgumentError('API key is required');
    }
    if (model.isEmpty) {
      throw ArgumentError('Model is required');
    }

    switch (type) {
      case AiProviderType.gemini:
        return GeminiProvider(apiKey: key, model: model, baseUrl: baseUrl);
      case AiProviderType.claude:
        return ClaudeProvider(apiKey: key, model: model, baseUrl: baseUrl);
      case AiProviderType.openai:
      case AiProviderType.grok:
      case AiProviderType.deepseek:
      case AiProviderType.openrouter:
      case AiProviderType.custom:
        final resolvedBase =
            (baseUrl == null || baseUrl.isEmpty) ? type.defaultBaseUrl : baseUrl;
        if (resolvedBase.isEmpty) {
          throw ArgumentError('Base URL is required for custom providers');
        }
        return OpenAiCompatibleProvider(
          apiKey: key,
          model: model,
          baseUrl: resolvedBase,
          providerType: type,
          preferJsonObjectMode: type.supportsJsonObjectMode,
          extraHeaders: _extraHeadersFor(type),
        );
    }
  }

  static Map<String, String> _extraHeadersFor(AiProviderType type) {
    return switch (type) {
      AiProviderType.openrouter => {
          // Recommended by OpenRouter for rankings / abuse prevention.
          'HTTP-Referer': 'https://aiquiz.app',
          'X-Title': 'AI Quiz',
        },
      _ => const {},
    };
  }
}
