import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/notification_service.dart';
import '../../core/utils/calendar_day.dart';
import 'ai_status_service.dart';

/// Automatically generates today's quiz when AI becomes ready.
class DailyQuizScheduler {
  DailyQuizScheduler(this._ref);

  final Ref _ref;
  bool _running = false;
  String? _lastAttemptDate;

  Future<void> trySchedule({bool force = false, bool countBuiltinQuota = false}) async {
    if (_running) return;
    final status = _ref.read(aiStatusProvider);
    if (!status.isOnline) return;

    final today = calendarDayKey();
    final stored = await _loadLastAttempt();
    if (stored != null && stored != today) {
      _lastAttemptDate = null;
    }

    final service = _ref.read(quizOfTheDayServiceProvider);
    final existingId = await service.findTodaysQuizId();
    if (existingId != null) {
      _lastAttemptDate = today;
      return;
    }

    // Auto-generate only the first daily quiz. Extra slots (frequency 2–3)
    // wait for an explicit Generate tap so unused quota is not burned.
    if (!force && await service.hasAnyDailyQuizToday()) return;

    if (!force && stored == today && existingId != null) return;

    _running = true;
    try {
      final id = await service.ensureTodaysQuiz(countBuiltinQuota: countBuiltinQuota);
      if (id != null) {
        await _saveLastAttempt(today);
        _ref.invalidate(todaysDailyQuizOfferProvider);
        _ref.invalidate(todaysDailyQuizProvider);
        await NotificationService.instance.notifyQuizOfTheDayReady(quizId: id);
      }
    } catch (_) {
      // Retry when AI comes back online - do not mark attempt complete.
    } finally {
      _running = false;
    }
  }

  bool get isGenerating => _running;

  Future<File> _stateFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/daily_quiz_scheduler.json');
  }

  Future<String?> _loadLastAttempt() async {
    if (_lastAttemptDate != null) return _lastAttemptDate;
    try {
      final file = await _stateFile();
      if (!file.existsSync()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        _lastAttemptDate = json['lastAttempt'] as String?;
      }
    } catch (_) {}
    return _lastAttemptDate;
  }

  Future<void> _saveLastAttempt(String date) async {
    _lastAttemptDate = date;
    try {
      final file = await _stateFile();
      await file.writeAsString(jsonEncode({'lastAttempt': date}));
    } catch (_) {}
  }
}

final dailyQuizSchedulerProvider = Provider<DailyQuizScheduler>((ref) {
  final scheduler = DailyQuizScheduler(ref);
  ref.listen(aiStatusProvider, (prev, next) {
    if (next.isOnline && !(prev?.isOnline ?? false)) {
      scheduler.trySchedule();
    }
  });
  return scheduler;
});

final dailyQuizGeneratingProvider = Provider<bool>((ref) {
  ref.watch(dailyQuizSchedulerProvider);
  return ref.read(dailyQuizSchedulerProvider).isGenerating;
});
