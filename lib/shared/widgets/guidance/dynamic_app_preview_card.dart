import 'package:flutter/material.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/theme/app_theme.dart';
import 'dynamic_app_explainer_sheet.dart';

class DynamicAppPreviewCard extends StatelessWidget {
  const DynamicAppPreviewCard({super.key, required this.goalMode});

  final String goalMode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final modes = ['learning', 'exam_prep', 'career'];
    final ordered = [goalMode, ...modes.where((m) => m != goalMode)];

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? theme.colorScheme.outlineVariant
              : AppTheme.purpleStart.withValues(alpha: 0.25),
        ),
        color: isDark
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65)
            : AppTheme.purpleStart.withValues(alpha: 0.06),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.dynamicAppTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.dynamicAppBody,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurface.withValues(alpha: 0.78),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              for (final mode in ordered.take(3))
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: _MiniLayoutPreview(
                      label: _modeLabel(l10n, mode),
                      highlighted: mode == goalMode,
                      icon: _modeIcon(mode),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton(
              onPressed: () => showDynamicAppExplainerSheet(context, goalMode: goalMode),
              child: Text(l10n.dynamicAppSeeHow),
            ),
          ),
        ],
      ),
    );
  }

  String _modeLabel(dynamic l10n, String mode) => switch (mode) {
        'exam_prep' => l10n.goalModeShortExam,
        'career' => l10n.goalModeShortCareer,
        _ => l10n.goalModeShortLearning,
      };

  IconData _modeIcon(String mode) => switch (mode) {
        'exam_prep' => Icons.emoji_events_outlined,
        'career' => Icons.work_outline,
        _ => Icons.auto_stories_outlined,
      };
}

class _MiniLayoutPreview extends StatelessWidget {
  const _MiniLayoutPreview({
    required this.label,
    required this.highlighted,
    required this.icon,
  });

  final String label;
  final bool highlighted;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = highlighted ? theme.colorScheme.primary : theme.colorScheme.onSurfaceVariant;
    return Column(
      children: [
        Container(
          height: 56,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: highlighted ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
              width: highlighted ? 2 : 1,
            ),
            color: highlighted
                ? theme.colorScheme.primary.withValues(alpha: 0.12)
                : theme.colorScheme.surface,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              ...List.generate(
                2,
                (_) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  height: 4,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.35),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          maxLines: 1,
          softWrap: false,
          overflow: TextOverflow.ellipsis,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelSmall?.copyWith(
            fontWeight: highlighted ? FontWeight.w700 : FontWeight.w500,
            color: theme.colorScheme.onSurface.withValues(alpha: highlighted ? 1 : 0.75),
          ),
        ),
      ],
    );
  }
}
