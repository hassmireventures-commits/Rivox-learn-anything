import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../data/local/models/study_plan_item.dart';
import '../../../data/local/models/syllabus_unit.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';

class StudyPlanWeekData {
  const StudyPlanWeekData({required this.items, required this.units});

  final List<StudyPlanItem> items;
  final List<SyllabusUnit> units;
}

final studyPlanWeekDataProvider =
    FutureProvider.autoDispose.family<StudyPlanWeekData, DateTime>((ref, weekStart) async {
  final progress = ref.watch(goalProgressRepositoryProvider);
  final syllabus = await progress.activeSyllabus();
  final items = await progress.planForRange(weekStart, weekStart.add(const Duration(days: 6)));
  final units = syllabus == null ? <SyllabusUnit>[] : await progress.unitsFor(syllabus.uuid);
  return StudyPlanWeekData(items: items, units: units);
});

/// Week view of the exam study plan (units, mocks, review blocks).
class StudyPlanScreen extends ConsumerStatefulWidget {
  const StudyPlanScreen({super.key});

  @override
  ConsumerState<StudyPlanScreen> createState() => _StudyPlanScreenState();
}

class _StudyPlanScreenState extends ConsumerState<StudyPlanScreen> {
  late DateTime _weekStart;

  @override
  void initState() {
    super.initState();
    _weekStart = _weekStartOf(DateTime.now());
  }

  DateTime _weekStartOf(DateTime anchor) {
    final d = DateTime(anchor.year, anchor.month, anchor.day);
    return d.subtract(Duration(days: d.weekday - DateTime.monday));
  }

  DateTime _dateOnly(DateTime dt) => DateTime(dt.year, dt.month, dt.day);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final planAsync = ref.watch(studyPlanWeekDataProvider(_weekStart));
    final personalization = ref.watch(personalizationProvider).asData?.value;
    final examName = personalization?.goalContextLabel ?? '';
    final daysLeft = personalization?.examDaysRemaining;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.examPlanTitle)),
      body: planAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFE67E22)),
          ),
        ),
        error: (e, _) => Center(child: Text('$e')),
        data: (data) => _buildBody(
          context,
          data.items,
          data.units,
          examName,
          daysLeft,
        ),
      ),
    );
  }

  Widget _buildBody(
    BuildContext context,
    List<StudyPlanItem> items,
    List<SyllabusUnit> units,
    String examName,
    int? daysLeft,
  ) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final byUuid = {for (final u in units) u.uuid: u};
    final weekEnd = _weekStart.add(const Duration(days: 6));
    final today = _dateOnly(DateTime.now());

    final grouped = <DateTime, List<StudyPlanItem>>{};
    for (var i = 0; i < 7; i++) {
      grouped[_weekStart.add(Duration(days: i))] = [];
    }
    for (final item in items) {
      final key = _dateOnly(item.calendarDay);
      grouped.putIfAbsent(key, () => []).add(item);
    }

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        AppCard(
          onTap: () => context.push('/library?goal=exam_prep'),
          child: ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.folder_open_rounded),
            title: Text(l10n.libraryImportMaterial),
            trailing: const Icon(Icons.chevron_right_rounded),
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          color: const Color(0xFFE67E22).withValues(alpha: 0.08),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.examPlanSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (examName.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  examName,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFFE67E22),
                  ),
                ),
              ],
              if (daysLeft != null) ...[
                const SizedBox(height: 4),
                Text(
                  l10n.reminderExamInDays(
                    daysLeft,
                    examName.isEmpty ? l10n.goalModeExamPrep : examName,
                  ),
                  style: theme.textTheme.labelMedium,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            IconButton(
              onPressed: () => setState(() {
                _weekStart = _weekStart.subtract(const Duration(days: 7));
              }),
              icon: const Icon(Icons.chevron_left_rounded),
            ),
            Expanded(
              child: Text(
                l10n.examPlanWeekRange(
                  _formatShort(_weekStart),
                  _formatShort(weekEnd),
                ),
                textAlign: TextAlign.center,
                style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
              ),
            ),
            IconButton(
              onPressed: () => setState(() {
                _weekStart = _weekStart.add(const Duration(days: 7));
              }),
              icon: const Icon(Icons.chevron_right_rounded),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (items.isEmpty)
          AppCard(
            child: Text(
              l10n.examPlanEmpty,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          )
        else
          ...grouped.entries.map((entry) {
            final day = entry.key;
            final dayItems = entry.value;
            final isToday = _dateOnly(day) == today;
            return Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: AppCard(
                color: isToday
                    ? const Color(0xFFE67E22).withValues(alpha: 0.06)
                    : null,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isToday ? l10n.examPlanToday(_formatDay(day)) : _formatDay(day),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isToday ? const Color(0xFFE67E22) : null,
                      ),
                    ),
                    if (dayItems.isEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l10n.examPlanRestDay,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      )
                    else
                      ...dayItems.map((item) {
                        final unit = item.unitUuid == null ? null : byUuid[item.unitUuid];
                        final title = unit?.title ?? l10n.examPlanKindReview;
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(
                            _kindIcon(item.kind),
                            color: const Color(0xFFE67E22),
                          ),
                          title: Text(_kindLabel(l10n, item.kind, title)),
                          subtitle: Text(
                            l10n.examPlanDayMinutes(item.completedMinutes, item.plannedMinutes),
                          ),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () => _openItem(context, item, unit),
                        );
                      }),
                  ],
                ),
              ),
            );
          }),
        const SizedBox(height: 12),
        PrimaryButton(
          label: l10n.examStartMock,
          icon: Icons.timer_outlined,
          onPressed: () => context.push('/exam/mock/create'),
        ),
      ],
    );
  }

  void _openItem(BuildContext context, StudyPlanItem item, SyllabusUnit? unit) {
    if (item.kind == 'mock') {
      context.push('/exam/mock/create');
      return;
    }
    final topic = unit?.title ?? '';
    if (topic.isEmpty) return;
    context.push('/quiz/create?topic=${Uri.encodeComponent(topic)}');
  }

  IconData _kindIcon(String kind) => switch (kind) {
        'mock' => Icons.timer_outlined,
        'review' => Icons.replay_rounded,
        _ => Icons.menu_book_outlined,
      };

  String _kindLabel(dynamic l10n, String kind, String unitTitle) => switch (kind) {
        'mock' => l10n.examPlanKindMock,
        'review' => l10n.examPlanKindReviewUnit(unitTitle),
        _ => l10n.examPlanKindStudyUnit(unitTitle),
      };

  String _formatDay(DateTime d) {
    const months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
    ];
    const weekdays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return '${weekdays[d.weekday - 1]}, ${months[d.month - 1]} ${d.day}';
  }

  String _formatShort(DateTime d) => '${d.month}/${d.day}';
}
