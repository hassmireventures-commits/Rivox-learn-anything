import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/quiz_kind.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/constants/supported_languages.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/healing/resilient_ai_provider.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/remote/ai/ai_provider_factory.dart';
import '../../../data/remote/ai/models/quiz_generation_request.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/language_picker_field.dart';
import '../../../shared/widgets/primary_button.dart';

class CreateQuizScreen extends ConsumerStatefulWidget {
  const CreateQuizScreen({
    super.key,
    this.forMultiplayer = false,
    this.initialTopic,
  });

  final bool forMultiplayer;
  final String? initialTopic;

  @override
  ConsumerState<CreateQuizScreen> createState() => _CreateQuizScreenState();
}

class _CreateQuizScreenState extends ConsumerState<CreateQuizScreen> {
  final _topicController = TextEditingController();
  int _questionCount = 10;
  String _difficulty = 'medium';
  String _questionType = 'mcq';
  bool _timerEnabled = false;
  int _timerSeconds = 30;
  bool _randomizeQuestions = true;
  bool _randomizeOptions = true;
  bool _generateExplanations = true;
  late String _languageCode;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _languageCode = SupportedLanguages.defaultCode;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final topic = widget.initialTopic ?? GoRouterState.of(context).uri.queryParameters['topic'];
      if (topic != null && topic.isNotEmpty && mounted) {
        _topicController.text = Uri.decodeComponent(topic);
        setState(() {});
      }
      final settings = ref.read(settingsProvider).valueOrNull;
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

  Future<void> _generate() async {
    final l10n = context.l10n;
    final topic = _topicController.text.trim();
    if (topic.isEmpty) {
      setState(() => _error = l10n.createQuizTopicRequired);
      return;
    }

    final providerConfig = await ref.read(defaultAiProviderProvider.future);
    if (providerConfig == null) {
      setState(() => _error = l10n.createQuizNoProvider);
      return;
    }

    final apiKey = await ref.read(providerRepositoryProvider).getApiKey(providerConfig.uuid);
    if (apiKey == null || apiKey.isEmpty) {
      setState(() => _error = l10n.createQuizMissingApiKey);
      return;
    }

    setState(() {
      _generating = true;
      _error = null;
    });

    final aiLanguage = aiLanguageName(_languageCode);
    final request = QuizGenerationRequest(
      topic: topic,
      questionCount: _questionCount,
      difficulty: _difficulty,
      questionType: _questionType,
      language: aiLanguage,
      randomizeQuestions: _randomizeQuestions,
      randomizeOptions: _randomizeOptions,
      generateExplanations: _generateExplanations,
      timerSeconds: _timerEnabled ? _timerSeconds : null,
    );

    try {
      await ref.read(telemetryServiceProvider).emit('quiz_started', {
        'topic': topic,
        'source': widget.forMultiplayer ? 'multiplayer' : 'solo',
      });

      if (widget.forMultiplayer) {
        final providers = await ref.read(aiProvidersProvider.future);
        final fallback = providers.length > 1 ? providers[1] : null;
        String? fallbackKey;
        if (fallback != null) {
          fallbackKey = await ref.read(providerRepositoryProvider).getApiKey(fallback.uuid);
        }
        final resilient = ResilientAiProvider(
          primaryKey: providerConfig.uuid,
          primaryFactory: () => AiProviderFactory.create(config: providerConfig, apiKey: apiKey),
          fallbackKey: fallback?.uuid,
          fallbackFactory: fallback != null && fallbackKey != null && fallbackKey.isNotEmpty
              ? () => AiProviderFactory.create(config: fallback, apiKey: fallbackKey!)
              : null,
          circuitBreaker: ref.read(circuitBreakerProvider),
          healthMonitor: ref.read(healthMonitorProvider),
          telemetry: ref.read(telemetryServiceProvider),
          usageTracker: ref.read(usageTrackerProvider),
        );
        final generated = await resilient.generateQuiz(request);
        final session = await ref.read(quizRepositoryProvider).saveGeneratedQuiz(
              request: request,
              generated: generated,
              source: 'multiplayer',
              quizKind: QuizKind.multiplayer,
            );
        if (!mounted) return;
        context.pushReplacement('/multiplayer/host/${session.uuid}');
      } else {
        final quizId = await ref.read(learningOrchestratorProvider).runQuizGeneration(
              topic: topic,
              questionCount: _questionCount,
              difficulty: _difficulty,
              questionType: _questionType,
              language: aiLanguage,
              explanations: _generateExplanations,
              timerSeconds: _timerEnabled ? _timerSeconds : null,
            );
        await ref.read(anonAnalyticsSyncProvider).publishPromptOutcome('standard', success: true);
        if (!mounted) return;
        context.pushReplacement('/quiz/play/$quizId');
      }
    } on AppException catch (e) {
      await ref.read(telemetryServiceProvider).emit('drop_off', {'screen': 'create_quiz'});
      if (e is RateLimitException && mounted) {
        await showApiLimitDialog(context, e);
      }
      setState(() => _error = e.message);
    } catch (e) {
      await ref.read(telemetryServiceProvider).emit('drop_off', {'screen': 'create_quiz'});
      setState(() => _error = l10n.createQuizGenerateFailed);
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final difficultyLabel = L10nHelpers.difficultyLabel(l10n, _difficulty);
    final typeLabel = _questionTypeLabel(l10n, _questionType);
    final timerPreview = _timerEnabled
        ? l10n.createQuizTimerPreview(_timerSeconds)
        : l10n.createQuizNoTimer;
    final languageDisplay = languageNativeName(_languageCode);
    final topic = _topicController.text.trim();

    return Stack(
      children: [
        Scaffold(
          appBar: AppBar(
            title: Text(widget.forMultiplayer ? l10n.createQuizHostTitle : l10n.createQuizTitle),
          ),
          body: AbsorbPointer(
            absorbing: _generating,
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (!widget.forMultiplayer)
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
                          hintText: l10n.createQuizTopicHint,
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
                      Slider(
                        value: AppConstants.questionCounts
                            .indexOf(_questionCount)
                            .clamp(0, AppConstants.questionCounts.length - 1)
                            .toDouble(),
                        min: 0,
                        max: (AppConstants.questionCounts.length - 1).toDouble(),
                        divisions: AppConstants.questionCounts.length - 1,
                        label: '$_questionCount',
                        onChanged: (v) {
                          setState(() => _questionCount = AppConstants.questionCounts[v.round()]);
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
                              ? l10n.createQuizTimerOn(_timerSeconds)
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
                    onChanged: (code) => setState(() => _languageCode = code),
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
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error),
                        const SizedBox(width: 12),
                        Expanded(child: Text(_error!)),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                PrimaryButton(
                  label: l10n.createQuizGenerateButton,
                  icon: Icons.auto_awesome_rounded,
                  isLoading: _generating,
                  onPressed: _generating ? null : _generate,
                ),
              ],
            ),
          ),
        ),
        GenerationOverlay(
          visible: _generating,
          topic: topic.isEmpty ? null : topic,
        ),
      ],
    );
  }
}
