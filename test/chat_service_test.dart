import 'package:ai_quiz_app/data/remote/ai/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatService.parseReply', () {
    test('extracts reply from clean {"reply": "..."} JSON', () {
      const raw = '{"reply": "Photosynthesis converts light into chemical energy."}';
      expect(
        ChatService.parseReply(raw),
        'Photosynthesis converts light into chemical energy.',
      );
    });

    test('extracts reply when JSON is wrapped in a markdown code fence', () {
      const raw = '```json\n{"reply": "Mitochondria are the powerhouse of the cell."}\n```';
      expect(ChatService.parseReply(raw), 'Mitochondria are the powerhouse of the cell.');
    });

    test('trims whitespace around the reply text', () {
      const raw = '{"reply": "  Extra spaces should be trimmed.  "}';
      expect(ChatService.parseReply(raw), 'Extra spaces should be trimmed.');
    });

    test('falls back to raw trimmed text when the model ignores the JSON contract', () {
      const raw = '  Just a plain sentence, no JSON at all.  ';
      expect(ChatService.parseReply(raw), 'Just a plain sentence, no JSON at all.');
    });

    test('throws InvalidJsonException when the model returns nothing usable', () {
      expect(() => ChatService.parseReply('   '), throwsA(isA<Exception>()));
    });

    test('ignores unrelated JSON without a reply key and falls back to raw text', () {
      const raw = '{"notReply": "unexpected shape"}';
      // No usable `reply` field -> falls back to the raw (non-empty) text.
      expect(ChatService.parseReply(raw), raw);
    });
  });

  group('ChatService.parseReplyWithAction', () {
    test('action "none" (or omitted) yields a null action', () {
      const raw = '{"reply": "The mitochondria is the powerhouse of the cell.", "action": "none"}';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, 'The mitochondria is the powerhouse of the cell.');
      expect(result.action, isNull);
    });

    test('missing action field entirely yields a null action (backward compatible)', () {
      const raw = '{"reply": "Just answering your question."}';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, 'Just answering your question.');
      expect(result.action, isNull);
    });

    test('proposeQuiz with all fields decodes a quiz action', () {
      const raw = '{"reply": "Want a quiz on AWS?", "action": "proposeQuiz", '
          '"quizTopic": "AWS", "quizQuestionCount": 12, "quizDifficulty": "hard"}';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, 'Want a quiz on AWS?');
      expect(result.action, isNotNull);
      expect(result.action!.isQuiz, isTrue);
      expect(result.action!.topic, 'AWS');
      expect(result.action!.questionCount, 12);
      expect(result.action!.difficulty, 'hard');
    });

    test('proposePath with topic only decodes a path action with null moduleCount', () {
      const raw = '{"reply": "Want a learning path on Rust?", "action": "proposePath", '
          '"pathTopic": "Rust"}';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.action, isNotNull);
      expect(result.action!.isPath, isTrue);
      expect(result.action!.topic, 'Rust');
      expect(result.action!.pathModuleCount, isNull);
    });

    test('proposeQuiz missing the required quizTopic degrades to no action, reply still returned', () {
      const raw = '{"reply": "Sure, want a quiz?", "action": "proposeQuiz"}';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, 'Sure, want a quiz?');
      expect(result.action, isNull);
    });

    test('unrecognized action string degrades to no action, reply still returned', () {
      const raw = '{"reply": "Hello!", "action": "doSomethingWeird"}';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, 'Hello!');
      expect(result.action, isNull);
    });

    test('non-JSON raw text still returns a plain reply with a null action', () {
      const raw = 'Just a plain sentence, no JSON at all.';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, raw);
      expect(result.action, isNull);
    });
  });
}
