import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/notification_service.dart';
import 'ai_status_service.dart';
import 'daily_content_service.dart';
import 'generation_job_service.dart';

/// Generates today's learning pick once per day when missing.
class DailyContentScheduler {
  DailyContentScheduler(this._ref);

  final Ref _ref;
  bool _running = false;
  bool _tryScheduleLock = false;
  String? _lastAttemptDate;
  String? _lastNotifiedDate;
  String? _lastOpenedDate;

  static String dateKey(DateTime dt) => '${dt.year}-${dt.month}-${dt.day}';

  static Future<File> stateFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/daily_content_scheduler.json');
  }

  /// Background-safe: true when today's pick was already notified or opened.
  static Future<bool> alreadyHandledToday() async {
    final today = dateKey(DateTime.now());
    try {
      final file = await stateFile();
      if (!await file.exists()) return false;
      final json = jsonDecode(await file.readAsString());
      if (json is! Map) return false;
      final notified = json['lastNotified'] as String?;
      final opened = json['lastOpened'] as String?;
      return notified == today || opened == today;
    } catch (_) {
      return false;
    }
  }

  /// Background-safe: persist notify dedupe without a Riverpod ref.
  static Future<void> markNotifiedTodayStatic() async {
    final today = dateKey(DateTime.now());
    try {
      final file = await stateFile();
      Map<String, dynamic> map = {};
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map) map = Map<String, dynamic>.from(decoded);
      }
      map['lastNotified'] = today;
      map['lastAttempt'] ??= today;
      await file.writeAsString(jsonEncode(map));
    } catch (_) {}
  }

  /// Background-safe: cancel OS notification + stop same-day re-notify.
  static Future<void> markOpenedTodayStatic() async {
    final today = dateKey(DateTime.now());
    try {
      final file = await stateFile();
      Map<String, dynamic> map = {};
      if (await file.exists()) {
        final decoded = jsonDecode(await file.readAsString());
        if (decoded is Map) map = Map<String, dynamic>.from(decoded);
      }
      map['lastOpened'] = today;
      map['lastAttempt'] ??= today;
      await file.writeAsString(jsonEncode(map));
    } catch (_) {}
    await NotificationService.instance.cancelDailyContentNotification();
  }

  Future<void> trySchedule({bool force = false}) async {
    if (_running || _tryScheduleLock) return;

    final genJob = _ref.read(generationJobServiceProvider);
    if (genJob.isBusy && genJob.kind == GenerationJobKind.dailyContent) return;

    _tryScheduleLock = true;
    try {
      final today = dateKey(DateTime.now());
      final existing = await _ref.read(dailyContentServiceProvider).findTodaysPack();
      if (existing != null) {
        _lastAttemptDate = today;
        await _saveLastAttempt(today);
        // Pack already exists — do not re-show the OS notification on every launch.
        return;
      }

      final stored = await _loadLastAttempt();
      if (!force && stored == today) return;

      _running = true;
      try {
        final pack = await _ref.read(dailyContentServiceProvider).ensureTodaysContent();
        if (pack != null) {
          await _saveLastAttempt(today);
          if (!await alreadyHandledToday()) {
            await NotificationService.instance.notifyDailyContentReady(pack: pack);
            await _saveLastNotified(today);
          }
        }
      } catch (_) {
        // Retry on next open, dashboard refresh, or manual generate.
      } finally {
        _running = false;
      }
    } finally {
      _tryScheduleLock = false;
    }
  }

  bool get isGenerating => _running;

  /// Call when the user opens today's learning pack so we stop re-notifying.
  Future<void> markOpenedToday() async {
    final today = dateKey(DateTime.now());
    _lastOpenedDate = today;
    await _writeState();
    await NotificationService.instance.cancelDailyContentNotification();
  }

  /// Clears same-day attempt memory + file (call after learning reset).
  Future<void> resetAttemptState() async {
    _running = false;
    _lastAttemptDate = null;
    _lastNotifiedDate = null;
    _lastOpenedDate = null;
    try {
      final file = await _stateFile();
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }

  Future<File> _stateFile() => stateFile();

  Future<String?> _loadLastAttempt() async {
    if (_lastAttemptDate != null) return _lastAttemptDate;
    try {
      final file = await _stateFile();
      if (!await file.exists()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        _lastAttemptDate = json['lastAttempt'] as String?;
        _lastNotifiedDate = json['lastNotified'] as String?;
        _lastOpenedDate = json['lastOpened'] as String?;
      }
    } catch (_) {}
    return _lastAttemptDate;
  }

  Future<void> _saveLastAttempt(String date) async {
    _lastAttemptDate = date;
    await _writeState();
  }

  Future<void> _saveLastNotified(String date) async {
    _lastNotifiedDate = date;
    await _writeState();
  }

  Future<void> _writeState() async {
    try {
      final file = await _stateFile();
      await file.writeAsString(
        jsonEncode({
          'lastAttempt': _lastAttemptDate,
          'lastNotified': _lastNotifiedDate,
          'lastOpened': _lastOpenedDate,
        }),
      );
    } catch (_) {}
  }
}

final dailyContentServiceProvider = Provider<DailyContentService>((ref) {
  return DailyContentService(
    quizRepository: ref.watch(quizRepositoryProvider),
    learnerRepository: ref.watch(learnerRepositoryProvider),
    llmManager: ref.watch(llmManagerProvider),
  );
});

final dailyContentSchedulerProvider = Provider<DailyContentScheduler>((ref) {
  final scheduler = DailyContentScheduler(ref);
  ref.listen(aiStatusProvider, (prev, next) {
    if (next.isOnline && !(prev?.isOnline ?? false)) {
      scheduler.trySchedule();
    }
  });
  return scheduler;
});
