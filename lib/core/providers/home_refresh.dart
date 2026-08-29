import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/ai_status_service.dart';
import '../services/daily_quiz_scheduler.dart';
import '../utils/calendar_day.dart';
import 'app_providers.dart';
import 'study_minutes_provider.dart';

/// Refreshes dashboard/home providers after goal or profile changes.
void invalidateHomeProviders(WidgetRef ref) {
  ref.invalidate(personalizationProvider);
  ref.invalidate(nextDecisionProvider);
  ref.invalidate(aiStudyPulseProvider);
  ref.invalidate(dashboardStatsProvider);
  ref.invalidate(todaysDailyQuizOfferProvider);
  ref.invalidate(todaysDailyQuizProvider);
  ref.read(todayStudyProgressProvider.notifier).refresh();
  ref.read(learningDataEpochProvider.notifier).state++;
}

/// Remounts ad slots so banner/native widgets request a fresh fill.
void bumpAdRefresh(WidgetRef ref) {
  ref.read(adRefreshEpochProvider.notifier).state++;
}

/// When the local calendar day changes, reload daily quiz state and schedule
/// today's quiz if missing (fixes stale QOTD cached across midnight).
void syncCalendarDayIfNeeded(WidgetRef ref) {
  final today = calendarDayKey();
  if (ref.read(calendarDayKeyProvider) == today) return;
  ref.read(calendarDayKeyProvider.notifier).state = today;
  ref.invalidate(todaysDailyQuizOfferProvider);
  ref.invalidate(todaysDailyQuizProvider);
  unawaited(ref.read(dailyQuizSchedulerProvider).trySchedule());
}
