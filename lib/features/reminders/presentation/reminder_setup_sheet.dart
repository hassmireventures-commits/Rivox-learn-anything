import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/services/exam_notification_scheduler.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/reminder_preferences.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/isar_service.dart';
import '../../../data/local/repositories/learner_repository.dart';
import '../../../data/local/repositories/quiz_repository.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/primary_button.dart';

/// Bumps when reminder prefs are saved so summary rows rebuild.
class ReminderPrefsTick extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state++;
}

final reminderPrefsTickProvider =
    NotifierProvider<ReminderPrefsTick, int>(ReminderPrefsTick.new);

Future<void> showReminderSetupSheet(BuildContext context, {WidgetRef? ref}) async {
  await showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => const Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: ReminderSetupSheet(),
    ),
  );
  await ReminderPreferencesStore.instance.load();
  ref?.read(reminderPrefsTickProvider.notifier).bump();
}

class ReminderSetupSheet extends ConsumerStatefulWidget {
  const ReminderSetupSheet({super.key});

  @override
  ConsumerState<ReminderSetupSheet> createState() => _ReminderSetupSheetState();
}

class _ReminderSetupSheetState extends ConsumerState<ReminderSetupSheet> {
  ReminderPreferences _prefs = ReminderPreferencesStore.instance.current;
  bool _loading = true;
  bool _suggesting = false;
  bool _saving = false;
  String _goalMode = 'learning';

  static const _days = [1, 2, 3, 4, 5, 6, 7];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final prefs = await ReminderPreferencesStore.instance.load();
    var goalMode = 'learning';
    try {
      final profile = await LearnerRepository(IsarService.instance).getOrCreateProfile();
      goalMode = profile.goalMode;
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _goalMode = goalMode;
      _loading = false;
    });
  }

  Future<void> _save(ReminderPreferences next) async {
    await ReminderPreferencesStore.instance.save(next);
    List<String>? weakTopics;
    try {
      final weak = await LearnerRepository(IsarService.instance).weakTopics(limit: 3);
      weakTopics = weak.map((e) => e.topic).toList();
    } catch (_) {}
    await NotificationService.instance.scheduleDailyReminder(
      weakTopics: weakTopics,
      languageCode: mounted ? Localizations.localeOf(context).languageCode : null,
    );
    await ExamNotificationScheduler.instance.reschedule();
    if (mounted) setState(() => _prefs = next);
  }

  Future<void> _saveAndClose() async {
    setState(() => _saving = true);
    try {
      if (_prefs.dailyReminderEnabled) {
        final granted =
            await NotificationService.instance.ensureNotificationPermission(context);
        if (!granted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.settingsReminderPermissionDenied)),
            );
          }
          return;
        }
      }
      await _save(_prefs);
      if (!mounted) return;
      ref.read(reminderPrefsTickProvider.notifier).bump();
      Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _toggleEnabled(bool enabled) async {
    if (enabled) {
      final granted =
          await NotificationService.instance.ensureNotificationPermission(context);
      if (!granted && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsReminderPermissionDenied)),
        );
        return;
      }
    }
    await _save(_prefs.copyWith(dailyReminderEnabled: enabled));
  }

  Future<void> _toggleAlarmMode(bool enabled) async {
    if (enabled) {
      final exactOk =
          await NotificationService.instance.ensureExactAlarmPermission();
      if (!exactOk && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsReminderAlarmExactDenied)),
        );
      }
    }
    await _save(_prefs.copyWith(alarmMode: enabled));
  }

  Future<void> _togglePlaySound(bool enabled) async {
    await _save(_prefs.copyWith(playSound: enabled));
  }

  String _soundLabel(String id) => switch (id) {
        'alarm' => 'Alarm',
        'urgent' => 'Urgent',
        _ => 'Alarm',
      };

  Future<void> _pickAlarmSound() async {
    final next = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => _AlarmSoundPickerSheet(initialSoundId: _prefs.alarmSound),
    );
    if (next == null || !mounted) return;
    await _save(_prefs.copyWith(alarmSound: next));
  }

  Future<void> _toggleVibrate(bool enabled) async {
    await _save(_prefs.copyWith(enableVibration: enabled));
  }

  Future<void> _toggleDay(int day) async {
    final days = Set<int>.of(_prefs.activeDays);
    if (days.contains(day)) {
      days.remove(day);
    } else {
      days.add(day);
    }
    await _save(_prefs.copyWith(activeDays: days));
  }

  Future<void> _pickDefaultTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: _prefs.reminderHour, minute: _prefs.reminderMinute),
    );
    if (!mounted || picked == null) return;
    await _save(_prefs.copyWith(
      reminderHour: picked.hour,
      reminderMinute: picked.minute,
      perDayTimes: {},
    ));
  }

  Future<void> _pickPerDayTime(int day) async {
    final override = _prefs.perDayTimes[day];
    final initial = override != null
        ? TimeOfDay(hour: override.hour, minute: override.minute)
        : TimeOfDay(hour: _prefs.reminderHour, minute: _prefs.reminderMinute);
    final picked = await showTimePicker(context: context, initialTime: initial);
    if (!mounted || picked == null) return;
    final updated = Map<int, ReminderTime>.of(_prefs.perDayTimes);
    updated[day] = ReminderTime(hour: picked.hour, minute: picked.minute);
    await _save(_prefs.copyWith(perDayTimes: updated));
  }

  Future<void> _suggestTimes() async {
    setState(() => _suggesting = true);
    try {
      final sessions = await QuizRepository(IsarService.instance).getRecent(limit: 200);
      final completions = sessions
          .where((s) => s.completedAt != null)
          .map((s) => s.completedAt!)
          .toList();
      final dayCounts = <int, Map<int, int>>{for (var d = 1; d <= 7; d++) d: {}};
      for (final dt in completions) {
        dayCounts[dt.weekday]![dt.hour] = (dayCounts[dt.weekday]![dt.hour] ?? 0) + 1;
      }
      final perDayTimes = Map<int, ReminderTime>.of(_prefs.perDayTimes);
      var anyFound = false;
      for (var d = 1; d <= 7; d++) {
        final counts = dayCounts[d]!;
        if (counts.isEmpty) continue;
        final bestHour = counts.entries.reduce((a, b) => a.value >= b.value ? a : b).key;
        perDayTimes[d] = ReminderTime(hour: bestHour, minute: 0);
        anyFound = true;
      }
      if (!mounted) return;
      if (!anyFound) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.settingsReminderSuggestNone)),
        );
        return;
      }
      await _save(_prefs.copyWith(perDayTimes: perDayTimes));
    } finally {
      if (mounted) setState(() => _suggesting = false);
    }
  }

  String _formatTime(int h, int m) {
    final period = h >= 12 ? 'PM' : 'AM';
    final displayH = h % 12 == 0 ? 12 : h % 12;
    return '$displayH:${m.toString().padLeft(2, '0')} $period';
  }

  String _dayLabel(int isoWeekday) {
    final l10n = context.l10n;
    return switch (isoWeekday) {
      1 => l10n.settingsReminderDayMon,
      2 => l10n.settingsReminderDayTue,
      3 => l10n.settingsReminderDayWed,
      4 => l10n.settingsReminderDayThu,
      5 => l10n.settingsReminderDayFri,
      6 => l10n.settingsReminderDaySat,
      7 => l10n.settingsReminderDaySun,
      _ => '?',
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_loading) {
      return SizedBox(
        height: 200,
        child: Center(child: CircularProgressIndicator(color: AppTheme.seedColor)),
      );
    }

    final defaultTimeLabel = _formatTime(_prefs.reminderHour, _prefs.reminderMinute);

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.85,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ListView(
          controller: scrollController,
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
          children: [
            Text(l10n.settingsSmartReminderTitle, style: theme.textTheme.titleLarge),
            const SizedBox(height: 4),
            Text(
              l10n.settingsReminderSheetSubtitle,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 16),
            AppCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.settingsReminderEnabled),
                subtitle: Text(l10n.settingsReminderEnabledSubtitle),
                value: _prefs.dailyReminderEnabled,
                onChanged: _toggleEnabled,
              ),
            ),
            if (_prefs.dailyReminderEnabled) ...[
              const SizedBox(height: 12),
              AppCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.settingsReminderAlarmMode),
                  subtitle: Text(l10n.settingsReminderAlarmModeSubtitle),
                  value: _prefs.alarmMode,
                  onChanged: _toggleAlarmMode,
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsReminderPlaySound),
                      value: _prefs.playSound,
                      onChanged: _togglePlaySound,
                    ),
                    if (_prefs.playSound)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.settingsAlarmSound),
                        subtitle: Text(_soundLabel(_prefs.alarmSound)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: _pickAlarmSound,
                      ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(l10n.settingsReminderVibrate),
                      value: _prefs.enableVibration,
                      onChanged: _toggleVibrate,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(l10n.settingsReminderActiveDays, style: theme.textTheme.titleSmall),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _days.map((day) {
                        final active = _prefs.activeDays.contains(day);
                        final override = _prefs.perDayTimes[day];
                        final timeLabel = override != null
                            ? _formatTime(override.hour, override.minute)
                            : defaultTimeLabel;
                        return GestureDetector(
                          onLongPress: active ? () => _pickPerDayTime(day) : null,
                          child: FilterChip(
                            label: Text('${_dayLabel(day)}\n$timeLabel', textAlign: TextAlign.center),
                            selected: active,
                            showCheckmark: false,
                            onSelected: (_) => _toggleDay(day),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: _pickDefaultTime,
                      icon: const Icon(Icons.schedule_rounded, size: 18),
                      label: Text(l10n.settingsReminderDefaultTime(defaultTimeLabel)),
                    ),
                    const SizedBox(height: 8),
                    FilledButton.tonalIcon(
                      onPressed: _suggesting ? null : _suggestTimes,
                      icon: _suggesting
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.auto_awesome_rounded, size: 18),
                      label: Text(l10n.settingsReminderSuggest),
                    ),
                  ],
                ),
              ),
            ],
            if (_goalMode == 'exam_prep') ...[
              const SizedBox(height: 12),
              AppCard(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: Text(l10n.reminderExamEnabled),
                  value: _prefs.examRemindersEnabled,
                  onChanged: (v) => _save(_prefs.copyWith(examRemindersEnabled: v)),
                ),
              ),
            ],
            const SizedBox(height: 20),
            PrimaryButton(
              label: l10n.commonSave,
              icon: Icons.check_rounded,
              isLoading: _saving,
              onPressed: _saving ? null : _saveAndClose,
            ),
          ],
        );
      },
    );
  }
}

class _AlarmSoundPickerSheet extends StatefulWidget {
  const _AlarmSoundPickerSheet({required this.initialSoundId});

  final String initialSoundId;

  @override
  State<_AlarmSoundPickerSheet> createState() => _AlarmSoundPickerSheetState();
}

class _AlarmSoundPickerSheetState extends State<_AlarmSoundPickerSheet> {
  late String _selected;
  String? _previewingId;

  static const _options = [
    ('alarm', 'Alarm'),
    ('urgent', 'Urgent'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialSoundId;
  }

  @override
  void dispose() {
    NotificationService.instance.cancelAlarmSoundPreview();
    super.dispose();
  }

  Future<void> _preview(String id) async {
    setState(() => _previewingId = id);
    await NotificationService.instance.previewAlarmSound(id);
    if (mounted) setState(() => _previewingId = null);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l10n.settingsAlarmSound, style: theme.textTheme.titleMedium),
            const SizedBox(height: 4),
            Text(
              l10n.settingsAlarmSoundPreviewHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 12),
            for (final (id, label) in _options)
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(label),
                leading: Radio<String>(
                  value: id,
                  groupValue: _selected,
                  onChanged: (v) {
                    if (v == null) return;
                    setState(() => _selected = v);
                  },
                ),
                trailing: IconButton(
                  tooltip: l10n.settingsAlarmSoundPreviewPlay,
                  onPressed: _previewingId == id ? null : () => _preview(id),
                  icon: _previewingId == id
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.volume_up_rounded),
                ),
                onTap: () => setState(() => _selected = id),
              ),
            const SizedBox(height: 8),
            PrimaryButton(
              label: l10n.settingsAlarmSoundSet,
              icon: Icons.check_rounded,
              onPressed: () => Navigator.pop(context, _selected),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact summary row for settings / dashboard / onboarding.
class ReminderSummaryButton extends ConsumerWidget {
  const ReminderSummaryButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(reminderPrefsTickProvider);
    final l10n = context.l10n;
    final prefs = ReminderPreferencesStore.instance.current;
    final summary = prefs.dailyReminderEnabled
        ? l10n.settingsReminderSummaryOn(
            prefs.activeDays.length,
            '${prefs.reminderHour}:${prefs.reminderMinute.toString().padLeft(2, '0')}',
          )
        : l10n.settingsReminderSummaryOff;

    return AppCard(
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Icon(
          prefs.alarmMode ? Icons.alarm_rounded : Icons.notifications_active_rounded,
          color: AppTheme.seedColor,
        ),
        title: Text(l10n.settingsSetReminderButton),
        subtitle: Text(summary),
        trailing: const Icon(Icons.chevron_right_rounded),
        onTap: () => showReminderSetupSheet(context, ref: ref),
      ),
    );
  }
}
