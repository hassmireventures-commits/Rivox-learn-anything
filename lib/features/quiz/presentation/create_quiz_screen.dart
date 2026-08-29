import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai_platform/prompt_firewall.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/network/network_service.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/supported_languages.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_ai_quota.dart';
import '../../../core/services/generation_job_service.dart';
import '../../../core/services/generation_sizing.dart';
import '../../../core/services/learner_goal_guard.dart';
import '../../../core/services/topic_goal_guardrail.dart';
import '../../../core/services/topic_goal_relevance.dart';
import '../../../core/theme/app_theme.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/built_in_quota_dialog.dart';
import '../../../shared/widgets/generation_job_overlay_binding.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/goal_required_dialog.dart';
import '../../../shared/widgets/language_picker_field.dart';
import '../../../shared/widgets/primary_button.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({
    super.key,
    this.initialTopic,
  });

  final String? initialTopic;

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _topicController = TextEditingController();
  int _questionCount = 5;
  String _difficulty = 'medium';
  String _questionType = 'mcq';
  bool _timerEnabled = false;
  int _timerSeconds = 30;
  bool _randomizeQuestions = true;
  bool _randomizeOptions = true;
  bool _generateExplanations = true;
  late String _languageCode;
  String? _error;
  bool _guardrailBusy = false;

  static const _generationTimeout = Duration(minutes: 3);

  @override
  void initState() {
    super.initState();
    _languageCode = SupportedLanguages.defaultCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final q = GoRouterState.of(context).uri.queryParameters;
      String decode(String? raw) {
        if (raw == null || raw.isEmpty) return '';
        try {
          return Uri.decodeComponent(raw);
        } catch (_) {
          return raw;
        }
      }

      final topic = widget.initialTopic ?? q['topic'];
      if (topic != null && topic.isNotEmpty && mounted) {
        _topicController.text = decode(topic);
      }
      final difficulty = decode(q['difficulty']);
      if (difficulty.isNotEmpty) {
        _difficulty = difficulty;
      }
      final type = decode(q['type']);
      if (type.isNotEmpty) {
        _questionType = type;
      }
      final countRaw = q['count'];
      if (countRaw != null) {
        final n = int.tryParse(countRaw);
        if (n != null && AppConstants.questionCounts.contains(n)) {
          _questionCount = n;
        }
      }
      if (mounted) setState(() {});
      final settings = ref.read(settingsProvider).asData?.value;
      if (settings != null && mounted) {
        setState(() {
          _languageCode = SupportedLanguages.normalizeCode(settings.language);
        });
      }
    });
  }

  @override
  void dispose() {
    _topicController.dispose();
    super.dispose();
  }

  String _questionTypeLabel(dynamic l10n, String type) {
    return switch (type) {
      'mcq' => l10n.questionTypeMcq,
      'true_false' => l10n.questionTypeTrueFalse,
      'fill_blank' => l10n.questionTypeFillBlank,
      'mixed' => l10n.questionTypeMixed,
      _ => type,
    };
  }

  void _cancelGeneration() {
    ref.read(generationJobServiceProvider).cancel();
  }

  void _continueInBackground() {
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy || job.kind != GenerationJobKind.quiz) return;
    job.continueInBackground();
    setState(() => _guardrailBusy = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generationRunningInBackground)),
    );
    if (context.canPop()) {
      context.pop();
    }
  }

  void _onLeaveWhileGenerating() {
    if (!mounted) return;
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy || job.kind != GenerationJobKind.quiz) return;
    if (job.uiAttached) {
      job.continueInBackground();
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generationRunningInBackground)),
    );
  }

  Future<void> _showGenerationError(Object e, {String? fallbackMessage}) async {
    if (!mounted) return;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final mapped = e is AppException
        ? e
        : AppException.from(
            e,
            fallback: fallbackMessage ?? context.l10n.createQuizGenerateFailed,
            task: 'quiz',
          );
    await showAppErrorDialog(
      context,
      mapped,
      onRateLimitDismissed: () async {
        await ref.read(usageTrackerProvider).clearActiveRateLimits();
        ref.invalidate(activeRateLimitProvider);
      },
      onRetry: _generate,
    );
  }

  Future<void> _generate() async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = context.l10n;
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() => _error = l10n.createQuizTopicRequired);
      return;
    }

    final job = ref.read(generationJobServiceProvider);
    if (job.isBusy || _guardrailBusy) {
      setState(() => _error = l10n.generationJobInProgress);
      return;
    }

    setState(() => _error = null);

    final profile = await ref.read(learnerProfileProvider.future);
    final repo = ref.read(learnerRepositoryProvider);
    if (!LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: repo)) {
      if (!mounted) return;
      await showGoalRequiredDialog(context);
      return;
    }

    final firewall = const PromptFirewall();
    final blocked = await firewall.sanitize(topic);
    if (blocked.blocked) {
      if (!mounted) return;
      setState(() => _error = l10n.topicLanguageNotAllowed);
      return;
    }

    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException catch (e) {
      await _showGenerationError(e);
      return;
    } catch (_) {}

    final personalization = await ref.read(personalizationProvider.future);
    final providers = await ref.read(aiProvidersProvider.future);
    final active = GenerationSizing.pickActiveCloudProvider(providers);
    final isBuiltin = GenerationSizing.isBuiltinProvider(active);
    if (isBuiltin || active?.uuid == BuiltInAiConfig.uuid) {
      try {
        await BuiltInAiQuota.instance.ensureCanGenerate();
      } on BuiltInQuotaExceededException {
        if (!mounted) return;
        final unlocked = await showBuiltInQuotaDialog(context);
        if (unlocked && mounted) {
          await _generate();
        }
        return;
      }
    }

    // Start processing UI, then run goal guardrail.
    if (!mounted) return;
    setState(() => _guardrailBusy = true);
    TopicGoalRelevanceResult relevance;
    try {
      relevance = await TopicGoalGuardrail(llmManager: ref.read(llmManagerProvider)).assess(
        topic: topic,
        goalLabel: personalization.goalContextLabel,
        primaryTopics: personalization.primaryTopics,
        focusTitles: [
          ...personalization.focusTitles,
          ...personalization.weakTopics,
        ],
      );
    } catch (_) {
      relevance = TopicGoalRelevanceGate.evaluate(
        topic: topic,
        goalLabel: personalization.goalContextLabel,
        goalTopics: [
          ...personalization.primaryTopics,
          ...personalization.focusTitles,
        ],
      );
    }
    if (!mounted) return;
    setState(() => _guardrailBusy = false);

    if (relevance.level == TopicGoalRelevance.offGoal) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.topicOffGoalTitle),
          content: Text(
            l10n.topicOffGoalBody(personalization.goalContextLabel, topic),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(l10n.commonDismiss),
            ),
          ],
        ),
      );
      return;
    }
    if (relevance.level == TopicGoalRelevance.borderline) {
      final ok = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l10n.topicBorderlineTitle),
          content: Text(
            l10n.topicBorderlineBody(personalization.goalContextLabel, topic),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text(l10n.commonDismiss),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: Text(l10n.topicBorderlineConfirm),
            ),
          ],
        ),
      );
      if (ok != true || !mounted) return;
    }

    final aiLanguage = aiLanguageName(_languageCode);
    final questionCount = GenerationSizing.clampQuizQuestionCount(
      questionCount: _questionCount,
      isBuiltin: isBuiltin,
    );
    final explanations = GenerationSizing.explanationsForBuiltin(
      requested: _generateExplanations,
      isBuiltin: isBuiltin,
      questionCount: questionCount,
    );
    if (isBuiltin &&
        (questionCount != _questionCount ||
            explanations != _generateExplanations) &&
        mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.generationBuiltinQuizClamped)),
      );
    }
    final examDuration =
        _timerEnabled ? _timerSeconds * questionCount : null;

    try {
      await ref.read(telemetryServiceProvider).emit('quiz_started', {
        'topic': topic,
        'source': 'solo',
      });

      await job
          .startQuiz(
            topic: topic,
            questionCount: questionCount,
            difficulty: _difficulty,
            questionType: _questionType,
            language: aiLanguage,
            explanations: explanations,
            randomizeQuestions: _randomizeQuestions,
            randomizeOptions: _randomizeOptions,
            examDurationSeconds: examDuration,
          )
          .timeout(_generationTimeout);

      if (!mounted) return;
      final latest = ref.read(generationJobServiceProvider);
      final route = latest.successRoute;
      final cancelled = latest.userCancelled;
      final waiting = latest.uiAttached;
      if (route != null && !cancelled && waiting) {
        await ref.read(anonAnalyticsSyncProvider).publishPromptOutcome('standard', success: true);
        context.pushReplacement(route);
      }
    } on TimeoutException catch (_) {
      final latest = ref.read(generationJobServiceProvider);
      if (!latest.uiAttached && latest.isBusy) {
        return;
      }
      try {
        await ref.read(anonAnalyticsSyncProvider).publishPromptOutcome('standard', success: false);
      } catch (_) {}
      await _showGenerationError(GenerationTimeoutException(l10n.createQuizTimeout));
    } on NoProviderConfiguredException catch (e) {
      await _showGenerationError(e);
    } on MissingApiKeyException catch (e) {
      await _showGenerationError(e);
    } on AppException catch (e) {
      try {
        await ref.read(telemetryServiceProvider).emit('drop_off', {'screen': 'create_quiz'});
        await ref.read(anonAnalyticsSyncProvider).publishPromptOutcome('standard', success: false);
      } catch (_) {}
      await _showGenerationError(e);
    } catch (e) {
      try {
        await ref.read(telemetryServiceProvider).emit('drop_off', {'screen': 'create_quiz'});
        await ref.read(anonAnalyticsSyncProvider).publishPromptOutcome('standard', success: false);
      } catch (_) {}
      await _showGenerationError(e, fallbackMessage: l10n.createQuizGenerateFailed);
    }
  }

  Future<void> _startDemoQuiz() async {
    final id = await ref.read(demoQuizServiceProvider).createDemoQuiz();
    if (!mounted) return;
    context.push('/quiz/play/$id');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final job = ref.watch(generationJobServiceProvider);
    final overlayState = watchGenerationJobOverlay(ref, GenerationJobKind.quiz);
    final showOverlay = overlayState.showOverlay;
    final showStrip = overlayState.showStrip;
    final generating = showOverlay || showStrip;
    final providers = ref.watch(aiProvidersProvider).asData?.value ?? [];
    final personalization = ref.watch(personalizationProvider).asData?.value;
    final topicHintExamples = [
      ...?personalization?.primaryTopics.take(2),
      ...?personalization?.focusTitles.take(1),
    ].where((s) => s.trim().isNotEmpty).toSet().take(3).join(', ');
    final topicHint = topicHintExamples.isNotEmpty
        ? l10n.createQuizTopicHintFromGoals(topicHintExamples)
        : l10n.createQuizTopicHint;
    final difficultyLabel = L10nHelpers.difficultyLabel(l10n, _difficulty);
    final typeLabel = _questionTypeLabel(l10n, _questionType);
    final totalSeconds = _timerSeconds * _questionCount;
    final timerPreview = _timerEnabled
        ? l10n.createQuizTimerPreview(totalSeconds)
        : l10n.createQuizNoTimer;
    final languageDisplay = languageNativeName(_languageCode);
    final topic = _topicController.text.trim();

    listenGenerationJobBackgroundSuccess(ref, GenerationJobKind.quiz, onSuccess: (route) {
      if (!mounted) return;
      context.pushReplacement(route);
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && generating) _onLeaveWhileGenerating();
      },
      child: Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(l10n.createQuizTitle),
          ),
          body: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20),
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.seedColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          l10n.quizKindQuick,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.seedColor,
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          l10n.createQuizQuickSubtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                ),
                if (providers.isEmpty) ...[
                  OutlinedButton.icon(
                    onPressed: _startDemoQuiz,
                    icon: const Icon(Icons.play_circle_outline_rounded),
                    label: Text(l10n.createQuizTryDemo),
                  ),
                  const SizedBox(height: 12),
                ],
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.createQuizTopicLabel, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      TextField(
                        controller: _topicController,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          hintText: topicHint,
                          prefixIcon: const Icon(Icons.lightbulb_outline_rounded),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.createQuizQuestionsCount(_questionCount),
                          style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: AppConstants.questionCounts.map((c) {
                          return ChoiceChip(
                            label: Text('$c'),
                            selected: _questionCount == c,
                            onSelected: (_) => setState(() => _questionCount = c),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.createQuizDifficulty, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        children: ['easy', 'medium', 'hard', 'expert'].map((d) {
                          return ChoiceChip(
                            label: Text(L10nHelpers.difficultyLabel(l10n, d)),
                            selected: _difficulty == d,
                            onSelected: (_) => setState(() => _difficulty = d),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.createQuizQuestionType, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          ('mcq', l10n.questionTypeMcq),
                          ('true_false', l10n.questionTypeTrueFalse),
                          ('fill_blank', l10n.questionTypeFillBlank),
                          ('mixed', l10n.questionTypeMixed),
                        ].map((t) {
                          return ChoiceChip(
                            label: Text(t.$2),
                            selected: _questionType == t.$1,
                            onSelected: (_) => setState(() => _questionType = t.$1),
                          );
                        }).toList(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.createQuizTimer),
                        subtitle: Text(
                          _timerEnabled
                              ? l10n.createQuizTimerOn(
                                  _timerSeconds,
                                  _questionCount,
                                  totalSeconds,
                                )
                              : l10n.commonOff,
                        ),
                        value: _timerEnabled,
                        onChanged: (v) => setState(() => _timerEnabled = v),
                      ),
                      if (_timerEnabled)
                        SizedBox(
                          height: 100,
                          child: ListWheelScrollView.useDelegate(
                            itemExtent: 40,
                            perspective: 0.003,
                            diameterRatio: 1.2,
                            physics: const FixedExtentScrollPhysics(),
                            onSelectedItemChanged: (i) {
                              setState(() => _timerSeconds = AppConstants.timerOptions[i]);
                            },
                            controller: FixedExtentScrollController(
                              initialItem: AppConstants.timerOptions.indexOf(_timerSeconds).clamp(0, 5),
                            ),
                            childDelegate: ListWheelChildBuilderDelegate(
                              childCount: AppConstants.timerOptions.length,
                              builder: (context, index) {
                                final value = AppConstants.timerOptions[index];
                                final selected = value == _timerSeconds;
                                return Center(
                                  child: Text(
                                    l10n.createQuizTimerOption(value),
                                    style: TextStyle(
                                      fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                                      fontSize: selected ? 18 : 14,
                                      color: selected ? AppTheme.seedColor : null,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: Column(
                    children: [
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.createQuizRandomizeQuestions),
                        value: _randomizeQuestions,
                        onChanged: (v) => setState(() => _randomizeQuestions = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.createQuizRandomizeOptions),
                        value: _randomizeOptions,
                        onChanged: (v) => setState(() => _randomizeOptions = v),
                      ),
                      SwitchListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(l10n.createQuizGenerateExplanations),
                        value: _generateExplanations,
                        onChanged: (v) => setState(() => _generateExplanations = v),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  child: LanguagePickerField(
                    selectedCode: _languageCode,
                    label: l10n.createQuizLanguage,
                    onChanged: (code) async {
                      setState(() => _languageCode = code);
                      return code;
                    },
                  ),
                ),
                const SizedBox(height: 16),
                AppCard(
                  color: AppTheme.seedColor.withValues(alpha: 0.08),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.createQuizLivePreview, style: Theme.of(context).textTheme.titleMedium),
                      const SizedBox(height: 8),
                      Text(
                        topic.isEmpty
                            ? l10n.createQuizPreviewEmpty(_questionCount, difficultyLabel)
                            : l10n.createQuizPreviewFilled(topic, _questionCount, difficultyLabel),
                      ),
                      Text(
                        l10n.createQuizPreviewDetails(typeLabel, timerPreview, languageDisplay),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  AppCard(
                    color: Theme.of(context).colorScheme.errorContainer,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                _error!,
                                style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer),
                              ),
                            ),
                          ],
                        ),
                        if (!_error!.contains('provider') && !_error!.contains('API key')) ...[
                          const SizedBox(height: 10),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton.icon(
                              onPressed: generating ? null : () {
                                setState(() => _error = null);
                                _generate();
                              },
                              icon: const Icon(Icons.refresh_rounded, size: 16),
                              label: const Text('Retry'),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                if (showStrip) ...[
                  AppCard(
                    child: Row(
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            l10n.generationInProgressStrip,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ),
                        if (job.successRoute != null)
                          TextButton(
                            onPressed: () => context.pushReplacement(job.successRoute!),
                            child: Text(l10n.generationOpenWhenReady),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],
                PrimaryButton(
                  label: l10n.createQuizGenerateButton,
                  icon: Icons.auto_awesome_rounded,
                  isLoading: showOverlay || _guardrailBusy,
                  onPressed: (showOverlay || _guardrailBusy) ? null : _generate,
                ),
              ],
            ),
        ),
        GenerationOverlay(
          visible: showOverlay,
          topic: topic.isEmpty ? null : topic,
          onCancel: () {
            setState(() => _guardrailBusy = false);
            _cancelGeneration();
          },
          onContinueInBackground: _continueInBackground,
        ),
      ],
    ),
    );
  }
}
