import 'package:dio/dio.dart';

import 'nvidia_ai_config.dart';

/// Thrown when no key could complete an NVIDIA call.
class NvidiaUnavailableException implements Exception {
  const NvidiaUnavailableException(this.detail);
  final String detail;

  @override
  String toString() => 'NvidiaUnavailableException: $detail';
}

/// Small POST client for the NVIDIA API catalog with key failover: a 401,
/// 403, or 429 on one key retries the same request on the next key for the
/// capability (see [NvidiaAiConfig.keysFor]). Any other error is returned to
/// the caller unchanged, so callers decide how to degrade.
class NvidiaClient {
  NvidiaClient({Dio? dio, List<String>? keysOverride})
      : _dio = dio ??
            Dio(BaseOptions(
              connectTimeout: const Duration(seconds: 15),
              receiveTimeout: const Duration(seconds: 60),
              sendTimeout: const Duration(seconds: 60),
              headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
            )),
        _keysOverride = keysOverride;

  final Dio _dio;
  final List<String>? _keysOverride;

  static bool isKeyProblem(int? status) => status == 401 || status == 403 || status == 429;

  Future<Map<String, dynamic>> postJson(
    String url,
    Map<String, dynamic> body, {
    required NvidiaCapability capability,
    Duration? timeout,
  }) async {
    final keys = _keysOverride ?? NvidiaAiConfig.keysFor(capability);
    if (keys.isEmpty) {
      throw const NvidiaUnavailableException('No NVIDIA key configured for this build.');
    }
    DioException? last;
    for (final key in keys) {
      try {
        final res = await _dio.post<Map<String, dynamic>>(
          url,
          data: body,
          options: Options(
            headers: {'Authorization': 'Bearer $key'},
            receiveTimeout: timeout,
            sendTimeout: timeout,
          ),
        );
        return res.data ?? const {};
      } on DioException catch (e) {
        last = e;
        if (!isKeyProblem(e.response?.statusCode)) rethrow;
      }
    }
    throw NvidiaUnavailableException('All keys rejected or rate limited (${last?.response?.statusCode}).');
  }

  /// Convenience for `/chat/completions`: returns the first choice's message.
  Future<Map<String, dynamic>> chat({
    required String model,
    required List<Map<String, dynamic>> messages,
    required NvidiaCapability capability,
    int maxTokens = 512,
    double temperature = 0.2,
    Map<String, dynamic> extra = const {},
    Duration? timeout,
  }) async {
    final data = await postJson(
      '${NvidiaAiConfig.chatBaseUrl}/chat/completions',
      {
        'model': model,
        'messages': messages,
        'max_tokens': maxTokens,
        'temperature': temperature,
        'stream': false,
        ...extra,
      },
      capability: capability,
      timeout: timeout,
    );
    final choices = data['choices'];
    if (choices is List && choices.isNotEmpty && choices.first is Map) {
      final message = (choices.first as Map)['message'];
      if (message is Map) return Map<String, dynamic>.from(message);
    }
    return const {};
  }
}
