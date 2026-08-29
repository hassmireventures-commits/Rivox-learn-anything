import 'package:dio/dio.dart';

import '../../network/dio_client.dart';

/// Shared HTTP client for free/open knowledge APIs.
class OpenKnowledgeClient {
  OpenKnowledgeClient._();

  /// MediaWiki requires an identifiable User-Agent (no API key).
  static const userAgent =
      'Rivox/1.0 (com.aiquiz.ai_quiz_app; educational; +https://learn-anything-43970.web.app)';

  static Dio create({Duration timeout = const Duration(seconds: 10)}) {
    return DioClient.create(
      timeout: timeout,
      headers: {
        'User-Agent': userAgent,
        'Accept': 'application/json,text/plain,*/*',
      },
    );
  }
}
