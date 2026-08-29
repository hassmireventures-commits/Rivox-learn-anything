import '../../data/local/models/learner_profile.dart';
import '../../data/local/models/recommendation.dart';
import '../../data/local/repositories/goal_progress_repository.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../theme/app_theme.dart';

class UiPersonalizationState {
  const UiPersonalizationState({
    required this.density,
    required this.navOrder,
    required this.recommendations,
    required this.weakTopics,
    required this.degradeCharts,
    required this.goalMode,
    required this.goalContextLabel,
    this.examDaysRemaining,
    this.syllabusCoveragePercent = 0,
    this.careerReadinessPercent = 0,
    this.focusTitles = const [],
    this.primaryTopics = const [],
    this.roleSeniorityLabel,
  });

  final ContentDensity density;
  final List<String> navOrder;
  final List<RecommendationItem> recommendations;
  final List<String> weakTopics;
  final bool degradeCharts;

  /// Active goal mode: 'learning' | 'exam_prep' | 'career'
  final String goalMode;

  /// Display-ready context label (exam name, role, or joined learning topics)
  final String goalContextLabel;

  /// Days until exam - non-null only when goalMode == 'exam_prep' and examDate is set.
  final int? examDaysRemaining;

  /// Weighted syllabus coverage 0 - 100 (exam_prep).
  final int syllabusCoveragePercent;

  /// Weighted role readiness 0 - 100 (career).
  final int careerReadinessPercent;

  /// Mode-aware focus list: weak units (exam) or skill gaps (career); else weakTopics.
  final List<String> focusTitles;

  /// Primary goal topics from the learner profile (syllabus / skills / learning goals).
  final List<String> primaryTopics;

  /// Display label for career seniority (Junior / Mid / Senior), if set.
  final String? roleSeniorityLabel;
}

class UiPersonalizationController {
  UiPersonalizationController(this._learnerRepository, this._goalProgress);

  final LearnerRepository _learnerRepository;
  final GoalProgressRepository _goalProgress;

  Future<UiPersonalizationState> build({bool degradeCharts = false}) async {
    final profile = await _learnerRepository.getOrCreateProfile();
    final recs = await _learnerRepository.activeRecommendations();
    final weak = await _learnerRepository.weakTopics(limit: 4);

    String goalMode = 'learning';
    String goalContext = '';
    try {
      goalMode = profile.goalMode;
    } catch (_) {}
    try {
      goalContext = profile.goalContext;
    } catch (_) {}

    int? examDaysRemaining;
    if (goalMode == 'exam_prep' && profile.examDate != null) {
      examDaysRemaining = profile.examDate!.difference(DateTime.now()).inDays;
      if (examDaysRemaining < 0) examDaysRemaining = 0;
    }

    final primaryTopics = _learnerRepository.goalsOf(profile);
    final goalContextLabel = goalContext.trim().isNotEmpty
        ? goalContext.trim()
        : (primaryTopics.isNotEmpty ? primaryTopics.take(3).join(', ') : '');
    final weakTitles = weak.map((t) => t.topic).toList();
    String? roleSeniorityLabel;
    try {
      final raw = profile.roleSeniority?.trim();
      if (raw != null && raw.isNotEmpty) {
        roleSeniorityLabel = switch (raw.toLowerCase()) {
          'junior' => 'Junior',
          'mid' || 'middle' => 'Mid',
          'senior' => 'Senior',
          _ => raw,
        };
      }
    } catch (_) {}

    var syllabusCoveragePercent = 0;
    var careerReadinessPercent = 0;
    var focusTitles = weakTitles;

    if (goalMode == 'exam_prep') {
      await _ensureExamBootstrap(profile, goalContext);
      syllabusCoveragePercent = await _goalProgress.syllabusCoveragePercent();
      final planFocus = await _goalProgress.studyPlanFocusTitles(limit: 3);
      if (planFocus.isNotEmpty) {
        focusTitles = planFocus;
      } else {
        final units = await _goalProgress.weakUnitTitles(limit: 3);
        if (units.isNotEmpty) focusTitles = units;
      }
    } else if (goalMode == 'career') {
      await _ensureCareerBootstrap(profile, goalContext);
      careerReadinessPercent = await _goalProgress.careerReadinessPercent();
      final gaps = await _goalProgress.topGapSkillTitles(limit: 3);
      if (gaps.isNotEmpty) focusTitles = gaps;
    }

    return UiPersonalizationState(
      density: ContentDensity.comfortable,
      navOrder: _learnerRepository.navOrderOf(profile),
      recommendations: recs,
      weakTopics: weakTitles,
      degradeCharts: degradeCharts,
      goalMode: goalMode,
      goalContextLabel: goalContextLabel,
      examDaysRemaining: examDaysRemaining,
      syllabusCoveragePercent: syllabusCoveragePercent,
      careerReadinessPercent: careerReadinessPercent,
      focusTitles: focusTitles,
      primaryTopics: primaryTopics,
      roleSeniorityLabel: roleSeniorityLabel,
    );
  }

  Future<void> _ensureExamBootstrap(LearnerProfile profile, String goalContext) async {
    final existing = await _goalProgress.activeSyllabus();
    if (existing == null) {
      final goals = _learnerRepository.goalsOf(profile);
      await _goalProgress.bootstrapSyllabus(
        title: goalContext.isNotEmpty ? goalContext : 'Exam syllabus',
        topics: goals,
        examDate: profile.examDate,
      );
    }
    if (profile.examDate != null) {
      final plan = await _goalProgress.currentWeekPlan();
      if (plan.isEmpty) {
        await _goalProgress.regenerateStudyPlan(
          examDate: profile.examDate!,
          dailyMinutes: profile.dailyMinutesGoal ?? 15,
        );
      }
    }
  }

  Future<void> _ensureCareerBootstrap(LearnerProfile profile, String goalContext) async {
    final existing = await _goalProgress.allCareerSkills();
    if (existing.isNotEmpty) return;
    final goals = _learnerRepository.goalsOf(profile);
    await _goalProgress.bootstrapCareerSkills(
      roleTitle: goalContext.isNotEmpty ? goalContext : 'Target role',
      skills: goals,
    );
  }
}
