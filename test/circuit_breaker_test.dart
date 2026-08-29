import 'package:ai_quiz_app/core/healing/circuit_breaker.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CircuitBreaker', () {
    test('opens after failure threshold', () {
      final breaker = CircuitBreaker(failureThreshold: 2);
      expect(breaker.allow('openai'), isTrue);

      breaker.recordFailure('openai');
      expect(breaker.allow('openai'), isTrue);

      breaker.recordFailure('openai');
      expect(breaker.allow('openai'), isFalse);
      expect(breaker.stateOf('openai'), CircuitState.open);
    });

    test('success resets failures', () {
      final breaker = CircuitBreaker(failureThreshold: 2);
      breaker.recordFailure('openai');
      breaker.recordSuccess('openai');

      breaker.recordFailure('openai');
      expect(breaker.allow('openai'), isTrue);
    });

    test('reset clears breaker state', () {
      final breaker = CircuitBreaker(failureThreshold: 1);
      breaker.recordFailure('gemini');
      expect(breaker.allow('gemini'), isFalse);

      breaker.reset('gemini');
      expect(breaker.allow('gemini'), isTrue);
    });
  });
}
