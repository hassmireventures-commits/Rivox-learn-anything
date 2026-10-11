import 'package:ai_quiz_app/core/services/agentic/learner_session_action.dart';
import 'package:ai_quiz_app/data/remote/ai/orchestrator_decision.dart';
import 'package:test/test.dart';

void main() {
  test('fromOrchestratorDecision maps openPathModule', () {
    final action = LearnerSessionAction.fromOrchestratorDecision(
      const OrchestratorDecision(
        action: LearningAction.openPathModule,
        reason: 'Keep going',
        topic: 'Module 2',
        pathId: 'path-1',
        moduleIndex: 1,
      ),
    );
    expect(action.kind, LearnerSessionKind.continuePath);
    expect(action.pathId, 'path-1');
    expect(action.moduleIndex, 1);
  });

  test('toProposedAction builds quiz proposal', () {
    final action = LearnerSessionAction(
      kind: LearnerSessionKind.generateQuiz,
      title: 'Practice',
      reason: 'Because',
      topic: 'SQL',
      questionCount: 10,
    );
    final proposed = action.toProposedAction();
    expect(proposed?.isQuiz, isTrue);
    expect(proposed?.topic, 'SQL');
    expect(proposed?.questionCount, 10);
  });
}
