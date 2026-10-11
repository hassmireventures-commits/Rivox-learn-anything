/// Next-step recommendation from the learning orchestrator (VM-testable, no I/O).
enum LearningAction {
  generateQuiz,
  suggestPath,
  summarizeWeaknesses,
  remedialQuiz,
  encourageBreak,
  followUp,
  openPathModule,
}

class OrchestratorDecision {
  const OrchestratorDecision({
    required this.action,
    required this.reason,
    this.topic,
    this.questionCount = 10,
    this.difficulty = 'medium',
    this.pathId,
    this.moduleIndex,
  });

  final LearningAction action;
  final String reason;
  final String? topic;
  final int questionCount;
  final String difficulty;
  final String? pathId;
  final int? moduleIndex;
}
