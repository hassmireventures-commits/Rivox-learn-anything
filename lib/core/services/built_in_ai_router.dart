import 'package:dio/dio.dart';

import '../../data/remote/ai/provider_error_mapper.dart';
import '../error/app_exception.dart';
import 'built_in_ai_config.dart';
import '../../data/remote/ai/ai_output_gate.dart';

/// Thrown when a NIM model returns chain-of-thought / instruction echo instead of usable text.
class UnusableModelOutputException implements Exception {
  const UnusableModelOutputException([this.detail = 'unusable model output']);
  final String detail;
}

/// Built-in AI model routing — retries alternate NIM models on HTTP or bad output.
class BuiltInAiRouter {
  BuiltInAiRouter._();

  /// Primary instruct model; Nemotron nano often returns reasoning leaks for JSON tasks.
  static const primaryModel = BuiltInAiConfig.defaultModel;

  /// Secondary models when primary fails or returns unusable output.
  static const fallbackModels = <String>[
    BuiltInAiConfig.fallbackModel,
  ];

  /// Unique model ids to try: known-good [primaryModel] first, then stored model, then fallbacks.
  static List<String> modelsToTry(String configuredModel) {
    final out = <String>[];
    void add(String model) {
      final trimmed = model.trim();
      if (trimmed.isNotEmpty && !out.contains(trimmed)) out.add(trimmed);
    }

    add(primaryModel);
    add(configuredModel);
    for (final model in fallbackModels) {
      add(model);
    }
    return out;
  }

  /// True when the HTTP error likely means the model id is wrong or retired.
  static bool isRetryableModelError(DioException e) {
    final status = e.response?.statusCode;
    if (status == 404 || status == 410) return true;

    final body = _bodyText(e.response?.data)?.toLowerCase() ?? '';
    return body.contains('end of life') ||
        body.contains('not found') ||
        body.contains('model') && body.contains('unavailable') ||
        body.contains('unknown model') ||
        body.contains('invalid model');
  }

  /// True when model text is empty or has no usable JSON payload.
  static bool isUnusableModelOutput(
    String? content, {
    bool expectJson = true,
  }) {
    if (content == null || content.trim().isEmpty) return true;
    if (!expectJson) {
      return isReasoningOrInstructionLeak(content);
    }
    return !AiOutputGate.acceptsJsonObject(content);
  }

  /// Detects chain-of-thought / parroted prompt rules (Nemotron-style leaks).
  static bool isReasoningOrInstructionLeak(String text) =>
      AiOutputGate.isInstructionLeak(text);

  /// Runs [attempt] across [modelsToTry] until one succeeds with usable output.
  static Future<T> withModelFallback<T>({
    required String configuredModel,
    required Future<T> Function(String model) attempt,
  }) async {
    DioException? lastDio;
    UnusableModelOutputException? lastOutput;
    for (final model in modelsToTry(configuredModel)) {
      try {
        return await attempt(model);
      } on UnusableModelOutputException catch (e) {
        lastOutput = e;
      } on InvalidJsonException catch (e) {
        lastOutput = UnusableModelOutputException(e.message);
      } on DioException catch (e) {
        if (!isRetryableModelError(e)) {
          throw ProviderErrorMapper.map(e, providerName: BuiltInAiConfig.displayName);
        }
        lastDio = e;
      }
    }
    if (lastDio != null) {
      throw ProviderErrorMapper.map(lastDio, providerName: BuiltInAiConfig.displayName);
    }
    if (lastOutput != null) {
      throw const ProviderUnavailableException(
        'Built-in AI returned unusable text. Try again shortly.',
      );
    }
    throw const ProviderUnavailableException(
      'Built-in AI models are temporarily unavailable. Try again shortly.',
    );
  }

  static String? _bodyText(dynamic data) {
    if (data == null) return null;
    if (data is String) return data;
    if (data is Map) {
      final error = data['error'];
      if (error is Map) {
        return error['message']?.toString() ?? error['detail']?.toString();
      }
      return data['detail']?.toString() ?? data['message']?.toString();
    }
    return data.toString();
  }
}
