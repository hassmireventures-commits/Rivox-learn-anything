import 'package:dio/dio.dart';

import '../../../../core/models/ai_usage_result.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../ai_provider.dart';
import '../ai_response_utils.dart';
import '../models/generated_quiz.dart';
import '../models/quiz_generation_request.dart';
import '../prompt_builder.dart';
import '../provider_error_mapper.dart';
import '../quiz_json_parser.dart';

/// OpenAI-compatible chat completions (OpenAI, Grok, DeepSeek, OpenRouter, custom).
class OpenAiCompatibleProvider implements AiProvider {
  OpenAiCompatibleProvider({
    required this.apiKey,
    required this.model,
    required this.baseUrl,
    this.providerType = AiProviderType.custom,
    this.extraHeaders = const {},
    this.preferJsonObjectMode = true,
  });

  final String apiKey;
  final String model;
  final String baseUrl;
  final AiProviderType providerType;
  final Map<String, String> extraHeaders;
  final bool preferJsonObjectMode;

  @override
  Future<GeneratedQuiz> generateQuiz(QuizGenerationRequest request) async {
    final root = AiResponseUtils.normalizeBaseUrl(baseUrl);
    final dio = DioClient.create(
      baseUrl: root,
      headers: {
        'Authorization': 'Bearer $apiKey',
        ...extraHeaders,
      },
    );

    final messages = [
      {
        'role': 'system',
        'content':
            'You are a quiz generator. Respond with a single valid JSON object only. '
            'No markdown, no code fences, no commentary.',
      },
      {
        'role': 'user',
        'content': PromptBuilder.build(request),
      },
    ];

    try {
      final content = await _complete(
        dio: dio,
        messages: messages,
        useJsonObjectMode: preferJsonObjectMode,
      );
      return QuizJsonParser.parse(content, expectedCount: request.questionCount);
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e);
    }
  }

  Future<String> _complete({
    required Dio dio,
    required List<Map<String, String>> messages,
    required bool useJsonObjectMode,
  }) async {
    Future<Response<Map<String, dynamic>>> send({required bool jsonMode}) {
      final data = <String, dynamic>{
        'model': model,
        'temperature': 0.4,
        'messages': messages,
      };
      if (jsonMode) {
        data['response_format'] = {'type': 'json_object'};
      }
      return dio.post<Map<String, dynamic>>('/chat/completions', data: data);
    }

    try {
      final response = await send(jsonMode: useJsonObjectMode);
      return _requireContent(response.data);
    } on DioException catch (e) {
      // Some OpenAI-compatible endpoints reject response_format.
      if (useJsonObjectMode && e.response?.statusCode == 400) {
        final response = await send(jsonMode: false);
        return _requireContent(response.data);
      }
      throw ProviderErrorMapper.map(e);
    }
  }

  String _requireContent(Map<String, dynamic>? data) {
    LastAiUsage.set(AiResponseUtils.parseOpenAiUsage(data));
    final content = AiResponseUtils.extractOpenAiContent(
      data?['choices']?[0]?['message']?['content'],
    );
    if (content == null || content.isEmpty) {
      throw const InvalidJsonException('AI returned an empty response.');
    }
    return content;
  }
}
