import 'daily_goal_service.dart';

class StudySessionTracker {
  StudySessionTracker._();
  static final instance = StudySessionTracker._();

  DateTime? _sessionStart;
  int _todaySeconds = 0;
  DateTime _day = DateTime.now();

  int get todayMinutes {
    _rollDayIfNeeded();
    _accumulateElapsed();
    return _todaySeconds ~/ 60;
  }

  int get todaySeconds {
    _rollDayIfNeeded();
    _accumulateElapsed();
    return _todaySeconds;
  }

  void beginStudy() {
    _rollDayIfNeeded();
    _accumulateElapsed();
    _sessionStart ??= DateTime.now();
  }

  void endStudy() {
    _accumulateElapsed();
    _sessionStart = null;
    DailyGoalService.notifyIfGoalReached();
  }

  void _accumulateElapsed() {
    final start = _sessionStart;
    if (start == null) return;
    final elapsedSeconds = DateTime.now().difference(start).inSeconds;
    if (elapsedSeconds > 0) {
      _todaySeconds += elapsedSeconds;
      _sessionStart = DateTime.now();
    }
  }

  void _rollDayIfNeeded() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    if (_day.isBefore(today)) {
      _day = today;
      _todaySeconds = 0;
      _sessionStart = null;
    }
  }
}
