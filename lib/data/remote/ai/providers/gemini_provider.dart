import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/models/ai_usage_result.dart';
import '../../../../core/network/dio_client.dart';
import '../ai_output_gate.dart';
import '../ai_provider.dart';
import '../ai_response_utils.dart';
import '../models/generated_quiz.dart';
import '../models/quiz_generation_request.dart';
import '../prompt_builder.dart';
import '../provider_error_mapper.dart';
import '../quiz_json_parser.dart';

class GeminiProvider implements AiProvider {
  GeminiProvider({
    required this.apiKey,
    required this.model,
    this.baseUrl,
  });

  final String apiKey;
  final String model;
  final String? baseUrl;

  static const _system =
      'You are a quiz generator. Respond with a single valid JSON object only. '
      'No markdown, no code fences, no commentary. '
      'The questions array length must exactly match the Count in the user message — never add extra questions. '
      'Each explanation must match the option at correctIndex.';

  @override
  Future<GeneratedQuiz> generateQuiz(QuizGenerationRequest request) async {
    final root = AiResponseUtils.normalizeBaseUrl(
      (baseUrl == null || baseUrl!.trim().isEmpty)
          ? AiProviderType.gemini.defaultBaseUrl
          : baseUrl!,
    );

    final dio = DioClient.create(
      baseUrl: root,
      headers: {
        'X-goog-api-key': apiKey,
      },
    );

    try {
      final userPrompt = await PromptBuilder.build(request);
      var content = await _complete(dio, userPrompt, strictRetry: false);
      if (AiOutputGate.needsStrictRetry(
        content,
        validateContent: (text) =>
            QuizJsonParser.accepts(text, expectedCount: request.questionCount),
      )) {
        content = await _complete(dio, userPrompt, strictRetry: true);
      }
      final json = AiOutputGate.requireJsonOutput(content);
      return QuizJsonParser.parse(json, expectedCount: request.questionCount);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e);
    }
  }

  Future<String?> _complete(
    Dio dio,
    String userPrompt, {
    required bool strictRetry,
  }) async {
    final sys = AiOutputGate.adaptSystemPrompt(
      strictRetry ? AiOutputGate.strictRetrySystemPrompt(_system) : _system,
      model,
    );
    final user = AiOutputGate.adaptUserPrompt(userPrompt, model);
    final response = await dio.post<Map<String, dynamic>>(
      '/models/$model:generateContent',
      data: {
        'contents': [
          {
            'role': 'user',
            'parts': [
              {'text': '$sys\n\n$user'},
            ],
          },
        ],
        'generationConfig': {
          'temperature': AiOutputGate.temperatureForModel(model, 0.4),
          'responseMimeType': 'application/json',
        },
      },
    );

    final promptFeedback = response.data?['promptFeedback'];
    if (promptFeedback is Map && promptFeedback['blockReason'] != null) {
      throw const ProviderUnavailableException(
        'Gemini blocked this prompt. Try a different topic.',
      );
    }

    LastAiUsage.set(AiResponseUtils.parseGeminiUsage(response.data));
    return AiOutputGate.normalizeJsonText(
      AiResponseUtils.extractGeminiContent(response.data),
    );
  }
}
