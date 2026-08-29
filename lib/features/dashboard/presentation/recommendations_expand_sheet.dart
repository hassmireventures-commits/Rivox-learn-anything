import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/personalization/ui_personalization_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/recommendation.dart';
import '../../../shared/navigation/recommendation_navigation.dart';
import '../../../shared/widgets/dashboard/filter_chip_row.dart';
import '../../../shared/widgets/dashboard/vertical_recommendation_card.dart';

Future<void> showRecommendationsSheet(
  BuildContext context, {
  required List<RecommendationItem> recommendations,
  required UiPersonalizationState ui,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    backgroundColor: Colors.transparent,
    builder: (context) => RecommendationsExpandSheet(
      recommendations: recommendations,
      ui: ui,
    ),
  );
}

class RecommendationsExpandSheet extends ConsumerStatefulWidget {
  const RecommendationsExpandSheet({
    super.key,
    required this.recommendations,
    required this.ui,
  });

  final List<RecommendationItem> recommendations;
  final UiPersonalizationState ui;

  @override
  ConsumerState<RecommendationsExpandSheet> createState() => _RecommendationsExpandSheetState();
}

class _RecommendationsExpandSheetState extends ConsumerState<RecommendationsExpandSheet> {
  int _filterIndex = 0;

  List<String> get _kinds {
    final kinds = <String>['all'];
    for (final r in widget.recommendations) {
      if (!kinds.contains(r.kind)) kinds.add(r.kind);
    }
    return kinds;
  }

  List<RecommendationItem> get _filtered {
    if (_kinds.isEmpty) return widget.recommendations;
    final kind = _kinds[_filterIndex];
    if (kind == 'all') return widget.recommendations;
    return widget.recommendations.where((r) => r.kind == kind).toList();
  }

  String _kindFilterLabel(String kind) {
    final l10n = context.l10n;
    if (kind == 'all') return l10n.dashboardFilterAll;
    return switch (kind) {
      'next_topic' => l10n.dashboardFilterPractice,
      'remedial' => l10n.dashboardFilterRemedial,
      'nudge' => l10n.dashboardFilterNudge,
      'break' => l10n.dashboardFilterBreak,
      'mock' => l10n.dashboardFilterMock,
      'interview' => l10n.dashboardFilterInterview,
      'path' => l10n.dashboardFilterPath,
      'layout' => l10n.dashboardFilterLayout,
      _ => kind,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final labels = _kinds.map(_kindFilterLabel).toList();
    final filtered = _filtered;

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.cardSurface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Container(
                  height: 120,
                  decoration: const BoxDecoration(
                    gradient: AppTheme.secondaryCoralGradient,
                  ),
                  padding: const EdgeInsets.fromLTRB(
                    AppTheme.pageHorizontal,
                    16,
                    AppTheme.pageHorizontal,
                    20,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dashboardRecommendationsTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.sectionHeading(color: Colors.white),
                      ),
                      if (widget.ui.goalContextLabel.isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          widget.ui.goalContextLabel,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.cardSubtitle(
                            color: Colors.white.withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppTheme.pageHorizontal,
                  16,
                  AppTheme.pageHorizontal,
                  8,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.ui.goalMode == 'career')
                      Text(
                        l10n.goalModeCareer,
                        style: AppTheme.cardSubtitle(),
                      )
                    else if (widget.ui.goalMode == 'exam_prep')
                      Text(
                        l10n.goalModeExamPrep,
                        style: AppTheme.cardSubtitle(),
                      )
                    else
                      Text(
                        l10n.goalModeLearning,
                        style: AppTheme.cardSubtitle(),
                      ),
                    const SizedBox(height: 12),
                    if (labels.length > 1)
                      FilterChipRow(
                        labels: labels,
                        selectedIndex: _filterIndex,
                        onSelected: (i) => setState(() => _filterIndex = i),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: filtered.isEmpty
                    ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Text(
                            l10n.dashboardNoRecommendations,
                            textAlign: TextAlign.center,
                            style: AppTheme.cardSubtitle(),
                          ),
                        ),
                      )
                    : ListView.separated(
                        controller: scrollController,
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.pageHorizontal,
                          0,
                          AppTheme.pageHorizontal,
                          24,
                        ),
                        itemCount: filtered.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppTheme.cardGap),
                        itemBuilder: (context, index) {
                          final item = filtered[index];
                          return VerticalRecommendationCard(
                            item: item,
                            accentIndex: index,
                            onTap: () => openRecommendation(context, ref, item: item),
                          );
                        },
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
