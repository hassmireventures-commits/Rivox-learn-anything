import 'package:flutter_test/flutter_test.dart';
import 'package:ai_quiz_app/core/services/agentic/goal_content_validation_agent.dart';
import 'package:ai_quiz_app/core/services/goal_topic_resolver.dart';

void main() {
  group('GoalContentValidationAgent', () {
    final agent = GoalContentValidationAgent();

    test('rejects Elsaid Maher article for elsai.ai', () {
      final result = agent.validateOpenKnowledgeArticle(
        goal: 'elsai.ai',
        title: 'Elsaid Maher',
        summary: 'Egyptian professional footballer.',
      );
      expect(result.approved, isFalse);
    });

    test('rejects off-brand generation topic for org goal', () {
      final result = agent.validateGenerationTopic(
        goal: 'elsai.ai',
        topic: 'Elsaid Maher',
      );
      expect(result.approved, isFalse);
    });

    test('approves deterministic fallback topic for org goal', () {
      final fallback = GoalTopicResolver.deterministicFallback('elsai.ai');
      final result = agent.validateGenerationTopic(
        goal: 'elsai.ai',
        topic: fallback.effectiveTopic,
      );
      expect(result.approved, isTrue);
    });
  });
}
