import 'package:dio/dio.dart';

import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
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
        // Google AI Studio / curl style.
        'X-goog-api-key': apiKey,
      },
    );

    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/models/$model:generateContent',
        // Older keys / clients still use query param auth.
        queryParameters: {'key': apiKey},
        data: {
          'contents': [
            {
              'role': 'user',
              'parts': [
                {'text': PromptBuilder.build(request)},
              ],
            },
          ],
          'generationConfig': {
            'temperature': 0.4,
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

      final content = AiResponseUtils.extractGeminiContent(response.data);
      if (content == null || content.isEmpty) {
        throw const InvalidJsonException(
          'Gemini returned an empty or blocked response.',
        );
      }
      return QuizJsonParser.parse(content, expectedCount: request.questionCount);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e);
    }
  }
}
