import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/providers/app_providers.dart';
import '../../core/providers/ai_platform_providers.dart';
import '../utils/calendar_day.dart';
import 'learner_memory.dart';
import 'learner_memory_service.dart';

/// Refreshes [LearnerMemorySnapshot] at most once per calendar day — mirrors
/// `DailyQuizScheduler`'s exact shape (last-attempt date in a JSON sidecar,
/// a `_running` re-entrancy guard, best-effort/never-throws) with one added
/// guard the existing daily schedulers don't need: skip while a generation
/// job is running, so this never competes with an active quiz/path/chat
/// generation for resources. A skip-because-busy does *not* mark the day as
/// done, so it's retried at the next opportunity instead of silently
/// missing a whole day.
class LearnerMemoryScheduler {
  LearnerMemoryScheduler(this._ref);

  final Ref _ref;
  bool _running = false;
  String? _lastRefreshedDate;

  bool get isRefreshing => _running;

  /// True when the day-based part of the guard says "nothing to do" —
  /// [trySchedule] separately checks `_running` and generation-busy before
  /// ever reaching this. Extracted as a pure function so the decision is
  /// unit-testable without Riverpod/Isar, same reasoning as
  /// `LearnerMemoryService.computeStreaks`.
  static bool shouldSkip({
    required bool force,
    required String? lastRefreshedDate,
    required String today,
  }) {
    if (force) return false;
    return lastRefreshedDate == today;
  }

  /// Refreshes and persists the snapshot if due (or [force]d), unless a
  /// generation job is currently busy. Never throws.
  Future<void> trySchedule({bool force = false}) async {
    if (_running) return;
    if (_ref.read(generationJobServiceProvider).isBusy) return;

    final today = calendarDayKey();
    final stored = force ? null : await _loadLastRefreshed();
    if (shouldSkip(force: force, lastRefreshedDate: stored, today: today)) return;

    _running = true;
    try {
      final service = LearnerMemoryService(
        isarService: _ref.read(isarServiceProvider),
        learnerRepository: _ref.read(learnerRepositoryProvider),
        quizRepository: _ref.read(quizRepositoryProvider),
        knowledgeRepository: _ref.read(knowledgeRepositoryProvider),
      );
      final snapshot = await service.compute();
      await _persist(snapshot);
      await _saveLastRefreshed(today);
    } catch (_) {
      // Best-effort — retried next opportunity, never surfaced to the user.
    } finally {
      _running = false;
    }
  }

  Future<LearnerMemorySnapshot?> readCached() async {
    try {
      final file = await _snapshotFile();
      if (!file.existsSync()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) return null;
      return LearnerMemorySnapshot.fromJson(json);
    } catch (_) {
      return null;
    }
  }

  Future<File> _snapshotFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/learner_memory.json');
  }

  Future<File> _stateFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/learner_memory_scheduler.json');
  }

  Future<void> _persist(LearnerMemorySnapshot snapshot) async {
    try {
      final file = await _snapshotFile();
      await file.writeAsString(jsonEncode(snapshot.toJson()));
    } catch (_) {}
  }

  Future<String?> _loadLastRefreshed() async {
    if (_lastRefreshedDate != null) return _lastRefreshedDate;
    try {
      final file = await _stateFile();
      if (!file.existsSync()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is Map<String, dynamic>) {
        _lastRefreshedDate = json['lastRefreshed'] as String?;
      }
    } catch (_) {}
    return _lastRefreshedDate;
  }

  Future<void> _saveLastRefreshed(String date) async {
    _lastRefreshedDate = date;
    try {
      final file = await _stateFile();
      await file.writeAsString(jsonEncode({'lastRefreshed': date}));
    } catch (_) {}
  }
}

final learnerMemorySchedulerProvider = Provider<LearnerMemoryScheduler>((ref) {
  return LearnerMemoryScheduler(ref);
});
