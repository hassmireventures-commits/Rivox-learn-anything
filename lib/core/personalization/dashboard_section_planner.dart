/// Ordered first-viewport + content slots for the home dashboard by goal mode.
enum DashboardSlot {
  urgency,
  primaryGoalCard,
  weeklyFocus,
  quizOfDay,
  learningPulse,
  gapsOrWeak,
  providerHealth,
  stats,
  analytics,
  actions,
}

class DashboardSectionPlanner {
  const DashboardSectionPlanner._();

  /// Returns the preferred section order for [goalMode].
  /// Learning keeps the legacy pulse-first layout.
  static List<DashboardSlot> slotsFor(String goalMode) {
    return switch (goalMode) {
      'exam_prep' => const [
          DashboardSlot.urgency,
          DashboardSlot.primaryGoalCard,
          DashboardSlot.weeklyFocus,
          DashboardSlot.quizOfDay,
          DashboardSlot.learningPulse,
          DashboardSlot.gapsOrWeak,
          DashboardSlot.providerHealth,
          DashboardSlot.stats,
          DashboardSlot.analytics,
          DashboardSlot.actions,
        ],
      'career' => const [
          DashboardSlot.primaryGoalCard,
          DashboardSlot.gapsOrWeak,
          DashboardSlot.quizOfDay,
          DashboardSlot.learningPulse,
          DashboardSlot.providerHealth,
          DashboardSlot.stats,
          DashboardSlot.analytics,
          DashboardSlot.actions,
        ],
      _ => const [
          DashboardSlot.quizOfDay,
          DashboardSlot.learningPulse,
          DashboardSlot.gapsOrWeak,
          DashboardSlot.providerHealth,
          DashboardSlot.stats,
          DashboardSlot.analytics,
          DashboardSlot.actions,
        ],
    };
  }
}
