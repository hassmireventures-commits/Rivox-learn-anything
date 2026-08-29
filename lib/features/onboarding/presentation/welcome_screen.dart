import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai_platform/ai_policy_registry.dart';
import '../../../core/ai_platform/prompt_firewall.dart';
import '../../../core/constants/supported_languages.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/language_change_coordinator.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/services/ai_study_pulse_service.dart';
import '../../../core/services/exam_notification_scheduler.dart';
import '../../../core/services/exam_plan_sync.dart';
import '../../../core/services/goal_topic_resolver.dart';
import '../../../core/services/learner_goal_guard.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../features/reminders/presentation/reminder_setup_sheet.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dashboard/dashboard_page_scaffold.dart';
import '../../../shared/widgets/dashboard/dashboard_section_header.dart';
import '../../../shared/widgets/dashboard/geometric_wavy_header.dart';
import '../../../shared/widgets/language_picker_field.dart';
import '../../../core/guidance/guidance_preferences_store.dart';
import '../../../core/guidance/guidance_controller.dart';
import '../../../shared/widgets/guidance/dynamic_app_preview_card.dart';
import '../../../shared/widgets/primary_button.dart';
class _GoalMode {
  const _GoalMode({
    required this.value,
    required this.icon,
    required this.color,
  });
  final String value;
  final IconData icon;
  final Color color;
}

const _goalModes = [
  _GoalMode(value: 'learning', icon: Icons.auto_stories_rounded, color: Color(0xFF5B4BDB)),
  _GoalMode(value: 'exam_prep', icon: Icons.emoji_events_rounded, color: Color(0xFFE67E22)),
  _GoalMode(value: 'career', icon: Icons.work_rounded, color: Color(0xFF27AE60)),
];

const _examTypes = ['cert', 'competitive', 'academic', 'other'];
const _seniorities = ['junior', 'mid', 'senior'];

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  final _nameController = TextEditingController();
  final _goalsController = TextEditingController();
  final _examNameController = TextEditingController();
  final _roleController = TextEditingController();
  final _pageController = PageController();

  int _dailyMinutes = 15;
  bool _saving = false;
  late String _languageCode;
  int _page = 0;
  static const int _totalPages = 4;
  bool _legalAccepted = false;

  String _goalMode = 'learning';
  DateTime? _examDate;
  String? _examType;
  String? _roleSeniority;
  String? _goalModeError;

  @override
  void initState() {
    super.initState();
    _languageCode = SupportedLanguages.defaultCodeForDevice(
      WidgetsBinding.instance.platformDispatcher.locale,
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _goalsController.dispose();
    _examNameController.dispose();
    _roleController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _persistOnboarding() async {
    await ref.read(guidanceControllerProvider.notifier).acceptLegal(
          GuidancePreferencesStore.currentLegalVersion,
        );
    await ref.read(profileRepositoryProvider).saveProfile(_nameController.text);
    await ref.read(profileRepositoryProvider).updateSettings(language: _languageCode);
    final goals = LearnerGoalGuard.parseCommaTopics(_goalsController.text);

    final goalContext = switch (_goalMode) {
      'exam_prep' => _examNameController.text.trim(),
      'career' => _roleController.text.trim(),
      _ => '',
    };

    await ref.read(learnerRepositoryProvider).updateProfile(
          goals: goals,
          dailyMinutesGoal: _dailyMinutes,
          goalMode: _goalMode,
          goalContext: goalContext,
          examDate: _goalMode == 'exam_prep' ? _examDate : null,
          clearExamDate: _goalMode != 'exam_prep',
          examType: _goalMode == 'exam_prep' ? _examType : null,
          clearExamType: _goalMode != 'exam_prep' || _examType == null,
          roleSeniority: _goalMode == 'career' ? _roleSeniority : null,
          clearRoleSeniority: _goalMode != 'career' || _roleSeniority == null,
        );
    final progress = ref.read(goalProgressRepositoryProvider);
    if (_goalMode == 'exam_prep') {
      await progress.clearCareerSkills();
      await progress.bootstrapSyllabus(
        title: goalContext.isNotEmpty ? goalContext : 'Exam syllabus',
        topics: goals,
        examDate: _examDate,
      );
      final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
      await syncExamPlanAndReminders(progress: progress, profile: profile);
    } else if (_goalMode == 'career') {
      await progress.clearSyllabus();
      await progress.clearStudyPlan();
      await progress.bootstrapCareerSkills(
        roleTitle: goalContext.isNotEmpty ? goalContext : 'Target role',
        skills: goals,
      );
      await ExamNotificationScheduler.instance.reschedule();
    } else {
      await progress.clearSyllabus();
      await progress.clearStudyPlan();
      await progress.clearCareerSkills();
      await ExamNotificationScheduler.instance.reschedule();
    }
    for (final goal in goals) {
      await ref.read(vectorStoreProvider).upsertTopic(goal);
    }
    await ref.read(telemetryServiceProvider).emit('onboarding_completed', {
      'goals': goals.length,
      'dailyMinutes': _dailyMinutes,
      'language': _languageCode,
      'goalMode': _goalMode,
      'hasExamDate': _examDate != null,
      'examType': _examType,
      'roleSeniority': _roleSeniority,
      'hasGoalContext': goalContext.isNotEmpty,
    });
    ref.invalidate(profileProvider);
    ref.invalidate(settingsProvider);
    ref.invalidate(learnerProfileProvider);
    invalidateHomeProviders(ref);
    ref.invalidate(aiProvidersProvider);
    ref.invalidate(defaultAiProviderProvider);
    await AiStudyPulseService(llmManager: ref.read(llmManagerProvider)).clearCache();
    GoalTopicResolver.clearCache();
  }

  Future<void> _finishOnboarding() async {
    setState(() => _saving = true);
    try {
      await _persistOnboarding();
      if (!mounted) return;
      context.go('/dashboard');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

    // Goal identity validation is handled in _nextFromGoalPage via LearnerGoalGuard.

  Future<void> _nextFromGoalPage(AppLocalizations l10n) async {
    final topics = LearnerGoalGuard.parseCommaTopics(_goalsController.text);
    final goalContext = switch (_goalMode) {
      'exam_prep' => _examNameController.text.trim(),
      'career' => _roleController.text.trim(),
      _ => '',
    };
    final err = LearnerGoalGuard.validateDraft(
      goalMode: _goalMode,
      goalContext: goalContext,
      topicsRaw: _goalsController.text,
      examDate: _examDate,
    );
    if (err != null) {
      final message = switch (err) {
        'syllabus' => l10n.goalSyllabusRequired,
        'skills' => l10n.goalSkillsRequired,
        'topics' => l10n.goalTopicsRequired,
        'tooVague' => l10n.goalTooVague,
        'examName' => l10n.goalExamNameRequired,
        'examDate' => l10n.goalExamDateRequired,
        'role' => l10n.goalRoleRequired,
        _ => l10n.goalTopicsRequired,
      };
      setState(() => _goalModeError = message);
      return;
    }

    final firewall = const PromptFirewall();
    await AiPolicyRegistry.load();
    final identity = goalContext.isNotEmpty ? goalContext : null;
    if (identity != null) {
      final idCheck = await firewall.sanitize(identity);
      if (idCheck.blocked) {
        setState(() => _goalModeError = l10n.topicLanguageNotAllowed);
        return;
      }
    }
    final topicBlock = await firewall.sanitizeTopics(topics);
    if (topicBlock != null) {
      setState(() => _goalModeError = l10n.topicLanguageNotAllowed);
      return;
    }

    setState(() => _goalModeError = null);
    _advancePage();
  }

  void _nextPage() {
    final l10n = context.l10n;
    if (_page == 0) {
      if (_nameController.text.trim().length < 2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.welcomeNameValidation)),
        );
        return;
      }
    }
    if (_page == 1) {
      _nextFromGoalPage(l10n);
      return;
    }
    _advancePage();
  }

  void _advancePage() {
    _pageController.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    setState(() => _page++);
  }

  void _prevPage() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
    setState(() => _page--);
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
        _goalModeError = null;
      });
    }
  }

  String _formatDate(DateTime dt) => '${dt.day}/${dt.month}/${dt.year}';

  String _examTypeLabel(AppLocalizations l10n, String value) => switch (value) {
        'cert' => l10n.goalExamTypeCert,
        'competitive' => l10n.goalExamTypeCompetitive,
        'academic' => l10n.goalExamTypeAcademic,
        _ => l10n.goalExamTypeOther,
      };

  String _seniorityLabel(AppLocalizations l10n, String value) => switch (value) {
        'junior' => l10n.goalRoleSeniorityJunior,
        'mid' => l10n.goalRoleSeniorityMid,
        _ => l10n.goalRoleSenioritySenior,
      };

  String _stepTitle(AppLocalizations l10n) => switch (_page) {
        0 => l10n.welcomeTitle,
        1 => l10n.onboardingGoalTitle,
        2 => l10n.onboardingHabitsTitle,
        3 => l10n.onboardingLegalTitle,
        _ => l10n.welcomeTitle,
      };

  String _stepSubtitle(AppLocalizations l10n) => switch (_page) {
        0 => l10n.welcomeSubtitle,
        1 => l10n.onboardingGoalSubtitle,
        2 => l10n.onboardingHabitsSubtitle,
        3 => l10n.onboardingLegalSubtitle,
        _ => l10n.onboardingStepProgress(_page + 1, _totalPages),
      };

  IconData _stepIcon() => switch (_page) {
        0 => Icons.waving_hand_rounded,
        1 => Icons.auto_awesome_rounded,
        2 => Icons.schedule_rounded,
        3 => Icons.gavel_rounded,
        _ => Icons.info_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final topInset = MediaQuery.paddingOf(context).top;

    return PopScope(
      canPop: _page == 0 && !_saving,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop || _saving) return;
        if (_page > 0) _prevPage();
      },
      child: Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Column(
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Semantics(
                label: _stepTitle(l10n),
                value: l10n.onboardingStepProgress(_page + 1, _totalPages),
                child: GeometricWavyHeader(
                  title: _stepTitle(l10n),
                  subtitle: l10n.onboardingStepProgress(_page + 1, _totalPages),
                  actions: [
                    Icon(
                      _stepIcon(),
                      color: Colors.white.withValues(alpha: 0.9),
                      size: 28,
                    ),
                  ],
                ),
              ),
              if (_page > 0)
                Positioned(
                  top: topInset + 4,
                  left: 4,
                  child: IconButton(
                    onPressed: _saving ? null : _prevPage,
                    icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
                  ),
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppTheme.pageHorizontal,
              12,
              AppTheme.pageHorizontal,
              0,
            ),
            child: Semantics(
              label: l10n.onboardingStepProgress(_page + 1, _totalPages),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: (_page + 1) / _totalPages,
                  minHeight: 4,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _buildIdentityPage(theme, l10n),
                _buildGoalModePage(theme, l10n),
                _buildHabitsPage(theme, l10n),
                _buildLegalPage(theme, l10n),
              ],
            ),
          ),
          if (_saving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    ),
    );
  }

  Widget _buildLegalPage(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageHorizontal,
        AppTheme.cardGap,
        AppTheme.pageHorizontal,
        AppTheme.pageHorizontal,
      ),
      children: [
        DashboardAnimatedSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _stepSubtitle(l10n),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              AppCard(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      value: _legalAccepted,
                      onChanged: (v) => setState(() => _legalAccepted = v ?? false),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l10n.legalAgreeCheckbox, style: theme.textTheme.bodyMedium),
                            Wrap(
                              spacing: 8,
                              children: [
                                TextButton(
                                  onPressed: () => context.push('/legal/terms'),
                                  child: Text(l10n.legalViewTerms),
                                ),
                                TextButton(
                                  onPressed: () => context.push('/legal/privacy'),
                                  child: Text(l10n.legalViewPrivacy),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              PrimaryButton(
                label: l10n.welcomeContinueButton,
                icon: Icons.check_rounded,
                isLoading: _saving,
                onPressed: _legalAccepted && !_saving
                    ? () async {
                        try {
                          await ref
                              .read(providerRepositoryProvider)
                              .ensureBuiltInSeeded();
                        } catch (_) {}
                        await _finishOnboarding();
                      }
                    : null,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildIdentityPage(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageHorizontal,
        AppTheme.cardGap,
        AppTheme.pageHorizontal,
        AppTheme.pageHorizontal,
      ),
      children: [
        DashboardAnimatedSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _stepSubtitle(l10n),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              AppCard(
                child: Column(
                  children: [
                    TextField(
                      controller: _nameController,
                      textCapitalization: TextCapitalization.words,
                      decoration: InputDecoration(
                        labelText: l10n.welcomeNameLabel,
                        prefixIcon: const Icon(Icons.person_outline_rounded),
                        labelStyle: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        floatingLabelStyle: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    LanguagePickerField(
                      selectedCode: _languageCode,
                      label: l10n.welcomePreferredLanguage,
                      onChanged: (code) async {
                        final next = await LanguageChangeCoordinator.confirmAndPrepare(
                          context,
                          currentCode: _languageCode,
                          nextCode: code,
                        );
                        if (next == null || !mounted) return null;
                        setState(() => _languageCode = next);
                        await ref.read(profileRepositoryProvider).updateSettings(language: next);
                        ref.invalidate(settingsProvider);
                        return next;
                      },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              PrimaryButton(
                label: l10n.welcomeContinueButton,
                icon: Icons.arrow_forward_rounded,
                onPressed: _nextPage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHabitsPage(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageHorizontal,
        AppTheme.cardGap,
        AppTheme.pageHorizontal,
        AppTheme.pageHorizontal,
      ),
      children: [
        DashboardAnimatedSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _stepSubtitle(l10n),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              AppCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DashboardSectionHeader(title: l10n.onboardingHabitsTitle),
                    const SizedBox(height: 8),
                    Text(l10n.welcomeDailyMinutes(_dailyMinutes)),
                    Slider(
                      value: _dailyMinutes.toDouble(),
                      min: 5,
                      max: 60,
                      divisions: 11,
                      label: l10n.welcomeMinutesShort(_dailyMinutes),
                      activeColor: theme.colorScheme.primary,
                      onChanged: (v) => setState(() => _dailyMinutes = v.round()),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              const ReminderSummaryButton(),
              const SizedBox(height: AppTheme.cardGap),
              PrimaryButton(
                label: l10n.welcomeContinueButton,
                icon: Icons.arrow_forward_rounded,
                onPressed: _nextPage,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGoalModePage(ThemeData theme, AppLocalizations l10n) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageHorizontal,
        AppTheme.cardGap,
        AppTheme.pageHorizontal,
        AppTheme.pageHorizontal,
      ),
      children: [
        DashboardAnimatedSection(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                _stepSubtitle(l10n),
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              ..._goalModes.map(
                (mode) => _GoalModeCard(
                  mode: mode,
                  label: _goalModeLabel(l10n, mode.value),
                  selected: _goalMode == mode.value,
                  onTap: () => setState(() {
                    _goalMode = mode.value;
                    _goalModeError = null;
                  }),
                  child: _buildGoalModeExtra(mode.value, theme, l10n),
                ),
              ),
              if (_goalModeError != null) ...[
                const SizedBox(height: 8),
                Text(
                  _goalModeError!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: AppTheme.cardGap),
              DynamicAppPreviewCard(goalMode: _goalMode),
              const SizedBox(height: AppTheme.cardGap),
              AppCard(
                child: TextField(
                  controller: _goalsController,
                  decoration: InputDecoration(
                    labelText: switch (_goalMode) {
                      'exam_prep' => l10n.onboardingSyllabusLabel,
                      'career' => l10n.onboardingSkillsLabel,
                      _ => l10n.welcomeGoalsLabel,
                    },
                    hintText: switch (_goalMode) {
                      'exam_prep' => l10n.onboardingSyllabusHint,
                      'career' => l10n.onboardingSkillsHint,
                      _ => l10n.welcomeGoalsHint,
                    },
                    prefixIcon: const Icon(Icons.flag_outlined),
                  ),
                ),
              ),
              const SizedBox(height: AppTheme.cardGap),
              PrimaryButton(
                label: l10n.welcomeContinueButton,
                icon: Icons.arrow_forward_rounded,
                onPressed: () => _nextFromGoalPage(l10n),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget? _buildGoalModeExtra(String mode, ThemeData theme, AppLocalizations l10n) {
    if (_goalMode != mode) return null;
    return switch (mode) {
      'exam_prep' => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _examNameController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_goalModeError != null) setState(() => _goalModeError = null);
                },
                decoration: InputDecoration(
                  labelText: l10n.goalExamNameLabel,
                  hintText: l10n.goalExamNamePlaceholder,
                  prefixIcon: const Icon(Icons.school_outlined),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.goalExamTypeLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _examTypes.map((type) {
                  final selected = _examType == type;
                  return FilterChip(
                    label: Text(_examTypeLabel(l10n, type)),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.18),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? theme.colorScheme.primary : null,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                    side: BorderSide(
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    ),
                    onSelected: (_) => setState(() {
                      _examType = selected ? null : type;
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      'career' => Padding(
          padding: const EdgeInsets.only(top: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextField(
                controller: _roleController,
                textCapitalization: TextCapitalization.words,
                onChanged: (_) {
                  if (_goalModeError != null) setState(() => _goalModeError = null);
                },
                decoration: InputDecoration(
                  labelText: l10n.goalRoleLabel,
                  hintText: l10n.goalRolePlaceholder,
                  prefixIcon: const Icon(Icons.work_outline_rounded),
                  isDense: true,
                ),
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.goalRoleSeniorityLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _seniorities.map((level) {
                  final selected = _roleSeniority == level;
                  return FilterChip(
                    label: Text(_seniorityLabel(l10n, level)),
                    selected: selected,
                    showCheckmark: false,
                    selectedColor: theme.colorScheme.primary.withValues(alpha: 0.18),
                    checkmarkColor: theme.colorScheme.primary,
                    labelStyle: TextStyle(
                      color: selected ? theme.colorScheme.primary : null,
                      fontWeight: selected ? FontWeight.w600 : null,
                    ),
                    side: BorderSide(
                      color: selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant,
                    ),
                    onSelected: (_) => setState(() {
                      _roleSeniority = selected ? null : level;
                    }),
                  );
                }).toList(),
              ),
            ],
          ),
        ),
      _ => null,
    };
  }

  // Removed legacy profile page - merged into identity + goal + habits steps.

  String _goalModeLabel(AppLocalizations l10n, String mode) => switch (mode) {
        'learning' => l10n.goalModeLearning,
        'exam_prep' => l10n.goalModeExamPrep,
        'career' => l10n.goalModeCareer,
        _ => mode,
      };
}

class _GoalModeCard extends StatelessWidget {
  const _GoalModeCard({
    required this.mode,
    required this.label,
    required this.selected,
    required this.onTap,
    this.child,
  });

  final _GoalMode mode;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = selected ? theme.colorScheme.primary : theme.colorScheme.outlineVariant;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AnimatedContainer(
        duration: AppTheme.motionFast,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
          border: Border.all(
            color: accent,
            width: selected ? 2 : 1,
          ),
          color: selected
              ? theme.colorScheme.primary.withValues(alpha: 0.12)
              : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: (selected ? theme.colorScheme.primary : mode.color)
                            .withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        mode.icon,
                        color: selected ? theme.colorScheme.primary : mode.color,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        label,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                          color: selected ? theme.colorScheme.primary : null,
                        ),
                      ),
                    ),
                    AnimatedSwitcher(
                      duration: AppTheme.motionFast,
                      child: selected
                          ? Icon(
                              Icons.check_circle_rounded,
                              size: 22,
                              color: theme.colorScheme.primary,
                              key: const ValueKey(true),
                            )
                          : Icon(
                              Icons.circle_outlined,
                              size: 22,
                              color: theme.colorScheme.outlineVariant,
                              key: const ValueKey(false),
                            ),
                    ),
                  ],
                ),
                ?child,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
