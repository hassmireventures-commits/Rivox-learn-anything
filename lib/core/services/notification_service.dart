import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:isar_community/isar.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:url_launcher/url_launcher.dart';
import '../locale/app_localizations_ext.dart';
import '../../l10n/app_localizations.dart';
import '../../data/local/isar_service.dart';
import '../../data/local/models/quiz_session.dart';
import 'daily_content_service.dart';
import 'daily_content_scheduler.dart';
import 'notification_history_store.dart';
import 'reminder_preferences.dart';

typedef NotificationNavigate = void Function(String route);

class NotificationService {
  NotificationService._();
  static final instance = NotificationService._();

  static const dailyReminderId = 1001;
  static const goalReachedId = 9001;
  static const snoozeReminderId = 9002;
  static const quizOfTheDayId = 2001;
  static const examReminderBaseId = 3000;
  static const examReminderDebugPreviewId = 3099;
  static const mockDueReminderId = 3100;
  static const generationReadyId = 4100;
  static const generationFailedId = 4101;
  static const dailyContentId = 2100;

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  GoRouter? _router;
  String _lastReminderLanguageCode = 'en';

  void bindRouter(GoRouter router) => _router = router;

  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.status;
    if (status.isGranted) return true;
    final result = await Permission.notification.request();
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final flnGranted = await androidPlugin?.requestNotificationsPermission();
    return result.isGranted || flnGranted == true;
  }

  /// Shows rationale (optional), requests system permission, or opens settings if blocked.
  Future<bool> ensureNotificationPermission(
    BuildContext context, {
    bool showRationale = true,
  }) async {
    var status = await Permission.notification.status;
    if (status.isGranted) return true;

    if (status.isPermanentlyDenied) {
      if (!context.mounted) return false;
      final l10n = context.l10n;
      final open = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.settingsReminderPermissionTitle),
          content: Text(l10n.settingsReminderPermissionPermanentlyDenied),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.settingsReminderPermissionOpenSettings),
            ),
          ],
        ),
      );
      if (open == true) await openAppSettings();
      return false;
    }

    if (showRationale && context.mounted) {
      final l10n = context.l10n;
      final proceed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.settingsReminderPermissionTitle),
          content: Text(l10n.settingsReminderPermissionRationale),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.settingsReminderPermissionContinue),
            ),
          ],
        ),
      );
      if (proceed != true) return false;
    }

    final granted = await requestNotificationPermission();
    if (!granted) {
      status = await Permission.notification.status;
      if (status.isPermanentlyDenied && context.mounted) {
        return ensureNotificationPermission(context, showRationale: false);
      }
    }
    return granted;
  }

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    try {
      final tzInfo = await FlutterTimezone.getLocalTimezone();
      tz.setLocalLocation(tz.getLocation(tzInfo.identifier));
    } catch (_) {}

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final ios = DarwinInitializationSettings(
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          'study_reminder',
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain('dismiss', 'Dismiss'),
            DarwinNotificationAction.plain('snooze', 'Snooze 10 min'),
          ],
        ),
      ],
    );
    await _plugin.initialize(
      settings: InitializationSettings(android: android, iOS: ios),
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    const qotdChannel = AndroidNotificationChannel(
      'quiz_of_the_day',
      'Quiz of the day',
      description: 'Daily quiz challenge notifications',
      importance: Importance.defaultImportance,
    );
    const examChannel = AndroidNotificationChannel(
      'exam_countdown',
      'Exam countdown',
      description: 'Reminders as your exam date approaches',
      importance: Importance.high,
    );
    const generationChannel = AndroidNotificationChannel(
      'content_generation',
      'Content generation',
      description: 'Quiz and learning path ready notifications',
      importance: Importance.high,
    );
    const dailyContentChannel = AndroidNotificationChannel(
      'daily_content',
      'Daily learning pick',
      description: 'Daily article or video recommendations',
      importance: Importance.defaultImportance,
    );
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(qotdChannel);
    await androidPlugin?.createNotificationChannel(examChannel);
    await androidPlugin?.createNotificationChannel(generationChannel);
    await androidPlugin?.createNotificationChannel(dailyContentChannel);
    await _deleteObsoleteAndroidChannels();

    _initialized = true;
    await ReminderPreferencesStore.instance.load();
    await _ensureCurrentSoundChannels();
    await scheduleDailyReminder();
  }

  /// Legacy unsuffixed channels kept the first-registered (often silent) sound.
  static const _obsoleteAndroidChannelIds = ['study_alarm', 'daily_study'];

  Future<void> _deleteObsoleteAndroidChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;
    for (final id in _obsoleteAndroidChannelIds) {
      try {
        await androidPlugin.deleteNotificationChannel(channelId: id);
      } catch (_) {}
    }
  }

  Future<void> _ensureCurrentSoundChannels() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin == null) return;
    final soundId = ReminderPreferencesStore.instance.current.alarmSound;
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        'study_alarm_$soundId',
        'Study alarms',
        description: 'Exact-time study alarms with sound',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        sound: _androidSoundFor(soundId),
      ),
    );
    await androidPlugin.createNotificationChannel(
      AndroidNotificationChannel(
        'daily_study_$soundId',
        'Daily study reminders',
        description: 'Reminders to reach your daily learning goal',
        importance: Importance.high,
      ),
    );
  }

  void _onNotificationTap(NotificationResponse response) {
    unawaited(_handleNotificationTap(response));
  }

  Future<void> _handleNotificationTap(NotificationResponse response) async {
    if (response.actionId == 'dismiss') {
      await dismissStudyReminderNotification(response.id);
      return;
    }
    if (response.actionId == 'snooze') {
      await scheduleSnoozeReminder();
      return;
    }
    final payload = response.payload;
    if (payload != null &&
        (payload.startsWith('http://') || payload.startsWith('https://'))) {
      final uri = Uri.tryParse(payload);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
      return;
    }
    if (payload != null && payload.startsWith('/')) {
      final route = await _resolveNotificationRoute(payload);
      if (route == '/daily-content') {
        await DailyContentScheduler.markOpenedTodayStatic();
      }
      await _navigateFromNotification(route);
      return;
    }
    if (payload != null && payload.isNotEmpty) {
      final route = await _resolveNotificationRoute('/quiz/play/$payload');
      await _navigateFromNotification(route);
      return;
    }
    _router?.go('/dashboard');
  }

  /// Detail routes opened from notifications need the dashboard shell underneath
  /// so the system back gesture returns home instead of exiting the app.
  Future<void> _navigateFromNotification(String route) async {
    final router = _router;
    if (router == null) return;
    final needsShell = route == '/daily-content' ||
        route.startsWith('/quiz/') ||
        route.startsWith('/paths/');
    if (needsShell) {
      router.go('/dashboard');
      await Future<void>.delayed(Duration.zero);
      router.push(route);
    } else {
      router.go(route);
    }
  }

  Future<void> cancelDailyContentNotification() async {
    if (!_initialized) return;
    await _plugin.cancel(id: dailyContentId);
  }

  /// If the quiz is already finished, open results instead of replaying.
  Future<String> _resolveNotificationRoute(String route) async {
    if (!route.startsWith('/quiz/play/')) return route;
    try {
      final query = route.contains('?') ? route.substring(route.indexOf('?')) : '';
      final pathOnly = route.split('?').first;
      final quizId = pathOnly.replaceFirst('/quiz/play/', '');
      if (quizId.isEmpty) return route;
      final session = await IsarService.instance.db.quizSessions
          .filter()
          .uuidEqualTo(quizId)
          .findFirst();
      if (session?.completedAt != null) {
        return '/quiz/results/$quizId$query';
      }
    } catch (_) {}
    return route;
  }

  /// Stops the active study alarm/reminder and re-arms weekly schedules.
  Future<void> dismissStudyReminderNotification(int? notificationId) async {
    if (!_initialized) return;
    if (notificationId != null) {
      await _plugin.cancel(id: notificationId);
    }
    await _plugin.cancel(id: snoozeReminderId);
    await scheduleDailyReminder(languageCode: _lastReminderLanguageCode);
  }

  Future<void> scheduleSnoozeReminder() async {
    if (!_initialized) return;
    final l10n = lookupAppLocalizations(Locale(_lastReminderLanguageCode));
    final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(minutes: 10));
    await _plugin.zonedSchedule(
      id: snoozeReminderId,
      title: l10n.settingsReminderNotifTitleAlarm,
      body: l10n.settingsReminderNotifBodyDefault,
      scheduledDate: scheduled,
      notificationDetails: _dailyNotificationDetails(alarmMode: true, l10n: l10n),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: '/dashboard',
    );
  }

  NotificationDetails _dailyNotificationDetails({
    required bool alarmMode,
    required AppLocalizations l10n,
  }) {
    final prefs = ReminderPreferencesStore.instance.current;
    final playSound = prefs.playSound;
    final vibrate = prefs.enableVibration;
    final soundId = prefs.alarmSound;
    final androidSound = _androidSoundFor(soundId);
    // Channel id includes sound so Android applies a new sound after the user changes it.
    if (alarmMode) {
      return NotificationDetails(
        android: AndroidNotificationDetails(
          'study_alarm_$soundId',
          'Study alarms',
          channelDescription: 'Exact-time study alarms with sound',
          importance: Importance.max,
          priority: Priority.max,
          playSound: playSound,
          enableVibration: vibrate,
          sound: playSound ? androidSound : null,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          actions: _studyReminderAndroidActions(l10n),
        ),
        iOS: DarwinNotificationDetails(
          presentSound: playSound,
          sound: playSound ? _iosSoundFor(soundId) : null,
          interruptionLevel: InterruptionLevel.timeSensitive,
          categoryIdentifier: 'study_reminder',
        ),
      );
    }
    return NotificationDetails(
      android: AndroidNotificationDetails(
        'daily_study_$soundId',
        'Daily study reminders',
        channelDescription: 'Reminders to reach your daily learning goal',
        importance: Importance.high,
        priority: Priority.high,
        playSound: playSound,
        enableVibration: vibrate,
        sound: playSound ? androidSound : null,
        actions: _studyReminderAndroidActions(l10n),
      ),
      iOS: DarwinNotificationDetails(
        presentSound: playSound,
        sound: playSound ? _iosSoundFor(soundId) : null,
        categoryIdentifier: 'study_reminder',
      ),
    );
  }

  List<AndroidNotificationAction> _studyReminderAndroidActions(AppLocalizations l10n) {
    return <AndroidNotificationAction>[
      AndroidNotificationAction(
        'dismiss',
        l10n.commonDismiss,
        showsUserInterface: false,
      ),
      AndroidNotificationAction(
        'snooze',
        l10n.settingsReminderNotifActionSnooze,
        showsUserInterface: false,
      ),
    ];
  }

  static const _alarmPreviewNotificationId = 21999;

  /// Plays a short notification using the selected alarm sound (preview).
  Future<void> previewAlarmSound(String soundId) async {
    if (!_initialized) await init();
    await requestNotificationPermission();
    await _plugin.cancel(id: _alarmPreviewNotificationId);
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    final channelId = 'alarm_preview_$soundId';
    final androidSound = _androidSoundFor(soundId);
    if (androidPlugin != null) {
      try {
        await androidPlugin.deleteNotificationChannel(channelId: channelId);
      } catch (_) {}
      await androidPlugin.createNotificationChannel(
        AndroidNotificationChannel(
          channelId,
          'Alarm sound preview',
          description: 'Preview study alarm sounds',
          importance: Importance.max,
          playSound: true,
          sound: androidSound,
        ),
      );
    }
    await _plugin.show(
      id: _alarmPreviewNotificationId,
      title: ' ',
      body: ' ',
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          channelId,
          'Alarm sound preview',
          channelDescription: 'Preview study alarm sounds',
          importance: Importance.max,
          priority: Priority.max,
          playSound: true,
          sound: androidSound,
          audioAttributesUsage: AudioAttributesUsage.alarm,
          category: AndroidNotificationCategory.alarm,
          onlyAlertOnce: true,
        ),
        iOS: DarwinNotificationDetails(
          presentSound: true,
          sound: _iosSoundFor(soundId),
          interruptionLevel: InterruptionLevel.timeSensitive,
        ),
      ),
    );
  }

  Future<void> cancelAlarmSoundPreview() async {
    if (!_initialized) return;
    await _plugin.cancel(id: _alarmPreviewNotificationId);
  }

  static AndroidNotificationSound? _androidSoundFor(String soundId) {
    return switch (soundId) {
      'alarm' => UriAndroidNotificationSound('content://settings/system/alarm_alert'),
      'urgent' => UriAndroidNotificationSound('content://settings/system/ringtone'),
      _ => UriAndroidNotificationSound('content://settings/system/alarm_alert'),
    };
  }

  static String _iosSoundFor(String soundId) {
    return switch (soundId) {
      'urgent' => 'default',
      _ => 'alarm.caf',
    };
  }

  /// Requests exact-alarm capability for alarm-mode reminders. Returns false if denied.
  Future<bool> ensureExactAlarmPermission() async {
    final status = await Permission.scheduleExactAlarm.status;
    if (status.isGranted) return true;
    final result = await Permission.scheduleExactAlarm.request();
    return result.isGranted;
  }

  Future<AndroidScheduleMode> _androidScheduleMode({required bool alarmMode}) async {
    if (!alarmMode) return AndroidScheduleMode.inexactAllowWhileIdle;
    final exact = await ensureExactAlarmPermission();
    return exact
        ? AndroidScheduleMode.exactAllowWhileIdle
        : AndroidScheduleMode.inexactAllowWhileIdle;
  }

  Future<void> scheduleDailyReminder({
    List<String>? weakTopics,
    String? languageCode,
  }) async {
    if (!_initialized) return;
    await _deleteObsoleteAndroidChannels();
    await _ensureCurrentSoundChannels();
    final prefs = ReminderPreferencesStore.instance.current;

    // Cancel legacy single-slot and all seven per-day slots.
    await _plugin.cancel(id: dailyReminderId);
    for (var d = 1; d <= 7; d++) {
      await _plugin.cancel(id: dailyReminderId + d);
    }

    if (!prefs.dailyReminderEnabled || prefs.activeDays.isEmpty) return;

    tz.TZDateTime now;
    try {
      now = tz.TZDateTime.now(tz.local);
    } catch (_) {
      return;
    }

    final resolvedLanguage = languageCode ?? 'en';
    _lastReminderLanguageCode = resolvedLanguage;
    final l10n = lookupAppLocalizations(Locale(resolvedLanguage));
    final scheduleMode = await _androidScheduleMode(alarmMode: prefs.alarmMode);

    for (final day in prefs.activeDays) {
      final override = prefs.perDayTimes[day];
      final h = override?.hour ?? prefs.reminderHour;
      final m = override?.minute ?? prefs.reminderMinute;
      final scheduled = _nextOccurrenceForWeekday(now, day, h, m);
      final alarmMode = prefs.alarmMode;

      await _plugin.zonedSchedule(
        id: dailyReminderId + day,
        title: alarmMode
            ? l10n.settingsReminderNotifTitleAlarm
            : l10n.settingsReminderNotifTitleDaily,
        body: _motivationalBody(l10n, day, weakTopics),
        scheduledDate: scheduled,
        notificationDetails: _dailyNotificationDetails(alarmMode: alarmMode, l10n: l10n),
        androidScheduleMode: scheduleMode,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: '/dashboard',
      );
    }
  }

  /// Returns the next [tz.TZDateTime] that falls on [isoWeekday] (1=Mon…7=Sun)
  /// at [hour]:[minute]. Always returns a future moment.
  tz.TZDateTime _nextOccurrenceForWeekday(
    tz.TZDateTime now,
    int isoWeekday,
    int hour,
    int minute,
  ) {
    // Dart DateTime.weekday matches ISO 8601: 1=Monday, 7=Sunday.
    var candidate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    // Advance day-by-day until we land on the requested weekday in the future.
    while (candidate.weekday != isoWeekday || !candidate.isAfter(now)) {
      candidate = candidate.add(const Duration(days: 1));
    }
    return candidate;
  }

  /// Returns a varied motivational body that optionally mentions a weak topic.
  String _motivationalBody(
    AppLocalizations l10n,
    int isoWeekday,
    List<String>? weakTopics,
  ) {
    if (weakTopics != null && weakTopics.isNotEmpty) {
      final topic = weakTopics[isoWeekday % weakTopics.length];
      return l10n.settingsReminderNotifBodyWeak(topic);
    }
    return l10n.settingsReminderNotifBodyDefault;
  }

  // ---------------------------------------------------------------------------
  // Quiz of the day
  // ---------------------------------------------------------------------------

  Future<void> scheduleQuizOfTheDayReminder({String? quizId}) async {
    await notifyQuizOfTheDayReady(quizId: quizId);
  }

  Future<void> _recordHistory({
    required String kind,
    required String title,
    required String body,
    String payload = '',
  }) async {
    try {
      await NotificationHistoryStore.instance.add(
        kind: kind,
        title: title,
        body: body,
        payload: payload,
      );
    } catch (_) {}
  }

  /// Shows an immediate local notification when today's quiz is ready.
  Future<void> notifyQuizOfTheDayReady({String? quizId}) async {
    if (!_initialized) {
      await init();
    }
    if (!_initialized) return;
    await requestNotificationPermission();
    const title = "Today's quiz is ready";
    const body = "Tap to take today's quick challenge.";
    await _plugin.cancel(id: quizOfTheDayId);
    await _plugin.show(
      id: quizOfTheDayId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'quiz_of_the_day',
          'Quiz of the day',
          channelDescription: 'Daily quiz challenge notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: quizId,
    );
    // QOTD stays as OS push only — not listed in History Daily study.
  }

  Future<void> notifyGenerationReady({
    required String title,
    required String body,
    required String route,
  }) async {
    if (!_initialized) {
      await init();
    }
    if (!_initialized) return;
    await requestNotificationPermission();
    await _plugin.show(
      id: generationReadyId,
      title: title,
      body: body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'content_generation',
          'Content generation',
          channelDescription: 'Quiz and learning path ready notifications',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: route,
    );
    // Generation stays as OS push only — not listed in History Daily study.
  }

  /// Daily article + video pack ready — opens in-app detail.
  ///
  /// [pack] is the validated pack; History stores a snapshot so older rows open
  /// those URLs in-app instead of always loading today's file.
  Future<void> notifyDailyContentReady({
    DailyContentPack? pack,
    DailyContentItem? item,
    String? title,
    String? body,
    String? languageCode,
  }) async {
    if (!_initialized) {
      await init();
    }
    if (!_initialized) return;
    await requestNotificationPermission();
    final l10n = lookupAppLocalizations(Locale(languageCode ?? 'en'));
    final t = title ?? l10n.dailyContentReadyTitle;
    final b = body ?? l10n.dailyContentReadyBody;
    const route = '/daily-content';
    final snapshotPack = pack ??
        (item != null
            ? DailyContentPack(
                dateKey: item.dateKey,
                topic: item.topic,
                article: item.type == 'article' ? item : null,
                video: item.type == 'video' ? item : null,
              )
            : null);
    final historyPayload = snapshotPack != null
        ? NotificationHistoryItem.payloadForPack(snapshotPack)
        : route;
    await _plugin.cancel(id: dailyContentId);
    await _plugin.show(
      id: dailyContentId,
      title: t,
      body: b,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_content',
          'Daily learning pick',
          channelDescription: 'Daily article or video recommendations',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      // Plugin payload must remain a simple route string.
      payload: route,
    );
    await _recordHistory(kind: 'content', title: t, body: b, payload: historyPayload);
  }

  Future<void> notifyGenerationFailed({
    required String title,
    required String body,
  }) async {
    if (!_initialized) {
      await init();
    }
    if (!_initialized) return;
    await _plugin.show(
      id: generationFailedId,
      title: title,
      body: body.length > 120 ? '${body.substring(0, 120)}…' : body,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'content_generation',
          'Content generation',
          channelDescription: 'Quiz and learning path ready notifications',
          importance: Importance.defaultImportance,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      payload: '/dashboard',
    );
  }

  // ---------------------------------------------------------------------------
  // Goal reached
  // ---------------------------------------------------------------------------

  Future<void> showGoalReached() async {
    if (!_initialized) return;
    final l10n = lookupAppLocalizations(Locale(_lastReminderLanguageCode));
    await _plugin.show(
      id: goalReachedId,
      title: 'Daily goal reached!',
      body: 'Great work today. Come back tomorrow to keep learning.',
      notificationDetails: _dailyNotificationDetails(alarmMode: false, l10n: l10n),
    );
  }

  // ---------------------------------------------------------------------------
  // Exam countdown (T−30 / −14 / −7 / −1) + mock-due
  // ---------------------------------------------------------------------------

  Future<void> cancelExamReminders() async {
    if (!_initialized) return;
    for (final offset in [30, 14, 7, 1]) {
      await _plugin.cancel(id: examReminderBaseId + offset);
    }
    await _plugin.cancel(id: examReminderDebugPreviewId);
    await _plugin.cancel(id: mockDueReminderId);
  }

  Future<void> scheduleExamCountdownReminders({
    required DateTime examDate,
    required String examName,
    required int reminderHour,
    required int reminderMinute,
  }) async {
    if (!_initialized) return;
    await cancelExamReminders();

    tz.TZDateTime now;
    try {
      now = tz.TZDateTime.now(tz.local);
    } catch (_) {
      return;
    }

    final examDay = DateTime(examDate.year, examDate.month, examDate.day);

    for (final daysBefore in [30, 14, 7, 1]) {
      final targetDay = examDay.subtract(Duration(days: daysBefore));
      final scheduled = tz.TZDateTime(
        tz.local,
        targetDay.year,
        targetDay.month,
        targetDay.day,
        reminderHour,
        reminderMinute,
      );
      if (!scheduled.isAfter(now)) continue;

      final (title, body) = _examCountdownCopy(
        daysBefore: daysBefore,
        examName: examName,
      );

      await _plugin.zonedSchedule(
        id: examReminderBaseId + daysBefore,
        title: title,
        body: body,
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'exam_countdown',
            'Exam countdown',
            channelDescription: 'Reminders as your exam date approaches',
            importance: Importance.high,
            priority: Priority.high,
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
    }
  }

  /// Debug-only preview so T−7 copy can be verified without waiting.
  Future<void> scheduleExamCountdownDebugPreview({required String examName}) async {
    if (!_initialized || !kDebugMode) return;
    await _plugin.cancel(id: examReminderDebugPreviewId);
    final scheduled = tz.TZDateTime.now(tz.local).add(const Duration(seconds: 8));
    final copy = _examCountdownCopy(daysBefore: 7, examName: examName);
    await _plugin.zonedSchedule(
      id: examReminderDebugPreviewId,
      title: '${copy.$1} (debug)',
      body: copy.$2,
      scheduledDate: scheduled,
      notificationDetails: const NotificationDetails(
        android: AndroidNotificationDetails(
          'exam_countdown',
          'Exam countdown',
          channelDescription: 'Reminders as your exam date approaches',
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> scheduleMockDueReminders({
    required List<DateTime> mockDays,
    required String examName,
    required int reminderHour,
    required int reminderMinute,
  }) async {
    if (!_initialized) return;
    await _plugin.cancel(id: mockDueReminderId);
    if (mockDays.isEmpty) return;

    tz.TZDateTime now;
    try {
      now = tz.TZDateTime.now(tz.local);
    } catch (_) {
      return;
    }

    for (final day in mockDays) {
      final scheduled = tz.TZDateTime(
        tz.local,
        day.year,
        day.month,
        day.day,
        reminderHour,
        reminderMinute,
      );
      if (!scheduled.isAfter(now)) continue;

      await _plugin.zonedSchedule(
        id: mockDueReminderId,
        title: 'Mock exam scheduled',
        body: 'Your study plan includes a timed mock today for $examName.',
        scheduledDate: scheduled,
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'exam_countdown',
            'Exam countdown',
            channelDescription: 'Reminders as your exam date approaches',
          ),
          iOS: DarwinNotificationDetails(),
        ),
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
      );
      break;
    }
  }

  (String, String) _examCountdownCopy({
    required int daysBefore,
    required String examName,
  }) {
    return switch (daysBefore) {
      1 => ('Exam tomorrow', 'Your exam is tomorrow - $examName. Rest well and review lightly.'),
      7 => ('One week to go', '7 days until $examName. Stick to your study plan and sit a mock.'),
      14 => ('Two weeks left', '14 days until $examName. Focus on weak syllabus units.'),
      _ => ('Exam countdown', '$daysBefore days until $examName. Keep your daily study rhythm.'),
    };
  }
}
