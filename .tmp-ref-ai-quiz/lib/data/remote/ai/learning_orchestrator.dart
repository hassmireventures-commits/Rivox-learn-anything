import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';

import '../../../core/constants/quiz_kind.dart';
import '../../../core/healing/provider_router.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/healing/circuit_breaker.dart';
import '../../../core/healing/health_monitor.dart';
import '../../../core/models/ai_usage_result.dart';
import '../../../core/healing/resilient_ai_provider.dart';
import '../../../core/services/usage_tracker.dart';
import '../../../core/telemetry/telemetry_service.dart';
import '../../local/isar_service.dart';
import '../../local/models/prompt_strategy.dart';
import '../../local/repositories/learner_repository.dart';
import '../../local/repositories/profile_repository.dart';
import '../../local/repositories/provider_repository.dart';
import '../../local/repositories/quiz_repository.dart';
import '../../ml/recommendation_engine.dart';
import '../../vector/local_vector_store.dart';
import 'ai_json_client.dart';
import 'ai_provider_factory.dart';
import 'models/learning_pattern_context.dart';
import 'models/quiz_generation_request.dart';
import 'path_json_parser.dart';
import 'path_prompt_builder.dart';
import 'prompt_builder.dart';

enum LearningAction {
  generateQuiz,
  suggestPath,
  summarizeWeaknesses,
  remedialQuiz,
  encourageBreak,
  followUp,
  openPathModule,
}

class OrchestratorDecision {
  const OrchestratorDecision({
    required this.action,
    required this.reason,
    this.topic,
    this.questionCount = 10,
    this.difficulty = 'medium',
    this.pathId,
    this.moduleIndex,
  });

  final LearningAction action;
  final String reason;
  final String? topic;
  final int questionCount;
  final String difficulty;
  final String? pathId;
  final int? moduleIndex;
}

class LearningOrchestrator {
  LearningOrchestrator({
    required this.isarService,
    required this.learnerRepository,
    required this.profileRepository,
    required this.providerRepository,
    required this.quizRepository,
    required this.recommendationEngine,
    required this.vectorStore,
    required this.telemetry,
    required this.circuitBreaker,
    required this.healthMonitor,
    this.usageTracker,
  });

  final IsarService isarService;
  final LearnerRepository learnerRepository;
  final ProfileRepository profileRepository;
  final ProviderRepository providerRepository;
  final QuizRepository quizRepository;
  final RecommendationEngine recommendationEngine;
  final LocalVectorStore vectorStore;
  final TelemetryService telemetry;
  final CircuitBreaker circuitBreaker;
  final HealthMonitor healthMonitor;
  final UsageTracker? usageTracker;

  Isar get _db => isarService.db;

  Future<void> ensureStrategies() async {
    final existing = await _db.promptStrategys.where().findAll();
    if (existing.isNotEmpty) return;
    final defaults = [
      ('standard', 'Standard quiz prompt'),
      ('simplified', 'Simplified JSON-focused prompt'),
      ('remedial', 'Remedial focus on weak areas'),
    ];
    await _db.writeTxn(() async {
      for (final d in defaults) {
        await _db.promptStrategys.put(
          PromptStrategy()
            ..strategyId = d.$1
            ..label = d.$2
            ..weight = 1
            ..attempts = 0
            ..successes = 0
            ..successRate = 0.5
            ..updatedAt = DateTime.now(),
        );
      }
    });
  }

  Future<OrchestratorDecision> decideNext() async {
    await recommendationEngine.refreshRecommendations();
    final recs = await learnerRepository.activeRecommendations();
    if (recs.isEmpty) {
      return const OrchestratorDecision(
        action: LearningAction.generateQuiz,
        reason: 'Start a fresh learning session',
        topic: 'General knowledge',
      );
    }

    final top = recs.first;
    await learnerRepository.markRecommendationShown(top.uuid);
    final activePath = await learnerRepository.primaryActivePath();

    return switch (top.kind) {
      'break' => OrchestratorDecision(
          action: LearningAction.encourageBreak,
          reason: top.reason,
        ),
      'remedial' => activePath != null
          ? OrchestratorDecision(
              action: LearningAction.openPathModule,
              reason: top.reason,
              pathId: activePath.uuid,
              moduleIndex: activePath.currentIndex,
            )
          : OrchestratorDecision(
              action: LearningAction.remedialQuiz,
              reason: top.reason,
              topic: top.topic ?? 'Review',
              questionCount: 5,
              difficulty: 'easy',
            ),
      'path' => OrchestratorDecision(
          action: LearningAction.suggestPath,
          reason: top.reason,
          topic: top.topic,
        ),
      'nudge' => activePath != null
          ? OrchestratorDecision(
              action: LearningAction.openPathModule,
              reason: top.reason,
              pathId: activePath.uuid,
              moduleIndex: activePath.currentIndex,
            )
          : OrchestratorDecision(
              action: LearningAction.generateQuiz,
              reason: top.reason,
              topic: top.topic ?? 'Quick practice',
              questionCount: 5,
            ),
      _ => activePath != null
          ? OrchestratorDecision(
              action: LearningAction.openPathModule,
              reason: top.reason,
              pathId: activePath.uuid,
              moduleIndex: activePath.currentIndex,
            )
          : OrchestratorDecision(
              action: LearningAction.generateQuiz,
              reason: top.reason,
              topic: top.topic ?? 'Practice',
            ),
    };
  }

  Future<String> generatePathTopics(String focus) async {
    try {
      return await generateLearningPathWithLlm(focus: focus);
    } catch (_) {
      return _generateVectorPath(focus);
    }
  }

  Future<String> generateLearningPathWithLlm({String? focus}) async {
    await ensureStrategies();
    final profile = await learnerRepository.getOrCreateProfile();
    final goals = learnerRepository.goalsOf(profile);
    final weak = await learnerRepository.weakTopics(limit: 5);
    final weakNames = weak.map((e) => e.topic).toList();
    final focusTopic = focus ?? (weakNames.isNotEmpty ? weakNames.first : goals.firstOrNull ?? 'Foundations');

    final providers = await providerRepository.getAll();
    if (providers.isEmpty) {
      throw StateError('No AI provider configured');
    }
    final router = ProviderRouter(circuitBreaker: circuitBreaker, usageTracker: usageTracker);
    final pick = await router.pickProviders(providers: providers, task: 'path');
    final primary = pick.primary;
    final apiKey = await providerRepository.getApiKey(primary.uuid);
    if (apiKey == null || apiKey.isEmpty) {
      throw StateError('Missing API key');
    }

    final settings = await profileRepository.getSettings();
    final languageName = aiLanguageName(settings.language);

    final prompt = PathPromptBuilder.build(
      goals: goals,
      weakTopics: weakNames,
      skillLevel: profile.skillLevel,
      dailyMinutes: profile.dailyMinutesGoal ?? 15,
      focus: focusTopic,
      language: languageName,
    );

    final sw = Stopwatch()..start();
    try {
      final raw = await AiJsonClient.complete(
        config: primary,
        apiKey: apiKey,
        userPrompt: prompt,
      );
      final usage = LastAiUsage.consume();
      final generated = PathJsonParser.parse(raw);
      final stepsJson = generated.steps
          .map((s) => s.toJson())
          .toList();
      final path = await learnerRepository.savePath(
        title: generated.title,
        topics: generated.steps.map((s) => s.title).toList(),
        source: 'ai',
        steps: stepsJson,
      );
      sw.stop();
      await usageTracker?.recordCall(
        providerKey: primary.uuid,
        latencyMs: sw.elapsedMilliseconds,
        success: true,
        promptTokens: usage?.promptTokens ?? 0,
        completionTokens: usage?.completionTokens ?? 0,
      );
      for (final step in generated.steps) {
        await vectorStore.upsertTopic(step.title);
      }
      await telemetry.emit('path_created', {'uuid': path.uuid, 'focus': focusTopic, 'source': 'ai'});
      return path.uuid;
    } catch (e) {
      sw.stop();
      await usageTracker?.recordCall(
        providerKey: primary.uuid,
        latencyMs: sw.elapsedMilliseconds,
        success: false,
      );
      rethrow;
    }
  }

  Future<String> _generateVectorPath(String focus) async {
    final related = await vectorStore.similar(focus, limit: 4);
    final topics = [focus, ...related.map((e) => e.topic)];
    final path = await learnerRepository.savePath(
      title: 'Path: $focus',
      topics: topics,
      source: 'ml',
    );
    await telemetry.emit('path_created', {'uuid': path.uuid, 'focus': focus});
    return path.uuid;
  }

  Future<String> runQuizGeneration({
    required String topic,
    int questionCount = 10,
    String difficulty = 'medium',
    String questionType = 'mcq',
    String? language,
    bool explanations = true,
    int? timerSeconds,
    LearningPatternContext? learningPattern,
    String quizKind = QuizKind.quick,
    String? pathId,
    int? moduleIndex,
  }) async {
    await ensureStrategies();
    final settings = await profileRepository.getSettings();
    final effectiveLanguage = language ?? aiLanguageName(settings.language);
    final strategy = await _pickStrategy();
    final providers = await providerRepository.getAll();
    if (providers.isEmpty) {
      throw StateError('No AI provider configured');
    }
    final router = ProviderRouter(circuitBreaker: circuitBreaker, usageTracker: usageTracker);
    final pick = await router.pickProviders(providers: providers, task: 'quiz');
    final primary = pick.primary;
    final fallback = pick.fallbacks.isNotEmpty ? pick.fallbacks.first : null;

    final primaryKey = await providerRepository.getApiKey(primary.uuid);
    if (primaryKey == null || primaryKey.isEmpty) {
      throw StateError('Missing API key');
    }

    String? fallbackKey;
    if (fallback != null) {
      fallbackKey = await providerRepository.getApiKey(fallback.uuid);
    }

    final resilient = ResilientAiProvider(
      primaryKey: primary.uuid,
      primaryFactory: () => AiProviderFactory.create(config: primary, apiKey: primaryKey),
      fallbackKey: fallback?.uuid,
      fallbackFactory: fallback != null && fallbackKey != null && fallbackKey.isNotEmpty
          ? () => AiProviderFactory.create(config: fallback, apiKey: fallbackKey!)
          : null,
      circuitBreaker: circuitBreaker,
      healthMonitor: healthMonitor,
      telemetry: telemetry,
      usageTracker: usageTracker,
    );

    if (strategy.strategyId == 'simplified') {
      resilient.useSimplifiedStrategy();
    }

    LearningPatternContext? pattern = learningPattern;
    if (pattern == null) {
      final node = await learnerRepository.allTopics();
      final match = node.where((n) => n.topic.toLowerCase() == topic.toLowerCase()).firstOrNull;
      if (match != null) {
        final accuracy = match.attempts > 0 ? match.correctCount / match.attempts : null;
        pattern = LearningPatternContext(
          moduleTitle: topic,
          priorAccuracy: accuracy,
        );
      }
    }

    final request = QuizGenerationRequest(
      topic: topic,
      questionCount: questionCount,
      difficulty: difficulty,
      questionType: questionType,
      language: effectiveLanguage,
      randomizeQuestions: true,
      randomizeOptions: true,
      generateExplanations: explanations && strategy.strategyId != 'simplified',
      timerSeconds: timerSeconds,
      learningPattern: pattern,
    );

    // Touch prompt builder so strategy-aware prompts stay centralized.
    PromptBuilder.build(request);

    await telemetry.emit('quiz_started', {'topic': topic, 'strategy': strategy.strategyId});
    try {
      final generated = await resilient.generateQuiz(request);
      final usage = LastAiUsage.consume();
      final session = await quizRepository.saveGeneratedQuiz(
        request: request,
        generated: generated,
        quizKind: quizKind,
        pathId: pathId,
        moduleIndex: moduleIndex,
        promptTokens: usage?.promptTokens,
        completionTokens: usage?.completionTokens,
      );
      await _recordStrategy(strategy.strategyId, success: true);
      await vectorStore.upsertTopic(topic);
      await healthMonitor.persist();
      return session.uuid;
    } catch (e) {
      await _recordStrategy(strategy.strategyId, success: false);
      await healthMonitor.persist();
      rethrow;
    }
  }

  Future<PromptStrategy> _pickStrategy() async {
    final all = await _db.promptStrategys.where().findAll();
    all.sort((a, b) => (b.weight * b.successRate).compareTo(a.weight * a.successRate));
    return all.first;
  }

  Future<void> _recordStrategy(String id, {required bool success}) async {
    final row = await _db.promptStrategys.filter().strategyIdEqualTo(id).findFirst();
    if (row == null) return;
    row
      ..attempts += 1
      ..successes += success ? 1 : 0
      ..successRate = row.successes / row.attempts
      ..weight = (row.weight + (success ? 0.05 : -0.05)).clamp(0.2, 2.0)
      ..updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.promptStrategys.put(row);
    });
  }

  Future<String> summarizeWeaknesses() async {
    final weak = await learnerRepository.weakTopics(limit: 5);
    if (weak.isEmpty) return 'No weak topics yet. Take a quiz to build your profile.';
    final lines = weak
        .map((t) => '• ${t.topic} (mastery ${(t.strength * 100).round()}%)')
        .join('\n');
    return 'Focus areas:\n$lines';
  }
}
