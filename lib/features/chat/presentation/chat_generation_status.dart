import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/app_providers.dart';

/// Ephemeral (not persisted — no `ChatMessage` write) inline "Generating…"
/// status for a quiz/path generation triggered from chat via
/// [ChatActionChip]. Watches `generationJobServiceProvider` directly rather
/// than duplicating its state.
///
/// Deliberately shows the RUNNING state only — "ready"/error states are
/// handled globally by `GenerationReadyBanner`/`showAppErrorDialog` so every
/// screen (not just chat) gets identical treatment, and so a completed job
/// can never get stuck showing a stale "ready" message here forever (the
/// bug this simplification fixes: this widget previously rendered its own
/// success/error state with no way to mark it "seen").
class ChatGenerationStatus extends ConsumerWidget {
  const ChatGenerationStatus({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(generationJobServiceProvider);
    if (!job.isRunning) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final label = switch (job.kind) {
      _ when job.topic != null && job.topic != 'Learning path' =>
        'Generating on "${job.topic}"…',
      _ => 'Generating…',
    };

    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  color: theme.colorScheme.onPrimaryContainer,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
