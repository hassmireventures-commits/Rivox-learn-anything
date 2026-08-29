import 'dart:convert';

import 'package:ai_quiz_app/data/local/models/question.dart';
import 'package:ai_quiz_app/data/local/repositories/flashcard_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SpacedRepetition.review (SM-2)', () {
    test('a "Good" review sequence produces the standard interval progression', () {
      var state = (easeFactor: 2.5, intervalDays: 0, repetitions: 0);

      // 1st Good review -> interval 1 day, repetitions 1.
      var result = SpacedRepetition.review(
        easeFactor: state.easeFactor,
        intervalDays: state.intervalDays,
        repetitions: state.repetitions,
        quality: 4,
      );
      expect(result.repetitions, 1);
      expect(result.intervalDays, 1);
      state = (easeFactor: result.easeFactor, intervalDays: result.intervalDays, repetitions: result.repetitions);

      // 2nd Good review -> interval 6 days, repetitions 2.
      result = SpacedRepetition.review(
        easeFactor: state.easeFactor,
        intervalDays: state.intervalDays,
        repetitions: state.repetitions,
        quality: 4,
      );
      expect(result.repetitions, 2);
      expect(result.intervalDays, 6);
      state = (easeFactor: result.easeFactor, intervalDays: result.intervalDays, repetitions: result.repetitions);

      // 3rd Good review -> interval is previous interval * ease factor, rounded.
      result = SpacedRepetition.review(
        easeFactor: state.easeFactor,
        intervalDays: state.intervalDays,
        repetitions: state.repetitions,
        quality: 4,
      );
      expect(result.repetitions, 3);
      expect(result.intervalDays, (state.intervalDays * state.easeFactor).round());
    });

    test('a low-quality ("Again") review resets repetitions and interval', () {
      final result = SpacedRepetition.review(
        easeFactor: 2.6,
        intervalDays: 15,
        repetitions: 4,
        quality: 0,
      );
      expect(result.repetitions, 0);
      expect(result.intervalDays, 1);
    });

    test('a low-quality review lowers the ease factor', () {
      final result = SpacedRepetition.review(
        easeFactor: 2.5,
        intervalDays: 6,
        repetitions: 2,
        quality: 0,
      );
      expect(result.easeFactor, lessThan(2.5));
    });

    test('ease factor never drops below 1.3, even after repeated Again reviews', () {
      var ease = 1.3;
      for (var i = 0; i < 20; i++) {
        final result = SpacedRepetition.review(
          easeFactor: ease,
          intervalDays: 1,
          repetitions: 0,
          quality: 0,
        );
        ease = result.easeFactor;
        expect(ease, greaterThanOrEqualTo(1.3));
      }
      expect(ease, 1.3);
    });

    test('an "Easy" review raises the ease factor', () {
      final result = SpacedRepetition.review(
        easeFactor: 2.5,
        intervalDays: 6,
        repetitions: 2,
        quality: 5,
      );
      expect(result.easeFactor, greaterThan(2.5));
    });
  });

  group('FlashcardRepository.fromWrongQuestion', () {
    test('combines correct answer text and explanation into back', () {
      final question = Question()
        ..quizUuid = 'quiz-1'
        ..orderIndex = 2
        ..text = 'What is the capital of France?'
        ..optionsJson = jsonEncode(['London', 'Paris', 'Berlin', 'Madrid'])
        ..correctIndex = 1
        ..explanation = 'Paris has been the capital since the Middle Ages.'
        ..type = 'mcq'
        ..isCorrect = false;

      final card = FlashcardRepository.fromWrongQuestion(
        question,
        goalMode: 'learning',
        uuid: 'card-uuid-1',
      );

      expect(card.front, 'What is the capital of France?');
      expect(card.back, contains('Paris'));
      expect(card.back, contains('Middle Ages'));
      expect(card.sourceType, 'mistake');
      expect(card.sourceRef, 'quiz-1:2');
      expect(card.goalMode, 'learning');
      expect(card.repetitions, 0);
      expect(card.easeFactor, 2.5);
    });

    test('falls back to correct answer alone when there is no explanation', () {
      final question = Question()
        ..quizUuid = 'quiz-2'
        ..orderIndex = 0
        ..text = '2 + 2 = ?'
        ..optionsJson = jsonEncode(['3', '4', '5'])
        ..correctIndex = 1
        ..type = 'mcq'
        ..isCorrect = false;

      final card = FlashcardRepository.fromWrongQuestion(
        question,
        goalMode: 'learning',
        uuid: 'card-uuid-2',
      );

      expect(card.back, '4');
    });
  });
}
