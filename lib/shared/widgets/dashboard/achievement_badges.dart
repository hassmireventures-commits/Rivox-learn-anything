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
  ),
  AchievementDef(
    id: 'streak_7',
    title: '7-Day Streak',
    icon: Icons.local_fire_department_rounded,
    isUnlocked: _streakAtLeast7,
    progressLabel: _streakProgress7,
  ),
  AchievementDef(
    id: 'streak_30',
    title: '30-Day Streak',
    icon: Icons.whatshot_rounded,
    isUnlocked: _streakAtLeast30,
    progressLabel: _streakProgress30,
  ),
  AchievementDef(
    id: 'questions_50',
    title: '50 Questions Solved',
    icon: Icons.quiz_rounded,
    isUnlocked: _questions50,
    progressLabel: _questionsProgress50,
  ),
  AchievementDef(
    id: 'questions_200',
    title: '200 Questions Solved',
    icon: Icons.menu_book_rounded,
    isUnlocked: _questions200,
    progressLabel: _questionsProgress200,
  ),
  AchievementDef(
    id: 'topics_5',
    title: '5 Topics Explored',
    icon: Icons.category_rounded,
    isUnlocked: _topics5,
    progressLabel: _topicsProgress5,
  ),
  AchievementDef(
    id: 'quizzes_10',
    title: '10 Quizzes Completed',
    icon: Icons.emoji_events_rounded,
    isUnlocked: _quizzes10,
    progressLabel: _quizzesProgress10,
  ),
  AchievementDef(
    id: 'accuracy_80',
    title: '80% Accuracy',
    icon: Icons.my_location_rounded,
    isUnlocked: _accuracy80,
    progressLabel: _accuracyProgress80,
  ),
];

// Streak milestones are based on the *longest* streak ever reached, not the
// current one - an achievement shouldn't be revoked just because today's
// streak has since broken.
bool _streakAtLeast3(DashboardStats s) => s.longestStreak >= 3;
String _streakProgress3(DashboardStats s) => '${s.longestStreak.clamp(0, 3)}/3';

bool _streakAtLeast7(DashboardStats s) => s.longestStreak >= 7;
String _streakProgress7(DashboardStats s) => '${s.longestStreak.clamp(0, 7)}/7';

bool _streakAtLeast30(DashboardStats s) => s.longestStreak >= 30;
String _streakProgress30(DashboardStats s) => '${s.longestStreak.clamp(0, 30)}/30';

bool _questions50(DashboardStats s) => s.totalQuestionsSolved >= 50;
String _questionsProgress50(DashboardStats s) =>
    '${s.totalQuestionsSolved.clamp(0, 50)}/50';

bool _questions200(DashboardStats s) => s.totalQuestionsSolved >= 200;
String _questionsProgress200(DashboardStats s) =>
    '${s.totalQuestionsSolved.clamp(0, 200)}/200';

bool _topics5(DashboardStats s) => s.topicsCovered >= 5;
String _topicsProgress5(DashboardStats s) => '${s.topicsCovered.clamp(0, 5)}/5';

bool _quizzes10(DashboardStats s) => s.quizzesAttempted >= 10;
String _quizzesProgress10(DashboardStats s) =>
    '${s.quizzesAttempted.clamp(0, 10)}/10';

bool _accuracy80(DashboardStats s) => s.accuracy >= 80;
String _accuracyProgress80(DashboardStats s) =>
    '${s.accuracy.clamp(0, 80).round()}/80%';

/// Renders [kAchievements] as a wrapping row of small badge chips - unlocked
/// ones highlighted with the accent color, locked ones greyed-out with a
/// progress subtitle. Reads only from the [stats] passed in (already fetched
/// via `dashboardStatsProvider` by the caller) - no new provider/async call.
class AchievementBadgesSection extends StatelessWidget {
  const AchievementBadgesSection({super.key, required this.stats});

  final DashboardStats stats;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final textTheme = Theme.of(context).textTheme;

    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: kAchievements.map((achievement) {
        final unlocked = achievement.isUnlocked(stats);
        final accent = unlocked ? AppTheme.seedColor : scheme.onSurfaceVariant;

        return Semantics(
          label: unlocked
              ? '${achievement.title}, unlocked'
              : '${achievement.title}, locked, progress ${achievement.progressLabel(stats)}',
          child: Container(
            width: 108,
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
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
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: accent.withValues(alpha: unlocked ? 0.15 : 0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    achievement.icon,
                    size: 20,
                    color: unlocked ? accent : accent.withValues(alpha: 0.5),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  achievement.title,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: unlocked ? null : scheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  unlocked ? '✓' : achievement.progressLabel(stats),
                  style: textTheme.labelSmall?.copyWith(
                    color: unlocked ? AppTheme.seedColor : scheme.onSurfaceVariant,
                    fontSize: 10,
                    fontWeight: unlocked ? FontWeight.w700 : null,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
