import '../../../core/personalization/ui_personalization_controller.dart';
import '../../../core/services/generation_job_service.dart';
import '../../../data/remote/ai/orchestrator_decision.dart';
import 'learner_session_action.dart';

/// Ranks the single best next learning session for Home (MoSCoW M1).
class LearnerSessionPlanner {
  const LearnerSessionPlanner._();

  static LearnerSessionAction plan({
    required GenerationJobService job,
    required int flashcardsDue,
    required OrchestratorDecision orchestrator,
    required UiPersonalizationState ui,
  }) {
    final pending = job.pendingReadyRoute;
    if (pending != null) {
      return LearnerSessionAction(
        kind: LearnerSessionKind.openReadyGeneration,
        title: job.topic ?? 'Your quiz',
        reason: 'Ready to open — finish what you started',
        readyRoute: pending,
      );
    }

    if (flashcardsDue > 0) {
      return LearnerSessionAction(
        kind: LearnerSessionKind.flashcardReview,
        title: 'Flashcard review',
        reason: '$flashcardsDue cards due — quick win before new material',
        flashcardsDue: flashcardsDue,
      );
    }

    if (ui.goalMode == 'exam_prep' &&
        ui.examDaysRemaining != null &&
        ui.examDaysRemaining! <= 14) {
      return const LearnerSessionAction(
        kind: LearnerSessionKind.openStudyPlan,
        title: 'Study plan',
        reason: 'Exam is close — follow today’s plan',
        navigateRoute: '/exam/plan',
      );
    }

    if (orchestrator.action != LearningAction.encourageBreak) {
      return LearnerSessionAction.fromOrchestratorDecision(orchestrator);
    }

    return const LearnerSessionAction(
      kind: LearnerSessionKind.dailyContent,
      title: "Today's pick",
      reason: 'Explore today’s learning pack',
      navigateRoute: '/daily-content',
    );
  }
}
