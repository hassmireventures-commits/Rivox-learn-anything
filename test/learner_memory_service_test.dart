import 'package:ai_quiz_app/core/services/learner_memory_scheduler.dart';
import 'package:ai_quiz_app/core/services/learner_memory_service.dart';
import 'package:ai_quiz_app/data/local/models/quiz_session.dart';
import 'package:flutter_test/flutter_test.dart';

QuizSession _session({
  required String topic,
  required double accuracy,
  required DateTime completedAt,
}) {
  return QuizSession()
    ..uuid = 'quiz-${completedAt.millisecondsSinceEpoch}-$topic'
    ..topic = topic
    ..difficulty = 'medium'
    ..questionType = 'mcq'
    ..questionCount = 10
    ..language = 'en'
    ..randomizeQuestions = false
    ..randomizeOptions = false
    ..generateExplanations = false
    ..startedAt = completedAt
    ..completedAt = completedAt
    ..source = 'solo'
    ..accuracy = accuracy;
}

void main() {
  group('LearnerMemoryService.topicAccuracyFrom', () {
    test('empty input produces an empty map', () {
      expect(LearnerMemoryService.topicAccuracyFrom(const []), isEmpty);
    });

    test('averages accuracy across multiple sessions of the same topic', () {
      final now = DateTime.now();
      final sessions = [
        _session(topic: 'AWS', accuracy: 80, completedAt: now),
        _session(topic: 'AWS', accuracy: 60, completedAt: now.subtract(const Duration(days: 1))),
      ];
      final result = LearnerMemoryService.topicAccuracyFrom(sessions);
      expect(result['AWS'], 70);
    });

    test('most-recently-active topic (first in the input list) comes first', () {
      final now = DateTime.now();
      // Caller is expected to pass sessions sorted most-recent-first, as
      // StatsRepository/the real query does.
      final sessions = [
        _session(topic: 'Python', accuracy: 50, completedAt: now),
        _session(topic: 'AWS', accuracy: 90, completedAt: now.subtract(const Duration(days: 2))),
      ];
      final result = LearnerMemoryService.topicAccuracyFrom(sessions);
      expect(result.keys.first, 'Python');
    });

    test('respects maxTopics', () {
      final now = DateTime.now();
      final sessions = List.generate(
        5,
        (i) => _session(topic: 'Topic$i', accuracy: 50, completedAt: now.subtract(Duration(days: i))),
      );
      final result = LearnerMemoryService.topicAccuracyFrom(sessions, maxTopics: 2);
      expect(result.length, 2);
    });
  });

  group('LearnerMemoryService.computeStreaks', () {
    test('empty input produces (0, 0)', () {
      expect(LearnerMemoryService.computeStreaks(const []), (0, 0));
    });

    test('consecutive days ending today give a matching current streak', () {
      final today = DateTime.now();
      final dates = [
        today,
        today.subtract(const Duration(days: 1)),
        today.subtract(const Duration(days: 2)),
      ];
      final result = LearnerMemoryService.computeStreaks(dates);
      expect(result.$1, 3); // currentStreak
      expect(result.$2, 3); // longestStreak
    });

    test('a gap keeps the longest streak but resets the current one', () {
      final today = DateTime.now();
      final dates = [
        today.subtract(const Duration(days: 10)),
        today.subtract(const Duration(days: 9)),
        today.subtract(const Duration(days: 8)),
        today.subtract(const Duration(days: 7)), // 4-day run, then a gap
        today, // isolated day
      ];
      final result = LearnerMemoryService.computeStreaks(dates);
      expect(result.$1, 1); // currentStreak: just today
      expect(result.$2, 4); // longestStreak: the earlier 4-day run
    });

    test('last activity more than a day ago gives a zero current streak', () {
      final today = DateTime.now();
      final dates = [today.subtract(const Duration(days: 5))];
      final result = LearnerMemoryService.computeStreaks(dates);
      expect(result.$1, 0);
    });
  });

  group('LearnerMemoryService.frequentlyMissedFrom', () {
    test('empty input produces an empty list', () {
      expect(LearnerMemoryService.frequentlyMissedFrom(const []), isEmpty);
    });

    test('ignores null/blank topics and sorts by miss count descending', () {
      final result = LearnerMemoryService.frequentlyMissedFrom([
        'AWS',
        'AWS',
        'Python',
        null,
        '',
        'AWS',
        'Python',
      ]);
      expect(result, ['AWS', 'Python']);
    });

    test('respects maxTopics', () {
      final result = LearnerMemoryService.frequentlyMissedFrom(
        ['A', 'B', 'C', 'D'],
        maxTopics: 2,
      );
      expect(result.length, 2);
    });
  });

  group('LearnerMemoryScheduler.shouldSkip', () {
    test('force always proceeds, regardless of last-refreshed date', () {
      expect(
        LearnerMemoryScheduler.shouldSkip(force: true, lastRefreshedDate: '2026-09-08', today: '2026-09-08'),
        isFalse,
      );
    });

    test('skips when already refreshed today', () {
      expect(
        LearnerMemoryScheduler.shouldSkip(force: false, lastRefreshedDate: '2026-09-08', today: '2026-09-08'),
        isTrue,
      );
    });

    test('proceeds when last refresh was a different day', () {
      expect(
        LearnerMemoryScheduler.shouldSkip(force: false, lastRefreshedDate: '2026-09-07', today: '2026-09-08'),
        isFalse,
      );
    });

    test('proceeds when never refreshed before', () {
      expect(
        LearnerMemoryScheduler.shouldSkip(force: false, lastRefreshedDate: null, today: '2026-09-08'),
        isFalse,
      );
    });
  });
}
