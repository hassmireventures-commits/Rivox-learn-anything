import '../../core/error/app_exception.dart';
import '../../core/services/usage_tracker.dart';
import '../../data/remote/ai/ai_provider.dart';
import '../../data/remote/ai/models/generated_quiz.dart';
import '../../data/remote/ai/models/quiz_generation_request.dart';
import '../telemetry/telemetry_service.dart';
import 'circuit_breaker.dart';
import 'health_monitor.dart';
import 'retry_policy.dart';

typedef ProviderFactory = AiProvider Function();

class ResilientAiProvider implements AiProvider {
  ResilientAiProvider({
    required this.primaryKey,
    required this.primaryFactory,
    required this.circuitBreaker,
    required this.healthMonitor,
    required this.telemetry,
    this.usageTracker,
    this.fallbackFactory,
    this.fallbackKey,
    this.retryPolicy = const RetryPolicy(),
  });

  final String primaryKey;
  final ProviderFactory primaryFactory;
  final ProviderFactory? fallbackFactory;
  final String? fallbackKey;
  final CircuitBreaker circuitBreaker;
  final HealthMonitor healthMonitor;
  final TelemetryService telemetry;
  final UsageTracker? usageTracker;
  final RetryPolicy retryPolicy;

  String _activeStrategy = 'standard';

  String get activeStrategy => _activeStrategy;

  void useSimplifiedStrategy() => _activeStrategy = 'simplified';

  @override
  Future<GeneratedQuiz> generateQuiz(QuizGenerationRequest request) async {
    final effectiveRequest = _activeStrategy == 'simplified'
        ? QuizGenerationRequest(
            topic: request.topic,
            questionCount: request.questionCount.clamp(5, 10),
            difficulty: request.difficulty == 'expert' ? 'hard' : request.difficulty,
            questionType: request.questionType == 'mixed' ? 'mcq' : request.questionType,
            language: request.language,
            randomizeQuestions: request.randomizeQuestions,
            randomizeOptions: request.randomizeOptions,
            generateExplanations: false,
            timerSeconds: request.timerSeconds,
          )
        : request;

    Future<GeneratedQuiz> attempt(String key, ProviderFactory factory) async {
      if (!circuitBreaker.allow(key)) {
        throw const ProviderUnavailableException(
          'Provider temporarily paused after repeated failures.',
        );
      }
      final sw = Stopwatch()..start();
      try {
        final quiz = await retryPolicy.run(() => factory().generateQuiz(effectiveRequest));
        sw.stop();
        circuitBreaker.recordSuccess(key);
        healthMonitor.record(latencyMs: sw.elapsedMilliseconds, success: true);
        await usageTracker?.recordCall(
          providerKey: key,
          latencyMs: sw.elapsedMilliseconds,
          success: true,
        );
        await telemetry.emit('retry_success', {'provider': key});
        return quiz;
      } catch (e) {
        sw.stop();
        circuitBreaker.recordFailure(key);
        healthMonitor.record(latencyMs: sw.elapsedMilliseconds, success: false);
        await usageTracker?.recordCall(
          providerKey: key,
          latencyMs: sw.elapsedMilliseconds,
          success: false,
        );
        if (e is RateLimitException) {
          await usageTracker?.recordRateLimit(
            providerKey: key,
            retryAfter: e.retryAfter,
          );
        }
        await telemetry.emit('provider_error', {
          'provider': key,
          'error': e.runtimeType.toString(),
        });
        rethrow;
      }
    }

    try {
      return await attempt(primaryKey, primaryFactory);
    } on InvalidJsonException {
      useSimplifiedStrategy();
      try {
        return await attempt(primaryKey, primaryFactory);
      } catch (_) {
        if (fallbackFactory != null && fallbackKey != null) {
          return attempt(fallbackKey!, fallbackFactory!);
        }
        rethrow;
      }
    } catch (_) {
      if (fallbackFactory != null && fallbackKey != null) {
        return attempt(fallbackKey!, fallbackFactory!);
      }
      rethrow;
    }
  }
}
