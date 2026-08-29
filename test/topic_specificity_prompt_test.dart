import 'package:ai_quiz_app/data/remote/ai/models/quiz_generation_request.dart';
import 'package:ai_quiz_app/data/remote/ai/topic_specificity_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

QuizGenerationRequest _req(String topic, {String difficulty = 'easy'}) =>
    QuizGenerationRequest(
      topic: topic,
      difficulty: difficulty,
      questionCount: 5,
      language: 'English',
      questionType: 'mcq',
      randomizeQuestions: true,
      randomizeOptions: true,
      generateExplanations: true,
    );

void main() {
  group('TopicSpecificityPrompt', () {
    test('Islamic history blocks generic Islam trivia', () {
      final block = TopicSpecificityPrompt.block(_req('Islamic history'));
      expect(block, contains('ISLAMIC HISTORY'));
      expect(block, contains('FORBIDDEN'));
      expect(block, contains('Ramadan'));
    });

    test('Bio medical scopes to biomedical not general biology', () {
      final block = TopicSpecificityPrompt.block(
        _req('Bio medical', difficulty: 'medium'),
      );
      expect(block, contains('BIOMEDICAL'));
      expect(block, isNot(contains('GENERAL SCOPE')));
    });

    test('suppresses beginner track for scoped topics', () {
      expect(
        TopicSpecificityPrompt.suppressBeginnerTrack(_req('Islamic history')),
        isTrue,
      );
    });

    test('does not suppress beginner track for general topics', () {
      expect(
        TopicSpecificityPrompt.suppressBeginnerTrack(_req('Python basics')),
        isFalse,
      );
    });
  });
}
