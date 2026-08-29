import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/quiz_kind.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/locale_utils.dart';
import '../../../core/network/network_service.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/primary_button.dart';

const _kCounts = [5, 8, 10, 12];

/// Configure and generate an interview drill (MCQ + short-answer mix).
class DrillCreateScreen extends ConsumerStatefulWidget {
  const DrillCreateScreen({super.key});

  @override
  ConsumerState<DrillCreateScreen> createState() => _DrillCreateScreenState();
}

class _DrillCreateScreenState extends ConsumerState<DrillCreateScreen> {
  final _themeController = TextEditingController();
  List<String> _themes = [];
  int _questionCount = 8;
  String _difficulty = 'medium';
  bool _loading = true;
  bool _generating = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _themeController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final qp = GoRouterState.of(context).uri.queryParameters['theme'];
    final l10n = context.l10n;
    final progress = ref.read(goalProgressRepositoryProvider);
    final knowledge = ref.read(knowledgeRepositoryProvider);
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    final skillThemes = await progress.interviewDrillThemes();
    final themes = <String>[];
    if (await knowledge.hasIndexedType(profile.goalMode, 'resume')) {
      themes.add(l10n.careerDrillSelfIntroTheme);
    }
    for (final t in skillThemes) {
      if (!themes.contains(t)) themes.add(t);
    }
    if (!mounted) return;
    setState(() {
      _themes = themes;
      if (qp != null && qp.isNotEmpty) {
        _themeController.text = Uri.decodeComponent(qp);
      } else if (themes.isNotEmpty) {
        _themeController.text = themes.first;
      }
      _loading = false;
    });
  }

  Future<void> _showGenerationError(Object e, {String? fallbackMessage}) async {
    if (!mounted) return;
    setState(() {
      _generating = false;
      _error = null;
    });
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    final mapped = e is AppException
        ? e
        : UnknownException(fallbackMessage ?? context.l10n.createQuizGenerateFailed);
    await showAppErrorDialog(
      context,
      mapped,
      onRateLimitDismissed: () async {
        await ref.read(usageTrackerProvider).clearActiveRateLimits();
        ref.invalidate(activeRateLimitProvider);
      },
    );
  }

  void _cancelGeneration() {
    if (!_generating) return;
    setState(() => _generating = false);
  }

  Future<void> _generate({bool voice = false}) async {
    FocusManager.instance.primaryFocus?.unfocus();
    final l10n = context.l10n;
    final theme = _themeController.text.trim();
    if (theme.isEmpty) {
      setState(() => _error = l10n.careerDrillThemeRequired);
      return;
    }
    final provider = await ref.read(defaultAiProviderProvider.future);
    if (provider == null) {
      setState(() => _error = l10n.examMockNoProvider);
      return;
    }

    setState(() {
      _generating = true;
      _error = null;
    });

    try {
      await NetworkService.instance.ensureConnected();
    } on NoInternetException catch (e) {
      await _showGenerationError(e);
      return;
    } catch (_) {}

    try {
      final settings = ref.read(settingsProvider).asData?.value;
      final language = aiLanguageName(settings?.language ?? 'en');
      final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
      final knowledge = ref.read(knowledgeRepositoryProvider);
      final role = profile.goalContext.trim();
      final company = await knowledge.extractCompanyFromJd(profile.goalMode);
      final roleLabel = role.isEmpty
          ? (company != null ? '@ $company' : '')
          : (company != null ? '$role @ $company' : role);
      final topic = roleLabel.isEmpty ? 'Interview: $theme' : 'Interview ($roleLabel): $theme';

      final hasResume = await knowledge.hasIndexedType(profile.goalMode, 'resume');
      final hasJd = await knowledge.hasIndexedType(profile.goalMode, 'jd');
      final generationMode = (hasResume || hasJd) ? 'grounded' : null;

      final quizId = await ref.read(learningOrchestratorProvider).runQuizGeneration(
            topic: topic,
            questionCount: _questionCount,
            difficulty: _difficulty,
            questionType: 'interview',
            language: language,
            explanations: true,
            quizKind: QuizKind.interview,
            passPercent: 60,
            generationMode: generationMode,
            voiceInterviewOnly: voice,
          );

      await ref.read(telemetryServiceProvider).emit('drill_started', {
        'theme': theme,
        'questions': _questionCount,
        'role': role,
      });

      if (!mounted) return;
      final voiceQuery = voice ? '?voice=1' : '';
      context.pushReplacement('/quiz/play/$quizId$voiceQuery');
    } on AppException catch (e) {
      await _showGenerationError(e);
    } catch (_) {
      await _showGenerationError(UnknownException(l10n.createQuizGenerateFailed));
    } finally {
      if (mounted) setState(() => _generating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF27AE60)),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: Text(l10n.careerDrillTitle)),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(24),
            children: [
              AppCard(
                color: const Color(0xFF27AE60).withValues(alpha: 0.08),
                child: Text(
                  l10n.careerDrillSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _themeController,
                decoration: InputDecoration(
                  labelText: l10n.careerDrillThemeLabel,
                  hintText: l10n.careerDrillThemeHint,
                  prefixIcon: const Icon(Icons.topic_outlined),
                ),
              ),
              if (_themes.isNotEmpty) ...[
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _themes.map((t) {
                    final selected = _themeController.text == t;
                    return FilterChip(
                      label: Text(t),
                      selected: selected,
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _themeController.text = t;
                        _error = null;
                      }),
                    );
                  }).toList(),
                ),
              ],
              const SizedBox(height: 16),
              Text(l10n.examMockQuestionCount, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _kCounts.map((c) {
                  return FilterChip(
                    label: Text('$c'),
                    selected: _questionCount == c,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _questionCount = c),
                  );
                }).toList(),
              ),
              const SizedBox(height: 16),
              Text(l10n.examMockDifficulty, style: theme.textTheme.titleSmall),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['easy', 'medium', 'hard'].map((d) {
                  return FilterChip(
                    label: Text(d),
                    selected: _difficulty == d,
                    showCheckmark: false,
                    onSelected: (_) => setState(() => _difficulty = d),
                  );
                }).toList(),
              ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error!,
                  style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.error),
                ),
              ],
              const SizedBox(height: 24),
              PrimaryButton(
                label: l10n.careerDrillGenerate,
                icon: Icons.record_voice_over_rounded,
                isLoading: _generating,
                onPressed: _generate,
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _generating ? null : () => context.push('/career/voice-interview'),
                icon: const Icon(Icons.mic_rounded),
                label: Text(l10n.interviewVoiceStart),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: _generating ? null : () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
                label: Text(l10n.commonCancel),
              ),
            ],
          ),
          GenerationOverlay(
            visible: _generating,
            topic: _themeController.text.trim().isEmpty ? null : _themeController.text.trim(),
            onCancel: _cancelGeneration,
          ),
        ],
      ),
    );
  }
}
