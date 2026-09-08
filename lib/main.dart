import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'core/services/app_bootstrap.dart';
import 'core/services/app_logger.dart';
import 'core/services/background_daily_tasks.dart';
import 'core/services/deep_link_handler.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_preferences.dart';
import 'core/services/secondary_goals_store.dart';
import 'core/services/article_bookmark_store.dart';
import 'data/local/isar_service.dart';
import 'data/local/repositories/goal_progress_repository.dart';
import 'core/ai_platform/ai_consent_gate.dart';
import 'core/ai_platform/ai_policy_registry.dart';
import 'core/services/readiness_zero_migration.dart';
import 'core/services/library_rag_consent_migration.dart';
import 'core/services/usage_tracker.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Crash reporting: debugPrint sink until Firebase/Crashlytics is ready
  // (initializeOptionalServices replaces this with Crashlytics).
  AppLogger.crashSink ??= (tag, message, {error, stack, extras}) {
    if (kDebugMode) {
      debugPrint('[CrashSink][$tag] $message${error != null ? ' | $error' : ''}');
    }
  };
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    AppLogger.error(
      'FlutterError',
      details.exceptionAsString(),
      details.exception,
      details.stack,
    );
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    AppLogger.error('PlatformError', '$error', error, stack);
    return true;
  };

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await IsarService.instance.init();
  await ReadinessZeroMigration.runIfNeeded(
    GoalProgressRepository(IsarService.instance),
  );
  await AiConsentGate.instance.load();
  await LibraryRagConsentMigration.runIfNeeded(IsarService.instance);
  await ReminderPreferencesStore.instance.load();
  await SecondaryGoalsStore.instance.load();
  await ArticleBookmarkStore.instance.load();
  await AiPolicyRegistry.load();
  await UsageTracker(IsarService.instance).init();

  NotificationService.instance.bindRouter(appRouter);
  DeepLinkHandler.instance.bindRouter(appRouter);
  unawaited(DeepLinkHandler.instance.start());

  runApp(const ProviderScope(child: AiQuizApp()));

  unawaited(initializeOptionalServices().then((_) {
    return BackgroundDailyTasks.register();
  }));
}
