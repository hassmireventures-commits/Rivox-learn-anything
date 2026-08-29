import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/study_session_tracker.dart';
import 'app_providers.dart';

class TodayStudyProgress {
  const TodayStudyProgress(this.todaySeconds);

  final int todaySeconds;

  int get todayMinutes => todaySeconds ~/ 60;
}

/// Live today's study progress for the dashboard goal ring (1s tick).
class TodayStudyProgressNotifier extends Notifier<TodayStudyProgress> {
  Timer? _timer;

  @override
  TodayStudyProgress build() {
    ref.watch(calendarDayKeyProvider);
    ref.onDispose(() => _timer?.cancel());
    _scheduleTick();
    return _read();
  }

  void _scheduleTick() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => refresh());
  }

  void refresh() {
    final next = _read();
    if (next.todaySeconds != state.todaySeconds) {
      state = next;
    }
  }

  TodayStudyProgress _read() =>
      TodayStudyProgress(StudySessionTracker.instance.todaySeconds);
}

final todayStudyProgressProvider =
    NotifierProvider<TodayStudyProgressNotifier, TodayStudyProgress>(
  TodayStudyProgressNotifier.new,
);
