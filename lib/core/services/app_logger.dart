import 'package:flutter/foundation.dart';

/// Pluggable sink for release crash/error reporting (Crashlytics/Sentry later).
typedef CrashReportSink = void Function(
  String tag,
  String message, {
  Object? error,
  StackTrace? stack,
  Map<String, String>? extras,
});

/// Centralized logger with PII/secret scrubbing before any sink sees the message.
class AppLogger {
  const AppLogger._();

  static CrashReportSink? crashSink;

  static final _secretPatterns = <RegExp>[
    RegExp(r'sk-[a-zA-Z0-9]{10,}'),
    RegExp(r'AIza[0-9A-Za-z\-_]{20,}'),
    RegExp(r'Bearer\s+[A-Za-z0-9\-._~+/]+=*', caseSensitive: false),
    RegExp(r'api[_-]?key["\s:=]+[A-Za-z0-9\-._]{8,}', caseSensitive: false),
  ];

  static String scrub(String input) {
    var out = input;
    for (final pattern in _secretPatterns) {
      out = out.replaceAll(pattern, '[REDACTED]');
    }
    return out;
  }

  static void debug(String tag, String message, [Object? extra]) {
    if (kDebugMode) {
      debugPrint('[$tag] ${scrub(message)}${extra != null ? '\n  ${scrub('$extra')}' : ''}');
    }
  }

  static void info(String tag, String message, [Object? extra]) {
    if (kDebugMode) {
      debugPrint('[$tag] ${scrub(message)}${extra != null ? '\n  ${scrub('$extra')}' : ''}');
    }
  }

  static void warning(String tag, String message, [Object? error, StackTrace? stack]) {
    final safe = scrub(message);
    debugPrint('[WARN][$tag] $safe${error != null ? '\n  ${scrub('$error')}' : ''}');
    if (stack != null && kDebugMode) debugPrint(stack.toString());
  }

  static void error(String tag, String message, [Object? error, StackTrace? stack]) {
    final safe = scrub(message);
    final safeError = error == null ? null : scrub('$error');
    debugPrint('[ERROR][$tag] $safe${safeError != null ? '\n  $safeError' : ''}');
    if (stack != null && kDebugMode) debugPrint(stack.toString());
    crashSink?.call(
      tag,
      safe,
      error: safeError,
      stack: stack,
    );
  }
}
