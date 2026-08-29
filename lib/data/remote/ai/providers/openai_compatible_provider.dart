import 'package:dio/dio.dart';

import '../../../../core/models/ai_usage_result.dart';
import '../../../../core/error/app_exception.dart';
import '../../../../core/network/dio_client.dart';
import '../../../../core/services/built_in_ai_config.dart';
import '../../../../core/services/built_in_ai_router.dart';
import '../ai_output_gate.dart';
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
    final isBuiltin = providerType == AiProviderType.builtin;
    final dio = DioClient.create(
      baseUrl: root,
      headers: {
        'Authorization': 'Bearer $apiKey',
        ...extraHeaders,
      },
      timeout: isBuiltin ? BuiltInAiConfig.requestTimeout : const Duration(seconds: 90),
    );

    final messages = [
      {
        'role': 'system',
        'content':
            'You are a quiz generator. Respond with a single valid JSON object only. '
            'No markdown, no code fences, no commentary. '
            'The questions array length must exactly match the Count in the user message — never add extra questions. '
            'Each explanation must match the option at correctIndex.',
      },
      {
        'role': 'user',
        'content': await PromptBuilder.build(request),
      },
    ];

    try {
      if (providerType == AiProviderType.builtin) {
        return BuiltInAiRouter.withModelFallback(
          configuredModel: model,
          attempt: (activeModel) async {
            final content = await _completeWithModel(
              dio: dio,
              messages: messages,
              activeModel: activeModel,
              useJsonObjectMode: preferJsonObjectMode,
              questionCount: request.questionCount,
            );
            return QuizJsonParser.parse(content, expectedCount: request.questionCount);
          },
        );
      }

      final content = await _complete(
        dio: dio,
        messages: messages,
        useJsonObjectMode: preferJsonObjectMode,
        questionCount: request.questionCount,
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
    required int questionCount,
  }) async {
    if (providerType == AiProviderType.builtin) {
      return BuiltInAiRouter.withModelFallback(
        configuredModel: model,
        attempt: (activeModel) => _completeWithModel(
          dio: dio,
          messages: messages,
          activeModel: activeModel,
          useJsonObjectMode: useJsonObjectMode,
          questionCount: questionCount,
        ),
      );
    }

    try {
      return await _completeWithModel(
        dio: dio,
        messages: messages,
        activeModel: model,
        useJsonObjectMode: useJsonObjectMode,
        questionCount: questionCount,
      );
    } on DioException catch (e) {
      throw ProviderErrorMapper.map(e);
    }
  }

  Future<String> _completeWithModel({
    required Dio dio,
    required List<Map<String, String>> messages,
    required String activeModel,
    required bool useJsonObjectMode,
    required int questionCount,
  }) async {
    Future<Response<Map<String, dynamic>>> send({
      required String activeModel,
      required bool jsonMode,
      bool strictRetry = false,
    }) {
      final data = <String, dynamic>{
        'model': activeModel,
        'temperature': AiOutputGate.temperatureForModel(
          activeModel,
          providerType == AiProviderType.builtin ? BuiltInAiConfig.temperature : 0.4,
        ),
        'messages': _messagesForModel(messages, activeModel, strictRetry: strictRetry),
      };
      if (providerType == AiProviderType.builtin) {
        data['top_p'] = BuiltInAiConfig.topP;
        data['max_tokens'] = BuiltInAiConfig.quizMaxTokensForModel(
          activeModel,
          questionCount,
        );
        data['frequency_penalty'] = BuiltInAiConfig.frequencyPenalty;
        data['presence_penalty'] = BuiltInAiConfig.presencePenalty;
      }
      if (jsonMode && AiOutputGate.useJsonObjectResponseFormat(activeModel)) {
        data['response_format'] = {'type': 'json_object'};
      }
      data.addAll(AiOutputGate.requestExtrasForModel(activeModel));
      return dio.post<Map<String, dynamic>>('/chat/completions', data: data);
    }

    final preferJsonMode =
        useJsonObjectMode && AiOutputGate.useJsonObjectResponseFormat(activeModel);

    try {
      final response = await send(activeModel: activeModel, jsonMode: preferJsonMode);
      var content = _rawContent(response.data, activeModel: activeModel);
      if (AiOutputGate.needsStrictRetry(
        content,
        validateContent: (text) =>
            QuizJsonParser.accepts(text, expectedCount: questionCount),
      )) {
        final retry = await send(
          activeModel: activeModel,
          jsonMode: false,
          strictRetry: true,
        );
        content = _rawContent(retry.data, activeModel: activeModel);
      }
      return _requireContent(content, activeModel: activeModel);
    } on DioException catch (e) {
      if (useJsonObjectMode && e.response?.statusCode == 400) {
        final response = await send(activeModel: activeModel, jsonMode: false);
        return _requireContent(
          _rawContent(response.data, activeModel: activeModel),
          activeModel: activeModel,
        );
      }
      rethrow;
    } on UnusableModelOutputException {
      rethrow;
    }
  }

  List<Map<String, String>> _messagesForModel(
    List<Map<String, String>> messages,
    String activeModel, {
    bool strictRetry = false,
  }) {
    if (messages.isEmpty) return messages;
    final out = List<Map<String, String>>.from(messages);
    for (var i = 0; i < out.length; i++) {
      if (out[i]['role'] == 'system') {
        final base = out[i]['content'] ?? '';
        out[i] = {
          'role': 'system',
          'content': AiOutputGate.adaptSystemPrompt(
            strictRetry
                ? '$base\n\nYour last answer was invalid. Output ONLY valid JSON with real values.'
                : base,
            activeModel,
          ),
        };
      } else if (out[i]['role'] == 'user') {
        out[i] = {
          'role': 'user',
          'content': AiOutputGate.adaptUserPrompt(
            out[i]['content'] ?? '',
            activeModel,
          ),
        };
      }
    }
    return out;
  }

  String? _rawContent(
    Map<String, dynamic>? data, {
    required String activeModel,
  }) {
    LastAiUsage.set(AiResponseUtils.parseOpenAiUsage(data));
    final choice = data?['choices'];
    final message = (choice is List && choice.isNotEmpty && choice.first is Map)
        ? (choice.first as Map)['message']
        : null;
    return AiOutputGate.normalizeFromOpenAiMessage(message, modelId: activeModel);
  }

  String _requireContent(
    String? content, {
    required String activeModel,
  }) {
    try {
      return AiOutputGate.requireJsonOutput(content);
    } on InvalidJsonException {
      if (providerType == AiProviderType.builtin) {
        throw UnusableModelOutputException('quiz model=$activeModel');
      }
      rethrow;
    }
  }
}
