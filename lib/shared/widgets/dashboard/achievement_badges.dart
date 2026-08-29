import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local/repositories/stats_repository.dart';

/// Definition of a single fixed milestone/achievement badge.
///
/// Badges are computed LIVE from [DashboardStats] on every build - there is
/// no persistence of "unlocked" state and no first-unlock celebration. This
/// keeps the feature intentionally simple: re-opening the dashboard always
/// reflects the current stats truthfully.
class AchievementDef {
  const AchievementDef({
    required this.id,
    required this.title,
    required this.icon,
    required this.isUnlocked,
    required this.progressLabel,
    required this.progress,
  });

  /// Stable identifier (not persisted anywhere today, but kept unique/stable
  /// in case a future version wants to key off it).
  final String id;

  /// Fixed, non-localized display title (this list is a compile-time
  /// constant, so it cannot depend on [BuildContext]/l10n).
  final String title;

  final IconData icon;

  /// Whether this milestone is currently met by [DashboardStats].
  final bool Function(DashboardStats stats) isUnlocked;

  /// Progress text shown while locked, e.g. "12/50".
  final String Function(DashboardStats stats) progressLabel;

  /// 0.0-1.0 completion ratio (unlocked badges evaluate to exactly 1.0) —
  /// used to sort the slide view so the closest-to-unlocking badge leads.
  final double Function(DashboardStats stats) progress;
}

/// Fixed set of milestone badges shown on the dashboard, tied directly to
/// fields already computed by [StatsRepository.getDashboardStats].
const List<AchievementDef> kAchievements = [
  AchievementDef(
    id: 'streak_3',
    title: '3-Day Streak',
    icon: Icons.local_fire_department_rounded,
    isUnlocked: _streakAtLeast3,
    progressLabel: _streakProgress3,
    progress: _streakRatio3,
  ),
  AchievementDef(
    id: 'streak_7',
    title: '7-Day Streak',
    icon: Icons.local_fire_department_rounded,
    isUnlocked: _streakAtLeast7,
    progressLabel: _streakProgress7,
    progress: _streakRatio7,
  ),
  AchievementDef(
    id: 'streak_30',
    title: '30-Day Streak',
    icon: Icons.whatshot_rounded,
    isUnlocked: _streakAtLeast30,
    progressLabel: _streakProgress30,
    progress: _streakRatio30,
  ),
  AchievementDef(
    id: 'questions_50',
    title: '50 Questions Solved',
    icon: Icons.quiz_rounded,
    isUnlocked: _questions50,
    progressLabel: _questionsProgress50,
    progress: _questionsRatio50,
  ),
  AchievementDef(
    id: 'questions_200',
    title: '200 Questions Solved',
    icon: Icons.menu_book_rounded,
    isUnlocked: _questions200,
    progressLabel: _questionsProgress200,
    progress: _questionsRatio200,
  ),
  AchievementDef(
    id: 'topics_5',
    title: '5 Topics Explored',
    icon: Icons.category_rounded,
    isUnlocked: _topics5,
    progressLabel: _topicsProgress5,
    progress: _topicsRatio5,
  ),
  AchievementDef(
    id: 'quizzes_10',
    title: '10 Quizzes Completed',
    icon: Icons.emoji_events_rounded,
    isUnlocked: _quizzes10,
    progressLabel: _quizzesProgress10,
    progress: _quizzesRatio10,
  ),
  AchievementDef(
    id: 'accuracy_80',
    title: '80% Accuracy',
    icon: Icons.my_location_rounded,
    isUnlocked: _accuracy80,
    progressLabel: _accuracyProgress80,
    progress: _accuracyRatio80,
  ),
];

// Streak milestones are based on the *longest* streak ever reached, not the
// current one - an achievement shouldn't be revoked just because today's
// streak has since broken.
bool _streakAtLeast3(DashboardStats s) => s.longestStreak >= 3;
String _streakProgress3(DashboardStats s) => '${s.longestStreak.clamp(0, 3)}/3';
double _streakRatio3(DashboardStats s) => (s.longestStreak / 3).clamp(0, 1);

bool _streakAtLeast7(DashboardStats s) => s.longestStreak >= 7;
String _streakProgress7(DashboardStats s) => '${s.longestStreak.clamp(0, 7)}/7';
double _streakRatio7(DashboardStats s) => (s.longestStreak / 7).clamp(0, 1);

bool _streakAtLeast30(DashboardStats s) => s.longestStreak >= 30;
String _streakProgress30(DashboardStats s) => '${s.longestStreak.clamp(0, 30)}/30';
double _streakRatio30(DashboardStats s) => (s.longestStreak / 30).clamp(0, 1);

bool _questions50(DashboardStats s) => s.totalQuestionsSolved >= 50;
String _questionsProgress50(DashboardStats s) =>
    '${s.totalQuestionsSolved.clamp(0, 50)}/50';
double _questionsRatio50(DashboardStats s) =>
    (s.totalQuestionsSolved / 50).clamp(0, 1);

bool _questions200(DashboardStats s) => s.totalQuestionsSolved >= 200;
String _questionsProgress200(DashboardStats s) =>
    '${s.totalQuestionsSolved.clamp(0, 200)}/200';
double _questionsRatio200(DashboardStats s) =>
    (s.totalQuestionsSolved / 200).clamp(0, 1);

bool _topics5(DashboardStats s) => s.topicsCovered >= 5;
String _topicsProgress5(DashboardStats s) => '${s.topicsCovered.clamp(0, 5)}/5';
double _topicsRatio5(DashboardStats s) => (s.topicsCovered / 5).clamp(0, 1);

bool _quizzes10(DashboardStats s) => s.quizzesAttempted >= 10;
String _quizzesProgress10(DashboardStats s) =>
    '${s.quizzesAttempted.clamp(0, 10)}/10';
double _quizzesRatio10(DashboardStats s) => (s.quizzesAttempted / 10).clamp(0, 1);

bool _accuracy80(DashboardStats s) => s.accuracy >= 80;
String _accuracyProgress80(DashboardStats s) =>
    '${s.accuracy.clamp(0, 80).round()}/80%';
double _accuracyRatio80(DashboardStats s) => (s.accuracy / 80).clamp(0, 1);

/// Renders [kAchievements] as a swipeable slide view, sorted so the
/// closest-to-unlocking badge leads (unlocked badges evaluate to progress
/// 1.0, so they naturally lead ahead of anything still in progress). Reads
/// only from the [stats] passed in (already fetched via `dashboardStatsProvider`
/// by the caller) - no new provider/async call.
class AchievementBadgesSection extends StatefulWidget {
  const AchievementBadgesSection({super.key, required this.stats});

  final DashboardStats stats;

  @override
  State<AchievementBadgesSection> createState() => _AchievementBadgesSectionState();
}

class _AchievementBadgesSectionState extends State<AchievementBadgesSection> {
  late final PageController _controller = PageController(viewportFraction: 0.42);
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;
    final stats = widget.stats;

    final sorted = kAchievements.toList()
      ..sort((a, b) => b.progress(stats).compareTo(a.progress(stats)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SizedBox(
          height: 168,
          child: PageView.builder(
            controller: _controller,
            itemCount: sorted.length,
            onPageChanged: (i) => setState(() => _page = i),
            itemBuilder: (context, index) {
              final achievement = sorted[index];
              final unlocked = achievement.isUnlocked(stats);
              final progress = achievement.progress(stats);
              final accent = unlocked ? AppTheme.seedColor : scheme.onSurfaceVariant;

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Semantics(
                  label: unlocked
                      ? '${achievement.title}, unlocked'
                      : '${achievement.title}, locked, progress ${achievement.progressLabel(stats)}',
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                    decoration: BoxDecoration(
                      color: unlocked
                          ? AppTheme.seedColor.withValues(alpha: 0.10)
                          : scheme.surfaceContainerHighest.withValues(alpha: 0.4),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: unlocked
                            ? AppTheme.seedColor.withValues(alpha: 0.35)
                            : scheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: unlocked ? 0.15 : 0.08),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            achievement.icon,
                            size: 24,
                            color: unlocked ? accent : accent.withValues(alpha: 0.5),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          achievement.title,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: unlocked ? null : scheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 5,
                            backgroundColor: scheme.outlineVariant.withValues(alpha: 0.4),
                            valueColor: AlwaysStoppedAnimation(
                              unlocked ? AppTheme.seedColor : scheme.onSurfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          unlocked ? '✓' : achievement.progressLabel(stats),
                          style: textTheme.labelSmall?.copyWith(
                            color: unlocked ? AppTheme.seedColor : scheme.onSurfaceVariant,
                            fontWeight: unlocked ? FontWeight.w700 : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(sorted.length, (i) {
            final active = i == _page;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: active ? 16 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: active
                    ? AppTheme.seedColor
                    : scheme.outlineVariant.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}
