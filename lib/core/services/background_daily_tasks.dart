import 'package:flutter/widgets.dart';
import 'package:workmanager/workmanager.dart';

import '../../core/ai_platform/ai_audit_log.dart';
import '../../core/ai_platform/ai_consent_gate.dart';
import '../../core/ai_platform/ai_request_pipeline.dart';
import '../../core/ai_platform/prompt_firewall.dart';
import '../../core/ai_platform/rag_context_builder.dart';
import '../../core/healing/circuit_breaker.dart';
import '../../core/healing/health_monitor.dart';
import '../../core/services/built_in_ai_quota.dart';
import '../../core/services/daily_content_scheduler.dart';
import '../../core/services/daily_content_service.dart';
import '../../core/services/llm_manager.dart';
import '../../core/services/notification_service.dart';
import '../../core/services/quiz_of_the_day_service.dart';
import '../../core/services/usage_tracker.dart';
import '../../core/telemetry/llm_telemetry_recorder.dart';
import '../../core/telemetry/telemetry_service.dart';
import '../../data/local/isar_service.dart';
import '../../data/local/repositories/knowledge_repository.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/profile_repository.dart';
import '../../data/local/repositories/provider_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import '../../data/ml/feature_engineering_service.dart';
import '../../data/ml/recommendation_engine.dart';
import '../../data/remote/ai/learning_orchestrator.dart';
import '../../data/secure/secure_key_storage.dart';
import '../../data/vector/knowledge_vector_store.dart';

/// Workmanager entry points for daily quiz + daily content generation.
class BackgroundDailyTasks {
  BackgroundDailyTasks._();

  static const dailyQuizTask = 'dailyQuizTask';
  static const dailyContentTask = 'dailyContentTask';
  static const quotaRestoreTask = 'quotaRestoreTask';

  static Future<void> register() async {
    await Workmanager().initialize(callbackDispatcher);
    final network = Constraints(networkType: NetworkType.connected);
    await Workmanager().registerPeriodicTask(
      dailyQuizTask,
      dailyQuizTask,
      frequency: const Duration(hours: 24),
      constraints: network,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
    await Workmanager().registerPeriodicTask(
      dailyContentTask,
      dailyContentTask,
      frequency: const Duration(hours: 24),
      constraints: network,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
    await Workmanager().registerPeriodicTask(
      quotaRestoreTask,
      quotaRestoreTask,
      frequency: const Duration(minutes: 15),
      existingWorkPolicy: ExistingPeriodicWorkPolicy.keep,
    );
  }
}

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      WidgetsFlutterBinding.ensureInitialized();
      await IsarService.instance.init();
      await AiConsentGate.instance.load();
      await BuiltInAiQuota.instance.restoreIfExpired();
      await NotificationService.instance.init();

      final isar = IsarService.instance;
      final secure = SecureKeyStorage();
      final learnerRepo = LearnerRepository(isar);
      final quizRepo = QuizRepository(isar);
      final profileRepo = ProfileRepository(isar);
      final providerRepo = ProviderRepository(isar, secure);
      final llm = LlmManager(providerRepository: providerRepo);

      if (taskName == BackgroundDailyTasks.dailyQuizTask ||
          taskName == Workmanager.iOSBackgroundTask) {
        await _runDailyQuiz(
          isar: isar,
          learnerRepo: learnerRepo,
          quizRepo: quizRepo,
          profileRepo: profileRepo,
          providerRepo: providerRepo,
          llm: llm,
        );
      }

      if (taskName == BackgroundDailyTasks.dailyContentTask ||
          taskName == Workmanager.iOSBackgroundTask) {
        await _runDailyContent(
          quizRepo: quizRepo,
          learnerRepo: learnerRepo,
          llm: llm,
        );
      }

      if (taskName == BackgroundDailyTasks.quotaRestoreTask) {
        await BuiltInAiQuota.instance.restoreIfExpired();
      }

      // Unknown task names: try both once.
      if (taskName != BackgroundDailyTasks.dailyQuizTask &&
          taskName != BackgroundDailyTasks.dailyContentTask &&
          taskName != BackgroundDailyTasks.quotaRestoreTask &&
          taskName != Workmanager.iOSBackgroundTask) {
        await _runDailyQuiz(
          isar: isar,
          learnerRepo: learnerRepo,
          quizRepo: quizRepo,
          profileRepo: profileRepo,
          providerRepo: providerRepo,
          llm: llm,
        );
        await _runDailyContent(
          quizRepo: quizRepo,
          learnerRepo: learnerRepo,
          llm: llm,
        );
      }
      return true;
    } catch (_) {
      return false;
    }
  });
}

Future<void> _runDailyQuiz({
  required IsarService isar,
  required LearnerRepository learnerRepo,
  required QuizRepository quizRepo,
  required ProfileRepository profileRepo,
  required ProviderRepository providerRepo,
  required LlmManager llm,
}) async {
  try {
    final vectorStore = KnowledgeVectorStore(isar);
    final features = FeatureEngineeringService(isar, learnerRepo);
    final recommendations = RecommendationEngine(isar, learnerRepo, features);
    final knowledgeRepo = KnowledgeRepository(isar, vectorStore);
    final consent = AiConsentGate.instance;
    final audit = AiAuditLog(isar);
    final pipeline = AiRequestPipeline(
      auditLog: audit,
      consentGate: consent,
      firewall: const PromptFirewall(),
      ragBuilder: RagContextBuilder(vectorStore: vectorStore, consentGate: consent),
    );
    final usage = UsageTracker(isar);
    await usage.init();
    final telemetry = TelemetryService(isar);
    final breaker = CircuitBreaker();
    final health = HealthMonitor(isar, breaker);
    final llmTelemetry = LlmTelemetryRecorder(
      usageTracker: usage,
      auditLog: audit,
      telemetry: telemetry,
    );
    final orchestrator = LearningOrchestrator(
      isarService: isar,
      learnerRepository: learnerRepo,
      profileRepository: profileRepo,
      providerRepository: providerRepo,
      quizRepository: quizRepo,
      recommendationEngine: recommendations,
      vectorStore: vectorStore,
      knowledgeRepository: knowledgeRepo,
      aiPipeline: pipeline,
      telemetry: telemetry,
      circuitBreaker: breaker,
      healthMonitor: health,
      llmManager: llm,
      llmTelemetry: llmTelemetry,
    );
    final qotd = QuizOfTheDayService(
      quizRepository: quizRepo,
      learnerRepository: learnerRepo,
      orchestrator: orchestrator,
    );
    // First daily quiz only. Extra frequency slots wait for an in-app Generate tap.
    if (await qotd.hasAnyDailyQuizToday()) return;
    final id = await qotd.ensureTodaysQuiz();
    if (id != null) {
      await NotificationService.instance.notifyQuizOfTheDayReady(quizId: id);
    }
  } catch (_) {}
}

Future<void> _runDailyContent({
  required QuizRepository quizRepo,
  required LearnerRepository learnerRepo,
  required LlmManager llm,
}) async {
  try {
    final service = DailyContentService(
      quizRepository: quizRepo,
      learnerRepository: learnerRepo,
      llmManager: llm,
    );
    final hadPack = await service.findTodaysPack();
    final pack = await service.ensureTodaysContent();
    if (pack != null && hadPack == null && !await DailyContentScheduler.alreadyHandledToday()) {
      await NotificationService.instance.notifyDailyContentReady(pack: pack);
      await DailyContentScheduler.markNotifiedTodayStatic();
    }
  } catch (_) {}
}
