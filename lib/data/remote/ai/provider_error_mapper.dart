import 'dart:io';

import 'package:dio/dio.dart';

import '../../../core/error/app_exception.dart';

class ProviderErrorMapper {
  const ProviderErrorMapper._();

  static AppException map(
    DioException e, {
    String providerName = 'AI provider',
    String task = 'quiz',
  }) {
    if (e.type == DioExceptionType.connectionError ||
        e.type == DioExceptionType.connectionTimeout ||
        e.type == DioExceptionType.unknown && _looksLikeNetwork(e)) {
      return const NoInternetException();
    }
    if (e.type == DioExceptionType.receiveTimeout ||
        e.type == DioExceptionType.sendTimeout) {
      return GenerationTimeoutException.forTask(task);
    }

    final status = e.response?.statusCode;
    final body = _messageFromBody(e.response?.data);

    if (status == 401 || status == 403) {
      return InvalidApiKeyException(
        body ?? 'Invalid API key. Check your provider settings.',
      );
    }
    if (status == 400 && _looksLikeAuth(body)) {
      return InvalidApiKeyException(
        body ?? 'Invalid API key. Check your provider settings.',
      );
    }
    if (status == 400 && _looksLikeJsonModeUnsupported(body)) {
      return const ProviderUnavailableException(
        'This model does not support JSON mode. Try another model.',
      );
    }
    if (status == 404) {
      return ProviderUnavailableException(
        body ?? 'Model or endpoint not found. Check the model name and base URL.',
      );
    }
    if (status == 429 || _looksLikeRateLimit(body)) {
      return RateLimitException(
        providerName: providerName,
        retryAfter: _parseRetryAfter(e),
        message: body ?? 'Rate limit exceeded. Wait a moment and try again.',
      );
    }
    if (status != null && status >= 500) {
      return ProviderUnavailableException(
        '$providerName is temporarily unavailable. Try again shortly.',
      );
    }

    return ProviderUnavailableException(
      body ?? '$providerName is unavailable. Try again.',
    );
  }

  static Duration? _parseRetryAfter(DioException e) {
    final headers = e.response?.headers;
    final raw = headers?.value('retry-after') ?? headers?.value('Retry-After');
    Duration parsed = const Duration(seconds: 60);
    if (raw != null) {
      final seconds = int.tryParse(raw);
      if (seconds != null) {
        parsed = Duration(seconds: seconds);
      } else {
        try {
          final date = HttpDate.parse(raw);
          final diff = date.difference(DateTime.now());
          parsed = diff.isNegative ? const Duration(seconds: 60) : diff;
        } catch (_) {}
      }
    }
    // Cap so one 429 cannot lock generation for a long window.
    if (parsed > const Duration(seconds: 60)) {
      return const Duration(seconds: 60);
    }
    return parsed;
  }

  static bool _looksLikeRateLimit(String? body) {
    if (body == null) return false;
    final lower = body.toLowerCase();
    return lower.contains('rate_limit') ||
        lower.contains('rate limit') ||
        lower.contains('quota') ||
        lower.contains('resource_exhausted') ||
        lower.contains('too many requests');
  }

  static bool _looksLikeNetwork(DioException e) {
    final message = '${e.message ?? ''} ${e.error ?? ''}'.toLowerCase();
    return message.contains('socket') ||
        message.contains('network') ||
        message.contains('failed host lookup') ||
        message.contains('connection') ||
        message.contains('connection abort') ||
        message.contains('software caused connection abort') ||
        message.contains('broken pipe') ||
        message.contains('connection reset');
  }

  static bool _looksLikeAuth(String? body) {
    if (body == null) return false;
    final lower = body.toLowerCase();
    return lower.contains('api key') ||
        lower.contains('api_key') ||
        lower.contains('unauthorized') ||
        lower.contains('permission') ||
        lower.contains('invalid key') ||
        lower.contains('authentication');
  }

  static bool _looksLikeJsonModeUnsupported(String? body) {
    if (body == null) return false;
    final lower = body.toLowerCase();
    return lower.contains('response_format') ||
        lower.contains('json_object') ||
        lower.contains('json mode');
  }

  static String? _messageFromBody(dynamic data) {
    if (data == null) return null;
    if (data is String && data.trim().isNotEmpty) {
      return _truncate(data.trim());
    }
    if (data is! Map) return null;

    final map = Map<String, dynamic>.from(data);
    final error = map['error'];
    if (error is Map) {
      final message = error['message']?.toString();
      if (message != null && message.trim().isNotEmpty) {
        return _truncate(message.trim());
      }
    }
    final message = map['message']?.toString();
    if (message != null && message.trim().isNotEmpty) {
      return _truncate(message.trim());
    }
    return null;
  }

  static String _truncate(String value) {
    if (value.length <= 180) return value;
    return '${value.substring(0, 180)}…';
  }
}
