import '../../core/error/app_exception.dart';
import '../../data/local/models/quiz_session.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/quiz_repository.dart';
import '../../data/remote/ai/learning_orchestrator.dart';
import '../constants/quiz_kind.dart';
import 'learner_goal_guard.dart';
import 'reminder_preferences.dart';
import 'topic_goal_relevance.dart';

/// Home / scheduler snapshot for today's daily-quiz slots.
class DailyQuizOffer {
  const DailyQuizOffer({
    required this.session,
    required this.completedCount,
    required this.frequency,
    required this.slotNumber,
    required this.canGenerate,
    required this.hasIncomplete,
  });

  /// Incomplete quiz if one exists; last completed when all slots are used.
  final QuizSession? session;
  final int completedCount;
  final int frequency;
  /// 1-based current incomplete slot, or the next slot to generate.
  final int slotNumber;
  final bool canGenerate;
  final bool hasIncomplete;

  bool get showSlotLabel => frequency > 1;
}

/// Manages the daily quiz challenge lifecycle.
class QuizOfTheDayService {
  QuizOfTheDayService({
    required this.quizRepository,
    required this.learnerRepository,
    required this.orchestrator,
  });

  final QuizRepository quizRepository;
  final LearnerRepository learnerRepository;
  final LearningOrchestrator orchestrator;

  Future<String?> findTodaysQuizId() async {
    final session = await quizRepository.findDailyQuizForDate(DateTime.now());
    if (session == null) return null;
    // Incomplete quiz for today — reuse it.
    if (session.completedAt == null) return session.uuid;
    // All slots used for today — nothing to auto-schedule.
    if (!(await canOfferAnother())) return null;
    return null;
  }

  Future<bool> isTodaysQuizCompleted() async {
    final session = await quizRepository.findDailyQuizForDate(DateTime.now());
    if (session?.completedAt == null) return false;
    return !(await canOfferAnother());
  }

  Future<bool> canOfferAnother() async {
    final offer = await loadOffer();
    return offer.canGenerate;
  }

  Future<DailyQuizOffer> loadOffer() async {
    await ReminderPreferencesStore.instance.load();
    final frequency =
        ReminderPreferencesStore.instance.current.dailyQuizFrequency.clamp(1, 3);
    final existing =
        await quizRepository.listDailyQuizzesForDate(DateTime.now());
    final incomplete = existing.where((s) => s.completedAt == null).toList();
    final completedCount = existing.where((s) => s.completedAt != null).length;
    final hasIncomplete = incomplete.isNotEmpty;
    final canGenerate = !hasIncomplete && existing.length < frequency;
    final QuizSession? session = hasIncomplete
        ? incomplete.first
        : (canGenerate ? null : (existing.isEmpty ? null : existing.last));
    final slotNumber = hasIncomplete
        ? completedCount + 1
        : (canGenerate ? existing.length + 1 : frequency.clamp(1, 3));
    return DailyQuizOffer(
      session: session,
      completedCount: completedCount,
      frequency: frequency,
      slotNumber: slotNumber.clamp(1, 3),
      canGenerate: canGenerate,
      hasIncomplete: hasIncomplete,
    );
  }

  Future<bool> hasAnyDailyQuizToday() async {
    final existing =
        await quizRepository.listDailyQuizzesForDate(DateTime.now());
    return existing.isNotEmpty;
  }

  /// Ensures today's quiz exists and returns its UUID.
  ///
  /// Returns `null` when no usable goal is set, or when no AI provider is
  /// configured. Never uses a generic "Daily review" topic.
  ///
  /// [countBuiltinQuota] is false for schedulers/background auto-generation so
  /// opening Home does not spend the user's Built-in allowance.
  Future<String?> ensureTodaysQuiz({bool countBuiltinQuota = false}) async {
    final today = DateTime.now();
    final existing = await quizRepository.listDailyQuizzesForDate(today);
    for (final s in existing) {
      if (s.completedAt == null) return s.uuid;
    }

    await ReminderPreferencesStore.instance.load();
    final frequency =
        ReminderPreferencesStore.instance.current.dailyQuizFrequency.clamp(1, 3);
    if (existing.length >= frequency) {
      return existing.isEmpty ? null : existing.last.uuid;
    }

    final profile = await learnerRepository.getOrCreateProfile();
    if (!LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: learnerRepository)) {
      return null;
    }

    final goals = learnerRepository.goalsOf(profile);
    final weak = await learnerRepository.weakTopics(limit: 3);
    final topic = _pickOnGoalTopic(goals: goals, weakTopics: weak.map((e) => e.topic).toList());
    if (topic == null || topic.isEmpty) return null;

    try {
      return await orchestrator.runQuizGeneration(
        topic: topic,
        questionCount: 5,
        difficulty: profile.skillLevel < 0.35 ? 'easy' : 'medium',
        questionType: 'mcq',
        quizKind: QuizKind.daily,
        countBuiltinQuota: countBuiltinQuota,
      );
    } on NoProviderConfiguredException {
      return null;
    }
  }

  /// Prefer a weak topic that still matches goals; else rotate goals by day.
  static String? _pickOnGoalTopic({
    required List<String> goals,
    required List<String> weakTopics,
  }) {
    if (goals.isEmpty) return null;
    for (final w in weakTopics) {
      final r = TopicGoalRelevanceGate.evaluate(
        topic: w,
        goalLabel: goals.first,
        goalTopics: goals,
      );
      if (r.level != TopicGoalRelevance.offGoal) return w;
    }
    final day = DateTime.now().day;
    return goals[day % goals.length];
  }
}
