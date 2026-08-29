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

class ClaudeProvider implements AiProvider {
  ClaudeProvider({
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
          ? AiProviderType.claude.defaultBaseUrl
          : baseUrl!,
    );

    final dio = DioClient.create(
      baseUrl: root,
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
    );

    try {
      final response = await dio.post<Map<String, dynamic>>(
        '/messages',
        data: {
          'model': model,
          'max_tokens': 8192,
          'temperature': 0.4,
          'system':
              'You are a quiz generator. Respond with a single valid JSON object only. '
              'No markdown, no code fences, no commentary.',
          'messages': [
            {
              'role': 'user',
              'content': PromptBuilder.build(request),
            },
          ],
        },
      );

      final content = AiResponseUtils.extractClaudeContent(response.data?['content']);
      if (content == null || content.isEmpty) {
        throw const InvalidJsonException('Claude returned an empty response.');
      }
      return QuizJsonParser.parse(content, expectedCount: request.questionCount);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e);
    }
  }
}
