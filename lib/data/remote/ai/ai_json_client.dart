import 'package:dio/dio.dart';

import '../../../core/models/ai_usage_result.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_ai_router.dart';
import '../../local/models/ai_provider_config.dart';
import 'ai_output_gate.dart';
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
    int? maxTokens,
    Duration? timeout,
    bool Function(String content)? validateContent,
  }) async {
    final type = AiProviderType.fromId(config.providerType);
    try {
      return await switch (type) {
        AiProviderType.gemini => _gemini(
            config, apiKey, systemPrompt, userPrompt,
            maxTokens: maxTokens, timeout: timeout,
            validateContent: validateContent,
          ),
        AiProviderType.claude => _claude(
            config, apiKey, systemPrompt, userPrompt,
            maxTokens: maxTokens, timeout: timeout,
            validateContent: validateContent,
          ),
        _ => _openAiCompatible(
            config, apiKey, systemPrompt, userPrompt, type,
            maxTokens: maxTokens, timeout: timeout,
            validateContent: validateContent,
          ),
      };
    } on AppException {
      rethrow;
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e, providerName: config.name, task: 'path');
    }
  }

  static Future<String> _openAiCompatible(
    AiProviderConfig config,
    String apiKey,
    String systemPrompt,
    String userPrompt,
    AiProviderType type, {
    int? maxTokens,
    Duration? timeout,
    bool Function(String content)? validateContent,
  }) async {
    final base = config.baseUrl;
    final root = AiResponseUtils.normalizeBaseUrl(
      (base != null && base.isNotEmpty) ? base : type.defaultBaseUrl,
    );
    final isBuiltin = type == AiProviderType.builtin;
    final dio = DioClient.create(
      baseUrl: root,
      headers: {'Authorization': 'Bearer $apiKey'},
      timeout: timeout ??
          (isBuiltin ? BuiltInAiConfig.requestTimeout : const Duration(seconds: 90)),
    );
    final data = <String, dynamic>{
      'temperature': isBuiltin ? BuiltInAiConfig.temperature : 0.35,
      'messages': [
        {'role': 'system', 'content': systemPrompt},
        {'role': 'user', 'content': userPrompt},
      ],
    };
    if (isBuiltin) {
      data['top_p'] = BuiltInAiConfig.topP;
      data['frequency_penalty'] = BuiltInAiConfig.frequencyPenalty;
      data['presence_penalty'] = BuiltInAiConfig.presencePenalty;
    } else if (maxTokens != null) {
      data['max_tokens'] = maxTokens;
    }

    Future<Response<Map<String, dynamic>>> postWithModel(
      String model, {
      bool strictRetry = false,
    }) {
      final adaptedSystem = AiOutputGate.adaptSystemPrompt(
        strictRetry
            ? AiOutputGate.strictRetrySystemPrompt(systemPrompt)
            : systemPrompt,
        model,
      );
      final adaptedUser = AiOutputGate.adaptUserPrompt(userPrompt, model);
      final payload = <String, dynamic>{
        ...data,
        'model': model,
        'temperature': AiOutputGate.temperatureForModel(
          model,
          isBuiltin ? BuiltInAiConfig.temperature : 0.35,
        ),
        'max_tokens': isBuiltin
            ? (maxTokens ?? BuiltInAiConfig.jsonMaxTokensForModel(model))
            : data['max_tokens'],
        'messages': [
          {'role': 'system', 'content': adaptedSystem},
          {'role': 'user', 'content': adaptedUser},
        ],
      };
      if (type.supportsJsonObjectMode &&
          AiOutputGate.useJsonObjectResponseFormat(model)) {
        payload['response_format'] = {'type': 'json_object'};
      }
      payload.addAll(AiOutputGate.requestExtrasForModel(model));
      return dio.post<Map<String, dynamic>>('/chat/completions', data: payload);
    }

    Future<String> completeWithModel(String model) async {
      Future<String?> fetch({required bool strictRetry}) async {
        try {
          final resp = await postWithModel(model, strictRetry: strictRetry);
          return _extractContent(resp.data, model: model);
        } on DioException catch (e) {
          if (!strictRetry &&
              type.supportsJsonObjectMode &&
              AiOutputGate.useJsonObjectResponseFormat(model) &&
              e.response?.statusCode == 400) {
            final payload = await postWithModel(model, strictRetry: false);
            return _extractContent(payload.data, model: model);
          }
          rethrow;
        }
      }

      var text = await fetch(strictRetry: false);
      if (AiOutputGate.needsStrictRetry(text, validateContent: validateContent)) {
        text = await fetch(strictRetry: true);
      }
      try {
        return AiOutputGate.requireJsonOutput(text, validateContent: validateContent);
      } on InvalidJsonException {
        if (isBuiltin) throw UnusableModelOutputException('model=$model');
        rethrow;
      }
    }

    if (isBuiltin) {
      return BuiltInAiRouter.withModelFallback(
        configuredModel: config.defaultModel,
        attempt: completeWithModel,
      );
    }

    return completeWithModel(config.defaultModel);
  }

  static String? _extractContent(Map<String, dynamic>? data, {required String model}) {
    LastAiUsage.set(AiResponseUtils.parseOpenAiUsage(data));
    final choice = data?['choices'];
    final message = (choice is List && choice.isNotEmpty && choice.first is Map)
        ? (choice.first as Map)['message']
        : null;
    return AiOutputGate.normalizeFromOpenAiMessage(message, modelId: model);
  }

  static Future<String> _gemini(
    AiProviderConfig config,
    String apiKey,
    String systemPrompt,
    String userPrompt, {
    int? maxTokens,
    Duration? timeout,
    bool Function(String content)? validateContent,
  }) async {
    final model = config.defaultModel;
    final dio = DioClient.create(
      baseUrl: AiProviderType.gemini.defaultBaseUrl,
      headers: {'X-goog-api-key': apiKey},
      timeout: timeout ?? const Duration(seconds: 90),
    );

    Future<String?> fetch({required bool strictRetry}) async {
      final sys = AiOutputGate.adaptSystemPrompt(
        strictRetry
            ? AiOutputGate.strictRetrySystemPrompt(systemPrompt)
            : systemPrompt,
        model,
      );
      final user = AiOutputGate.adaptUserPrompt(userPrompt, model);
      final genConfig = <String, dynamic>{
        'temperature': AiOutputGate.temperatureForModel(model, 0.35),
        'responseMimeType': 'application/json',
      };
      if (maxTokens != null) genConfig['maxOutputTokens'] = maxTokens;
      final response = await dio.post<Map<String, dynamic>>(
        '/models/$model:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': '$sys\n\n$user'},
              ],
            },
          ],
          'generationConfig': genConfig,
        },
      );
      LastAiUsage.set(AiResponseUtils.parseGeminiUsage(response.data));
      return AiOutputGate.normalizeJsonText(
        AiResponseUtils.extractGeminiContent(response.data),
      );
    }

    var text = await fetch(strictRetry: false);
    if (AiOutputGate.needsStrictRetry(text, validateContent: validateContent)) {
      text = await fetch(strictRetry: true);
    }
    return AiOutputGate.requireJsonOutput(text, validateContent: validateContent);
  }

  static Future<String> _claude(
    AiProviderConfig config,
    String apiKey,
    String systemPrompt,
    String userPrompt, {
    int? maxTokens,
    Duration? timeout,
    bool Function(String content)? validateContent,
  }) async {
    final model = config.defaultModel;
    final dio = DioClient.create(
      baseUrl: AiProviderType.claude.defaultBaseUrl,
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
      },
      timeout: timeout ?? const Duration(seconds: 90),
    );

    Future<String?> fetch({required bool strictRetry}) async {
      final sys = AiOutputGate.adaptSystemPrompt(
        strictRetry
            ? AiOutputGate.strictRetrySystemPrompt(systemPrompt)
            : systemPrompt,
        model,
      );
      final user = AiOutputGate.adaptUserPrompt(userPrompt, model);
      final response = await dio.post<Map<String, dynamic>>(
        '/messages',
        data: {
          'model': model,
          'max_tokens': maxTokens ?? 4096,
          'temperature': AiOutputGate.temperatureForModel(model, 0.35),
          'system': sys,
          'messages': [
            {'role': 'user', 'content': user},
          ],
        },
      );
      LastAiUsage.set(AiResponseUtils.parseClaudeUsage(response.data));
      return AiOutputGate.normalizeJsonText(
        AiResponseUtils.extractClaudeContent(response.data?['content']),
      );
    }

    var text = await fetch(strictRetry: false);
    if (AiOutputGate.needsStrictRetry(text, validateContent: validateContent)) {
      text = await fetch(strictRetry: true);
    }
    return AiOutputGate.requireJsonOutput(text, validateContent: validateContent);
  }
}
