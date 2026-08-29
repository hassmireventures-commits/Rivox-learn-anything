import 'package:isar_community/isar.dart';

import '../isar_service.dart';
import '../models/daily_stat.dart';
import '../models/quiz_session.dart';

class DashboardStats {
  const DashboardStats({
    required this.quizzesAttempted,
    required this.accuracy,
    required this.averageScore,
    required this.topicsCovered,
    required this.totalQuestionsSolved,
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyActivity,
    required this.activityTrend,
    required this.difficultyDistribution,
    required this.topicBreakdown,
    required this.recentQuizzes,
  });

  final int quizzesAttempted;
  final double accuracy;
  final double averageScore;
  final int topicsCovered;
  final int totalQuestionsSolved;
  final int currentStreak;
  final int longestStreak;
  final List<WeeklyPoint> weeklyActivity;
  final List<WeeklyPoint> activityTrend;
  final Map<String, int> difficultyDistribution;
  final Map<String, int> topicBreakdown;
  final List<QuizSession> recentQuizzes;
}

class WeeklyPoint {
  const WeeklyPoint(this.label, this.count, {this.date});

  final String label;
  final int count;

  /// Calendar day for localized chart labels (Mon, Tue, …).
  final DateTime? date;
}

class StatsRepository {
  StatsRepository(this._isarService);

  final IsarService _isarService;
  Isar get _db => _isarService.db;

  Future<void> recordCompletion(QuizSession session) async {
    final now = session.completedAt ?? DateTime.now();
    final dateKey = _dateKey(now);
    var stat = await _db.dailyStats.filter().dateKeyEqualTo(dateKey).findFirst();
    stat ??= DailyStat()
      ..dateKey = dateKey
      ..date = DateTime(now.year, now.month, now.day)
      ..quizzesCount = 0
      ..questionsSolved = 0
      ..correctCount = 0
      ..accuracySum = 0
      ..totalTimeSeconds = 0;

    stat
      ..quizzesCount += 1
      ..questionsSolved += session.questionCount
      ..correctCount += session.correctCount ?? 0
      ..accuracySum += session.accuracy ?? 0
      ..totalTimeSeconds += session.timeTakenSeconds ?? 0;

    await _db.writeTxn(() async {
      await _db.dailyStats.put(stat!);
    });
  }

  Future<DashboardStats> getDashboardStats() async {
    final completed = await _db.quizSessions
        .filter()
        .completedAtIsNotNull()
        .sortByCompletedAtDesc()
        .findAll();

    if (completed.isEmpty) {
      return DashboardStats(
        quizzesAttempted: 0,
        accuracy: 0,
        averageScore: 0,
        topicsCovered: 0,
        totalQuestionsSolved: 0,
        currentStreak: 0,
        longestStreak: 0,
        weeklyActivity: _emptyWeek(),
        activityTrend: _emptyTrend(),
        difficultyDistribution: const {},
        topicBreakdown: const {},
        recentQuizzes: const [],
      );
    }

    final quizzesAttempted = completed.length;
    final totalQuestions = completed.fold<int>(0, (s, q) => s + q.questionCount);
    final totalCorrect = completed.fold<int>(0, (s, q) => s + (q.correctCount ?? 0));
    final accuracy = totalQuestions == 0 ? 0.0 : (totalCorrect / totalQuestions) * 100;
    final averageScore =
        completed.fold<double>(0, (s, q) => s + (q.accuracy ?? 0)) / quizzesAttempted;
    final topics = completed.map((q) => q.topic.toLowerCase()).toSet().length;

    final difficultyDistribution = <String, int>{};
    final topicBreakdown = <String, int>{};
    for (final q in completed) {
      difficultyDistribution[q.difficulty] = (difficultyDistribution[q.difficulty] ?? 0) + 1;
      topicBreakdown[q.topic] = (topicBreakdown[q.topic] ?? 0) + 1;
    }

    final streaks = _computeStreaks(completed);
    final weekly = _weeklyActivity(completed);
    final trend = _activityTrend(completed);
    final recent = completed.take(5).toList();

    return DashboardStats(
      quizzesAttempted: quizzesAttempted,
      accuracy: accuracy,
      averageScore: averageScore,
      topicsCovered: topics,
      totalQuestionsSolved: totalQuestions,
      currentStreak: streaks.$1,
      longestStreak: streaks.$2,
      weeklyActivity: weekly,
      activityTrend: trend,
      difficultyDistribution: difficultyDistribution,
      topicBreakdown: topicBreakdown,
      recentQuizzes: recent,
    );
  }

  (int, int) _computeStreaks(List<QuizSession> completed) {
    final days = completed
        .map((q) => q.completedAt!)
        .map((d) => DateTime(d.year, d.month, d.day))
        .toSet()
        .toList()
      ..sort();

    if (days.isEmpty) return (0, 0);

    var longest = 1;
    var currentRun = 1;
    for (var i = 1; i < days.length; i++) {
      final diff = days[i].difference(days[i - 1]).inDays;
      if (diff == 1) {
        currentRun++;
        longest = currentRun > longest ? currentRun : longest;
      } else if (diff > 1) {
        currentRun = 1;
      }
    }

    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    final yesterday = todayDate.subtract(const Duration(days: 1));
    final lastDay = days.last;

    int currentStreak = 0;
    if (lastDay == todayDate || lastDay == yesterday) {
      currentStreak = 1;
      for (var i = days.length - 1; i > 0; i--) {
        if (days[i].difference(days[i - 1]).inDays == 1) {
          currentStreak++;
        } else {
          break;
        }
      }
    }

    return (currentStreak, longest);
  }

  List<WeeklyPoint> _weeklyActivity(List<QuizSession> completed) {
    return _dailyActivityPoints(completed, days: 7);
  }

  List<WeeklyPoint> _activityTrend(List<QuizSession> completed) {
    return _dailyActivityPoints(completed, days: 14);
  }

  /// Last [days] calendar days in chronological order (questions solved per day).
  List<WeeklyPoint> _dailyActivityPoints(List<QuizSession> completed, {required int days}) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    return List.generate(days, (i) {
      final day = today.subtract(Duration(days: days - 1 - i));
      final daySessions = completed.where((q) {
        final d = q.completedAt!;
        return d.year == day.year && d.month == day.month && d.day == day.day;
      });
      final questions = daySessions.fold<int>(0, (s, q) => s + q.questionCount);
      return WeeklyPoint('', questions, date: day);
    });
  }

  List<WeeklyPoint> _emptyWeek() => _emptyDays(7);

  List<WeeklyPoint> _emptyTrend() => _emptyDays(14);

  List<WeeklyPoint> _emptyDays(int days) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    return List.generate(days, (i) {
      final day = today.subtract(Duration(days: days - 1 - i));
      return WeeklyPoint('', 0, date: day);
    });
  }

  String _dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  Future<Map<String, dynamic>> exportStats() async {
    final stats = await _db.dailyStats.where().findAll();
    return {
      'dailyStats': stats
          .map((s) => {
                'dateKey': s.dateKey,
                'date': s.date.toIso8601String(),
                'quizzesCount': s.quizzesCount,
                'questionsSolved': s.questionsSolved,
                'correctCount': s.correctCount,
                'accuracySum': s.accuracySum,
                'totalTimeSeconds': s.totalTimeSeconds,
              })
          .toList(),
    };
  }

  Future<void> importStats(Map<String, dynamic> data) async {
    final list = (data['dailyStats'] as List?) ?? [];
    final stats = list.map((raw) {
      final m = Map<String, dynamic>.from(raw as Map);
      return DailyStat()
        ..dateKey = m['dateKey'] as String
        ..date = DateTime.parse(m['date'] as String)
        ..quizzesCount = m['quizzesCount'] as int
        ..questionsSolved = m['questionsSolved'] as int
        ..correctCount = m['correctCount'] as int
        ..accuracySum = (m['accuracySum'] as num).toDouble()
        ..totalTimeSeconds = m['totalTimeSeconds'] as int;
    }).toList();

    await _db.writeTxn(() async {
      await _db.dailyStats.putAll(stats);
    });
  }

  Future<void> clearAll() async {
    await _db.writeTxn(() async {
      await _db.dailyStats.clear();
    });
  }
}
