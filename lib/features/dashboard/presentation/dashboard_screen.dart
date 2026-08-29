import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/responsive_layout.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/providers/study_minutes_provider.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../features/reminders/presentation/reminder_setup_sheet.dart';
import 'insights_expand_sheet.dart';
import 'recommendations_expand_sheet.dart';
import '../../../data/local/repositories/stats_repository.dart';
import '../../../core/services/daily_content_scheduler.dart';
import '../../../core/services/daily_content_service.dart';
import '../../../core/services/daily_quiz_scheduler.dart';
import '../../../core/services/generation_job_service.dart';
import '../../../core/personalization/dashboard_section_planner.dart';
import '../../../core/personalization/ui_personalization_controller.dart';
import '../../../shared/navigation/recommendation_navigation.dart';
import '../../../shared/navigation/study_path_navigation.dart';
import '../../../shared/widgets/api_limit_banner.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/ai_status_badge.dart';
import '../../../shared/widgets/ai_study_pulse_card.dart';
import '../../../core/services/ai_status_service.dart';
import '../../../shared/widgets/metric_honesty_banner.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/recent_quiz_activity_card.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../../shared/widgets/dashboard/achievement_badges.dart';
import '../../../shared/widgets/dashboard/dashboard_section_header.dart';
import '../../../shared/widgets/dashboard/geometric_wavy_header.dart';
import '../../../shared/widgets/dashboard/horizontal_feature_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final locale = Localizations.localeOf(context).toString();
    final layout = responsiveLayoutOf(context);
    final profileAsync = ref.watch(profileProvider);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final personalization = ref.watch(personalizationProvider);
    final learnerProfileAsync = ref.watch(learnerProfileProvider);
    final dailyGoal = learnerProfileAsync.asData?.value.dailyMinutesGoal ?? 15;
    final decision = ref.watch(nextDecisionProvider);
    final providersAsync = ref.watch(aiProvidersProvider);
    final rateLimitAsync = ref.watch(activeRateLimitProvider);
    // Sensible default used while personalization is loading or on error so the
    // dashboard is never replaced by a full-screen spinner.
    final ui = personalization.asData?.value ?? UiPersonalizationState(
      density: ContentDensity.comfortable,
      navOrder: const [],
      recommendations: const [],
      weakTopics: const [],
      degradeCharts: false,
      goalMode: 'learning',
      goalContextLabel: '',
      syllabusCoveragePercent: 0,
      careerReadinessPercent: 0,
      focusTitles: const [],
    );

    return Column(
      children: [
        GeometricWavyHeader(
          title: profileAsync.when(
            data: (profile) => l10n.dashboardGreeting(
              L10nHelpers.greeting(l10n),
              profile?.name ?? l10n.dashboardLearnerFallback,
            ),
            loading: () => l10n.appName,
            error: (_, _) => l10n.appName,
          ),
          subtitle: ui.goalContextLabel.isNotEmpty ? ui.goalContextLabel : null,
          actions: [
            const AiStatusBadge(),
            IconButton(
              tooltip: l10n.settingsTooltip,
              icon: const Icon(Icons.settings_outlined, color: Colors.white),
              onPressed: () => context.push('/settings'),
            ),
          ],
        ),
        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              syncCalendarDayIfNeeded(ref);
              bumpAdRefresh(ref);
              ref.read(todayStudyProgressProvider.notifier).refresh();
              await ref.read(recommendationEngineProvider).refreshRecommendations();
              ref.invalidate(dashboardStatsProvider);
              ref.invalidate(personalizationProvider);
              ref.invalidate(nextDecisionProvider);
              ref.invalidate(providerUsageProvider);
              ref.invalidate(activeRateLimitProvider);
              ref.invalidate(aiStudyPulseProvider);
              await ref.read(dailyQuizSchedulerProvider).trySchedule();
              await ref.read(anonAnalyticsSyncProvider).syncIfOptedIn();
            },
            color: AppTheme.seedColor,
            child: Builder(
              builder: (context) {
                return CustomScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  slivers: [
                    SliverPadding(
                      padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageHorizontal),
                      sliver: Builder(
                        builder: (context) {
                          final children = <Widget>[
                            if (providersAsync.asData?.value.isEmpty ?? false)
                              AppCard(
                                color: AppTheme.accentOrange.withValues(alpha: 0.18),
                                onTap: () => context.push('/settings/providers'),
                                child: Row(
                                  children: [
                                    const Icon(Icons.key_rounded, color: AppTheme.accentOrange),
                                    const SizedBox(width: 12),
                                    Expanded(child: Text(l10n.dashboardAddProviderPrompt)),
                                    const Icon(Icons.chevron_right_rounded),
                                  ],
                                ),
                              ),
                            rateLimitAsync.when(
                              data: (limit) {
                                final until = limit?.retryAfterUntil;
                                if (until == null || !until.isAfter(DateTime.now())) {
                                  return const SizedBox.shrink();
                                }
                                return ApiLimitCountdownBanner(
                                  providerName: limit!.providerKey,
                                  retryAfterUntil: until,
                                  onExpired: () {
                                    ref.invalidate(activeRateLimitProvider);
                                  },
                                );
                              },
                              loading: () => const SizedBox.shrink(),
                              error: (_, _) => const SizedBox.shrink(),
                            ),
                            const SizedBox(height: AppTheme.cardGap),
                            const AiStudyPulseCard(),
                            ..._dashboardSections(
                              context: context,
                              ref: ref,
                              ui: ui,
                              layout: layout,
                              l10n: l10n,
                              locale: locale,
                              dailyGoal: dailyGoal,
                              decision: decision,
                              statsAsync: statsAsync,
                              providersAsync: providersAsync,
                            ),
                            SizedBox(height: AppTheme.cardGap),
                          ];
                          return SliverList(delegate: SliverChildListDelegate(children));
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

List<Widget> _dashboardSections({
  required BuildContext context,
  required WidgetRef ref,
  required UiPersonalizationState ui,
  required ResponsiveLayout layout,
  required dynamic l10n,
  required String locale,
  required int dailyGoal,
  required AsyncValue<dynamic> decision,
  required AsyncValue<DashboardStats> statsAsync,
  required AsyncValue<List<dynamic>> providersAsync,
}) {
  final gap = const SizedBox(height: AppTheme.cardGap);
  final widgets = <Widget>[];

  for (final slot in DashboardSectionPlanner.slotsFor(ui.goalMode)) {
    switch (slot) {
      case DashboardSlot.urgency:
        if (ui.examDaysRemaining != null && ui.examDaysRemaining! <= 14) {
          widgets.add(gap);
          widgets.add(_ExamUrgencyBanner(daysRemaining: ui.examDaysRemaining!));
        }
      case DashboardSlot.primaryGoalCard:
        if (ui.goalMode == 'exam_prep') {
          widgets.add(gap);
          widgets.add(_ExamCountdownBanner(ui: ui));
        } else if (ui.goalMode == 'career') {
          widgets.add(gap);
          widgets.add(_CareerReadinessCard(ui: ui));
        }
      case DashboardSlot.weeklyFocus:
        if (ui.goalMode == 'exam_prep' && ui.focusTitles.isNotEmpty) {
          widgets.add(gap);
          widgets.add(DashboardSectionHeader(title: l10n.examWeeklyFocusTitle));
          widgets.add(const SizedBox(height: AppTheme.cardGap));
          widgets.add(
            SizedBox(
              height: 200,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: ui.focusTitles.take(3).length,
                separatorBuilder: (_, _) => const SizedBox(width: AppTheme.cardGap),
                itemBuilder: (context, index) {
                  final topic = ui.focusTitles[index];
                  return HorizontalFeatureCard(
                    width: 200,
                    variant: HorizontalFeatureCardVariant.secondary,
                    accentIndex: index,
                    title: topic,
                    subtitle: l10n.dashboardFocusAreaReason,
                    onTap: () => openQuizInsightForTopic(context, ref, topic: topic),
                  );
                },
              ),
            ),
          );
        }
      case DashboardSlot.quizOfDay:
        widgets.add(gap);
        widgets.add(
          DashboardSectionHeader(
            title: l10n.dashboardQuizOfTheDay,
            actionLabel: ui.recommendations.isNotEmpty ? l10n.dashboardSeeAll : null,
            onAction: ui.recommendations.isNotEmpty
                ? () => showRecommendationsSheet(
                      context,
                      recommendations: ui.recommendations,
                      ui: ui,
                    )
                : null,
          ),
        );
        widgets.add(const SizedBox(height: AppTheme.cardGap));
        widgets.add(
          SizedBox(
            height: 200,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: 1 + ui.recommendations.take(3).length,
              separatorBuilder: (_, _) => const SizedBox(width: AppTheme.cardGap),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _QuizOfTheDayFeatureCard();
                }
                final rec = ui.recommendations[index - 1];
                return HorizontalFeatureCard(
                  width: 200,
                  variant: HorizontalFeatureCardVariant.secondary,
                  accentIndex: index,
                  title: rec.title,
                  subtitle: rec.reason,
                  pillLabel: rec.topic,
                  onTap: () => openRecommendation(context, ref, item: rec),
                );
              },
            ),
          ),
        );
        widgets.add(gap);
        widgets.add(const _DailyLearningPackCard());
      case DashboardSlot.learningPulse:
        widgets.add(gap);
        widgets.add(DashboardSectionHeader(title: l10n.dashboardLearningPulse));
        widgets.add(const SizedBox(height: AppTheme.cardGap));
        widgets.add(
          decision.when(
            data: (d) {
              final titles = ui.goalMode == 'exam_prep'
                  ? <String>[]
                  : (ui.focusTitles.isNotEmpty ? ui.focusTitles : ui.weakTopics);
              return SizedBox(
                height: 200,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 1 + titles.take(3).length,
                  separatorBuilder: (_, _) => const SizedBox(width: AppTheme.cardGap),
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return HorizontalFeatureCard(
                        width: 260,
                        gradient: AppTheme.accentBlueGradient,
                        title: d.topic ?? l10n.dashboardContinueLearn,
                        subtitle: d.reason,
                        footer: PrimaryButton(
                          label: l10n.dashboardContinueLearn,
                          icon: Icons.auto_awesome_rounded,
                          onPressed: () async {
                            final path = await ref.read(learnerRepositoryProvider).primaryActivePath();
                            if (!context.mounted) return;
                            if (path != null) {
                              context.push('/paths/${path.uuid}?module=${path.currentIndex}');
                            } else {
                              context.go('/learn');
                            }
                          },
                        ),
                      );
                    }
                    final topic = titles[index - 1];
                    return HorizontalFeatureCard(
                      width: 200,
                      variant: HorizontalFeatureCardVariant.secondary,
                      accentIndex: index,
                      title: topic,
                      subtitle: l10n.dashboardFocusAreaReason,
                      onTap: () => openQuizInsightForTopic(context, ref, topic: topic),
                    );
                  },
                ),
              );
            },
            loading: () => const SizedBox.shrink(),
            error: (_, _) => const SizedBox.shrink(),
          ),
        );
      case DashboardSlot.gapsOrWeak:
        break;
      case DashboardSlot.providerHealth:
        break;
      case DashboardSlot.stats:
        widgets.add(gap);
        widgets.add(
          statsAsync.when(
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _StatsSection(stats: stats, columns: layout.statsColumns),
                const SizedBox(height: AppTheme.cardGap),
                DashboardSectionHeader(title: l10n.dashboardAchievementsTitle),
                const SizedBox(height: AppTheme.cardGap),
                AchievementBadgesSection(stats: stats),
                const SizedBox(height: 12),
                OutlinedButton.icon(
                  onPressed: () {
                    ref.invalidate(providerUsageProvider);
                    ref.invalidate(totalAiTokensTodayProvider);
                    showInsightsExpandSheet(context);
                  },
                  icon: const Icon(Icons.insights_outlined),
                  label: Text(l10n.dashboardMoreInsights),
                ),
              ],
            ),
            loading: () => const Center(
              child: CircularProgressIndicator(color: AppTheme.seedColor),
            ),
            error: (e, _) => Text('$e'),
          ),
        );
        widgets.add(gap);
        widgets.add(const ReminderSummaryButton());
      case DashboardSlot.analytics:
        widgets.add(
          statsAsync.when(
            data: (stats) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                gap,
                DashboardSectionHeader(title: l10n.dashboardRecentQuizActivity),
                const SizedBox(height: AppTheme.cardGap),
                if (stats.recentQuizzes.isEmpty)
                  AppCard(child: Text(l10n.dashboardNoQuizzesYet))
                else ...[
                  ...stats.recentQuizzes.take(3).map(
                        (q) => Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.cardGap),
                          child: RecentQuizActivityCard(
                            session: q,
                            locale: locale,
                            onTap: () => openQuizResult(context, q),
                          ),
                        ),
                      ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => context.go('/history?segment=quizzes'),
                      icon: const Icon(Icons.history_rounded, size: 18),
                      label: Text(l10n.dashboardSeeAllHistory),
                    ),
                  ),
                ],
              ],
            ),
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: Center(
                child: CircularProgressIndicator(color: AppTheme.seedColor),
              ),
            ),
            error: (_, _) => const SizedBox.shrink(),
          ),
        );
      case DashboardSlot.actions:
        widgets.add(gap);
        widgets.add(
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/quiz/create'),
                  icon: const Icon(Icons.add_rounded),
                  label: Text(l10n.dashboardNewQuiz),
                ),
              ),
              if (providersAsync.asData?.value.isEmpty ?? false) ...[
                const SizedBox(width: 10),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      final id = await ref.read(demoQuizServiceProvider).createDemoQuiz();
                      if (context.mounted) context.push('/quiz/play/$id');
                    },
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    label: Text(l10n.dashboardTryDemoQuiz),
                  ),
                ),
              ],
            ],
          ),
        );
    }
  }

  return widgets;
}


class _QuizOfTheDayFeatureCard extends ConsumerStatefulWidget {
  const _QuizOfTheDayFeatureCard();

  @override
  ConsumerState<_QuizOfTheDayFeatureCard> createState() => _QuizOfTheDayFeatureCardState();
}

class _QuizOfTheDayFeatureCardState extends ConsumerState<_QuizOfTheDayFeatureCard> {
  bool _generating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _autoGenerate());
  }

  Future<void> _autoGenerate() async {
    if (_generating) return;
    setState(() => _generating = true);
    await ref.read(dailyQuizSchedulerProvider).trySchedule();
    await ref.read(dailyContentSchedulerProvider).trySchedule();
    if (mounted) setState(() => _generating = false);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final generating = _generating || ref.watch(dailyQuizGeneratingProvider);
    ref.listen(calendarDayKeyProvider, (prev, next) {
      if (prev != null && prev != next) {
        unawaited(_autoGenerate());
      }
    });
    return ref.watch(todaysDailyQuizOfferProvider).when(
      data: (offer) {
        final session = offer.session;
        final pill = offer.showSlotLabel
            ? l10n.dashboardDailyQuizSlot(offer.slotNumber, offer.frequency)
            : l10n.dashboardQuizOfTheDay;
        if (session != null && session.completedAt != null) {
          final accuracy = (session.accuracy ?? 0).round();
          final title = offer.showSlotLabel
              ? l10n.dashboardDailyQuizCompletedSlot(
                  offer.completedCount,
                  offer.frequency,
                )
              : l10n.dashboardQuizOfTheDayCompleted;
          return HorizontalFeatureCard(
            width: 260,
            title: title,
            subtitle: '$accuracy% | ${session.topic}',
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.check_circle_outline, color: Colors.white, size: 22),
            ),
            pillLabel: pill,
            onTap: () => context.push('/quiz/results/${session.uuid}'),
          );
        }
        if (session != null) {
          return HorizontalFeatureCard(
            width: 260,
            title: session.topic,
            subtitle: l10n.dashboardQuizOfTheDayStart,
            pillLabel: pill,
            leading: const CircleAvatar(
              radius: 20,
              backgroundColor: Colors.white24,
              child: Icon(Icons.today_outlined, color: Colors.white, size: 22),
            ),
            onTap: () => context.push('/quiz/play/${session.uuid}'),
          );
        }
        final generateTitle = offer.showSlotLabel
            ? l10n.dashboardDailyQuizSlot(offer.slotNumber, offer.frequency)
            : l10n.dashboardQuizOfTheDay;
        final generateSubtitle = generating
            ? l10n.dashboardQuizOfTheDayGenerating
            : (offer.showSlotLabel
                ? l10n.dashboardDailyQuizGenerateSlot(
                    offer.slotNumber,
                    offer.frequency,
                  )
                : l10n.dashboardQuizOfTheDayGenerate);
        return HorizontalFeatureCard(
          width: 260,
          title: generateTitle,
          subtitle: generateSubtitle,
          pillLabel: pill,
          footer: generating
              ? const LinearProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                )
              : null,
          onTap: generating
              ? null
              : () async {
                  setState(() => _generating = true);
                  await ref
                      .read(dailyQuizSchedulerProvider)
                      .trySchedule(force: true, countBuiltinQuota: true);
                  if (mounted) setState(() => _generating = false);
                },
        );
      },
      loading: () => HorizontalFeatureCard(
        width: 260,
        title: l10n.dashboardQuizOfTheDay,
        footer: const LinearProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
      error: (e, _) => HorizontalFeatureCard(
        width: 260,
        title: l10n.dashboardQuizOfTheDay,
        subtitle: '$e',
      ),
    );
  }
}

class _StatsSection extends StatelessWidget {
  const _StatsSection({required this.stats, required this.columns});
  final DashboardStats stats;
  final int columns;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final tiles = [
      StatTile(
        label: l10n.statQuizzes,
        value: '${stats.quizzesAttempted}',
        icon: Icons.quiz_rounded,
        color: AppTheme.seedColor,
      ),
      StatTile(
        label: l10n.statAccuracy,
        value: '${stats.accuracy.toStringAsFixed(0)}%',
        icon: Icons.my_location_rounded,
        color: AppTheme.accentGreen,
      ),
      StatTile(
        label: l10n.statStreak,
        value: l10n.statStreakDays(stats.currentStreak),
        icon: Icons.local_fire_department_rounded,
        color: AppTheme.accentOrange,
      ),
      StatTile(
        label: l10n.statTopics,
        value: '${stats.topicsCovered}',
        icon: Icons.category_rounded,
        color: AppTheme.accentPink,
      ),
    ];
    return GridView.count(
      crossAxisCount: columns,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.15,
      children: tiles,
    );
  }
}

// ── Exam urgency sticky banner (≤7 days) ─────────────────────────────────────

class _ExamUrgencyBanner extends StatelessWidget {
  const _ExamUrgencyBanner({required this.daysRemaining});
  final int daysRemaining;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.5)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Colors.orange, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              l10n.dashboardUrgencyExam(daysRemaining),
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Daily learning pack ───────────────────────────────────────────────────────

class _DailyLearningPackCard extends ConsumerStatefulWidget {
  const _DailyLearningPackCard();

  @override
  ConsumerState<_DailyLearningPackCard> createState() => _DailyLearningPackCardState();
}

class _DailyLearningPackCardState extends ConsumerState<_DailyLearningPackCard> {
  DailyContentPack? _pack;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    var pack = await ref.read(dailyContentServiceProvider).findTodaysPack();
    if (pack == null) {
      unawaited(ref.read(dailyContentSchedulerProvider).trySchedule(force: true));
    }
    if (!mounted) return;
    setState(() {
      _pack = pack;
      _loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    ref.listen<int>(learningDataEpochProvider, (prev, next) {
      if (prev != next) _load();
    });
    ref.listen<GenerationJobService>(generationJobServiceProvider, (prev, next) {
      if (next.kind != GenerationJobKind.dailyContent) return;
      if (next.successRoute != null &&
          (prev?.successRoute == null || prev?.successRoute != next.successRoute)) {
        _load();
      }
    });
    final subtitle = _loading
        ? l10n.dailyContentGenerating
        : (_pack?.isComplete == true
            ? l10n.dailyContentCardSubtitle
            : l10n.dailyContentCardSubtitle);
    return AppCard(
      onTap: () => context.push('/daily-content'),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppTheme.accentBlue.withValues(alpha: 0.15),
            child: const Icon(
              Icons.auto_stories_outlined,
              color: AppTheme.accentBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dailyContentDetailTitle,
                  style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}

// ── Exam countdown card ───────────────────────────────────────────────────────

class _ExamCountdownBanner extends ConsumerWidget {
  const _ExamCountdownBanner({required this.ui});
  final UiPersonalizationState ui;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final days = ui.examDaysRemaining;
    final covered = ui.syllabusCoveragePercent;

    return AppCard(
      color: const Color(0xFFE67E22).withValues(alpha: 0.08),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MetricHonestyBanner(),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFE67E22).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.emoji_events_rounded, color: Color(0xFFE67E22), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      days != null
                          ? l10n.dashboardExamDaysLeft(days)
                          : l10n.goalModeExamPrep,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFFE67E22),
                      ),
                    ),
                    if (ui.goalContextLabel.isNotEmpty)
                      Text(
                        ui.goalContextLabel,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.dashboardExamSyllabusCoverage(covered),
                style: theme.textTheme.labelMedium,
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: covered / 100,
                  minHeight: 8,
                  backgroundColor: const Color(0xFFE67E22).withValues(alpha: 0.15),
                  color: const Color(0xFFE67E22),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/exam/plan'),
                  icon: const Icon(Icons.calendar_month_outlined, size: 18),
                  label: Text(l10n.examPlanOpen),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE67E22),
                    side: const BorderSide(color: Color(0xFFE67E22)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => context.push('/exam/mock/create'),
                  icon: const Icon(Icons.timer_outlined, size: 18),
                  label: Text(l10n.examStartMock),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFE67E22),
                    side: const BorderSide(color: Color(0xFFE67E22)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Career readiness card ─────────────────────────────────────────────────────

class _CareerReadinessCard extends ConsumerWidget {
  const _CareerReadinessCard({required this.ui});
  final UiPersonalizationState ui;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final readinessPct = ui.careerReadinessPercent;

    return AppCard(
      color: const Color(0xFF27AE60).withValues(alpha: 0.07),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const MetricHonestyBanner(
            message:
                'Readiness starts at 0% and rises as you complete learning-path modules — not from job titles or employer scores.',
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.work_rounded, color: Color(0xFF27AE60), size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.dashboardCareerReadiness,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: const Color(0xFF27AE60),
                      ),
                    ),
                    if (ui.goalContextLabel.isNotEmpty)
                      Text(
                        l10n.dashboardCareerRole(ui.goalContextLabel),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    if (ui.roleSeniorityLabel != null) ...[
                      const SizedBox(height: 4),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Chip(
                          visualDensity: VisualDensity.compact,
                          label: Text(ui.roleSeniorityLabel!),
                          backgroundColor:
                              const Color(0xFF27AE60).withValues(alpha: 0.12),
                          labelStyle: theme.textTheme.labelSmall?.copyWith(
                            color: const Color(0xFF27AE60),
                            fontWeight: FontWeight.w600,
                          ),
                          padding: EdgeInsets.zero,
                          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Text(
                '$readinessPct%',
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: const Color(0xFF27AE60),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: readinessPct / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFF27AE60).withValues(alpha: 0.15),
              color: const Color(0xFF27AE60),
            ),
          ),
          if (ui.focusTitles.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              ui.focusTitles.take(2).join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => context.push('/career/matrix'),
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(l10n.careerOpenMatrix),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF27AE60),
                side: const BorderSide(color: Color(0xFF27AE60)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}



