import 'package:dio/dio.dart';

import 'rate_limit_retry_interceptor.dart';

class DioClient {
  DioClient._();

  static Dio create({
    String? baseUrl,
    Map<String, dynamic>? headers,
    Duration timeout = const Duration(seconds: 90),
    int maxRateLimitRetries = 3,
  }) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl ?? '',
        connectTimeout: timeout,
        receiveTimeout: timeout,
        sendTimeout: timeout,
        headers: {
          'Content-Type': 'application/json',
          ...?headers,
        },
      ),
    );
    dio.interceptors.add(
      RateLimitRetryInterceptor(dio: dio, maxRetries: maxRateLimitRetries),
    );
    return dio;
  }
}
