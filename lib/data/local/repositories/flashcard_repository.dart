import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../isar_service.dart';
import '../models/flashcard.dart';
import '../models/question.dart';

/// Pure SM-2 (SuperMemo-2) spaced-repetition math, extracted so it can be unit
/// tested without an Isar instance.
class SpacedRepetition {
  const SpacedRepetition._();

  /// Computes the next ease factor / interval / repetitions for a review.
  ///
  /// [quality] is 0-5 (a 4-button Again/Hard/Good/Easy UI maps to 0/3/4/5).
  static ({double easeFactor, int intervalDays, int repetitions}) review({
    required double easeFactor,
    required int intervalDays,
    required int repetitions,
    required int quality,
  }) {
    int newRepetitions;
    int newIntervalDays;
    if (quality < 3) {
      newRepetitions = 0;
      newIntervalDays = 1;
    } else {
      newRepetitions = repetitions + 1;
      newIntervalDays = newRepetitions == 1
          ? 1
          : (newRepetitions == 2 ? 6 : (intervalDays * easeFactor).round());
    }

    final newEaseFactor = (easeFactor +
            (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02)))
        .clamp(1.3, double.infinity);

    return (
      easeFactor: newEaseFactor,
      intervalDays: newIntervalDays,
      repetitions: newRepetitions,
    );
  }
}

class FlashcardRepository {
  FlashcardRepository(this._isarService);

  final IsarService _isarService;
  Isar get _db => _isarService.db;

  /// Cards due for review (soonest-due first), for the given goal mode.
  Future<List<Flashcard>> getDueCards(String goalMode, {int limit = 20}) async {
    final now = DateTime.now();
    return _db.flashcards
        .filter()
        .goalModeEqualTo(goalMode, caseSensitive: false)
        .nextReviewAtLessThan(now, include: true)
        .sortByNextReviewAt()
        .limit(limit)
        .findAll();
  }

  Future<int> countDue(String goalMode) async {
    final now = DateTime.now();
    return _db.flashcards
        .filter()
        .goalModeEqualTo(goalMode, caseSensitive: false)
        .nextReviewAtLessThan(now, include: true)
        .count();
  }

  Future<void> addCards(List<Flashcard> cards) async {
    if (cards.isEmpty) return;
    await _db.writeTxn(() async {
      await _db.flashcards.putAll(cards);
    });
  }

  /// Records a review using the standard SM-2 algorithm.
  ///
  /// [quality] is 0-5 (a 4-button Again/Hard/Good/Easy UI maps to 0/3/4/5).
  Future<void> recordReview(String uuid, int quality) async {
    final card = await _db.flashcards.filter().uuidEqualTo(uuid).findFirst();
    if (card == null) return;

    final result = SpacedRepetition.review(
      easeFactor: card.easeFactor,
      intervalDays: card.intervalDays,
      repetitions: card.repetitions,
      quality: quality,
    );

    final now = DateTime.now();
    card
      ..easeFactor = result.easeFactor
      ..intervalDays = result.intervalDays
      ..repetitions = result.repetitions
      ..lastReviewedAt = now
      ..nextReviewAt = now.add(Duration(days: result.intervalDays));

    await _db.writeTxn(() async {
      await _db.flashcards.put(card);
    });
  }

  /// Builds a free (no AI call) flashcard from a wrongly-answered question.
  static Flashcard fromWrongQuestion(
    Question question, {
    required String goalMode,
    required String uuid,
  }) {
    var correctText = '';
    try {
      final options = (jsonDecode(question.optionsJson) as List).cast<String>();
      if (question.correctIndex >= 0 && question.correctIndex < options.length) {
        correctText = options[question.correctIndex];
      }
    } catch (_) {}

    final explanation = (question.explanation ?? '').trim();
    final back = explanation.isEmpty
        ? correctText
        : (correctText.isEmpty ? explanation : '$correctText\n\n$explanation');

    final now = DateTime.now();
    return Flashcard()
      ..uuid = uuid
      ..front = question.text
      ..back = back
      ..sourceType = 'mistake'
      ..sourceRef = '${question.quizUuid}:${question.orderIndex}'
      ..goalMode = goalMode
      ..createdAt = now
      ..nextReviewAt = now;
  }
}
