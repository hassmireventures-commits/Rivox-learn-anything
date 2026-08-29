import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/ai_provider_config.dart';
import '../../data/local/models/app_settings.dart';
import '../../data/local/models/learner_profile.dart';
import '../../data/local/models/user_profile.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/profile_repository.dart';
import '../../data/local/repositories/provider_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import '../../data/local/repositories/stats_repository.dart';
import '../../data/ml/feature_engineering_service.dart';
import '../../data/ml/recommendation_engine.dart';
import '../../data/remote/ai/learning_orchestrator.dart';
import '../../data/remote/analytics/anon_analytics_sync.dart';
import '../../data/remote/firestore/multiplayer_repository.dart';
import '../../data/secure/secure_key_storage.dart';
import '../../data/vector/local_vector_store.dart';
import '../healing/circuit_breaker.dart';
import '../healing/health_monitor.dart';
import '../personalization/ui_personalization_controller.dart';
import '../models/provider_usage.dart';
import '../services/ad_service.dart';
import '../services/usage_tracker.dart';
import '../telemetry/telemetry_service.dart';
import '../constants/supported_languages.dart';
import '../locale/locale_utils.dart';
import '../theme/app_theme.dart';

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

final learnerRepositoryProvider = Provider<LearnerRepository>((ref) {
  return LearnerRepository(ref.watch(isarServiceProvider));
});

final telemetryServiceProvider = Provider<TelemetryService>((ref) {
  return TelemetryService(ref.watch(isarServiceProvider));
});

final circuitBreakerProvider = Provider<CircuitBreaker>((ref) => CircuitBreaker());

final healthMonitorProvider = Provider<HealthMonitor>((ref) {
  return HealthMonitor(ref.watch(isarServiceProvider), ref.watch(circuitBreakerProvider));
});

final usageTrackerProvider = Provider<UsageTracker>((ref) {
  return UsageTracker();
});

final adServiceProvider = Provider<AdService>((ref) {
  final service = AdService();
  ref.onDispose(service.dispose);
  service.loadRewarded();
  return service;
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

final vectorStoreProvider = Provider<LocalVectorStore>((ref) {
  return LocalVectorStore(ref.watch(isarServiceProvider));
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
    telemetry: ref.watch(telemetryServiceProvider),
    circuitBreaker: ref.watch(circuitBreakerProvider),
    healthMonitor: ref.watch(healthMonitorProvider),
    usageTracker: ref.watch(usageTrackerProvider),
  );
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
  );
});

final multiplayerRepositoryProvider = Provider<MultiplayerRepository>((ref) {
  return MultiplayerRepository();
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
  final settings = ref.watch(settingsProvider).valueOrNull;
  return localeFromCode(settings?.language ?? SupportedLanguages.defaultCode);
});

final preferredAiLanguageProvider = Provider<String>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return aiLanguageName(settings?.language ?? SupportedLanguages.defaultCode);
});

final themeModeProvider = Provider<ThemeMode>((ref) {
  final settings = ref.watch(settingsProvider).valueOrNull;
  return switch (settings?.themeMode) {
    'light' => ThemeMode.light,
    'dark' => ThemeMode.dark,
    _ => ThemeMode.system,
  };
});

final contentDensityProvider = Provider<ContentDensity>((ref) {
  final personalization = ref.watch(personalizationProvider).valueOrNull;
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
