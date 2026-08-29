import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Immutable record for a (hour, minute) time pair used for per-day overrides.
class ReminderTime {
  const ReminderTime({required this.hour, required this.minute});

  final int hour;
  final int minute;

  Map<String, dynamic> toJson() => {'hour': hour, 'minute': minute};

  factory ReminderTime.fromJson(Map<String, dynamic> json) => ReminderTime(
        hour: json['hour'] as int? ?? 19,
        minute: json['minute'] as int? ?? 0,
      );

  @override
  bool operator ==(Object other) =>
      other is ReminderTime && other.hour == hour && other.minute == minute;

  @override
  int get hashCode => Object.hash(hour, minute);
}

class ReminderPreferences {
  ReminderPreferences({
    this.dailyReminderEnabled = false,
    this.examRemindersEnabled = true,
    this.alarmMode = false,
    this.playSound = true,
    this.enableVibration = true,
    this.reminderHour = 19,
    this.reminderMinute = 0,
    this.alarmSound = 'alarm',
    this.dailyQuizFrequency = 1,
    Set<int>? activeDays,
    Map<int, ReminderTime>? perDayTimes,
  })  : activeDays = activeDays ?? {1, 2, 3, 4, 5, 6, 7},
        perDayTimes = perDayTimes ?? {};

  final bool dailyReminderEnabled;

  /// Countdown reminders at T−30/−14/−7/−1 for exam_prep.
  final bool examRemindersEnabled;

  /// When true, use exact alarm scheduling with high-priority channel.
  final bool alarmMode;

  /// Play notification sound (alarm and daily channels).
  final bool playSound;

  /// Vibrate on notification.
  final bool enableVibration;

  /// Global default reminder hour (24-h).
  final int reminderHour;

  /// Global default reminder minute.
  final int reminderMinute;

  /// Alarm / reminder sound id: alarm | urgent.
  final String alarmSound;

  /// How many daily quizzes to offer per day (1-3).
  final int dailyQuizFrequency;

  /// ISO weekdays that have reminders active: 1 = Monday … 7 = Sunday.
  /// Defaults to all seven days for backward compatibility.
  final Set<int> activeDays;

  /// Per-day time overrides. Key = ISO weekday. Falls back to global default
  /// when absent.
  final Map<int, ReminderTime> perDayTimes;

  ReminderPreferences copyWith({
    bool? dailyReminderEnabled,
    bool? examRemindersEnabled,
    bool? alarmMode,
    bool? playSound,
    bool? enableVibration,
    int? reminderHour,
    int? reminderMinute,
    String? alarmSound,
    int? dailyQuizFrequency,
    Set<int>? activeDays,
    Map<int, ReminderTime>? perDayTimes,
  }) {
    return ReminderPreferences(
      dailyReminderEnabled: dailyReminderEnabled ?? this.dailyReminderEnabled,
      examRemindersEnabled: examRemindersEnabled ?? this.examRemindersEnabled,
      alarmMode: alarmMode ?? this.alarmMode,
      playSound: playSound ?? this.playSound,
      enableVibration: enableVibration ?? this.enableVibration,
      reminderHour: reminderHour ?? this.reminderHour,
      reminderMinute: reminderMinute ?? this.reminderMinute,
      alarmSound: alarmSound ?? this.alarmSound,
      dailyQuizFrequency: (dailyQuizFrequency ?? this.dailyQuizFrequency).clamp(1, 3),
      activeDays: activeDays ?? Set.of(this.activeDays),
      perDayTimes: perDayTimes ?? Map.of(this.perDayTimes),
    );
  }

  Map<String, dynamic> toJson() => {
        'dailyReminderEnabled': dailyReminderEnabled,
        'examRemindersEnabled': examRemindersEnabled,
        'alarmMode': alarmMode,
        'playSound': playSound,
        'enableVibration': enableVibration,
        'reminderHour': reminderHour,
        'reminderMinute': reminderMinute,
        'alarmSound': alarmSound,
        'dailyQuizFrequency': dailyQuizFrequency,
        'activeDays': activeDays.toList(),
        'perDayTimes': perDayTimes.map(
          (k, v) => MapEntry(k.toString(), v.toJson()),
        ),
      };

  factory ReminderPreferences.fromJson(Map<String, dynamic> json) {
    final rawDays = json['activeDays'];
    final activeDays = rawDays is List
        ? rawDays.map((e) => e as int).toSet()
        : <int>{1, 2, 3, 4, 5, 6, 7};

    final rawPerDay = json['perDayTimes'];
    final perDayTimes = <int, ReminderTime>{};
    if (rawPerDay is Map) {
      rawPerDay.forEach((k, v) {
        final day = int.tryParse(k.toString());
        if (day != null && v is Map<String, dynamic>) {
          perDayTimes[day] = ReminderTime.fromJson(v);
        }
      });
    }

    final alarmMode = json['alarmMode'] as bool? ?? false;
    return ReminderPreferences(
      dailyReminderEnabled: json['dailyReminderEnabled'] as bool? ?? false,
      examRemindersEnabled: json['examRemindersEnabled'] as bool? ?? true,
      alarmMode: alarmMode,
      playSound: json['playSound'] as bool? ?? true,
      enableVibration: json['enableVibration'] as bool? ?? (alarmMode ? true : false),
      reminderHour: json['reminderHour'] as int? ?? 19,
      reminderMinute: json['reminderMinute'] as int? ?? 0,
      alarmSound: _normalizeAlarmSound(json['alarmSound'] as String?),
      dailyQuizFrequency: ((json['dailyQuizFrequency'] as num?)?.toInt() ?? 1).clamp(1, 3),
      activeDays: activeDays,
      perDayTimes: perDayTimes,
    );
  }
}

String _normalizeAlarmSound(String? id) {
  return switch (id) {
    'urgent' => 'urgent',
    'alarm' => 'alarm',
    _ => 'alarm',
  };
}

class ReminderPreferencesStore {
  ReminderPreferencesStore._();
  static final instance = ReminderPreferencesStore._();

  ReminderPreferences _cached = ReminderPreferences();

  ReminderPreferences get current => _cached;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/reminder_preferences.json');
  }

  Future<ReminderPreferences> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return _cached;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        _cached = ReminderPreferences.fromJson(json);
      }
    } catch (_) {}
    return _cached;
  }

  Future<void> save(ReminderPreferences prefs) async {
    _cached = prefs;
    final file = await _file();
    await file.writeAsString(jsonEncode(prefs.toJson()));
  }
}
