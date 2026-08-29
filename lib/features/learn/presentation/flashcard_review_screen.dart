import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/local/models/flashcard.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';

/// Spaced-repetition flashcard review (mistakes + library-generated cards).
class FlashcardReviewScreen extends ConsumerStatefulWidget {
  const FlashcardReviewScreen({super.key, this.goalMode});

  /// Falls back to the current learner profile's goal mode when omitted.
  final String? goalMode;

  @override
  ConsumerState<FlashcardReviewScreen> createState() => _FlashcardReviewScreenState();
}

class _FlashcardReviewScreenState extends ConsumerState<FlashcardReviewScreen> {
  List<Flashcard> _cards = const [];
  int _index = 0;
  bool _showAnswer = false;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    var goalMode = widget.goalMode ?? '';
    if (goalMode.isEmpty) {
      final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
      goalMode = profile.goalMode;
    }
    final cards = await ref.read(flashcardRepositoryProvider).getDueCards(goalMode);
    if (!mounted) return;
    setState(() {
      _cards = cards;
      _index = 0;
      _showAnswer = false;
      _loading = false;
    });
  }

  Future<void> _rate(int quality) async {
    if (_index >= _cards.length) return;
    final card = _cards[_index];
    await ref.read(flashcardRepositoryProvider).recordReview(card.uuid, quality);
    if (!mounted) return;
    setState(() {
      _index++;
      _showAnswer = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_loading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.flashcardsTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final done = _cards.isEmpty || _index >= _cards.length;
    if (done) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.flashcardsTitle)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.style_rounded,
                  size: 48,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(height: 16),
                Text(
                  l10n.flashcardsEmpty,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ],
            ),
          ),
        ),
      );
    }

    final card = _cards[_index];
    return Scaffold(
      appBar: AppBar(title: Text(l10n.flashcardsTitle)),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${_index + 1} / ${_cards.length}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: AppCard(
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        card.front,
                        style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
                        textAlign: TextAlign.center,
                      ),
                      if (_showAnswer) ...[
                        const SizedBox(height: 20),
                        Divider(color: theme.colorScheme.outlineVariant),
                        const SizedBox(height: 20),
                        Text(
                          card.back,
                          style: theme.textTheme.bodyLarge,
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            if (!_showAnswer)
              PrimaryButton(
                label: l10n.flashcardShowAnswer,
                onPressed: () => setState(() => _showAnswer = true),
              )
            else
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rate(0),
                      child: Text(l10n.flashcardAgain),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rate(3),
                      child: Text(l10n.flashcardHard),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rate(4),
                      child: Text(l10n.flashcardGood),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => _rate(5),
                      child: Text(l10n.flashcardEasy),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
