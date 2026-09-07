import 'package:ai_quiz_app/core/services/learner_goal_guard.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearnerGoalGuard.isTopicTooVague', () {
    test('short but real subjects are not too vague', () {
      for (final topic in ['AWS', 'SQL', 'Git', 'Vue', 'Go', 'R', 'C']) {
        expect(
          LearnerGoalGuard.isTopicTooVague(topic),
          isFalse,
          reason: '"$topic" should be accepted as a specific subject',
        );
      }
    });

    test('generic filler words are too vague', () {
      for (final topic in ['learning', 'Learn', 'studying', 'anything', 'skills']) {
        expect(
          LearnerGoalGuard.isTopicTooVague(topic),
          isTrue,
          reason: '"$topic" should be rejected as too vague',
        );
      }
    });

    test('empty/blank input is too vague', () {
      expect(LearnerGoalGuard.isTopicTooVague(''), isTrue);
      expect(LearnerGoalGuard.isTopicTooVague('   '), isTrue);
    });
  });

  group('LearnerGoalGuard.validateDraft', () {
    test('accepts a short specific topic for the default (learning) goal mode', () {
      final result = LearnerGoalGuard.validateDraft(
        goalMode: 'learning',
        goalContext: '',
        topicsRaw: 'AWS',
      );
      expect(result, isNull);
    });

    test('rejects a purely vague topic for the default goal mode', () {
      final result = LearnerGoalGuard.validateDraft(
        goalMode: 'learning',
        goalContext: '',
        topicsRaw: 'learning',
      );
      expect(result, 'tooVague');
    });

    test('rejects empty topics for the default goal mode', () {
      final result = LearnerGoalGuard.validateDraft(
        goalMode: 'learning',
        goalContext: '',
        topicsRaw: '',
      );
      expect(result, 'topics');
    });
  });
}
