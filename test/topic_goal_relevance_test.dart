import 'package:ai_quiz_app/core/services/topic_goal_relevance.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopicGoalRelevanceGate org domains', () {
    test('elsai.ai goal matches same domain topic', () {
      final r = TopicGoalRelevanceGate.evaluate(
        topic: 'elsai.ai',
        goalLabel: 'elsai.ai',
        goalTopics: const ['elsai.ai'],
      );
      expect(r.level, TopicGoalRelevance.onGoal);
    });

    test('elsai.ai goal matches brand in resolved topic', () {
      final r = TopicGoalRelevanceGate.evaluate(
        topic: 'Elsai — organization and products',
        goalLabel: 'elsai.ai',
        goalTopics: const ['elsai.ai'],
      );
      expect(r.level, TopicGoalRelevance.onGoal);
    });

    test('Python topic stays off-goal for elsai.ai', () {
      final r = TopicGoalRelevanceGate.evaluate(
        topic: 'Python',
        goalLabel: 'elsai.ai',
        goalTopics: const ['elsai.ai'],
      );
      expect(r.level, isNot(TopicGoalRelevance.onGoal));
    });
  });
}
