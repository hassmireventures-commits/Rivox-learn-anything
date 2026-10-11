import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/personalization/learning_domain.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';

/// One-line streak, freezes, and level at the top of Home: the Duolingo
/// retention loop in a single quiet row (less UI, more UX). The streak flame
/// turns to an "at risk" prompt when nothing has been done today.
class ProgressionStrip extends ConsumerWidget {
  const ProgressionStrip({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(dashboardStatsProvider).asData?.value;
    final personalization = ref.watch(personalizationProvider).asData?.value;
    if (stats == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final domain = LearningDomains.profileForGoal([
      personalization?.goalContextLabel ?? '',
      ...?personalization?.primaryTopics,
    ]);
    final level = stats.level;
    final flameColor = stats.activeToday
        ? AppTheme.accentOrange
        : stats.currentStreak > 0
            ? AppTheme.coralStart
            : scheme.onSurfaceVariant;

    return Semantics(
      label: 'Streak ${stats.currentStreak} days, level ${level.level}',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: scheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
          border: Border.all(color: scheme.outlineVariant.withValues(alpha: 0.6)),
        ),
        child: Row(
          children: [
            Icon(Icons.local_fire_department_rounded, color: flameColor, size: 22),
            const SizedBox(width: 4),
            Text('${stats.currentStreak}', style: theme.textTheme.titleMedium),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                stats.streakAtRisk
                    ? 'Keep it alive today'
                    : stats.currentStreak == 1
                        ? 'day'
                        : 'days',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: stats.streakAtRisk ? AppTheme.coralStart : scheme.onSurfaceVariant,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (stats.freezesBanked > 0) ...[
              const SizedBox(width: 10),
              Tooltip(
                message: 'Streak freeze: covers one missed day automatically',
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.ac_unit_rounded, size: 16, color: AppTheme.accentBlue),
                    const SizedBox(width: 2),
                    Text('${stats.freezesBanked}', style: theme.textTheme.labelMedium),
                  ],
                ),
              ),
            ],
            const Spacer(),
            Icon(domain.icon, size: 16, color: domain.accent),
            const SizedBox(width: 6),
            Text('Lv ${level.level}', style: theme.textTheme.labelLarge),
            const SizedBox(width: 8),
            SizedBox(
              width: 56,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: level.progress,
                  minHeight: 6,
                  color: domain.accent,
                  backgroundColor: scheme.surfaceContainerHighest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
