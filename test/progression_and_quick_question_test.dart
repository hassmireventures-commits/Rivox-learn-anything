import 'dart:math';

import 'package:ai_quiz_app/core/services/notification_quick_question.dart';
import 'package:ai_quiz_app/core/services/progression.dart';
import 'package:ai_quiz_app/core/services/youtube_search_service.dart';
import 'package:ai_quiz_app/data/local/models/question.dart';
import 'package:flutter_test/flutter_test.dart';

DateTime _d(int day) => DateTime(2026, 10, day);

Question _question({
  String text = 'Which word is a synonym of "rapid"?',
  String options = '["Quick","Slow","Late","Heavy"]',
  int correct = 0,
  String type = 'mcq',
  String? stimulus,
}) =>
    Question()
      ..quizUuid = 'quiz-1'
      ..orderIndex = 0
      ..text = text
      ..optionsJson = options
      ..correctIndex = correct
      ..explanation = 'Rapid means fast.'
      ..type = type
      ..stimulusJson = stimulus;

void main() {
  group('Progression.streak', () {
    test('consecutive days count, today inactive is only "at risk"', () {
      final s = Progression.streak([_d(1), _d(2), _d(3)], today: _d(4));
      expect(s.current, 3);
      expect(s.activeToday, isFalse);
      expect(s.atRisk, isTrue);
    });

    test('a missed day without a freeze resets the run', () {
      final s = Progression.streak([_d(1), _d(2), _d(4)], today: _d(4));
      expect(s.current, 1);
      expect(s.longest, 2);
    });

    test('a 7-day run earns a freeze that covers the next missed day', () {
      final days = [for (var i = 1; i <= 7; i++) _d(i), _d(9)];
      final s = Progression.streak(days, today: _d(9));
      expect(s.current, 8, reason: 'day 8 frozen, run survives');
      expect(s.frozenDays, [_d(8)]);
      expect(s.freezesBanked, 0);
      expect(s.activeToday, isTrue);
    });

    test('multiple activities on one day count once', () {
      final s = Progression.streak(
        [DateTime(2026, 10, 1, 9), DateTime(2026, 10, 1, 21)],
        today: _d(1),
      );
      expect(s.current, 1);
    });
  });

  group('Progression XP and levels', () {
    test('xp formula and level thresholds 100, 200, 300', () {
      expect(
        Progression.xp(quizzesCompleted: 2, correctAnswers: 10, quickAnswers: 3, quickCorrect: 2),
        2 * 10 + 10 * 2 + 3 * 3 + 2 * 2,
      );
      expect(Progression.level(0).level, 1);
      expect(Progression.level(99).level, 1);
      expect(Progression.level(100).level, 2);
      expect(Progression.level(299).level, 2);
      final l3 = Progression.level(350);
      expect(l3.level, 3);
      expect(l3.xpIntoLevel, 50);
      expect(l3.xpForNext, 300);
    });
  });

  group('QuickQuestion (answer from the notification)', () {
    test('keeps the correct option plus two distractors, max three buttons', () {
      final q = QuickQuestion.fromQuestion(_question(), random: Random(1))!;
      expect(q.options, hasLength(3));
      expect(q.options[q.correctIndex], 'Quick');
      expect(q.body, contains('A) '));
    });

    test('payload round-trips and grading explains a miss', () {
      final q = QuickQuestion.fromQuestion(_question(), random: Random(2))!;
      final back = QuickQuestion.fromPayload(q.toPayload())!;
      expect(back.options, q.options);
      final wrong = (back.correctIndex + 1) % back.options.length;
      final g = back.grade(wrong);
      expect(g.correct, isFalse);
      expect(g.body, contains('Quick'));
      expect(g.body, contains('Rapid means fast.'));
      expect(back.grade(back.correctIndex).title, 'Correct!');
    });

    test('action ids map to options; other ids are ignored', () {
      expect(QuickQuestion.optionFromActionId(QuickQuestion.actionIdFor(2)), 2);
      expect(QuickQuestion.optionFromActionId('snooze'), isNull);
      expect(QuickQuestion.fromPayload('/dashboard'), isNull);
    });

    test('skips questions that cannot be answered from a notification', () {
      expect(QuickQuestion.fromQuestion(_question(type: 'short_answer')), isNull);
      expect(QuickQuestion.fromQuestion(_question(stimulus: '{"kind":"passage"}')), isNull);
      expect(QuickQuestion.fromQuestion(_question(options: '["Only"]')), isNull);
      expect(QuickQuestion.fromQuestion(_question(text: 'x' * 400)), isNull);
    });
  });

  group('YoutubeSearchService.parseResultsPage', () {
    test('reads video ids and titles in order, de-duplicated', () {
      const html = 'var ytInitialData = {"contents":['
          '{"videoRenderer":{"videoId":"abcDEF12345","thumbnail":{},"title":{"runs":[{"text":"Squat form \\u0026 cues"}]}}},'
          '{"reelShelfRenderer":{"videoId":"zzzzzzzzzzz"}},'
          '{"videoRenderer":{"videoId":"abcDEF12345","title":{"runs":[{"text":"dup"}]}}},'
          '{"videoRenderer":{"videoId":"XYZ_-987654","title":{"runs":[{"text":"Deadlift basics"}]}}}'
          ']};';
      final hits = YoutubeSearchService.parseResultsPage(html);
      expect(hits.map((h) => h.videoId), ['abcDEF12345', 'XYZ_-987654']);
      expect(hits.first.title, 'Squat form & cues');
    });

    test('empty or unrelated html yields nothing', () {
      expect(YoutubeSearchService.parseResultsPage(''), isEmpty);
      expect(YoutubeSearchService.parseResultsPage('<html>consent</html>'), isEmpty);
    });
  });
}
