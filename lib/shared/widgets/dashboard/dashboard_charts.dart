import 'package:community_charts_flutter/community_charts_flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/repositories/stats_repository.dart';

class _BarDatum {
  const _BarDatum(this.label, this.value);
  final String label;
  final int value;
}

class _PieDatum {
  const _PieDatum(this.label, this.value);
  final String label;
  final int value;
}

class _TrendDatum {
  const _TrendDatum(this.index, this.label, this.value);
  final int index;
  final String label;
  final int value;
}

String _chartDayLabel(BuildContext context, WeeklyPoint point) {
  if (point.label.isNotEmpty) return point.label;
  final date = point.date;
  if (date == null) return '';
  return DateFormat.E(Localizations.localeOf(context).toString()).format(date);
}

String _chartShortDateLabel(BuildContext context, WeeklyPoint point) {
  final date = point.date;
  if (date == null) return point.label;
  return DateFormat.Md(Localizations.localeOf(context).toString()).format(date);
}

/// Shared dashboard charts using community_charts_flutter.
class DashboardWeeklyChart extends StatelessWidget {
  const DashboardWeeklyChart({super.key, required this.points});

  final List<WeeklyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || points.every((p) => p.count == 0)) {
      return Center(child: Text(context.l10n.dashboardNoChartData));
    }

    final data = points
        .map((p) => _BarDatum(_chartDayLabel(context, p), p.count))
        .toList();
    final maxY = data.fold<int>(0, (m, d) => d.value > m ? d.value : m);
    final summary = data.map((d) => '${d.label}: ${d.value}').join(', ');

    return Semantics(
      label: 'Weekly quiz activity chart. $summary',
      child: charts.BarChart(
      [
        charts.Series<_BarDatum, String>(
          id: 'weekly',
          data: data,
          domainFn: (d, _) => d.label,
          measureFn: (d, _) => d.value,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppTheme.purpleStart),
        ),
      ],
      animate: false,
      defaultInteractions: false,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          desiredTickCount: maxY < 3 ? 3 : maxY + 1,
        ),
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(AppTheme.mutedSlate.withValues(alpha: 0.2)),
          ),
        ),
      ),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 11,
            color: charts.ColorUtil.fromDartColor(AppTheme.mutedSlate),
          ),
        ),
      ),
    ),
    );
  }
}

class DashboardTopicPieChart extends StatelessWidget {
  const DashboardTopicPieChart({super.key, required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    if (data.isEmpty) {
      return Center(child: Text(context.l10n.dashboardNoChartData));
    }

    final sorted = data.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(6).toList();
    final rest = sorted.skip(6);
    final otherCount = rest.fold<int>(0, (s, e) => s + e.value);
    final entries = <_PieDatum>[
      for (final e in top) _PieDatum(e.key, e.value),
      if (otherCount > 0) _PieDatum(context.l10n.dashboardTopicOther, otherCount),
    ];
    final colors = [
      AppTheme.purpleStart,
      AppTheme.accentGreen,
      AppTheme.accentOrange,
      AppTheme.accentPink,
      AppTheme.accentBlue,
      AppTheme.accentTeal,
      AppTheme.mutedSlate,
    ];
    final summary = entries.map((e) => '${e.label}: ${e.value}').join(', ');

    return Semantics(
      label: 'Topic distribution chart. $summary',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: charts.PieChart(
              [
                charts.Series<_PieDatum, String>(
                  id: 'topics',
                  data: entries,
                  domainFn: (d, _) => d.label,
                  measureFn: (d, _) => d.value,
                  colorFn: (d, i) =>
                      charts.ColorUtil.fromDartColor(colors[i! % colors.length]),
                  labelAccessorFn: (d, _) {
                    final total = entries.fold<int>(0, (s, e) => s + e.value);
                    if (total == 0) return '';
                    return '${((d.value / total) * 100).round()}%';
                  },
                ),
              ],
              animate: false,
              defaultInteractions: false,
              layoutConfig: charts.LayoutConfig(
                leftMarginSpec: charts.MarginSpec.fixedPixel(0),
                topMarginSpec: charts.MarginSpec.fixedPixel(0),
                rightMarginSpec: charts.MarginSpec.fixedPixel(0),
                bottomMarginSpec: charts.MarginSpec.fixedPixel(0),
              ),
            ),
          ),
          const SizedBox(height: 8),
          ...entries.asMap().entries.map((e) {
            final i = e.key;
            final d = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: colors[i % colors.length],
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      d.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                  Text(
                    '${d.value}',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }
}

class DashboardDifficultyChart extends StatelessWidget {
  const DashboardDifficultyChart({super.key, required this.data});

  final Map<String, int> data;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (data.isEmpty) {
      return Center(child: Text(l10n.dashboardNoChartData));
    }

    final keys = data.keys.toList();
    final chartData = [
      for (final key in keys) _BarDatum(L10nHelpers.difficultyLabel(l10n, key), data[key]!),
    ];
    final maxY = chartData.fold<int>(0, (m, d) => d.value > m ? d.value : m);

    return charts.BarChart(
      [
        charts.Series<_BarDatum, String>(
          id: 'difficulty',
          data: chartData,
          domainFn: (d, _) => d.label,
          measureFn: (d, _) => d.value,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppTheme.accentBlue),
        ),
      ],
      animate: false,
      defaultInteractions: false,
      primaryMeasureAxis: charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          desiredTickCount: maxY < 1 ? 2 : maxY + 1,
        ),
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(AppTheme.mutedSlate.withValues(alpha: 0.2)),
          ),
        ),
      ),
      domainAxis: charts.OrdinalAxisSpec(
        renderSpec: charts.SmallTickRendererSpec(
          labelStyle: charts.TextStyleSpec(
            fontSize: 10,
            color: charts.ColorUtil.fromDartColor(AppTheme.mutedSlate),
          ),
        ),
      ),
    );
  }
}

class DashboardDailyGoalRing extends StatelessWidget {
  const DashboardDailyGoalRing({
    super.key,
    required this.todaySeconds,
    required this.goalMinutes,
    this.showTitle = true,
  });

  final int todaySeconds;
  final int goalMinutes;
  final bool showTitle;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final todayMinutes = todaySeconds ~/ 60;
    final goalSeconds = goalMinutes * 60;
    final progress =
        goalSeconds == 0 ? 0.0 : (todaySeconds / goalSeconds).clamp(0.0, 1.0);

    return Semantics(
      label: l10n.dashboardDailyStudyProgress(todayMinutes, goalMinutes),
      value: '${(progress * 100).round()} percent',
      child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (showTitle) ...[
          Text(
            l10n.dashboardDailyStudyGoal,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.cardTitle(onColoredCard: false),
          ),
          const SizedBox(height: 12),
        ],
        Row(
          children: [
            SizedBox(
              width: 72,
              height: 72,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 8,
                    backgroundColor: AppTheme.purpleStart.withValues(alpha: 0.12),
                    color: AppTheme.purpleStart,
                  ),
                  Center(
                    child: Text(
                      '${(progress * 100).round()}%',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                l10n.dashboardDailyStudyProgress(todayMinutes, goalMinutes),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.cardSubtitle(),
              ),
            ),
          ],
        ),
      ],
    ),
    );
  }
}

/// Line chart for overall learning activity (questions solved per day).
class DashboardActivityTrendChart extends StatelessWidget {
  const DashboardActivityTrendChart({super.key, required this.points});

  final List<WeeklyPoint> points;

  @override
  Widget build(BuildContext context) {
    if (points.isEmpty || points.every((p) => p.count == 0)) {
      return Center(child: Text(context.l10n.dashboardNoChartData));
    }

    final data = points.asMap().entries
        .map((e) => _TrendDatum(e.key, _chartShortDateLabel(context, e.value), e.value.count))
        .toList();
    final maxY = data.fold<int>(0, (m, d) => d.value > m ? d.value : m);
    final summary = data.map((d) => '${d.label}: ${d.value}').join(', ');

    return Semantics(
      label: 'Activity trend chart. $summary',
      child: charts.LineChart(
        [
          charts.Series<_TrendDatum, int>(
            id: 'activity_trend',
            data: data,
            domainFn: (d, _) => d.index,
            measureFn: (d, _) => d.value,
            colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppTheme.accentTeal),
          ),
        ],
        animate: false,
        defaultInteractions: false,
        primaryMeasureAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            desiredTickCount: maxY < 3 ? 3 : (maxY + 1).clamp(3, 6),
          ),
          renderSpec: charts.GridlineRendererSpec(
            lineStyle: charts.LineStyleSpec(
              color: charts.ColorUtil.fromDartColor(AppTheme.mutedSlate.withValues(alpha: 0.2)),
            ),
          ),
        ),
        domainAxis: charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
            desiredTickCount: data.length.clamp(3, 7),
          ),
          tickFormatterSpec: charts.BasicNumericTickFormatterSpec((value) {
            if (value == null) return '';
            final i = value.toInt();
            if (i < 0 || i >= data.length) return '';
            return data[i].label;
          }),
          renderSpec: charts.SmallTickRendererSpec(
            labelRotation: -45,
            labelStyle: charts.TextStyleSpec(
              fontSize: 10,
              color: charts.ColorUtil.fromDartColor(AppTheme.mutedSlate),
            ),
          ),
        ),
      ),
    );
  }
}

/// Weekly chart for insights sheet (simple int list, no labels).
class DashboardWeeklySimpleChart extends StatelessWidget {
  const DashboardWeeklySimpleChart({super.key, required this.values});

  final List<int> values;

  @override
  Widget build(BuildContext context) {
    if (values.every((v) => v == 0)) {
      return Center(child: Text(context.l10n.dashboardNoQuizzesYet));
    }

    final data = List.generate(values.length, (i) => _BarDatum('$i', values[i]));
    return charts.BarChart(
      [
        charts.Series<_BarDatum, String>(
          id: 'weekly_simple',
          data: data,
          domainFn: (d, _) => d.label,
          measureFn: (d, _) => d.value,
          colorFn: (_, __) => charts.ColorUtil.fromDartColor(AppTheme.purpleStart),
        ),
      ],
      animate: false,
      defaultInteractions: false,
      primaryMeasureAxis: charts.NumericAxisSpec(
        renderSpec: charts.GridlineRendererSpec(
          lineStyle: charts.LineStyleSpec(
            color: charts.ColorUtil.fromDartColor(AppTheme.mutedSlate.withValues(alpha: 0.2)),
          ),
        ),
      ),
      domainAxis: const charts.OrdinalAxisSpec(
        showAxisLine: false,
        renderSpec: charts.SmallTickRendererSpec(labelRotation: 0),
      ),
    );
  }
}
