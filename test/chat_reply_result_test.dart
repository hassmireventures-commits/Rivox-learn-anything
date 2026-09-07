import 'package:ai_quiz_app/data/remote/ai/chat_reply_result.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatProposedAction.toJson / fromJson round-trip', () {
    test('quiz action round-trips', () {
      const action = ChatProposedAction.quiz(topic: 'AWS', questionCount: 10, difficulty: 'medium');
      final decoded = ChatProposedAction.fromJson(action.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.isQuiz, isTrue);
      expect(decoded.topic, 'AWS');
      expect(decoded.questionCount, 10);
      expect(decoded.difficulty, 'medium');
    });

    test('path action round-trips', () {
      const action = ChatProposedAction.path(topic: 'Rust', pathModuleCount: 5);
      final decoded = ChatProposedAction.fromJson(action.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.isPath, isTrue);
      expect(decoded.topic, 'Rust');
      expect(decoded.pathModuleCount, 5);
    });
  });

  group('ChatProposedAction.fromJson defensive decoding (legacy/malformed contextRef)', () {
    test('unrecognized kind returns null, not a throw', () {
      expect(ChatProposedAction.fromJson({'kind': 'somethingElse', 'topic': 'X'}), isNull);
    });

    test('missing topic returns null', () {
      expect(ChatProposedAction.fromJson({'kind': 'quiz'}), isNull);
    });

    test('empty topic returns null', () {
      expect(ChatProposedAction.fromJson({'kind': 'quiz', 'topic': '   '}), isNull);
    });

    test('completely unrelated legacy contextRef shape returns null', () {
      expect(ChatProposedAction.fromJson({'someOldField': 'unrelated'}), isNull);
    });
  });
}
