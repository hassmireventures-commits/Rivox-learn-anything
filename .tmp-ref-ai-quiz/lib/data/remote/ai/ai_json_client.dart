import 'package:dio/dio.dart';

import '../../../core/models/ai_usage_result.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../local/models/ai_provider_config.dart';
import 'ai_provider.dart';
import 'ai_response_utils.dart';
import 'provider_error_mapper.dart';

class AiJsonClient {
  const AiJsonClient._();

  static Future<String> complete({
    required AiProviderConfig config,
    required String apiKey,
    required String userPrompt,
    String systemPrompt =
        'You are a curriculum designer. Respond with a single valid JSON object only. No markdown.',
  }) async {
    final type = AiProviderType.fromId(config.providerType);
    try {
      return switch (type) {
        AiProviderType.gemini => _gemini(config, apiKey, systemPrompt, userPrompt),
        AiProviderType.claude => _claude(config, apiKey, systemPrompt, userPrompt),
        _ => _openAiCompatible(config, apiKey, systemPrompt, userPrompt, type),
      };
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e, providerName: config.name);
    }
  }

  static Future<String> _openAiCompatible(
    AiProviderConfig config,
    String apiKey,
    String systemPrompt,
    String userPrompt,
    AiProviderType type,
  ) async {
    final base = config.baseUrl;
    final root = AiResponseUtils.normalizeBaseUrl(
      (base != null && base.isNotEmpty) ? base : type.defaultBaseUrl,
    );
    final dio = DioClient.create(
      baseUrl: root,
      headers: {'Authorization': 'Bearer $apiKey'},
    );
    final data = <String, dynamic>{
      'model': config.defaultModel,
      'temperature': 0.35,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
    };
    if (type.supportsJsonObjectMode) {
      data['response_format'] = {'type': 'json_object'};
    }
    final response = await dio.post<Map<String, dynamic>>('/chat/completions', data: data);
    LastAiUsage.set(AiResponseUtils.parseOpenAiUsage(response.data));
    final content = AiResponseUtils.extractOpenAiContent(
      response.data?['choices']?[0]?['message']?['content'],
    );
    if (content == null || content.isEmpty) {
      throw const InvalidJsonException('AI returned an empty response.');
    }
    return content;
  }

  static Future<String> _gemini(
    AiProviderConfig config,
    String apiKey,
    String systemPrompt,
    String userPrompt,
  ) async {
    final model = config.defaultModel;
    final dio = DioClient.create(baseUrl: AiProviderType.gemini.defaultBaseUrl);
    final response = await dio.post<Map<String, dynamic>>(
      '/models/$model:generateContent',
      queryParameters: {'key': apiKey},
      data: {
        'contents': [
          {
            'parts': [
              {'text': '$systemPrompt\n\n$userPrompt'},
            ],
          },
        ],
        'generationConfig': {'temperature': 0.35},
      },
    );
    LastAiUsage.set(AiResponseUtils.parseGeminiUsage(response.data));
    final content = AiResponseUtils.extractGeminiContent(response.data);
    if (content == null || content.isEmpty) {
      throw const InvalidJsonException('AI returned an empty response.');
    }
    return content;
  }

  static Future<String> _claude(
    AiProviderConfig config,
    String apiKey,
    String systemPrompt,
    String userPrompt,
  ) async {
    final dio = DioClient.create(
      baseUrl: AiProviderType.claude.defaultBaseUrl,
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
    );
    final response = await dio.post<Map<String, dynamic>>(
      '/messages',
      data: {
        'model': config.defaultModel,
        'max_tokens': 4096,
        'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': userPrompt},
        ],
      },
    );
    LastAiUsage.set(AiResponseUtils.parseClaudeUsage(response.data));
    final content = AiResponseUtils.extractClaudeContent(response.data?['content']);
    if (content == null || content.isEmpty) {
      throw const InvalidJsonException('AI returned an empty response.');
    }
    return content;
  }
}
