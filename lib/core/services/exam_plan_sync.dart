import '../../data/local/models/learner_profile.dart';
import '../../data/local/repositories/goal_progress_repository.dart';
import 'exam_notification_scheduler.dart';

/// Regenerates the study plan and reschedules exam notifications.
Future<void> syncExamPlanAndReminders({
  required GoalProgressRepository progress,
  required LearnerProfile profile,
}) async {
  if (profile.goalMode != 'exam_prep' || profile.examDate == null) {
    await progress.clearStudyPlan();
    await ExamNotificationScheduler.instance.reschedule();
    return;
  }

  await progress.regenerateStudyPlan(
    examDate: profile.examDate!,
    dailyMinutes: profile.dailyMinutesGoal ?? 15,
  );
  await ExamNotificationScheduler.instance.reschedule();
}
