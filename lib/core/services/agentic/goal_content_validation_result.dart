/// Outcome of the agentic goal-content validation pipeline.
enum GoalValidationLayer { deterministic, agent }

enum GoalValidationVerdict { approved, rejected, borderline }

class GoalContentValidationResult {
  const GoalContentValidationResult({
    required this.verdict,
    required this.reason,
    this.layer = GoalValidationLayer.deterministic,
  });

  final GoalValidationVerdict verdict;
  final String reason;
  final GoalValidationLayer layer;

  bool get approved => verdict == GoalValidationVerdict.approved;

  factory GoalContentValidationResult.approved(
    String reason, {
    GoalValidationLayer layer = GoalValidationLayer.deterministic,
  }) =>
      GoalContentValidationResult(
        verdict: GoalValidationVerdict.approved,
        reason: reason,
        layer: layer,
      );

  factory GoalContentValidationResult.rejected(
    String reason, {
    GoalValidationLayer layer = GoalValidationLayer.deterministic,
  }) =>
      GoalContentValidationResult(
        verdict: GoalValidationVerdict.rejected,
        reason: reason,
        layer: layer,
      );
}
