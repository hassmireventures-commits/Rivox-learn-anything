import 'dart:async';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../../firebase_options.dart';
import 'ad_service.dart';
import 'ads_init_service.dart';
import '../constants/ad_unit_ids.dart';
import 'app_logger.dart';
import 'exam_notification_scheduler.dart';
import 'notification_service.dart';

/// Initializes non-critical services after the first frame without blocking UI.
Future<void> initializeOptionalServices() async {
  await _runStartupStep(
    name: 'notifications',
    timeout: const Duration(seconds: 5),
    action: NotificationService.instance.init,
  );

  await _runStartupStep(
    name: 'exam_reminders',
    timeout: const Duration(seconds: 5),
    action: ExamNotificationScheduler.instance.reschedule,
  );

  if (DefaultFirebaseOptions.isConfigured) {
    await _runStartupStep(
      name: 'firebase',
      timeout: const Duration(seconds: 8),
      action: () async {
        await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform,
        );
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);

        // Firebase Analytics respects the same "help improve" opt-in as the
        // existing anonymized telemetry (anon_analytics_sync.dart) — off
        // until the learner explicitly turns it on in Settings, matching
        // this app's local-first/opt-in-by-default privacy stance. Kept in
        // sync live from settings_screen.dart's own toggle handler.
        try {
          final profile =
              await LearnerRepository(IsarService.instance).getOrCreateProfile();
          await FirebaseAnalytics.instance
              .setAnalyticsCollectionEnabled(profile.helpImproveOptIn);
        } catch (_) {
          // Best-effort — a failure here must not block the rest of startup.
        }

        AppLogger.crashSink = (tag, message, {error, stack, extras}) {
          final extrasMap = <String, Object>{
            'tag': tag,
            if (extras != null) ...extras,
          };
          FirebaseCrashlytics.instance.recordError(
            error ?? message,
            stack,
            reason: message,
            information: extrasMap.entries
                .map((e) => '${e.key}=${e.value}')
                .toList(),
            fatal: false,
          );
        };
      },
    );
  } else if (kDebugMode) {
    debugPrint('Skipping Firebase init - options not configured.');
  }

  await _runStartupStep(
    name: 'mobile_ads',
    timeout: const Duration(seconds: 35),
    action: () async {
      final canRequestAds = await AdsInitService.ensureCanRequestAds();
      if (canRequestAds) {
        AdService.notifySdkReady();
      } else if (kDebugMode) {
        debugPrint(
          'Ads not loaded - UMP consent not obtained (canRequestAds=false). '
          'Units: banner=${AdUnitIds.bannerAdUnitId} native=${AdUnitIds.nativeAdUnitId} '
          'testMode=${AdUnitIds.usingTestAds}',
        );
      }
    },
  );
}

Future<void> _runStartupStep({
  required String name,
  required Duration timeout,
  required Future<dynamic> Function() action,
}) async {
  try {
    await action().timeout(timeout);
  } catch (e, st) {
    debugPrint('Startup step "$name" failed: $e');
    debugPrint(st.toString());
  }
}
