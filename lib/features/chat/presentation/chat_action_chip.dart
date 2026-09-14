import 'package:flutter/material.dart';

import '../../../data/remote/ai/chat_reply_result.dart';

/// Inline "Generate quiz on X?" / "Generate a learning path on X?" button
/// attached to an assistant chat bubble that proposed an action. Purely
/// presentational — the actual firewall/quota/sizing/start sequence lives in
/// the tap callback supplied by `chat_screen.dart`. Never runs anything on
/// its own; a tap is the only thing that can trigger real generation.
class ChatActionChip extends StatefulWidget {
  const ChatActionChip({super.key, required this.action, required this.onConfirm});

  final ChatProposedAction action;
  final Future<void> Function() onConfirm;

  @override
  State<ChatActionChip> createState() => _ChatActionChipState();
}

class _ChatActionChipState extends State<ChatActionChip> {
  bool _busy = false;

  Future<void> _tap() async {
    if (_busy) return; // synchronous double-tap guard, before any await
    setState(() => _busy = true);
    try {
      await widget.onConfirm();
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = switch (widget.action) {
      final a when a.isQuiz => 'Generate quiz on ${a.topic}',
      final a when a.isVideo => 'Search YouTube for ${a.topic}',
      final a when a.isNavigate => 'Open ${a.topic}',
      final a => 'Generate a learning path on ${a.topic}',
    };
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: OutlinedButton.icon(
        onPressed: _busy ? null : _tap,
        style: OutlinedButton.styleFrom(
          foregroundColor: theme.colorScheme.primary,
          side: BorderSide(color: theme.colorScheme.primary.withValues(alpha: 0.5)),
        ),
        icon: _busy
            ? SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2, color: theme.colorScheme.primary),
              )
            : Icon(
                switch (widget.action) {
                  final a when a.isQuiz => Icons.quiz_rounded,
                  final a when a.isVideo => Icons.smart_display_rounded,
                  final a when a.isNavigate => Icons.open_in_new_rounded,
                  _ => Icons.route_rounded,
                },
                size: 18,
              ),
        label: Text(label, overflow: TextOverflow.ellipsis),
      ),
    );
  }
}
