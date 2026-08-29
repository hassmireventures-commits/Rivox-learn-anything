import 'package:flutter/foundation.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/repositories/goal_progress_repository.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../telemetry/telemetry_service.dart';
import 'notification_service.dart';
import 'reminder_preferences.dart';

/// Reschedules exam countdown and mock-due notifications from profile + plan.
class ExamNotificationScheduler {
  ExamNotificationScheduler._();
  static final instance = ExamNotificationScheduler._();

  Future<void> reschedule() async {
    final isar = IsarService.instance;
    final learner = LearnerRepository(isar);
    final progress = GoalProgressRepository(isar);
    final profile = await learner.getOrCreateProfile();
    final prefs = ReminderPreferencesStore.instance.current;

    if (profile.goalMode != 'exam_prep' || !prefs.examRemindersEnabled) {
      await NotificationService.instance.cancelExamReminders();
      return;
    }

    final examDate = profile.examDate;
    if (examDate == null) {
      await NotificationService.instance.cancelExamReminders();
      return;
    }

    final examName =
        profile.goalContext.trim().isEmpty ? 'your exam' : profile.goalContext.trim();

    await NotificationService.instance.scheduleExamCountdownReminders(
      examDate: examDate,
      examName: examName,
      reminderHour: prefs.reminderHour,
      reminderMinute: prefs.reminderMinute,
    );

    final mockItems = await progress.upcomingMockPlanItems(limit: 3);
    await NotificationService.instance.scheduleMockDueReminders(
      mockDays: mockItems.map((i) => i.calendarDay).toList(),
      examName: examName,
      reminderHour: prefs.reminderHour,
      reminderMinute: prefs.reminderMinute,
    );

    if (kDebugMode) {
      final daysLeft = examDate.difference(DateTime.now()).inDays;
      if (daysLeft == 7) {
        await NotificationService.instance.scheduleExamCountdownDebugPreview(
          examName: examName,
        );
      }
    }

    await TelemetryService(isar).emit('exam_reminder_scheduled', {
      'daysUntil': examDate.difference(DateTime.now()).inDays,
      'mockSlots': mockItems.length,
    });
  }
}
