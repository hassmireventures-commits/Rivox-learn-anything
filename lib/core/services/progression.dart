/// Streak with freezes, XP, and levels: the Duolingo-style retention loop,
/// computed purely from activity the app already stores (completed quizzes
/// and quick-question answers). No extra persisted state, so it can never
/// drift from the real history.
class StreakState {
  const StreakState({
    required this.current,
    required this.longest,
    required this.freezesBanked,
    required this.frozenDays,
    required this.activeToday,
  });

  static const StreakState empty =
      StreakState(current: 0, longest: 0, freezesBanked: 0, frozenDays: [], activeToday: false);

  final int current;
  final int longest;

  /// Freezes available to cover a future missed day.
  final int freezesBanked;

  /// Missed days a freeze covered (shown as "freeze used").
  final List<DateTime> frozenDays;
  final bool activeToday;

  /// A live streak that ends at midnight without activity today.
  bool get atRisk => current > 0 && !activeToday;
}

class LevelState {
  const LevelState({required this.level, required this.xpIntoLevel, required this.xpForNext});

  final int level;
  final int xpIntoLevel;

  /// XP needed to go from this level to the next.
  final int xpForNext;

  double get progress => xpForNext == 0 ? 0 : xpIntoLevel / xpForNext;
}

class Progression {
  Progression._();

  /// One freeze earned for every this-many consecutive active days.
  static const int daysPerFreeze = 7;
  static const int maxFreezes = 2;

  static const int xpPerQuiz = 10;
  static const int xpPerCorrectAnswer = 2;
  static const int xpPerQuickAnswer = 3;
  static const int xpPerQuickCorrect = 2;

  /// Level step: level L -> L+1 costs [levelStep] * L XP (100, 200, 300, ...).
  static const int levelStep = 100;

  static DateTime _day(DateTime d) => DateTime(d.year, d.month, d.day);

  /// Walks every calendar day from the first active day to [today]. An
  /// inactive past day spends a banked freeze if there is one (the run
  /// survives but does not grow), otherwise resets the run. Today being
  /// inactive never breaks the streak; it only makes it [StreakState.atRisk].
  static StreakState streak(Iterable<DateTime> activity, {DateTime? today}) {
    final days = activity.map(_day).toSet();
    if (days.isEmpty) return StreakState.empty;
    final now = _day(today ?? DateTime.now());
    final sorted = days.toList()..sort();
    var run = 0;
    var longest = 0;
    var freezes = 0;
    var sinceFreeze = 0;
    final frozen = <DateTime>[];
    for (var d = sorted.first; !d.isAfter(now); d = DateTime(d.year, d.month, d.day + 1)) {
      if (days.contains(d)) {
        run++;
        sinceFreeze++;
        if (sinceFreeze >= daysPerFreeze) {
          sinceFreeze = 0;
          if (freezes < maxFreezes) freezes++;
        }
        if (run > longest) longest = run;
      } else if (d != now) {
        if (run > 0 && freezes > 0) {
          freezes--;
          frozen.add(d);
        } else {
          run = 0;
          sinceFreeze = 0;
        }
      }
    }
    return StreakState(
      current: run,
      longest: longest,
      freezesBanked: freezes,
      frozenDays: frozen,
      activeToday: days.contains(now),
    );
  }

  static int xp({
    required int quizzesCompleted,
    required int correctAnswers,
    required int quickAnswers,
    required int quickCorrect,
  }) =>
      quizzesCompleted * xpPerQuiz +
      correctAnswers * xpPerCorrectAnswer +
      quickAnswers * xpPerQuickAnswer +
      quickCorrect * xpPerQuickCorrect;

  static LevelState level(int xp) {
    var level = 1;
    var remaining = xp < 0 ? 0 : xp;
    while (remaining >= levelStep * level) {
      remaining -= levelStep * level;
      level++;
    }
    return LevelState(level: level, xpIntoLevel: remaining, xpForNext: levelStep * level);
  }
}
