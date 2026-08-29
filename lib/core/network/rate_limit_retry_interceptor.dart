import 'package:dio/dio.dart';

/// Retries requests that receive HTTP 429 (Too Many Requests).
///
/// Waits for the duration specified in the `Retry-After` response header
/// (seconds), or [defaultDelay] when the header is absent, then re-issues
/// the original request via [dio.fetch]. Gives up after [maxRetries] attempts.
class RateLimitRetryInterceptor extends Interceptor {
  RateLimitRetryInterceptor({
    required Dio dio,
    this.maxRetries = 3,
    this.defaultDelay = const Duration(seconds: 2),
  }) : _dio = dio;

  static const _retryCountKey = 'rate_limit_retry_count';

  final Dio _dio;
  final int maxRetries;
  final Duration defaultDelay;

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 429) {
      return handler.next(err);
    }

    final retryCount = (err.requestOptions.extra[_retryCountKey] as int?) ?? 0;
    if (retryCount >= maxRetries) {
      return handler.next(err);
    }

    final delay = _delayFor(err.response?.headers.value('retry-after'));
    await Future<void>.delayed(delay);

    final options = err.requestOptions;
    options.extra[_retryCountKey] = retryCount + 1;

    try {
      final response = await _dio.fetch<dynamic>(options);
      handler.resolve(response);
    } on DioException catch (retryError) {
      handler.next(retryError);
    }
  }

  Duration _delayFor(String? retryAfter) {
    if (retryAfter == null || retryAfter.trim().isEmpty) {
      return defaultDelay;
    }
    final seconds = int.tryParse(retryAfter.trim());
    if (seconds == null || seconds < 0) {
      return defaultDelay;
    }
    return Duration(seconds: seconds);
  }
}
