import 'models/generated_quiz.dart';
import 'models/quiz_generation_request.dart';

abstract class AiProvider {
  Future<GeneratedQuiz> generateQuiz(QuizGenerationRequest request);
}

enum AiProviderType {
  openai(
    'OpenAI',
    'gpt-4o-mini',
    'https://api.openai.com/v1',
  ),
  gemini(
    'Gemini',
    'gemini-flash-latest',
    'https://generativelanguage.googleapis.com/v1beta',
  ),
  claude(
    'Claude',
    'claude-sonnet-4-20250514',
    'https://api.anthropic.com/v1',
  ),
  grok(
    'Grok',
    'grok-2-latest',
    'https://api.x.ai/v1',
  ),
  deepseek(
    'DeepSeek',
    'deepseek-chat',
    'https://api.deepseek.com/v1',
  ),
  openrouter(
    'OpenRouter',
    'openai/gpt-4o-mini',
    'https://openrouter.ai/api/v1',
  ),
  custom(
    'Custom (OpenAI Compatible)',
    'gpt-4o-mini',
    '',
  );

  const AiProviderType(this.label, this.defaultModel, this.defaultBaseUrl);

  final String label;
  final String defaultModel;
  final String defaultBaseUrl;

  /// Whether this provider typically supports OpenAI `response_format: json_object`.
  bool get supportsJsonObjectMode => switch (this) {
        AiProviderType.openai ||
        AiProviderType.openrouter ||
        AiProviderType.deepseek ||
        AiProviderType.grok ||
        AiProviderType.custom =>
          true,
        AiProviderType.gemini || AiProviderType.claude => false,
      };

  static AiProviderType fromId(String id) {
    return AiProviderType.values.firstWhere(
      (e) => e.name == id,
      orElse: () => AiProviderType.custom,
    );
  }
}
