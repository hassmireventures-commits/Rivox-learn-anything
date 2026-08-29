import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/models/provider_usage.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/providers/study_minutes_provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dashboard/dashboard_chart_card.dart';
import '../../../shared/widgets/dashboard/dashboard_charts.dart';
import '../../../shared/widgets/dashboard/dashboard_section_header.dart';
import '../../../shared/widgets/bottom_native_ad_slot.dart';

Future<void> showInsightsExpandSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const InsightsExpandSheet(),
  );
}

class InsightsExpandSheet extends ConsumerStatefulWidget {
  const InsightsExpandSheet({super.key});

  @override
  ConsumerState<InsightsExpandSheet> createState() => _InsightsExpandSheetState();
}

class _InsightsExpandSheetState extends ConsumerState<InsightsExpandSheet> {
  bool _refreshing = false;

  Future<void> _refresh() async {
    if (_refreshing) return;
    setState(() => _refreshing = true);
    try {
      ref.read(todayStudyProgressProvider.notifier).refresh();
      bumpAdRefresh(ref);
      ref.invalidate(dashboardStatsProvider);
      ref.invalidate(providerUsageProvider);
      ref.invalidate(totalAiTokensTodayProvider);
      await ref.read(dashboardStatsProvider.future);
    } finally {
      if (mounted) setState(() => _refreshing = false);
    }
  }

  static bool _hasAiUsageToday(int totalTokens, List<ProviderUsage> usage) {
    if (totalTokens > 0) return true;
    for (final u in usage) {
      if (u.callCountToday > 0) return true;
      if (u.promptTokensToday + u.completionTokensToday > 0) return true;
    }
    return false;
  }

  static List<ProviderUsage> _activeProviderUsage(List<ProviderUsage> usage) {
    return usage
        .where(
          (u) =>
              u.callCountToday > 0 ||
              u.promptTokensToday + u.completionTokensToday > 0,
        )
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final statsAsync = ref.watch(dashboardStatsProvider);
    final profileAsync = ref.watch(learnerProfileProvider);
    final studyProgress = ref.watch(todayStudyProgressProvider);
    final tokensAsync = ref.watch(totalAiTokensTodayProvider);
    final usageAsync = ref.watch(providerUsageProvider);
    final providersAsync = ref.watch(aiProvidersProvider);
    final providerNames = <String, String>{
      for (final p in providersAsync.asData?.value ?? const [])
        p.uuid: p.name,
    };
    final dailyGoalMinutes = profileAsync.asData?.value.dailyMinutesGoal ?? 15;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return statsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
          data: (stats) => ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(
              AppTheme.pageHorizontal,
              0,
              AppTheme.pageHorizontal,
              24,
            ),
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(l10n.dashboardChartsTitle, style: theme.textTheme.titleLarge),
                  ),
                  IconButton(
                    tooltip: l10n.dashboardRefreshInsights,
                    onPressed: _refreshing ? null : _refresh,
                    icon: _refreshing
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : const Icon(Icons.refresh_rounded),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.cardGap),
              DashboardSectionHeader(title: l10n.dashboardWeeklyActivity),
              const SizedBox(height: AppTheme.cardGap),
              DashboardChartCard(
                title: l10n.dashboardWeeklyActivity,
                child: DashboardWeeklyChart(points: stats.weeklyActivity),
              ),
              const SizedBox(height: AppTheme.cardGap),
              DashboardSectionHeader(title: l10n.dashboardActivityTrend),
              const SizedBox(height: AppTheme.cardGap),
              DashboardChartCard(
                title: l10n.dashboardActivityTrend,
                child: DashboardActivityTrendChart(points: stats.activityTrend),
              ),
              const SizedBox(height: AppTheme.cardGap),
              DashboardSectionHeader(title: l10n.dashboardTopicBreakdown),
              const SizedBox(height: AppTheme.cardGap),
              DashboardChartCard(
                title: l10n.dashboardTopicBreakdown,
                aspectRatio: 1.1,
                child: DashboardTopicPieChart(data: stats.topicBreakdown),
              ),
              const SizedBox(height: AppTheme.cardGap),
              DashboardSectionHeader(title: l10n.dashboardDifficultyMix),
              const SizedBox(height: AppTheme.cardGap),
              DashboardChartCard(
                title: l10n.dashboardDifficultyMix,
                child: DashboardDifficultyChart(data: stats.difficultyDistribution),
              ),
              const SizedBox(height: AppTheme.cardGap),
              DashboardChartCard(
                title: l10n.dashboardDailyStudyGoal,
                aspectRatio: 2.4,
                child: DashboardDailyGoalRing(
                  todaySeconds: studyProgress.todaySeconds,
                  goalMinutes: dailyGoalMinutes,
                  showTitle: false,
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              DashboardSectionHeader(title: l10n.dashboardAiUsageToday),
              const SizedBox(height: AppTheme.cardGap),
              _AiUsageSection(
                tokensAsync: tokensAsync,
                usageAsync: usageAsync,
                providerNames: providerNames,
              ),
              const SizedBox(height: AppTheme.cardGap),
              const ScrollableNativeAdSlot(slotId: 'insights'),
            ],
          ),
        );
      },
    );
  }
}

class _AiUsageSection extends StatelessWidget {
  const _AiUsageSection({
    required this.tokensAsync,
    required this.usageAsync,
    required this.providerNames,
  });

  final AsyncValue<int> tokensAsync;
  final AsyncValue<List<ProviderUsage>> usageAsync;
  final Map<String, String> providerNames;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    return tokensAsync.when(
      loading: () => const AppCard(child: Text('…')),
      error: (e, _) => AppCard(child: Text('$e')),
      data: (totalTokens) => usageAsync.when(
        loading: () => AppCard(
          child: Text(
            l10n.settingsAiTokensTodayLabel(totalTokens),
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        error: (e, _) => AppCard(child: Text('$e')),
        data: (usage) {
          final hasUsage = _InsightsExpandSheetState._hasAiUsageToday(totalTokens, usage);
          final activeUsage = _InsightsExpandSheetState._activeProviderUsage(usage);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppCard(
                child: Text(
                  l10n.settingsAiTokensTodayLabel(totalTokens),
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              if (!hasUsage)
                AppCard(
                  child: Text(
                    l10n.dashboardUsageEmpty,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                )
              else
                ...activeUsage.map((u) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: AppTheme.cardGap),
                    child: AppCard(
                      child: Row(
                        children: [
                          const Icon(Icons.smart_toy_outlined, color: AppTheme.seedColor),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  u.providerKey == 'local-mlc'
                                      ? 'On-device LLM'
                                      : (providerNames[u.providerKey] ?? u.providerKey),
                                  style: const TextStyle(fontWeight: FontWeight.w700),
                                ),
                                Text(
                                  l10n.dashboardProviderUsageDetailed(
                                    u.callCountToday,
                                    u.promptTokensToday + u.completionTokensToday,
                                    u.lastLatencyMs,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
            ],
          );
        },
      ),
    );
  }
}
