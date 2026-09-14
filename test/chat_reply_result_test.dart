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

    test('video action round-trips', () {
      const action = ChatProposedAction.video(topic: 'binary search trees');
      final decoded = ChatProposedAction.fromJson(action.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.isVideo, isTrue);
      expect(decoded.isQuiz, isFalse);
      expect(decoded.isPath, isFalse);
      expect(decoded.topic, 'binary search trees');
    });

    test('navigate action round-trips', () {
      const action = ChatProposedAction.navigate(topic: 'Library', route: '/library');
      final decoded = ChatProposedAction.fromJson(action.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.isNavigate, isTrue);
      expect(decoded.topic, 'Library');
      expect(decoded.route, '/library');
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

    test('navigate with an unrecognized destination name returns null', () {
      expect(
        ChatProposedAction.fromJson({'kind': 'navigate', 'topic': 'Not A Real Screen'}),
        isNull,
      );
    });

    test('navigate name match is case-insensitive', () {
      final decoded = ChatProposedAction.fromJson({'kind': 'navigate', 'topic': 'library'});
      expect(decoded, isNotNull);
      expect(decoded!.isNavigate, isTrue);
      expect(decoded.topic, 'Library');
      expect(decoded.route, '/library');
    });
  });

  group('ChatNavigationTargets.match', () {
    test('exact match returns the canonical name and route', () {
      final match = ChatNavigationTargets.match('History');
      expect(match, ('History', '/history'));
    });

    test('unrecognized name returns null', () {
      expect(ChatNavigationTargets.match('Not A Screen'), isNull);
    });
  });

  group('ChatSourceSuggestion', () {
    test('round-trips through toJson/fromJson', () {
      const source = ChatSourceSuggestion(
        title: 'Binary search tree',
        url: 'https://en.wikipedia.org/wiki/Binary_search_tree',
        source: 'Wikipedia',
      );
      final decoded = ChatSourceSuggestion.fromJson(source.toJson());
      expect(decoded, isNotNull);
      expect(decoded!.title, source.title);
      expect(decoded.url, source.url);
      expect(decoded.source, source.source);
    });

    test('missing url returns null, not a throw', () {
      expect(ChatSourceSuggestion.fromJson({'title': 'X', 'source': 'Wikipedia'}), isNull);
    });

    test('missing title returns null', () {
      expect(ChatSourceSuggestion.fromJson({'url': 'https://example.com', 'source': 'Wikipedia'}), isNull);
    });
  });
}
