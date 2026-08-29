import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/ai_provider_config.dart';
import '../../data/local/models/app_settings.dart';
import '../../data/local/models/learner_profile.dart';
import '../../data/local/models/quiz_session.dart';
import '../../data/local/models/user_profile.dart';
import '../../data/local/repositories/flashcard_repository.dart';
import '../../data/local/repositories/goal_progress_repository.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/profile_repository.dart';
import '../../data/local/repositories/provider_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import '../../data/local/repositories/stats_repository.dart';
import '../../data/ml/feature_engineering_service.dart';
import '../../data/ml/recommendation_engine.dart';
import '../../data/remote/ai/learning_orchestrator.dart';
import '../../data/remote/analytics/anon_analytics_sync.dart';
import '../../data/secure/secure_key_storage.dart';
import '../../data/vector/knowledge_vector_store.dart';
import '../healing/circuit_breaker.dart';
import '../healing/health_monitor.dart';
import '../theme/app_theme.dart';
import '../personalization/ui_personalization_controller.dart';
import '../services/ai_engine_mode_store.dart';
import '../services/demo_quiz_service.dart';
import '../services/generation_job_service.dart';
import '../services/llm_manager.dart';
import '../services/quiz_of_the_day_service.dart';
import '../services/built_in_ai_quota.dart';
import '../services/whisper_stt_service.dart';
import '../services/article_bookmark_store.dart';
import '../models/provider_usage.dart';
import '../services/ad_service.dart';
import '../services/usage_tracker.dart';
import '../telemetry/telemetry_service.dart';
import '../constants/supported_languages.dart';
import '../locale/locale_utils.dart';
import '../utils/calendar_day.dart';
import 'ai_platform_providers.dart';

/// Bumped after learning/full reset so KeepAlive tabs (History/Learn/Home) reload.
final learningDataEpochProvider = StateProvider<int>((ref) => 0);

/// Local calendar day; updated on app resume when the date changes.
final calendarDayKeyProvider = StateProvider<String>((ref) => calendarDayKey());

/// Bumped on pull-to-refresh so banner/native ad widgets remount and reload.
final adRefreshEpochProvider = StateProvider<int>((ref) => 0);

final isarServiceProvider = Provider<IsarService>((ref) => IsarService.instance);

final secureKeyStorageProvider = Provider<SecureKeyStorage>((ref) => SecureKeyStorage());

final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository(ref.watch(isarServiceProvider));
});

final providerRepositoryProvider = Provider<ProviderRepository>((ref) {
  return ProviderRepository(
    ref.watch(isarServiceProvider),
    ref.watch(secureKeyStorageProvider),
  );
});

final quizRepositoryProvider = Provider<QuizRepository>((ref) {
  return QuizRepository(ref.watch(isarServiceProvider));
});

final statsRepositoryProvider = Provider<StatsRepository>((ref) {
  return StatsRepository(ref.watch(isarServiceProvider));
});

final flashcardRepositoryProvider = Provider<FlashcardRepository>((ref) {
  return FlashcardRepository(ref.watch(isarServiceProvider));
});

final flashcardsDueCountProvider =
    FutureProvider.family<int, String>((ref, goalMode) async {
  return ref.watch(flashcardRepositoryProvider).countDue(goalMode);
});

final learnerRepositoryProvider = Provider<LearnerRepository>((ref) {
  return LearnerRepository(ref.watch(isarServiceProvider));
});

final goalProgressRepositoryProvider = Provider<GoalProgressRepository>((ref) {
  return GoalProgressRepository(ref.watch(isarServiceProvider));
});

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return TelemetryService(ref.watch(isarServiceProvider));
});

final circuitBreakerProvider = Provider<CircuitBreaker>((ref) => CircuitBreaker());

final healthMonitorProvider = Provider<HealthMonitor>((ref) {
  return HealthMonitor(ref.watch(isarServiceProvider), ref.watch(circuitBreakerProvider));
});

final usageTrackerProvider = Provider<UsageTracker>((ref) {
  return UsageTracker(ref.watch(isarServiceProvider));
});

final adServiceProvider = ChangeNotifierProvider<AdService>((ref) {
  // init() registers the instance so that AdService.notifySdkReady() -
  // called from app_bootstrap after MobileAds.initialize() - can reach it.
  return AdService()..init();
});

final featureEngineeringProvider = Provider<FeatureEngineeringService>((ref) {
  return FeatureEngineeringService(
    ref.watch(isarServiceProvider),
    ref.watch(learnerRepositoryProvider),
  );
});

final recommendationEngineProvider = Provider<RecommendationEngine>((ref) {
  return RecommendationEngine(
    ref.watch(isarServiceProvider),
    ref.watch(learnerRepositoryProvider),
    ref.watch(featureEngineeringProvider),
  );
});

final vectorStoreProvider = Provider<KnowledgeVectorStore>((ref) {
  return KnowledgeVectorStore(ref.watch(isarServiceProvider));
});

final llmManagerProvider = Provider<LlmManager>((ref) {
  return LlmManager(
    providerRepository: ref.watch(providerRepositoryProvider),
  );
});

final aiEngineModeProvider = FutureProvider<AiEngineMode?>((ref) async {
  return ref.watch(llmManagerProvider).currentMode();
});

final learningOrchestratorProvider = Provider<LearningOrchestrator>((ref) {
  return LearningOrchestrator(
    isarService: ref.watch(isarServiceProvider),
    learnerRepository: ref.watch(learnerRepositoryProvider),
    profileRepository: ref.watch(profileRepositoryProvider),
    providerRepository: ref.watch(providerRepositoryProvider),
    quizRepository: ref.watch(quizRepositoryProvider),
    recommendationEngine: ref.watch(recommendationEngineProvider),
    vectorStore: ref.watch(vectorStoreProvider),
    knowledgeRepository: ref.watch(knowledgeRepositoryProvider),
    aiPipeline: ref.watch(aiRequestPipelineProvider),
    telemetry: ref.watch(telemetryServiceProvider),
    circuitBreaker: ref.watch(circuitBreakerProvider),
    healthMonitor: ref.watch(healthMonitorProvider),
    llmManager: ref.watch(llmManagerProvider),
    llmTelemetry: ref.watch(llmTelemetryProvider),
  );
});

final generationJobServiceProvider =
    ChangeNotifierProvider<GenerationJobService>((ref) {
  return GenerationJobService(
    orchestrator: ref.watch(learningOrchestratorProvider),
  );
});

final builtInQuotaProvider = FutureProvider((ref) async {
  ref.watch(generationJobServiceProvider);
  await BuiltInAiQuota.instance.restoreIfExpired();
  return BuiltInAiQuota.instance.load();
});

final anonAnalyticsSyncProvider = Provider<AnonAnalyticsSync>((ref) {
  return AnonAnalyticsSync(
    telemetry: ref.watch(telemetryServiceProvider),
    learnerRepository: ref.watch(learnerRepositoryProvider),
    secureStorage: ref.watch(secureKeyStorageProvider),
  );
});

final uiPersonalizationControllerProvider = Provider<UiPersonalizationController>((ref) {
  return UiPersonalizationController(
    ref.watch(learnerRepositoryProvider),
    ref.watch(goalProgressRepositoryProvider),
  );
});

final profileProvider = FutureProvider<UserProfile?>((ref) async {
  return ref.watch(profileRepositoryProvider).getProfile();
});

final settingsProvider = FutureProvider<AppSettings>((ref) async {
  return ref.watch(profileRepositoryProvider).getSettings();
});

final learnerProfileProvider = FutureProvider<LearnerProfile>((ref) async {
  return ref.watch(learnerRepositoryProvider).getOrCreateProfile();
});

final personalizationProvider = FutureProvider<UiPersonalizationState>((ref) async {
  final health = ref.watch(healthMonitorProvider);
  return ref.watch(uiPersonalizationControllerProvider).build(
        degradeCharts: health.degradeNonCriticalUi,
      );
});

final localeProvider = Provider<Locale>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return localeFromCode(settings?.language ?? SupportedLanguages.defaultCode);
});

final preferredAiLanguageProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return aiLanguageName(settings?.language ?? SupportedLanguages.defaultCode);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider).asData?.value;
  return switch (settings?.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

final contentDensityProvider = Provider<ContentDensity>((ref) {
  final personalization = ref.watch(personalizationProvider).asData?.value;
  return personalization?.density ?? ContentDensity.comfortable;
});

final aiProvidersProvider = FutureProvider<List<AiProviderConfig>>((ref) async {
  return ref.watch(providerRepositoryProvider).getAll();
});

final defaultAiProviderProvider = FutureProvider<AiProviderConfig?>((ref) async {
  return ref.watch(providerRepositoryProvider).getDefault();
});

final dashboardStatsProvider = FutureProvider<DashboardStats>((ref) async {
  return ref.watch(statsRepositoryProvider).getDashboardStats();
});

final playerIdProvider = FutureProvider<String>((ref) async {
  final storage = ref.watch(secureKeyStorageProvider);
  final existing = await storage.getPlayerId();
  if (existing != null && existing.isNotEmpty) return existing;
  final id = DateTime.now().microsecondsSinceEpoch.toString();
  await storage.savePlayerId(id);
  return id;
});

final nextDecisionProvider = FutureProvider<OrchestratorDecision>((ref) async {
  return ref.watch(learningOrchestratorProvider).decideNext();
});

final providerUsageProvider = FutureProvider<List<ProviderUsage>>((ref) async {
  return ref.watch(usageTrackerProvider).allUsage();
});

final activeRateLimitProvider = FutureProvider<ProviderUsage?>((ref) async {
  return ref.watch(usageTrackerProvider).activeRateLimit();
});

// aiStatusProvider is defined in lib/core/services/ai_status_service.dart

final demoQuizServiceProvider = Provider<DemoQuizService>((ref) {
  return DemoQuizService(ref.watch(quizRepositoryProvider));
});

final quizOfTheDayServiceProvider = Provider<QuizOfTheDayService>((ref) {
  return QuizOfTheDayService(
    quizRepository: ref.watch(quizRepositoryProvider),
    learnerRepository: ref.watch(learnerRepositoryProvider),
    orchestrator: ref.watch(learningOrchestratorProvider),
  );
});

final todaysDailyQuizOfferProvider = FutureProvider<DailyQuizOffer>((ref) async {
  ref.watch(calendarDayKeyProvider);
  return ref.watch(quizOfTheDayServiceProvider).loadOffer();
});

final todaysDailyQuizProvider = FutureProvider<QuizSession?>((ref) async {
  final offer = await ref.watch(todaysDailyQuizOfferProvider.future);
  // Missing session after reset/clear → treat as no QOTD (Play/Generate), not Results.
  return offer.session;
});

final whisperSttServiceProvider = Provider<WhisperSttService>((ref) {
  final service = WhisperSttService(secureStorage: ref.watch(secureKeyStorageProvider));
  ref.onDispose(service.dispose);
  return service;
});

final articleBookmarkStoreProvider =
    ChangeNotifierProvider<ArticleBookmarkStore>((ref) {
  final store = ArticleBookmarkStore.instance;
  ref.onDispose(() {});
  return store;
});
