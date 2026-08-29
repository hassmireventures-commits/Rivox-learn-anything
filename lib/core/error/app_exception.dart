import 'dart:async';

import 'package:dio/dio.dart';

import '../../data/remote/ai/provider_error_mapper.dart';

sealed class AppException implements Exception {
  const AppException(this.message);
  final String message;

  @override
  String toString() => message;

  /// Maps arbitrary failures (Dio, timeouts, etc.) to user-facing [AppException]s.
  static AppException from(
    Object error, {
    String fallback = 'Something went wrong. Please try again.',
    String task = 'quiz',
  }) {
    if (error is AppException) return error;
    if (error is DioException) {
      return ProviderErrorMapper.map(error, task: task);
    }
    if (error is TimeoutException) {
      return GenerationTimeoutException.forTask(task);
    }
    return UnknownException(fallback);
  }
}

class InvalidApiKeyException extends AppException {
  const InvalidApiKeyException([super.message = 'Invalid API key. Check your provider settings.']);
}

class NoInternetException extends AppException {
  const NoInternetException([super.message = 'No internet connection.']);
}

class ProviderUnavailableException extends AppException {
  const ProviderUnavailableException([super.message = 'AI provider is unavailable.']);
}

class RateLimitException extends AppException {
  const RateLimitException({
    this.providerName = 'AI provider',
    this.retryAfter,
    String? message,
  }) : super(message ?? 'API rate limit reached. Please wait and try again.');

  final String providerName;
  final Duration? retryAfter;

  DateTime? get retryAfterUntil =>
      retryAfter == null ? null : DateTime.now().add(retryAfter!);
}

class InvalidJsonException extends AppException {
  const InvalidJsonException([
    super.message = 'AI returned invalid quiz data. Try again.',
    this.emptyResponse = false,
  ]);

  /// True when the model returned no usable text (skip expensive simplified retry).
  final bool emptyResponse;
}

class GenerationTimeoutException extends AppException {
  const GenerationTimeoutException([super.message = 'Quiz generation timed out.']);

  factory GenerationTimeoutException.forTask(String task) {
    return switch (task) {
      'path' || 'path_generation' => const GenerationTimeoutException(
          'Learning path generation timed out. Check your connection and try again.',
        ),
      'quiz' || 'quiz_generation' => const GenerationTimeoutException(
          'Quiz generation timed out. Check your connection and try again.',
        ),
      _ => const GenerationTimeoutException(
          'AI generation timed out. Check your connection and try again.',
        ),
    };
  }
}

class RoomExpiredException extends AppException {
  const RoomExpiredException([super.message = 'This quiz room has expired.']);
}

class RoomFullException extends AppException {
  const RoomFullException([super.message = 'This quiz room is no longer accepting players.']);
}

class NotFoundException extends AppException {
  const NotFoundException([super.message = 'Item not found.']);
}

class StorageException extends AppException {
  const StorageException([super.message = 'Local storage error.']);
}

class UnknownException extends AppException {
  const UnknownException([super.message = 'Something went wrong.']);
}

class ActivePathExistsException extends AppException {
  const ActivePathExistsException([
    super.message = 'You already have an active learning path. Finish it before creating a new one.',
  ]);
}

class NoProviderConfiguredException extends AppException {
  const NoProviderConfiguredException([
    super.message = 'No AI provider configured. Add one in Settings → AI Providers.',
  ]);
}

class TopicNotAllowedException extends AppException {
  const TopicNotAllowedException([super.message = 'Topic not allowed.']);
}

class TokenBudgetExceededException extends AppException {
  const TokenBudgetExceededException([
    super.message = 'Daily AI token limit reached. Try again tomorrow or switch to economy mode in Settings.',
  ]);
}

class BuiltInQuotaExceededException extends AppException {
  const BuiltInQuotaExceededException([
    super.message =
        'Daily Built-in AI limit reached. Watch an ad for more, or add your own provider.',
  ]);
}

/// Typed library/upload failures mapped to l10n in the UI.
class LibraryException extends AppException {
  const LibraryException(this.code, [String? message])
      : super(message ?? code);

  /// Stable key: invalidUrl | httpsOnly | emptyPage | notEnoughText |
  /// noContent | invalidUpload | indexFailed | notResume | notJd
  final String code;
}

class MissingApiKeyException extends AppException {
  const MissingApiKeyException([
    super.message = 'API key missing. Open Settings → AI Providers to add your key.',
  ]);
}

class EngineNotChosenException extends AppException {
  const EngineNotChosenException([
    super.message =
        'AI is not ready. Check Settings → AI Providers, or restart the app.',
  ]);
}
