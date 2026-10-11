import '../../../data/remote/ai/chat_reply_result.dart';

/// How much autonomy the app grants when executing a [ChatProposedAction].
enum AgentActionTier {
  /// Safe, reversible in-app navigation — may run immediately with undo.
  autoWithUndo,

  /// Leaves the app or opens external content — still needs an explicit tap.
  confirmExternal,

  /// Spends BYOK / Built-in quota — preflight + explicit confirm.
  confirmGeneration,
}

/// Codified autonomy tiers for the agentic pivot (MoSCoW M3).
class AgentAutonomyPolicy {
  AgentAutonomyPolicy._();

  /// Learning-path edits from chat (`PathEditPlan`) are also [AgentActionTier.autoWithUndo]:
  /// they cost no quota and `LearningPlanEditor` keeps an exact snapshot, so
  /// the agent fixes the plan itself and the learner can undo. They are not a
  /// [ChatProposedAction], so they never pass through [tierFor].
  static const AgentActionTier pathEditTier = AgentActionTier.autoWithUndo;

  static AgentActionTier tierFor(ChatProposedAction action) {
    if (action.isNavigate) return AgentActionTier.autoWithUndo;
    // In-app player now (VideoSearchScreen); YouTube itself only as fallback.
    if (action.isVideo) return AgentActionTier.confirmExternal;
    // fixQuiz regenerates (spends quota), so it confirms like any generation.
    if (action.isQuiz || action.isPath || action.isFixQuiz) {
      return AgentActionTier.confirmGeneration;
    }
    return AgentActionTier.confirmGeneration;
  }

  static bool mayAutoExecute(ChatProposedAction action) =>
      tierFor(action) == AgentActionTier.autoWithUndo;

  static bool requiresGenerationPreflight(ChatProposedAction action) =>
      tierFor(action) == AgentActionTier.confirmGeneration;
}
