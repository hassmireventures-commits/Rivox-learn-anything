import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local/repositories/learner_repository.dart';

/// B39 — an alternate, visual view of a learning path's modules, next to
/// the existing list (not a replacement — the list stays the primary way
/// to actually work through a path in order).
///
/// Deliberately a straight-line connected-node "path" rather than a
/// free-form mind map or a general graph-layout package: a learning path's
/// modules are already a linear, sequential dependency chain (each step
/// locks until the previous completes), not a branching structure, so a
/// simple vertical sequence is the honest fit for the data that exists
/// today — a generic graph-layout dependency would be solving a harder
/// problem than this data actually poses.
class PathMapView extends StatelessWidget {
  const PathMapView({
    super.key,
    required this.steps,
    required this.currentIndex,
    required this.isModuleUnlocked,
    required this.onTapModule,
  });

  final List<PathStepData> steps;
  final int currentIndex;
  final bool Function(int index) isModuleUnlocked;
  final ValueChanged<int> onTapModule;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 12),
      itemCount: steps.length,
      itemBuilder: (context, index) {
        final unlocked = isModuleUnlocked(index);
        final done = index < currentIndex;
        final current = index == currentIndex;
        final isLast = index == steps.length - 1;
        final lineColor = done ? AppTheme.accentGreen : theme.colorScheme.outlineVariant;

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  _PathMapNode(index: index, done: done, current: current, unlocked: unlocked),
                  if (!isLast)
                    Expanded(
                      child: Container(
                        width: 3,
                        margin: const EdgeInsets.symmetric(vertical: 2),
                        color: lineColor,
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(bottom: 28, top: 6),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => onTapModule(index),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Text(
                        steps[index].title,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: current ? FontWeight.w800 : FontWeight.w500,
                          color: unlocked ? null : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _PathMapNode extends StatelessWidget {
  const _PathMapNode({
    required this.index,
    required this.done,
    required this.current,
    required this.unlocked,
  });

  final int index;
  final bool done;
  final bool current;
  final bool unlocked;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final background = done
        ? AppTheme.accentGreen
        : current
            ? AppTheme.seedColor
            : theme.colorScheme.surfaceContainerHighest;
    final foreground = (done || current) ? Colors.white : theme.colorScheme.onSurfaceVariant;

    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: background,
        shape: BoxShape.circle,
        border: current
            ? Border.all(color: AppTheme.seedColor.withValues(alpha: 0.4), width: 4)
            : null,
      ),
      child: done
          ? Icon(Icons.check_rounded, color: foreground, size: 20)
          : !unlocked
              ? Icon(Icons.lock_rounded, color: foreground, size: 16)
              : Text(
                  '${index + 1}',
                  style: TextStyle(color: foreground, fontWeight: FontWeight.w700),
                ),
    );
  }
}
