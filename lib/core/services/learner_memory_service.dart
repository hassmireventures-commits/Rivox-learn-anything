import 'package:isar_community/isar.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/learner_profile.dart';
import '../../data/local/models/quiz_session.dart';
import '../../data/local/repositories/knowledge_repository.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import 'learner_memory.dart';
import 'notification_history_store.dart';

/// Assembles a [LearnerMemorySnapshot] purely from data this app already
/// computes/stores elsewhere — no new tracking, no AI call, no network.
/// Every read here is local (Isar + a JSON sidecar file), matching the
/// confirmed "local statistical rollup" design for the quiz-pattern piece.
class LearnerMemoryService {
  LearnerMemoryService({
    required IsarService isarService,
    required LearnerRepository learnerRepository,
    required QuizRepository quizRepository,
    required KnowledgeRepository knowledgeRepository,
  })  : _isarService = isarService,
        _learnerRepository = learnerRepository,
        _quizRepository = quizRepository,
        _knowledgeRepository = knowledgeRepository;

  final IsarService _isarService;
  final LearnerRepository _learnerRepository;
  final QuizRepository _quizRepository;
  final KnowledgeRepository _knowledgeRepository;

  static const int _maxTopicsInAccuracy = 8;
  static const int _maxFrequentlyMissed = 6;
  static const int _wrongAnswerSampleSize = 30;
  static const int _maxRecentDailyTopics = 7;

  Future<LearnerMemorySnapshot> compute() async {
    final profile = await _learnerRepository.getOrCreateProfile();
    final goalMode = _safeGoalMode(profile);
    final goalContext = _safeGoalContext(profile);
    final primaryTopics = _learnerRepository.goalsOf(profile);
    final goalContextLabel = goalContext.trim().isNotEmpty
        ? goalContext.trim()
        : (primaryTopics.isNotEmpty ? primaryTopics.take(3).join(', ') : '');

    final librarySources = await _libraryRefs();
    final (topicAccuracy, streaks) = await _quizPattern();
    final frequentlyMissed = await _frequentlyMissedTopics();
    final recentDailyTopics = await _recentDailyTopics();

    return LearnerMemorySnapshot(
      goalMode: goalMode,
      goalContextLabel: goalContextLabel,
      primaryTopics: primaryTopics,
      librarySources: librarySources,
      topicAccuracy: topicAccuracy,
      frequentlyMissed: frequentlyMissed,
      currentStreak: streaks.$1,
      longestStreak: streaks.$2,
      recentDailyTopics: recentDailyTopics,
      computedAt: DateTime.now(),
    );
  }

  String _safeGoalMode(LearnerProfile profile) {
    try {
      return profile.goalMode;
    } catch (_) {
      return 'learning';
    }
  }

  String _safeGoalContext(LearnerProfile profile) {
    try {
      return profile.goalContext;
    } catch (_) {
      return '';
    }
  }

  Future<List<LibrarySourceRef>> _libraryRefs() async {
    final sources = await _knowledgeRepository.allEnabledSources();
    return sources.map((s) => LibrarySourceRef(title: s.title, type: s.type)).toList();
  }

  /// Average accuracy per topic (most-recently-active topic first) plus the
  /// existing streak computation — same source data
  /// `StatsRepository.getDashboardStats()` uses, aggregated differently
  /// (accuracy, not just a quiz count).
  Future<(Map<String, int>, (int, int))> _quizPattern() async {
    final completed = await _isarService.db.quizSessions
        .filter()
        .completedAtIsNotNull()
        .sortByCompletedAtDesc()
        .findAll();
    return (
      topicAccuracyFrom(completed, maxTopics: _maxTopicsInAccuracy),
      computeStreaks(completed.map((s) => s.completedAt!).toList()),
    );
  }

  /// Average accuracy per topic, most-recently-active topic first. Extracted
  /// as a pure function (plain constructed [QuizSession]s in, no live Isar
  /// needed) so it can be unit tested directly — same reasoning as
  /// `SpacedRepetition.review` in `flashcard_repository.dart`.
  static Map<String, int> topicAccuracyFrom(
    List<QuizSession> completed, {
    int maxTopics = 8,
  }) {
    if (completed.isEmpty) return const {};

    final sumByTopic = <String, double>{};
    final countByTopic = <String, int>{};
    final topicOrder = <String>[]; // first-seen (most recent) order
    for (final s in completed) {
      final topic = s.topic.trim();
      if (topic.isEmpty) continue;
      if (!countByTopic.containsKey(topic)) topicOrder.add(topic);
      sumByTopic[topic] = (sumByTopic[topic] ?? 0) + (s.accuracy ?? 0);
      countByTopic[topic] = (countByTopic[topic] ?? 0) + 1;
    }

    final topicAccuracy = <String, int>{};
    for (final topic in topicOrder.take(maxTopics)) {
      final avg = sumByTopic[topic]! / countByTopic[topic]!;
      topicAccuracy[topic] = avg.round();
    }
    return topicAccuracy;
  }

  /// Mirrors `StatsRepository._computeStreaks` (kept local/duplicated on
  /// purpose — a private method on another class, not worth exposing just
  /// for this reuse). Pure — no live Isar needed, unit-testable directly.
  static (int, int) computeStreaks(List<DateTime> completedAtValues) {
    final days = completedAtValues.map((d) => DateTime(d.year, d.month, d.day)).toSet().toList()
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

    var currentStreak = 0;
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

  /// Topics behind the most wrong answers, most-missed first. Resolves each
  /// wrong question's topic via its quiz session (`Question` itself has no
  /// topic field) — same per-quiz session lookup `getWrongQuestions` already
  /// does internally for sorting.
  Future<List<String>> _frequentlyMissedTopics() async {
    final wrong = await _quizRepository.getWrongQuestions(limit: _wrongAnswerSampleSize);
    if (wrong.isEmpty) return const [];

    final topicByQuiz = <String, String?>{};
    final uniqueQuizUuids = wrong.map((q) => q.quizUuid).toSet();
    for (final quizUuid in uniqueQuizUuids) {
      final session = await _quizRepository.getSession(quizUuid);
      topicByQuiz[quizUuid] = session?.topic;
    }
    return frequentlyMissedFrom(
      wrong.map((q) => topicByQuiz[q.quizUuid]).toList(),
      maxTopics: _maxFrequentlyMissed,
    );
  }

  /// Groups already-resolved topics (one per wrong question, nulls for
  /// unresolvable ones) by miss count, most-missed first. Extracted as a
  /// pure function for the same reason as [topicAccuracyFrom].
  static List<String> frequentlyMissedFrom(
    List<String?> topicsForWrongQuestions, {
    int maxTopics = 6,
  }) {
    final missCountByTopic = <String, int>{};
    for (final raw in topicsForWrongQuestions) {
      final topic = raw?.trim();
      if (topic == null || topic.isEmpty) continue;
      missCountByTopic[topic] = (missCountByTopic[topic] ?? 0) + 1;
    }
    final sorted = missCountByTopic.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return sorted.take(maxTopics).map((e) => e.key).toList();
  }

  Future<List<String>> _recentDailyTopics() async {
    try {
      final history = await NotificationHistoryStore.instance.list();
      final content = history.where((h) => h.kind == 'content').toList()
        ..sort((a, b) => b.createdAtIso.compareTo(a.createdAtIso));
      return content
          .take(_maxRecentDailyTopics)
          .map((h) => h.title)
          .where((t) => t.trim().isNotEmpty)
          .toList();
    } catch (_) {
      return const [];
    }
  }
}
