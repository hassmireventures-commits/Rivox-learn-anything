import 'package:ai_quiz_app/core/services/goal_topic_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('GoalTopicResolver.needsResolution', () {
    test('detects domain goals like elsai.ai', () {
      expect(GoalTopicResolver.needsResolution('elsai.ai'), isTrue);
      expect(GoalTopicResolver.needsResolution('https://elsai.ai'), isTrue);
    });

    test('skips normal study topics', () {
      expect(GoalTopicResolver.needsResolution('Python'), isFalse);
      expect(GoalTopicResolver.needsResolution('Islamic history'), isFalse);
    });

    test('detects other TLDs', () {
      expect(GoalTopicResolver.needsResolution('acme.io'), isTrue);
      expect(GoalTopicResolver.needsResolution('startup.dev'), isTrue);
    });
  });

  group('ResolvedGoalTopic.promptBlock', () {
    test('includes scope and forbidden list', () {
      const r = ResolvedGoalTopic(
        original: 'elsai.ai',
        effectiveTopic: 'Elsai AI platform',
        learningScope: 'Learn what Elsai builds and its AI products.',
        avoid: ['generic web dev', 'unrelated ML trivia'],
      );
      expect(r.promptBlock, contains('elsai.ai'));
      expect(r.promptBlock, contains('Elsai AI platform'));
      expect(r.promptBlock, contains('generic web dev'));
    });
  });

  group('GoalTopicResolver.deterministicFallback', () {
    test('always produces scope for domain goals', () {
      final r = GoalTopicResolver.deterministicFallback('elsai.ai');
      expect(r.effectiveTopic, contains('Elsai'));
      expect(r.learningScope.length, greaterThan(40));
      expect(r.promptBlock, contains('elsai.ai'));
    });
  });
}
