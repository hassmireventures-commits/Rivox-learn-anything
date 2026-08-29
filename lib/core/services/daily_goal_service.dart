import '../../data/local/isar_service.dart';
import '../../data/local/repositories/learner_repository.dart';
import '../../data/local/repositories/profile_repository.dart';
import 'exam_notification_scheduler.dart';
import 'notification_service.dart';
import 'reminder_preferences.dart';
import 'study_session_tracker.dart';

class DailyGoalService {
  DailyGoalService({
    required this.profileRepository,
    required this.learnerRepository,
  });

  final ProfileRepository profileRepository;
  final LearnerRepository learnerRepository;

  static DateTime? _goalNotifiedDay;

  static Future<void> notifyIfGoalReached() async {
    final isar = IsarService.instance;
    final service = DailyGoalService(
      profileRepository: ProfileRepository(isar),
      learnerRepository: LearnerRepository(isar),
    );
    await service.checkGoalReached();
  }

  Future<int> dailyMinutesGoal() async {
    final profile = await learnerRepository.getOrCreateProfile();
    return profile.dailyMinutesGoal ?? 15;
  }

  int todayStudyMinutes() => StudySessionTracker.instance.todayMinutes;

  Future<void> checkGoalReached() async {
    final goal = await dailyMinutesGoal();
    final today = todayStudyMinutes();
    final now = DateTime.now();
    final day = DateTime(now.year, now.month, now.day);
    if (_goalNotifiedDay == day) return;
    if (today >= goal) {
      _goalNotifiedDay = day;
      await NotificationService.instance.showGoalReached();
    }
  }

  Future<void> updateReminderPreferences(ReminderPreferences prefs) async {
    await ReminderPreferencesStore.instance.save(prefs);
    await NotificationService.instance.scheduleDailyReminder();
    await ExamNotificationScheduler.instance.reschedule();
  }
}
