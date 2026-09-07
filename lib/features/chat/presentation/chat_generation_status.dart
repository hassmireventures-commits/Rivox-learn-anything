import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';

/// Ephemeral (not persisted — no `ChatMessage` write) inline status for a
/// quiz/path generation triggered from chat via [ChatActionChip]. Watches
/// `generationJobServiceProvider` directly rather than duplicating its
/// state; renders nothing when no job is running/just-finished/errored.
class ChatGenerationStatus extends ConsumerWidget {
  const ChatGenerationStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(generationJobServiceProvider);
    final theme = Theme.of(context);

    if (job.isRunning) {
      final label = switch (job.kind) {
        _ when job.topic != null && job.topic != 'Learning path' =>
          'Generating on "${job.topic}"…',
        _ => 'Generating…',
      };
      return _StatusBar(
        color: theme.colorScheme.primaryContainer,
        onColor: theme.colorScheme.onPrimaryContainer,
        icon: const SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
        label: label,
      );
    }

    if (!job.isRunning && job.successRoute != null && !job.userCancelled) {
      final ready = job.kind?.name == 'path' ? 'Learning path ready' : 'Quiz ready';
      return _StatusBar(
        color: theme.colorScheme.tertiaryContainer,
        onColor: theme.colorScheme.onTertiaryContainer,
        icon: const Icon(Icons.check_circle_rounded, size: 18),
        label: '$ready — tap to open',
        onTap: () => context.push(job.successRoute!),
      );
    }

    if (job.errorMessage != null) {
      return _StatusBar(
        color: theme.colorScheme.errorContainer,
        onColor: theme.colorScheme.onErrorContainer,
        icon: const Icon(Icons.error_outline_rounded, size: 18),
        label: job.errorMessage!,
      );
    }

    return const SizedBox.shrink();
  }
}

class _StatusBar extends StatelessWidget {
  const _StatusBar({
    required this.color,
    required this.onColor,
    required this.icon,
    required this.label,
    this.onTap,
  });

  final Color color;
  final Color onColor;
  final Widget icon;
  final String label;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
          child: Row(
            children: [
              icon,
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(color: onColor, fontWeight: FontWeight.w600),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
