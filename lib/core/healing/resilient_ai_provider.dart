import '../../core/error/app_exception.dart';
import '../../core/telemetry/llm_telemetry_recorder.dart';
import '../../data/remote/ai/ai_provider.dart';
import '../../data/remote/ai/models/generated_quiz.dart';
import '../../data/remote/ai/models/quiz_generation_request.dart';
import '../models/ai_usage_result.dart';
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
    this.llmTelemetry,
    this.fallbackFactory,
    this.fallbackKey,
    this.retryPolicy = const RetryPolicy(),
    this.task = 'quiz_generation',
  });

  final String primaryKey;
  final ProviderFactory primaryFactory;
  final ProviderFactory? fallbackFactory;
  final String? fallbackKey;
  final CircuitBreaker circuitBreaker;
  final HealthMonitor healthMonitor;
  final TelemetryService telemetry;
  final LlmTelemetryRecorder? llmTelemetry;
  final RetryPolicy retryPolicy;
  final String task;

  String _activeStrategy = 'standard';

  /// When true, only [fallbackKey] is attempted (e.g. Built-in quota exhausted).
  bool skipPrimary = false;

  /// Provider key that produced the last successful quiz (primary or fallback).
  String? lastSucceededProviderKey;

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
            interviewPersona: request.interviewPersona,
            voiceInterviewOnly: request.voiceInterviewOnly,
            goalMode: request.goalMode,
            examType: request.examType,
            examName: request.examName,
            syllabusUnitTitles: request.syllabusUnitTitles,
            topicResolutionBlock: request.topicResolutionBlock,
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
        lastSucceededProviderKey = key;
        final usage = LastAiUsage.consume();
        await llmTelemetry?.recordCall(
          providerKey: key,
          task: task,
          latencyMs: sw.elapsedMilliseconds,
          success: true,
          promptTokens: usage?.promptTokens ?? 0,
          completionTokens: usage?.completionTokens ?? 0,
          ragChunkIds: request.citationChunkIds,
        );
        await telemetry.emit('retry_success', {'provider': key});
        return quiz;
      } catch (e) {
        sw.stop();
        // Bad quiz JSON is a model-output issue, not a provider outage.
        if (e is! InvalidJsonException) {
          circuitBreaker.recordFailure(key);
        }
        healthMonitor.record(latencyMs: sw.elapsedMilliseconds, success: false);
        await llmTelemetry?.recordCall(
          providerKey: key,
          task: task,
          latencyMs: sw.elapsedMilliseconds,
          success: false,
          errorKind: e.runtimeType.toString(),
        );
        if (e is RateLimitException) {
          await llmTelemetry?.recordRateLimit(
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

    if (skipPrimary) {
      if (fallbackFactory == null || fallbackKey == null) {
        throw const ProviderUnavailableException('No fallback provider available.');
      }
      return attempt(fallbackKey!, fallbackFactory!);
    }

    try {
      return await attempt(primaryKey, primaryFactory);
    } on RateLimitException {
      if (fallbackFactory != null && fallbackKey != null) {
        return attempt(fallbackKey!, fallbackFactory!);
      }
      rethrow;
    } on InvalidJsonException catch (e) {
      // Empty responses: skip another full primary attempt (avoids multi-minute waits).
      if (e.emptyResponse) {
        if (fallbackFactory != null && fallbackKey != null) {
          return attempt(fallbackKey!, fallbackFactory!);
        }
        rethrow;
      }
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
