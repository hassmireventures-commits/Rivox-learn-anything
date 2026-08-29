import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'app.dart';
import 'core/router/app_router.dart';
import 'core/debug/agent_debug_log.dart';
import 'core/services/deep_link_service.dart';
import 'core/services/notification_service.dart';
import 'core/services/reminder_preferences.dart';
import 'data/local/isar_service.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await IsarService.instance.init();
  await ReminderPreferencesStore.instance.load();
  try {
    await NotificationService.instance.init();
    // #region agent log
    AgentDebugLog.log(
      location: 'main.dart:init',
      message: 'NotificationService init ok',
      hypothesisId: 'H5',
      data: {'initialized': true},
    );
    // #endregion
  } catch (e, st) {
    // #region agent log
    AgentDebugLog.log(
      location: 'main.dart:init',
      message: 'NotificationService init failed',
      hypothesisId: 'H5',
      data: {'error': e.toString(), 'stack': st.toString().split('\n').take(3).join(' | ')},
    );
    // #endregion
  }

  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Firebase is optional until real options / google-services.json are provided.
  }

  try {
    await MobileAds.instance.initialize();
  } catch (_) {
    // Ads remain optional if the platform is not configured yet.
  }

  bindDeepLinks(appRouter);

  runApp(const ProviderScope(child: AiQuizApp()));
}
