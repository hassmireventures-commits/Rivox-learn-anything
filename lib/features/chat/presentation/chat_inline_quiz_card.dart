import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/remote/ai/chat_reply_result.dart';

/// Interactive multiple-choice form rendered inside an assistant reply (the
/// in-chat quiz). Stateless about answers: every pick goes out through
/// [onAnswer] and comes back as a new [quiz], so the persisted
/// `ChatMessage.contextRef` stays the single source of truth across reloads.
class ChatInlineQuizCard extends StatelessWidget {
  const ChatInlineQuizCard({
    super.key,
    required this.quiz,
    required this.onAnswer,
    this.onExplainMistakes,
    this.onAnotherRound,
    this.onFullQuiz,
  });

  final ChatInlineQuiz quiz;
  final void Function(int questionIndex, int option) onAnswer;

  /// Footer actions, shown once every question is answered. Null hides the
  /// button (e.g. while a reply is still being generated).
  final VoidCallback? onExplainMistakes;
  final VoidCallback? onAnotherRound;
  final VoidCallback? onFullQuiz;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final total = quiz.questions.length;
    return Container(
      margin: const EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: scheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Row(
              children: [
                Icon(Icons.quiz_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    quiz.topic.isEmpty ? 'Quick check' : 'Quick check: ${quiz.topic}',
                    style: theme.textTheme.titleSmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Text(
                  '${quiz.answeredCount}/$total',
                  style: theme.textTheme.labelMedium?.copyWith(color: scheme.onSurfaceVariant),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: total == 0 ? 0 : quiz.answeredCount / total,
                minHeight: 4,
                backgroundColor: scheme.surfaceContainerHighest,
              ),
            ),
          ),
          for (var i = 0; i < total; i++)
            _QuestionBlock(
              index: i,
              total: total,
              question: quiz.questions[i],
              picked: quiz.answerFor(i),
              onPick: (option) => onAnswer(i, option),
            ),
          if (quiz.isComplete) _ResultFooter(card: this),
          const SizedBox(height: 4),
        ],
      ),
    );
  }
}

class _QuestionBlock extends StatelessWidget {
  const _QuestionBlock({
    required this.index,
    required this.total,
    required this.question,
    required this.picked,
    required this.onPick,
  });

  final int index;
  final int total;
  final ChatInlineQuestion question;
  final int? picked;
  final ValueChanged<int> onPick;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final answered = picked != null;
    final correct = picked == question.correctIndex;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            total > 1 ? '${index + 1}. ${question.prompt}' : question.prompt,
            style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600, height: 1.35),
          ),
          const SizedBox(height: 8),
          for (var o = 0; o < question.options.length; o++)
            _OptionTile(
              label: question.options[o],
              letter: String.fromCharCode(65 + o),
              state: !answered
                  ? _OptionState.idle
                  : o == question.correctIndex
                      ? _OptionState.correct
                      : o == picked
                          ? _OptionState.wrong
                          : _OptionState.dimmed,
              onTap: answered ? null : () => onPick(o),
            ),
          if (answered)
            Padding(
              padding: const EdgeInsets.only(top: 2, bottom: 2),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    correct ? Icons.check_circle_rounded : Icons.info_outline_rounded,
                    size: 16,
                    color: correct ? AppTheme.accentGreen : theme.colorScheme.error,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      [
                        correct ? 'Correct.' : 'Not quite.',
                        if (question.explanation.isNotEmpty) question.explanation,
                      ].join(' '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

enum _OptionState { idle, correct, wrong, dimmed }

class _OptionTile extends StatelessWidget {
  const _OptionTile({
    required this.label,
    required this.letter,
    required this.state,
    required this.onTap,
  });

  final String label;
  final String letter;
  final _OptionState state;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final (Color border, Color fill, Color fg, IconData? trailing) = switch (state) {
      _OptionState.idle => (scheme.outlineVariant, Colors.transparent, scheme.onSurface, null),
      _OptionState.correct => (
          AppTheme.accentGreen,
          AppTheme.accentGreen.withValues(alpha: 0.12),
          scheme.onSurface,
          Icons.check_rounded,
        ),
      _OptionState.wrong => (
          scheme.error,
          scheme.error.withValues(alpha: 0.10),
          scheme.onSurface,
          Icons.close_rounded,
        ),
      _OptionState.dimmed => (
          scheme.outlineVariant.withValues(alpha: 0.5),
          Colors.transparent,
          scheme.onSurfaceVariant.withValues(alpha: 0.7),
          null,
        ),
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Semantics(
        button: onTap != null,
        selected: state == _OptionState.correct || state == _OptionState.wrong,
        child: Material(
          color: fill,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(color: border),
          ),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: ConstrainedBox(
              constraints: const BoxConstraints(minHeight: 44),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                child: Row(
                  children: [
                    Container(
                      width: 24,
                      height: 24,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: border),
                      ),
                      child: Text(letter, style: theme.textTheme.labelSmall?.copyWith(color: fg)),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label,
                        style: theme.textTheme.bodyMedium?.copyWith(color: fg, height: 1.3),
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(width: 6),
                      Icon(trailing, size: 18, color: border),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultFooter extends StatelessWidget {
  const _ResultFooter({required this.card});

  final ChatInlineQuizCard card;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final quiz = card.quiz;
    final total = quiz.questions.length;
    final perfect = quiz.score == total;
    final hasMisses = quiz.missed.isNotEmpty;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Divider(height: 1),
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                perfect ? Icons.emoji_events_rounded : Icons.insights_rounded,
                size: 20,
                color: perfect ? AppTheme.brandGold : theme.colorScheme.primary,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  perfect ? 'All $total correct. Nice work.' : '${quiz.score} of $total correct',
                  style: theme.textTheme.titleSmall,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: [
              if (hasMisses && card.onExplainMistakes != null)
                ActionChip(
                  avatar: const Icon(Icons.lightbulb_outline_rounded, size: 16),
                  label: const Text('Explain my mistakes'),
                  onPressed: card.onExplainMistakes,
                ),
              if (card.onAnotherRound != null)
                ActionChip(
                  avatar: const Icon(Icons.refresh_rounded, size: 16),
                  label: Text(perfect ? 'Harder questions' : 'Another round'),
                  onPressed: card.onAnotherRound,
                ),
              if (card.onFullQuiz != null)
                ActionChip(
                  avatar: const Icon(Icons.playlist_add_check_rounded, size: 16),
                  label: const Text('Full quiz'),
                  onPressed: card.onFullQuiz,
                ),
            ],
          ),
        ],
      ),
    );
  }
}
