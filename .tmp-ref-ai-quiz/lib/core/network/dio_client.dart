import 'package:dio/dio.dart';

class DioClient {
  DioClient._();

  static Dio create({
    String? baseUrl,
    Map<String, dynamic>? headers,
    Duration timeout = const Duration(seconds: 90),
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
    return dio;
  }
}
