import '../../../data/remote/ai/chat_reply_result.dart';
import '../../../data/remote/ai/orchestrator_decision.dart';

/// Single ranked “next session” the Home orchestrator surfaces (MoSCoW M1/M2).
enum LearnerSessionKind {
  openReadyGeneration,
  flashcardReview,
  continuePath,
  generateQuiz,
  suggestPath,
  remedialQuiz,
  encourageBreak,
  dailyContent,
  openStudyPlan,
}

class LearnerSessionAction {
  const LearnerSessionAction({
    required this.kind,
    required this.title,
    required this.reason,
    this.topic,
    this.questionCount,
    this.difficulty,
    this.pathId,
    this.moduleIndex,
    this.readyRoute,
    this.flashcardsDue,
    this.navigateRoute,
  });

  final LearnerSessionKind kind;
  final String title;
  final String reason;
  final String? topic;
  final int? questionCount;
  final String? difficulty;
  final String? pathId;
  final int? moduleIndex;
  final String? readyRoute;
  final int? flashcardsDue;
  final String? navigateRoute;

  ChatProposedAction? toProposedAction() {
    return switch (kind) {
      LearnerSessionKind.generateQuiz ||
      LearnerSessionKind.remedialQuiz =>
        ChatProposedAction.quiz(
          topic: topic ?? title,
          questionCount: questionCount,
          difficulty: difficulty,
        ),
      LearnerSessionKind.suggestPath => ChatProposedAction.path(
          topic: topic ?? title,
        ),
      _ => null,
    };
  }

  static LearnerSessionAction fromOrchestratorDecision(OrchestratorDecision d) {
    return switch (d.action) {
      LearningAction.encourageBreak => LearnerSessionAction(
          kind: LearnerSessionKind.encourageBreak,
          title: 'Take a short break',
          reason: d.reason,
        ),
      LearningAction.openPathModule => LearnerSessionAction(
          kind: LearnerSessionKind.continuePath,
          title: d.topic ?? 'Continue your path',
          reason: d.reason,
          pathId: d.pathId,
          moduleIndex: d.moduleIndex,
        ),
      LearningAction.suggestPath => LearnerSessionAction(
          kind: LearnerSessionKind.suggestPath,
          title: d.topic ?? 'New learning path',
          reason: d.reason,
          topic: d.topic,
        ),
      LearningAction.remedialQuiz => LearnerSessionAction(
          kind: LearnerSessionKind.remedialQuiz,
          title: d.topic ?? 'Quick review',
          reason: d.reason,
          topic: d.topic,
          questionCount: d.questionCount,
          difficulty: d.difficulty,
        ),
      LearningAction.generateQuiz ||
      LearningAction.followUp ||
      LearningAction.summarizeWeaknesses =>
        LearnerSessionAction(
          kind: LearnerSessionKind.generateQuiz,
          title: d.topic ?? 'Practice quiz',
          reason: d.reason,
          topic: d.topic,
          questionCount: d.questionCount,
          difficulty: d.difficulty,
        ),
    };
  }
}
