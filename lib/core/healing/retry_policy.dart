import '../../core/error/app_exception.dart';

class RetryPolicy {
  const RetryPolicy({
    this.maxAttempts = 3,
    this.initialDelay = const Duration(milliseconds: 400),
    this.multiplier = 2.0,
  });

  final int maxAttempts;
  final Duration initialDelay;
  final double multiplier;

  bool shouldRetry(Object error) {
    if (error is RateLimitException) return false;
    if (error is InvalidApiKeyException) return false;
    if (error is InvalidJsonException) return false;
    return true;
  }

  Future<T> run<T>(Future<T> Function() action) async {
    var attempt = 0;
    var delay = initialDelay;
    while (true) {
      attempt++;
      try {
        return await action();
      } catch (e) {
        if (attempt >= maxAttempts || !shouldRetry(e)) rethrow;
        await Future<void>.delayed(delay);
        delay = Duration(milliseconds: (delay.inMilliseconds * multiplier).round());
      }
    }
  }
}
