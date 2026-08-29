import 'package:dio/dio.dart';

import '../../../core/error/app_exception.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/network_service.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_ai_router.dart';
import '../../local/models/ai_provider_config.dart';
import 'ai_output_gate.dart';
import 'ai_provider.dart';
import 'ai_response_utils.dart';
import 'provider_error_mapper.dart';

class ProviderConnectionResult {
  const ProviderConnectionResult({required this.reply});

  final String reply;
}

class ProviderConnectionTester {
  const ProviderConnectionTester._();

  static const _greetingPrompt = 'Hi';

  static Future<void> test({
    required AiProviderConfig config,
    required String apiKey,
  }) async {
    final result = await testWithGreeting(config: config, apiKey: apiKey);
    if (result.reply.trim().isEmpty) {
      throw const ProviderUnavailableException(
        'AI responded but returned empty text. Try another model.',
      );
    }
  }

  /// Sends a short greeting and returns the model reply (uses [config], not DB default).
  static Future<ProviderConnectionResult> testWithGreeting({
    required AiProviderConfig config,
    required String apiKey,
  }) async {
    await NetworkService.instance.ensureConnected();

    final type = AiProviderType.fromId(config.providerType);
    if (type == AiProviderType.gemini) {
      final reply = await _greetingGemini(config, apiKey);
      return ProviderConnectionResult(reply: reply);
    }
    if (type == AiProviderType.claude) {
      final reply = await _greetingClaude(config, apiKey);
      return ProviderConnectionResult(reply: reply);
    }

    final baseUrl = (config.baseUrl?.trim().isNotEmpty == true)
        ? config.baseUrl!.trim()
        : type.defaultBaseUrl;
    if (baseUrl.isEmpty) {
      throw const ProviderUnavailableException(
        'Base URL is required for this provider.',
      );
    }
    final reply = await _greetingChatCompletion(
      config: config,
      apiKey: apiKey,
      type: type,
      baseUrl: baseUrl,
    );
    return ProviderConnectionResult(reply: reply);
  }

  static Future<String> _greetingChatCompletion({
    required AiProviderConfig config,
    required String apiKey,
    required AiProviderType type,
    required String baseUrl,
  }) async {
    final root =
        baseUrl.endsWith('/') ? baseUrl.substring(0, baseUrl.length - 1) : baseUrl;
    final isBuiltin = type == AiProviderType.builtin;
    final dio = DioClient.create(
      baseUrl: root,
      headers: {
        'Authorization': 'Bearer $apiKey',
        ..._extraHeadersFor(type),
      },
      timeout: isBuiltin ? BuiltInAiConfig.pulseTimeout : const Duration(seconds: 30),
    );

    Future<String> pingModel(String model) async {
      try {
        final response = await dio.post<Map<String, dynamic>>(
          '/chat/completions',
          data: {
            'model': model,
            'max_tokens': 64,
            'temperature': 0.7,
            'messages': [
              {'role': 'user', 'content': _greetingPrompt},
            ],
            ...AiOutputGate.requestExtrasForModel(model),
          },
          options: Options(
            receiveTimeout:
                isBuiltin ? BuiltInAiConfig.pulseTimeout : const Duration(seconds: 30),
            sendTimeout: const Duration(seconds: 15),
          ),
        );
        final content = _extractReply(response.data, contentOnly: isBuiltin);
        if (content == null ||
            content.trim().isEmpty ||
            BuiltInAiRouter.isUnusableModelOutput(content, expectJson: false)) {
          throw const UnusableModelOutputException('empty greeting');
        }
        return content.trim();
      } on DioException catch (e) {
        throw ProviderErrorMapper.map(e, providerName: config.name);
      }
    }

    if (isBuiltin) {
      return BuiltInAiRouter.withModelFallback(
        configuredModel: config.defaultModel,
        attempt: pingModel,
      );
    }
    return pingModel(config.defaultModel);
  }

  static Future<String> _greetingGemini(
    AiProviderConfig config,
    String apiKey,
  ) async {
    final base = (config.baseUrl?.trim().isNotEmpty == true)
        ? config.baseUrl!.trim()
        : AiProviderType.gemini.defaultBaseUrl;
    try {
      final dio = DioClient.create(
        baseUrl: base,
        timeout: const Duration(seconds: 30),
        headers: {'X-goog-api-key': apiKey},
      );
      final response = await dio.post<Map<String, dynamic>>(
        '/models/${config.defaultModel}:generateContent',
        data: {
          'contents': [
            {
              'parts': [
                {'text': _greetingPrompt},
              ],
            },
          ],
          'generationConfig': {'maxOutputTokens': 64, 'temperature': 0.7},
        },
      );
      final content = AiResponseUtils.extractGeminiContent(response.data);
      if (content == null || content.trim().isEmpty) {
        throw const ProviderUnavailableException(
          'AI responded but returned empty text. Try another model.',
        );
      }
      return content.trim();
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e, providerName: config.name);
    }
  }

  static Future<String> _greetingClaude(
    AiProviderConfig config,
    String apiKey,
  ) async {
    final base = (config.baseUrl?.trim().isNotEmpty == true)
        ? config.baseUrl!.trim()
        : AiProviderType.claude.defaultBaseUrl;
    try {
      final dio = DioClient.create(
        baseUrl: base,
        headers: {
          'x-api-key': apiKey,
          'anthropic-version': '2023-06-01',
        },
      );
      final response = await dio.post<Map<String, dynamic>>(
        '/messages',
        data: {
          'model': config.defaultModel,
          'max_tokens': 64,
          'messages': [
            {'role': 'user', 'content': _greetingPrompt},
          ],
        },
        options: Options(
          receiveTimeout: const Duration(seconds: 30),
          sendTimeout: const Duration(seconds: 15),
        ),
      );
      final content = AiResponseUtils.extractClaudeContent(response.data?['content']);
      if (content == null || content.trim().isEmpty) {
        throw const ProviderUnavailableException(
          'AI responded but returned empty text. Try another model.',
        );
      }
      return content.trim();
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e, providerName: config.name);
    }
  }

  static String? _extractReply(Map<String, dynamic>? data, {bool contentOnly = false}) {
    final choice = data?['choices'];
    final message = (choice is List && choice.isNotEmpty && choice.first is Map)
        ? (choice.first as Map)['message']
        : null;
    return AiResponseUtils.extractOpenAiMessage(message, contentOnly: contentOnly) ??
        AiResponseUtils.extractOpenAiContent(
          data?['choices']?[0]?['message']?['content'],
        );
  }

  static Map<String, String> _extraHeadersFor(AiProviderType type) {
    return switch (type) {
      AiProviderType.openrouter => {
          'HTTP-Referer': 'https://aiquiz.app',
          'X-Title': 'AI Quiz',
        },
      _ => const {},
    };
  }
}
