import 'dart:convert';

import 'package:ai_quiz_app/core/services/agentic/learning_plan_editor.dart';
import 'package:ai_quiz_app/data/remote/ai/chat_reply_result.dart';
import 'package:ai_quiz_app/data/remote/ai/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

List<Map<String, dynamic>> _steps(List<String> titles) =>
    [for (final t in titles) {'title': t, 'summary': 's', 'difficulty': 'medium', 'estimatedMinutes': 15}];

List<String> _titles(PathEditResult r) => r.steps.map((s) => s['title'] as String).toList();

void main() {
  group('PathEditOp / PathEditPlan decoding', () {
    test('model 1-based "module" numbers become 0-based indexes', () {
      final plan = PathEditPlan.fromJson({
        'reason': 'off-goal module',
        'ops': [
          {'op': 'remove', 'module': 3},
          {'op': 'rename', 'module': 1, 'title': 'Advanced English for IELTS'},
          {'op': 'add', 'title': 'Listening: maps', 'module': 2},
          {'op': 'move', 'module': 4, 'toModule': 1},
          {'op': 'explode', 'module': 1},
          {'op': 'remove'},
        ],
      })!;
      expect(plan.ops.map((o) => o.kind), ['remove', 'rename', 'add', 'move']);
      expect(plan.ops[0].index, 2);
      expect(plan.ops[2].index, 1);
      expect(plan.ops[3].toIndex, 0);
      expect(plan.describe(), contains('removed module 3'));
    });

    test('nothing usable returns null', () {
      expect(PathEditPlan.fromJson(null), isNull);
      expect(PathEditPlan.fromJson({'ops': []}), isNull);
      expect(PathEditPlan.fromJson({'ops': [{'op': 'add'}]}), isNull);
    });
  });

  group('LearningPlanEditor.applyOps', () {
    test('remove before the current module moves the progress pointer back', () {
      final r = LearningPlanEditor.applyOps(
        _steps(['A', 'B', 'C', 'D']),
        [const PathEditOp.remove(index: 0)],
        currentIndex: 2,
      );
      expect(_titles(r), ['B', 'C', 'D']);
      expect(r.currentIndex, 1, reason: 'learner is still on C');
    });

    test('add before the current module moves the pointer forward', () {
      final r = LearningPlanEditor.applyOps(
        _steps(['A', 'B']),
        [const PathEditOp.add(title: 'New', index: 0)],
        currentIndex: 1,
      );
      expect(_titles(r), ['New', 'A', 'B']);
      expect(r.currentIndex, 2);
    });

    test('rename clears stale notes and video for that module', () {
      final steps = _steps(['Advanced English'])..first['youtubeVideoId'] = 'abcdefghijk';
      final r = LearningPlanEditor.applyOps(
        steps,
        [const PathEditOp.rename(index: 0, title: 'Advanced English for IELTS')],
        currentIndex: 0,
      );
      expect(r.steps.first['title'], 'Advanced English for IELTS');
      expect(r.steps.first['summary'], '');
      expect(r.steps.first.containsKey('youtubeVideoId'), isFalse);
    });

    test('guard rails: never below one module, out-of-range ops skipped', () {
      final r = LearningPlanEditor.applyOps(
        _steps(['Only']),
        [const PathEditOp.remove(index: 0), const PathEditOp.rename(index: 5, title: 'x')],
        currentIndex: 0,
      );
      expect(_titles(r), ['Only']);
      expect(r.applied, 0);
    });

    test('move reorders and input is not mutated', () {
      final input = _steps(['A', 'B', 'C']);
      final r = LearningPlanEditor.applyOps(
        input,
        [const PathEditOp.move(index: 2, toIndex: 0)],
        currentIndex: 0,
      );
      expect(_titles(r), ['C', 'A', 'B']);
      expect(input.map((s) => s['title']), ['A', 'B', 'C']);
    });
  });

  group('ChatService.parseReplyWithAction, self-healing actions', () {
    test('fixQuiz plus a path edit in one reply', () {
      final raw = jsonEncode({
        'reply': 'That quiz was about a car, not IELTS. I renamed the module and can rebuild the quiz.',
        'action': 'fixQuiz',
        'fixQuizId': 'quiz-123',
        'quizTopic': 'Advanced English for IELTS',
        'pathEdit': {
          'reason': 'ambiguous title',
          'ops': [
            {'op': 'rename', 'module': 2, 'title': 'Advanced English for IELTS'},
          ],
        },
      });
      final result = ChatService.parseReplyWithAction(raw);
      expect(result.action!.isFixQuiz, isTrue);
      expect(result.action!.quizId, 'quiz-123');
      expect(result.action!.topic, 'Advanced English for IELTS');
      expect(result.pathEdit!.ops.single.index, 1);

      final ctx = jsonDecode(result.toContextRef()!) as Map<String, dynamic>;
      expect(ChatProposedAction.fromJson(ctx)!.quizId, 'quiz-123');
      expect(PathEditPlan.fromJson(ctx[ChatReplyResult.pathEditKey]), isNotNull);
    });

    test('fixQuiz without an id degrades to no action', () {
      const raw = '{"reply": "ok", "action": "fixQuiz", "quizTopic": "x"}';
      expect(ChatService.parseReplyWithAction(raw).action, isNull);
    });
  });
}
