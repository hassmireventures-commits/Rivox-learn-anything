import 'dart:convert';

import 'package:ai_quiz_app/data/remote/ai/chat_reply_result.dart';
import 'package:ai_quiz_app/data/remote/ai/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> _q(String question, List<String> options, Object answer, [String? why]) => {
      'question': question,
      'options': options,
      'answerIndex': answer,
      'explanation': ?why,
    };

void main() {
  group('ChatInlineQuiz.fromJson', () {
    test('decodes a well-formed quiz', () {
      final quiz = ChatInlineQuiz.fromJson({
        'topic': 'Recursion',
        'questions': [
          _q('What stops recursion?', ['Base case', 'Loop', 'Stack'], 0, 'It ends the calls.'),
          _q('Too deep recursion causes?', ['Stack overflow', 'Heap leak'], 0),
        ],
      });
      expect(quiz, isNotNull);
      expect(quiz!.topic, 'Recursion');
      expect(quiz.questions, hasLength(2));
      expect(quiz.questions.first.explanation, 'It ends the calls.');
      expect(quiz.answeredCount, 0);
      expect(quiz.isComplete, isFalse);
    });

    test('accepts the answer as the text of the correct option', () {
      final quiz = ChatInlineQuiz.fromJson({
        'questions': [
          {'question': '2 + 2?', 'options': ['3', '4', '5'], 'answer': '4'},
        ],
      });
      expect(quiz!.questions.single.correctIndex, 1);
    });

    test('drops invalid questions individually, keeps the valid ones', () {
      final quiz = ChatInlineQuiz.fromJson({
        'questions': [
          _q('', ['a', 'b'], 0), // no prompt
          _q('One option only', ['a'], 0),
          _q('Answer out of range', ['a', 'b'], 5),
          _q('Duplicate options', ['Same', 'same'], 0),
          _q('Valid', ['a', 'b', 'c'], 2),
        ],
      });
      expect(quiz!.questions.single.prompt, 'Valid');
    });

    test('returns null when nothing renderable is left, never throws', () {
      expect(ChatInlineQuiz.fromJson(null), isNull);
      expect(ChatInlineQuiz.fromJson('nope'), isNull);
      expect(ChatInlineQuiz.fromJson({'questions': 'x'}), isNull);
      expect(ChatInlineQuiz.fromJson({'questions': [_q('Bad', ['a'], 0)]}), isNull);
    });

    test('caps the number of questions', () {
      final quiz = ChatInlineQuiz.fromJson({
        'questions': [for (var i = 0; i < 9; i++) _q('Q$i', ['a', 'b'], 0)],
      });
      expect(quiz!.questions, hasLength(ChatInlineQuiz.maxQuestions));
    });
  });

  group('ChatInlineQuiz answering', () {
    final base = ChatInlineQuiz.fromJson({
      'topic': 'Math',
      'questions': [
        _q('1 + 1?', ['1', '2'], 1),
        _q('2 * 3?', ['6', '5'], 0),
      ],
    })!;

    test('withAnswer records a pick and scores it', () {
      final q = base.withAnswer(0, 1).withAnswer(1, 1);
      expect(q.isComplete, isTrue);
      expect(q.score, 1);
      expect(q.missed.single.$1, 1);
    });

    test('an answered question is final (double tap safe)', () {
      final once = base.withAnswer(0, 0);
      final twice = once.withAnswer(0, 1);
      expect(identical(once, twice), isTrue);
      expect(twice.answerFor(0), 0);
    });

    test('out-of-range picks are ignored', () {
      expect(identical(base.withAnswer(5, 0), base), isTrue);
      expect(identical(base.withAnswer(0, 9), base), isTrue);
    });

    test('answers survive a contextRef round-trip next to other keys', () {
      final answered = base.withAnswer(0, 1);
      final contextRef = jsonEncode({
        'kind': 'quiz',
        'topic': 'Math',
        ChatInlineQuiz.contextKey: answered.toJson(),
      });
      final restored = ChatInlineQuiz.fromContextRef(contextRef)!;
      expect(restored.answerFor(0), 1);
      expect(restored.answerFor(1), isNull);
      // The proposal decoder still reads the same blob unaffected.
      expect(ChatProposedAction.fromJson(jsonDecode(contextRef) as Map<String, dynamic>)!.isQuiz,
          isTrue);
    });

    test('history summary tells the model what was asked and how it went', () {
      final summary = base.withAnswer(0, 0).withAnswer(1, 0).toHistorySummary();
      expect(summary, contains('score 1/2'));
      expect(summary, contains('learner picked "1", wrong'));
      expect(summary, contains('learner answered correctly'));
    });
  });

  group('ChatSuggestedReplies.normalize', () {
    test('trims, de-duplicates, drops overlong, caps count', () {
      final out = ChatSuggestedReplies.normalize([
        ' Give me an example ',
        'give me an example',
        '',
        'x' * 200,
        'Quiz me',
        'Explain simply',
        'One too many',
      ]);
      expect(out, ['Give me an example', 'Quiz me', 'Explain simply']);
    });

    test('non-list input yields empty', () {
      expect(ChatSuggestedReplies.normalize('Quiz me'), isEmpty);
      expect(ChatSuggestedReplies.normalize(null), isEmpty);
    });
  });

  group('ChatService.parseReplyWithAction, inline quiz and suggestions', () {
    test('inlineQuiz action decodes the quiz and suggestions', () {
      final raw = jsonEncode({
        'reply': 'Here are 2 quick questions.',
        'action': 'inlineQuiz',
        'inlineQuiz': {
          'topic': 'HTTP',
          'questions': [
            _q('Status for Not Found?', ['200', '404', '500'], 1),
            _q('Safe method?', ['GET', 'POST'], 0),
          ],
        },
        'suggestions': ['Explain 404 vs 410', 'Quiz me again'],
      });
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, 'Here are 2 quick questions.');
      expect(result.action, isNull);
      expect(result.inlineQuiz!.questions, hasLength(2));
      expect(result.suggestions, ['Explain 404 vs 410', 'Quiz me again']);
    });

    test('a malformed inline quiz degrades to plain reply, never throws', () {
      const raw = '{"reply": "Try these.", "action": "inlineQuiz", "inlineQuiz": {"questions": 3}}';
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.reply, 'Try these.');
      expect(result.inlineQuiz, isNull);
    });

    test('toContextRef keeps action keys top-level and adds the rest', () {
      final result = ChatReplyResult(
        reply: 'r',
        action: const ChatProposedAction.quiz(topic: 'AWS'),
        inlineQuiz: ChatInlineQuiz.fromJson({
          'questions': [_q('Q', ['a', 'b'], 0)],
        }),
        suggestions: const ['More'],
      );
      final decoded = jsonDecode(result.toContextRef()!) as Map<String, dynamic>;
      expect(decoded['kind'], 'quiz');
      expect(decoded[ChatInlineQuiz.contextKey], isA<Map>());
      expect(decoded[ChatSuggestedReplies.contextKey], ['More']);
      expect(const ChatReplyResult(reply: 'plain').toContextRef(), isNull);
    });
  });
}
