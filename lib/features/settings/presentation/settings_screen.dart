import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/ai_platform/ai_policy_registry.dart';
import '../../../core/ai_platform/prompt_firewall.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/supported_languages.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/language_change_coordinator.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/providers/firebase_providers.dart';
import '../../../core/services/ai_study_pulse_service.dart';
import '../../../core/services/article_bookmark_store.dart';
import '../../../core/services/goal_topic_resolver.dart';
import '../../../core/services/daily_content_scheduler.dart';
import '../../../core/services/exam_notification_scheduler.dart';
import '../../../core/services/exam_plan_sync.dart';
import '../../../core/services/notification_history_store.dart';
import '../../../core/services/notification_service.dart';
import '../../../core/services/reminder_preferences.dart';
import '../../../core/guidance/guidance_controller.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../features/guidance/presentation/whats_new_sheet.dart';
import '../../../features/reminders/presentation/reminder_setup_sheet.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/services/learner_goal_guard.dart';
import '../../../core/services/secondary_goals_store.dart';
import '../../../core/models/saved_goal.dart';
import '../../../data/local/path_steps_storage.dart';
import '../../../shared/widgets/ai_status_badge.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dashboard/dashboard_page_scaffold.dart';
import '../../../shared/widgets/settings_leading_icon.dart';
import '../../../shared/widgets/hassmire_logo.dart';
import '../../../shared/widgets/language_picker_field.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final Map<String, bool> _sectionExpanded = {
    'goals': false,
    'habits': false,
    'ai': false,
    'support': false,
    'app': false,
    'privacy': false,
    'about': false,
  };

  late final Map<String, ExpansionTileController> _tileControllers = {
    for (final id in _sectionExpanded.keys) id: ExpansionTileController(),
  };

  Widget _sectionTile({
    required String id,
    required String title,
    required List<Widget> children,
  }) {
    return _KeepAliveTile(
      child: ExpansionTile(
        key: ValueKey('settings_$id'),
        controller: _tileControllers[id],
        initiallyExpanded: _sectionExpanded[id]!,
        maintainState: true,
        onExpansionChanged: (v) {
          if (_sectionExpanded[id] == v) return;
          setState(() => _sectionExpanded[id] = v);
        },
        title: Text(title),
        children: children,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final profile = ref.watch(profileProvider).asData?.value;
    final settings = ref.watch(settingsProvider).asData?.value;
    final learner = ref.watch(learnerProfileProvider).asData?.value;
    final providers = ref.watch(aiProvidersProvider).asData?.value ?? [];
    final firebaseReady = ref.watch(firebaseConfiguredProvider);
    final defaultProviderName =
        providers.where((p) => p.isDefault).map((p) => p.name).firstOrNull ?? l10n.commonNone;

    return DashboardPageScaffold(
      title: l10n.settingsTitle,
      headerHeight: 100,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => context.pop(),
      ),
      actions: const [AiStatusBadge(), SizedBox(width: 8)],
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageHorizontal),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              AppCard(
                child: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.person_rounded)),
                  title: Text(profile?.name ?? l10n.settingsLearnerFallback),
                  subtitle: Text(l10n.settingsTapToRename),
                  trailing: const Icon(Icons.edit_rounded),
                  onTap: () => _renameProfile(context, ref, profile?.name ?? ''),
                ),
              ),
              const SizedBox(height: 8),
              _sectionTile(
                id: 'goals',
                title: l10n.settingsSectionYourGoals,
                children: const [
                  _GoalModeSettingsCard(),
                  SizedBox(height: 8),
                ],
              ),
              _sectionTile(
                id: 'habits',
                title: l10n.settingsSectionStudyHabits,
                children: const [
                  _DailyGoalSettingsCard(),
                  SizedBox(height: 8),
                ],
              ),
              _sectionTile(
                id: 'ai',
                title: l10n.settingsSectionAiLibrary,
                children: [
                  AppCard(
                    onTap: () => context.push('/settings/providers'),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const SettingsLeadingIcon(Icons.smart_toy_rounded),
                      title: Text(l10n.settingsAiProviders),
                      subtitle: Text(
                        providers.isEmpty
                            ? l10n.settingsNoProviders
                            : l10n.settingsProvidersSummary(providers.length, defaultProviderName),
                      ),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Row(
                        children: [
                          Expanded(child: Text(l10n.settingsHelpImproveTitle)),
                          IconButton(
                            tooltip: l10n.settingsHelpImproveLearnMoreTitle,
                            icon: const Icon(Icons.info_outline_rounded),
                            onPressed: () {
                              showDialog<void>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  title: Text(l10n.settingsHelpImproveLearnMoreTitle),
                                  content: Text(l10n.settingsHelpImproveLearnMoreBody),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(ctx),
                                      child: Text(l10n.commonDismiss),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                      subtitle: Text(
                        firebaseReady
                            ? l10n.settingsHelpImproveSubtitle
                            : l10n.settingsHelpImproveUnavailable,
                      ),
                      value: firebaseReady && (learner?.helpImproveOptIn ?? false),
                      onChanged: firebaseReady
                          ? (v) async {
                              await ref.read(learnerRepositoryProvider).updateProfile(helpImproveOptIn: v);
                              ref.invalidate(learnerProfileProvider);
                              if (v) {
                                await ref.read(anonAnalyticsSyncProvider).syncIfOptedIn();
                              }
                            }
                          : null,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _AiLibrarySettingsCard(),
                  const SizedBox(height: 8),
                ],
              ),
              _sectionTile(
                id: 'support',
                title: l10n.supportTitle,
                children: [
                  AppCard(
                    onTap: () => context.push('/support'),
                    child: ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const SettingsLeadingIcon(Icons.favorite_rounded, color: AppTheme.accentOrange),
                      title: Text(l10n.settingsSupportTitle),
                      subtitle: Text(l10n.settingsSupportSubtitle),
                      trailing: const Icon(Icons.chevron_right_rounded),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Consumer(
                    builder: (context, ref, _) {
                      final adService = ref.watch(adServiceProvider);
                      if (!adService.interstitialReady &&
                          !adService.loadingInterstitial) {
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          adService.loadInterstitial();
                        });
                      }
                      return OutlinedButton.icon(
                        onPressed: () async {
                          final shown = await adService.showInterstitial();
                          if (!context.mounted) return;
                          if (shown) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.settingsThanksForSupport)),
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(l10n.supportAdNotReady)),
                            );
                            adService.loadInterstitial();
                          }
                        },
                        icon: const Icon(Icons.ondemand_video_rounded),
                        label: Text(
                          adService.loadingInterstitial
                              ? l10n.settingsLoadingAd
                              : l10n.settingsWatchAdToSupport,
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              _sectionTile(
                id: 'app',
                title: l10n.settingsSectionApp,
                children: [
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.settingsAppearance, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 12),
                        SegmentedButton<String>(
                          style: ButtonStyle(
                            textStyle: WidgetStatePropertyAll(
                              Theme.of(context).textTheme.titleSmall?.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                            ),
                            visualDensity: VisualDensity.compact,
                            padding: const WidgetStatePropertyAll(
                              EdgeInsets.symmetric(horizontal: 8, vertical: 10),
                            ),
                          ),
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: 'system',
                              label: Text(
                                l10n.themeSystem,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              icon: const Icon(Icons.brightness_auto, size: 18),
                            ),
                            ButtonSegment(
                              value: 'light',
                              label: Text(
                                l10n.themeLight,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              icon: const Icon(Icons.light_mode, size: 18),
                            ),
                            ButtonSegment(
                              value: 'dark',
                              label: Text(
                                l10n.themeDark,
                                maxLines: 1,
                                softWrap: false,
                                overflow: TextOverflow.ellipsis,
                                textAlign: TextAlign.center,
                              ),
                              icon: const Icon(Icons.dark_mode, size: 18),
                            ),
                          ],
                          selected: {settings?.themeMode ?? 'system'},
                          onSelectionChanged: (value) async {
                            await ref.read(profileRepositoryProvider).updateSettings(themeMode: value.first);
                            ref.invalidate(settingsProvider);
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(l10n.settingsLanguage, style: Theme.of(context).textTheme.titleMedium),
                        const SizedBox(height: 4),
                        Text(l10n.settingsLanguageSubtitle, style: Theme.of(context).textTheme.bodySmall),
                        const SizedBox(height: 12),
                        LanguagePickerField(
                          selectedCode: settings?.language ?? SupportedLanguages.defaultCode,
                          label: l10n.settingsLanguage,
                          onChanged: (code) async {
                            final current =
                                settings?.language ?? SupportedLanguages.defaultCode;
                            final next = await LanguageChangeCoordinator.confirmAndPrepare(
                              context,
                              currentCode: current,
                              nextCode: code,
                            );
                            if (next == null || !context.mounted) return null;
                            await ref.read(profileRepositoryProvider).updateSettings(language: next);
                            ref.invalidate(settingsProvider);
                            return next;
                          },
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.help_outline_rounded),
                          title: Text(l10n.settingsHelpGuidance),
                          onTap: () => context.push('/help'),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.explore_outlined),
                          title: Text(l10n.settingsReplayTour),
                          onTap: () async {
                            await ref.read(guidanceControllerProvider.notifier).resetWalkthrough();
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text(l10n.settingsReplayTour)),
                              );
                              context.go('/dashboard');
                            }
                          },
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.new_releases_outlined),
                          title: Text(l10n.settingsWhatsNew),
                          onTap: () => showWhatsNewSheet(context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              _sectionTile(
                id: 'privacy',
                title: l10n.settingsSectionDataPrivacy,
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.upload_file_rounded),
                          title: Text(l10n.settingsExportData),
                          subtitle: Text(l10n.settingsExportSubtitle),
                          onTap: () => _exportData(context, ref),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.download_rounded),
                          title: Text(l10n.settingsImportData),
                          onTap: () => _importData(context, ref),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: SettingsLeadingIcon(
                            Icons.delete_forever_rounded,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          title: Text(
                            l10n.settingsResetApplication,
                            style: TextStyle(color: Theme.of(context).colorScheme.error),
                          ),
                          onTap: () => _resetApp(context, ref),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
              _sectionTile(
                id: 'about',
                title: l10n.settingsSectionAbout,
                children: [
                  AppCard(
                    child: Column(
                      children: [
                        const HassmireLogo(height: 56),
                        const SizedBox(height: 8),
                        Text(
                          l10n.organizationName,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 12),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.info_outline_rounded),
                          title: Text(l10n.settingsAbout),
                          subtitle: Text(l10n.settingsAboutVersion(l10n.appName, AppConstants.appVersion)),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.privacy_tip_outlined),
                          title: Text(l10n.settingsPrivacyPolicy),
                          onTap: () => context.push('/legal/privacy'),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.description_outlined),
                          title: Text(l10n.settingsTerms),
                          onTap: () => context.push('/legal/terms'),
                        ),
                        const Divider(),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const SettingsLeadingIcon(Icons.code_outlined),
                          title: Text(l10n.settingsOpenSourceLicenses),
                          onTap: () => showLicensePage(context: context),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppTheme.cardGap),
                ],
              ),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _renameProfile(BuildContext context, WidgetRef ref, String current) async {
    final l10n = context.l10n;
    final controller = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsRenameTitle),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.settingsNameLabel),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );
    if (result != null && result.isNotEmpty) {
      await ref.read(profileRepositoryProvider).saveProfile(result);
      ref.invalidate(profileProvider);
    }
  }

  Future<void> _exportData(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    try {
      final quizData = await ref.read(quizRepositoryProvider).exportData();
      final statsData = await ref.read(statsRepositoryProvider).exportStats();
      final profile = await ref.read(profileRepositoryProvider).getProfile();
      final settings = await ref.read(profileRepositoryProvider).getSettings();
      final providers = await ref.read(providerRepositoryProvider).getAll();

      final payload = {
        'version': 1,
        'exportedAt': DateTime.now().toIso8601String(),
        'profile': profile == null
            ? null
            : {'name': profile.name, 'createdAt': profile.createdAt.toIso8601String()},
        'settings': {
          'themeMode': settings.themeMode,
          'language': settings.language,
        },
        'providers': providers
            .map((p) => {
                  'uuid': p.uuid,
                  'name': p.name,
                  'providerType': p.providerType,
                  'baseUrl': p.baseUrl,
                  'defaultModel': p.defaultModel,
                  'isDefault': p.isDefault,
                  'createdAt': p.createdAt.toIso8601String(),
                })
            .toList(),
        ...quizData,
        ...statsData,
      };

      final dir = await getTemporaryDirectory();
      final file = File('${dir.path}/learn_anything_backup_${DateTime.now().millisecondsSinceEpoch}.json');
      await file.writeAsString(const JsonEncoder.withIndent('  ').convert(payload));
      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: l10n.settingsBackupShareText));
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsExportFailed('$e'))),
        );
      }
    }
  }

  Future<void> _importData(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final result = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['json'],
    );
    if (result == null || result.files.single.path == null) return;

    try {
      final content = await File(result.files.single.path!).readAsString();
      final data = jsonDecode(content) as Map<String, dynamic>;

      if (data['profile'] is Map) {
        final name = (data['profile'] as Map)['name']?.toString();
        if (name != null && name.isNotEmpty) {
          await ref.read(profileRepositoryProvider).saveProfile(name);
        }
      }
      if (data['settings'] is Map) {
        final s = Map<String, dynamic>.from(data['settings'] as Map);
        await ref.read(profileRepositoryProvider).updateSettings(
              themeMode: s['themeMode'] as String?,
              language: s['language'] as String?,
              roomExpiryHours: s['roomExpiryHours'] as int?,
            );
      }

      await ref.read(quizRepositoryProvider).importData(data);
      await ref.read(statsRepositoryProvider).importStats(data);

      ref.invalidate(profileProvider);
      ref.invalidate(settingsProvider);
      ref.invalidate(dashboardStatsProvider);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsImportComplete)),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.settingsImportFailed('$e'))),
        );
      }
    }
  }

  Future<void> _resetApp(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final choice = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.settingsResetTitle),
        content: Text(l10n.settingsResetChoose),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: Text(l10n.commonCancel)),
          TextButton(
            onPressed: () => Navigator.pop(context, 'learning'),
            child: Text(l10n.settingsResetLearningOnly),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Theme.of(context).colorScheme.error),
            onPressed: () => Navigator.pop(context, 'full'),
            child: Text(l10n.settingsResetFull),
          ),
        ],
      ),
    );
    if (choice == null) return;

    if (!context.mounted) return;
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: AlertDialog(
          content: Row(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(width: 20),
              Expanded(child: Text(l10n.settingsResetting)),
            ],
          ),
        ),
      ),
    );

    try {
      await SecondaryGoalsStore.instance.save([]);
      await ref.read(dailyContentSchedulerProvider).resetAttemptState();
      await ArticleBookmarkStore.instance.clear();
      if (choice == 'learning') {
        await ref.read(isarServiceProvider).clearLearningData();
        await PathStepsStorage.instance.clearAll();
        await ref.read(usageTrackerProvider).clearCache();
        await ref.read(dailyContentServiceProvider).clearPersisted();
        await NotificationHistoryStore.instance.clear();
        await AiStudyPulseService(llmManager: ref.read(llmManagerProvider)).clearCache();
        GoalTopicResolver.clearCache();
      } else {
        await ref.read(isarServiceProvider).clearAll();
        await ref.read(secureKeyStorageProvider).clearAllKeys();
        await PathStepsStorage.instance.clearAll();
        await ref.read(usageTrackerProvider).clearCache();
        await ref.read(dailyContentServiceProvider).clearPersisted();
        await NotificationHistoryStore.instance.clear();
        await AiStudyPulseService(llmManager: ref.read(llmManagerProvider)).clearCache();
        GoalTopicResolver.clearCache();
      }
    } finally {
      if (context.mounted) Navigator.of(context, rootNavigator: true).pop();
    }

    ref.invalidate(profileProvider);
    ref.invalidate(settingsProvider);
    ref.invalidate(aiProvidersProvider);
    invalidateHomeProviders(ref);
    ref.invalidate(providerUsageProvider);
    ref.invalidate(learnerProfileProvider);
    ref.invalidate(activeRateLimitProvider);
    ref.invalidate(defaultAiProviderProvider);

    if (!context.mounted) return;
    context.go(choice == 'full' ? '/welcome' : '/dashboard');
  }
}

class _DailyGoalSettingsCard extends ConsumerStatefulWidget {
  const _DailyGoalSettingsCard();

  @override
  ConsumerState<_DailyGoalSettingsCard> createState() => _DailyGoalSettingsCardState();
}

class _DailyGoalSettingsCardState extends ConsumerState<_DailyGoalSettingsCard> {
  int _dailyGoal = 15;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    await ReminderPreferencesStore.instance.load();
    if (!mounted) return;
    setState(() {
      _dailyGoal = profile.dailyMinutesGoal ?? 15;
      _loading = false;
    });
  }

  Future<void> _saveGoal(int minutes) async {
    setState(() => _dailyGoal = minutes);
    await ref.read(learnerRepositoryProvider).updateProfile(dailyMinutesGoal: minutes);
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    if (profile.goalMode == 'exam_prep') {
      await syncExamPlanAndReminders(
        progress: ref.read(goalProgressRepositoryProvider),
        profile: profile,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    if (_loading) {
      return const AppCard(child: LinearProgressIndicator());
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsDailyGoalTitle, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text(l10n.settingsDailyGoalMinutes(_dailyGoal)),
          Slider(
            value: _dailyGoal.toDouble(),
            min: 5,
            max: 120,
            divisions: 23,
            label: '$_dailyGoal',
            onChanged: (v) => _saveGoal(v.round()),
          ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l10n.settingsDailyQuizFrequency,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text('${ReminderPreferencesStore.instance.current.dailyQuizFrequency}'),
              Slider(
                value: ReminderPreferencesStore.instance.current.dailyQuizFrequency
                    .toDouble(),
                min: 1,
                max: 3,
                divisions: 2,
                label: '${ReminderPreferencesStore.instance.current.dailyQuizFrequency}',
                onChanged: (v) async {
                  final prefs = ReminderPreferencesStore.instance.current;
                  await ReminderPreferencesStore.instance.save(
                    prefs.copyWith(dailyQuizFrequency: v.round()),
                  );
                  setState(() {});
                  ref.invalidate(todaysDailyQuizOfferProvider);
                  ref.invalidate(todaysDailyQuizProvider);
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const ReminderSummaryButton(),
      ],
    );
  }
}

// ── Goal Mode Settings Card ───────────────────────────────────────────────────

class _AiLibrarySettingsCard extends ConsumerWidget {
  const _AiLibrarySettingsCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final tokensAsync = ref.watch(totalAiTokensTodayProvider);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsAiLibrary, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const SettingsLeadingIcon(Icons.folder_open_rounded),
            title: Text(l10n.libraryOpenHub),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push('/library'),
          ),
          const Divider(),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.settingsAiTokensToday),
            subtitle: tokensAsync.when(
              data: (n) => Text(l10n.settingsAiTokensTodayLabel(n)),
              loading: () => const Text('…'),
              error: (e, _) => Text('$e'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keeps ExpansionTiles alive when scrolled offscreen in the Settings SliverList.
class _KeepAliveTile extends StatefulWidget {
  const _KeepAliveTile({required this.child});

  final Widget child;

  @override
  State<_KeepAliveTile> createState() => _KeepAliveTileState();
}

class _KeepAliveTileState extends State<_KeepAliveTile>
    with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }
}

const _kGoalModes = [
  ('learning', Icons.auto_stories_rounded, Color(0xFF5B4BDB)),
  ('exam_prep', Icons.emoji_events_rounded, Color(0xFFE67E22)),
  ('career', Icons.work_rounded, Color(0xFF27AE60)),
];

const _kExamTypes = ['cert', 'competitive', 'academic', 'other'];
const _kSeniorities = ['junior', 'mid', 'senior'];

class _GoalModeSettingsCard extends ConsumerStatefulWidget {
  const _GoalModeSettingsCard();

  @override
  ConsumerState<_GoalModeSettingsCard> createState() => _GoalModeSettingsCardState();
}

class _GoalModeSettingsCardState extends ConsumerState<_GoalModeSettingsCard> {
  String _goalMode = 'learning';
  DateTime? _examDate;
  String? _examType;
  String? _roleSeniority;
  bool _saving = false;
  String? _error;
  DateTime? _lastSyncedAt;
  final _contextController = TextEditingController();
  final _topicsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await SecondaryGoalsStore.instance.load();
      _syncFromProvider();
    });
  }

  @override
  void dispose() {
    _contextController.dispose();
    _topicsController.dispose();
    super.dispose();
  }

  void _syncFromProvider() {
    final profile = ref.read(learnerProfileProvider).asData?.value;
    if (profile == null) return;
    if (_lastSyncedAt == profile.updatedAt) return;
    final repo = ref.read(learnerRepositoryProvider);
    _lastSyncedAt = profile.updatedAt;
    setState(() {
      _goalMode = profile.goalMode;
      _examDate = profile.examDate;
      _examType = profile.examType;
      _roleSeniority = profile.roleSeniority;
      _contextController.text = profile.goalContext;
      _topicsController.text = repo.goalsOf(profile).join(', ');
      _error = null;
    });
  }

  Future<void> _switchGoal() async {
    final l10n = context.l10n;
    final repo = ref.read(learnerRepositoryProvider);
    final profile = await repo.getOrCreateProfile();
    final options = repo.allGoalsOf(profile);
    if (!mounted) return;
    final picked = await showModalBottomSheet<SavedGoal>(
      context: context,
      showDragHandle: true,
      builder: (ctx) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(20),
        children: [
          Text(l10n.goalSwitchTitle, style: Theme.of(ctx).textTheme.titleMedium),
          const SizedBox(height: 12),
          ...options.map(
            (g) => ListTile(
              leading: Icon(_iconForMode(g.mode)),
              title: Text(g.displayLabel),
              subtitle: Text(_modeLabel(g.mode)),
              onTap: () => Navigator.pop(ctx, g),
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    setState(() => _saving = true);
    await repo.switchPrimaryGoal(picked);
    await _bootstrapForMode(picked.mode, picked.context, repo.goalsOf(await repo.getOrCreateProfile()));
    ref.invalidate(learnerProfileProvider);
    ref.invalidate(personalizationProvider);
    _lastSyncedAt = null;
    _syncFromProvider();
    if (mounted) setState(() => _saving = false);
  }

  Future<void> _addGoal() async {
    final l10n = context.l10n;
    String mode = 'learning';
    final contextCtrl = TextEditingController();
    final topicsCtrl = TextEditingController();
    final added = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.goalAddTitle),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: mode,
                items: _kGoalModes
                    .map((t) => DropdownMenuItem(value: t.$1, child: Text(_modeLabel(t.$1))))
                    .toList(),
                onChanged: (v) => mode = v ?? 'learning',
                decoration: InputDecoration(labelText: l10n.settingsGoalModeTitle),
              ),
              TextField(
                controller: contextCtrl,
                decoration: InputDecoration(labelText: l10n.goalAddContextLabel),
              ),
              TextField(
                controller: topicsCtrl,
                decoration: InputDecoration(labelText: l10n.welcomeGoalsLabel),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(l10n.commonCancel)),
          FilledButton(onPressed: () => Navigator.pop(ctx, true), child: Text(l10n.commonSave)),
        ],
      ),
    );
    if (added != true) return;
    final topics = topicsCtrl.text
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList();
    await ref.read(learnerRepositoryProvider).addSecondaryGoal(
          SavedGoal(mode: mode, context: contextCtrl.text.trim(), topics: topics),
        );
    ref.invalidate(learnerProfileProvider);
    if (mounted) {
      setState(() {});
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(l10n.goalAddSaved)));
    }
  }

  IconData _iconForMode(String mode) => switch (mode) {
        'exam_prep' => Icons.emoji_events_rounded,
        'career' => Icons.work_rounded,
        _ => Icons.auto_stories_rounded,
      };

  Future<void> _bootstrapForMode(String mode, String ctx, List<String> goals) async {
    final progress = ref.read(goalProgressRepositoryProvider);
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    if (mode == 'exam_prep') {
      await progress.clearCareerSkills();
      await progress.bootstrapSyllabus(
        title: ctx.isNotEmpty ? ctx : 'Exam syllabus',
        topics: goals,
        examDate: profile.examDate,
      );
      await syncExamPlanAndReminders(progress: progress, profile: profile);
    } else if (mode == 'career') {
      await progress.clearSyllabus();
      await progress.clearStudyPlan();
      await progress.bootstrapCareerSkills(
        roleTitle: ctx.isNotEmpty ? ctx : 'Target role',
        skills: goals,
      );
      await ExamNotificationScheduler.instance.reschedule();
    } else {
      await progress.clearSyllabus();
      await progress.clearStudyPlan();
      await progress.clearCareerSkills();
      await ExamNotificationScheduler.instance.reschedule();
    }
  }

  Future<void> _save() async {
    final l10n = context.l10n;
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    final ctx = _contextController.text.trim();
    final err = LearnerGoalGuard.validateDraft(
      goalMode: _goalMode,
      goalContext: _goalMode == 'learning' ? '' : ctx,
      topicsRaw: _topicsController.text,
      examDate: _examDate,
    );
    if (err != null) {
      setState(() {
        _error = switch (err) {
          'syllabus' => l10n.goalSyllabusRequired,
          'skills' => l10n.goalSkillsRequired,
          'topics' => l10n.goalTopicsRequired,
          'tooVague' => l10n.goalTooVague,
          'examName' => l10n.goalExamNameRequired,
          'examDate' => l10n.goalExamDateRequired,
          'role' => l10n.goalRoleRequired,
          _ => l10n.goalTopicsRequired,
        };
      });
      return;
    }

    final topics = LearnerGoalGuard.parseCommaTopics(_topicsController.text);
    final firewall = const PromptFirewall();
    await AiPolicyRegistry.load();
    if (_goalMode != 'learning' && ctx.isNotEmpty) {
      final idCheck = await firewall.sanitize(ctx);
      if (idCheck.blocked) {
        setState(() => _error = l10n.topicLanguageNotAllowed);
        return;
      }
    }
    final topicBlock = await firewall.sanitizeTopics(topics);
    if (topicBlock != null) {
      setState(() => _error = l10n.topicLanguageNotAllowed);
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });
    await ref.read(learnerRepositoryProvider).updateProfile(
          goalMode: _goalMode,
          goalContext: _goalMode == 'learning' ? '' : ctx,
          goals: topics,
          examDate: _goalMode == 'exam_prep' ? _examDate : null,
          clearExamDate: _goalMode != 'exam_prep',
          examType: _goalMode == 'exam_prep' ? _examType : null,
          clearExamType: _goalMode != 'exam_prep' || _examType == null,
          roleSeniority: _goalMode == 'career' ? _roleSeniority : null,
          clearRoleSeniority: _goalMode != 'career' || _roleSeniority == null,
        );
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    final goals = ref.read(learnerRepositoryProvider).goalsOf(profile);
    await _bootstrapForMode(_goalMode, ctx, goals);
    ref.invalidate(learnerProfileProvider);
    GoalTopicResolver.clearCache();
    invalidateHomeProviders(ref);
    await NotificationService.instance.scheduleDailyReminder();
    await ExamNotificationScheduler.instance.reschedule();
    await ref.read(dailyContentSchedulerProvider).resetAttemptState();
    unawaited(ref.read(dailyContentSchedulerProvider).trySchedule(force: true));
    if (!mounted) return;
    FocusScope.of(context).unfocus();
    FocusManager.instance.primaryFocus?.unfocus();
    SystemChannels.textInput.invokeMethod('TextInput.hide');
    setState(() {
      _saving = false;
      _lastSyncedAt = profile.updatedAt;
      _goalMode = profile.goalMode;
      _examDate = profile.examDate;
      _examType = profile.examType;
      _roleSeniority = profile.roleSeniority;
      _contextController.text = profile.goalContext;
      _topicsController.text = goals.join(', ');
      _error = null;
    });
    // Drop caret / focus ring so the card no longer looks mid-edit.
    _contextController.selection =
        TextSelection.collapsed(offset: _contextController.text.length);
    _topicsController.selection =
        TextSelection.collapsed(offset: _topicsController.text.length);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(l10n.goalModeSaved)),
    );
  }

  Future<void> _pickExamDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _examDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: DateTime.now().add(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 730)),
    );
    if (picked != null) {
      setState(() {
        _examDate = picked;
        _error = null;
      });
    }
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  String _modeLabel(String mode) {
    final l10n = context.l10n;
    return switch (mode) {
      'learning' => l10n.goalModeLearning,
      'exam_prep' => l10n.goalModeExamPrep,
      'career' => l10n.goalModeCareer,
      _ => mode,
    };
  }

  String _examTypeLabel(String value) {
    final l10n = context.l10n;
    return switch (value) {
      'cert' => l10n.goalExamTypeCert,
      'competitive' => l10n.goalExamTypeCompetitive,
      'academic' => l10n.goalExamTypeAcademic,
      _ => l10n.goalExamTypeOther,
    };
  }

  String _seniorityLabel(String value) {
    final l10n = context.l10n;
    return switch (value) {
      'junior' => l10n.goalRoleSeniorityJunior,
      'mid' => l10n.goalRoleSeniorityMid,
      _ => l10n.goalRoleSenioritySenior,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    ref.listen(learnerProfileProvider, (previous, next) {
      final profile = next.asData?.value;
      if (profile != null && profile.updatedAt != _lastSyncedAt) {
        _syncFromProvider();
      }
    });

    final profile = ref.watch(learnerProfileProvider).asData?.value;
    final secondary = profile != null
        ? ref.read(learnerRepositoryProvider).secondaryGoalsOf(profile)
        : const <SavedGoal>[];

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.settingsGoalModeTitle, style: theme.textTheme.titleMedium),
          const SizedBox(height: 4),
          Text(
            l10n.settingsGoalModeSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (profile != null && profile.goalContext.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              '${_modeLabel(profile.goalMode)} · ${profile.goalContext}',
              style: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    visualDensity: VisualDensity.compact,
                    textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  onPressed: _saving ? null : _switchGoal,
                  icon: const Icon(Icons.swap_horiz_rounded, size: 18),
                  label: Text(l10n.goalSwitchTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    minimumSize: const Size.fromHeight(44),
                    visualDensity: VisualDensity.compact,
                    textStyle: theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
                  ),
                  onPressed: _saving ? null : _addGoal,
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(l10n.goalAddTitle, maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ),
            ],
          ),
          if (profile != null) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final g in ref.read(learnerRepositoryProvider).allGoalsOf(profile))
                  Chip(
                    avatar: Icon(
                      _iconForMode(g.mode),
                      size: 16,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    label: Text(
                      g.displayLabel.isNotEmpty ? g.displayLabel : _modeLabel(g.mode),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    backgroundColor: theme.colorScheme.primaryContainer,
                    side: BorderSide(color: theme.colorScheme.primary, width: 1.5),
                    labelStyle: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: theme.colorScheme.onPrimaryContainer,
                    ),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
          ],
          if (secondary.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              l10n.goalSecondaryCount(secondary.length),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _kGoalModes.map((tuple) {
              final (value, icon, color) = tuple;
              final selected = _goalMode == value;
              return FilterChip(
                avatar: Icon(icon, size: 16, color: selected ? color : null),
                label: Text(_modeLabel(value)),
                selected: selected,
                showCheckmark: false,
                onSelected: (_) {
                  setState(() {
                    _goalMode = value;
                    _error = null;
                  });
                },
                selectedColor: color.withValues(alpha: 0.12),
                side: BorderSide(color: selected ? color : theme.colorScheme.outlineVariant),
                labelStyle: TextStyle(
                  fontWeight: selected ? FontWeight.w700 : FontWeight.normal,
                  color: selected ? color : null,
                ),
              );
            }).toList(),
          ),
          if (_goalMode == 'exam_prep') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _contextController,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: l10n.goalExamNameLabel,
                hintText: l10n.goalExamNamePlaceholder,
                prefixIcon: const Icon(Icons.school_outlined),
                isDense: true,
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _pickExamDate,
              icon: const Icon(Icons.calendar_today_rounded, size: 18),
              label: Text(
                _examDate != null
                    ? '${l10n.goalExamDate}: ${_formatDate(_examDate!)}'
                    : l10n.goalExamDateNone,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.goalExamTypeLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kExamTypes.map((type) {
                final selected = _examType == type;
                return FilterChip(
                  label: Text(_examTypeLabel(type)),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() {
                    _examType = selected ? null : type;
                  }),
                );
              }).toList(),
            ),
          ] else if (_goalMode == 'career') ...[
            const SizedBox(height: 12),
            TextField(
              controller: _contextController,
              textCapitalization: TextCapitalization.words,
              onChanged: (_) {
                if (_error != null) setState(() => _error = null);
              },
              decoration: InputDecoration(
                labelText: l10n.goalRoleLabel,
                hintText: l10n.goalRolePlaceholder,
                prefixIcon: const Icon(Icons.work_outline_rounded),
                isDense: true,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              l10n.goalRoleSeniorityLabel,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _kSeniorities.map((level) {
                final selected = _roleSeniority == level;
                return FilterChip(
                  label: Text(_seniorityLabel(level)),
                  selected: selected,
                  showCheckmark: false,
                  onSelected: (_) => setState(() {
                    _roleSeniority = selected ? null : level;
                  }),
                );
              }).toList(),
            ),
          ],
          const SizedBox(height: 12),
          TextField(
            controller: _topicsController,
            decoration: InputDecoration(
              labelText: l10n.welcomeGoalsLabel,
              hintText: l10n.welcomeGoalsHint,
              prefixIcon: const Icon(Icons.flag_outlined),
              isDense: true,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
            ),
          ],
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _saving ? null : _save,
              child: _saving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(l10n.goalModeSaveButton),
            ),
          ),
        ],
      ),
    );
  }
}