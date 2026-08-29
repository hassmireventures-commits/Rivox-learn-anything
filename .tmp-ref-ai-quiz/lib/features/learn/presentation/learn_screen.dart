import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/layout/responsive_layout.dart';
import '../../../core/debug/agent_debug_log.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/remote/ai/learning_orchestrator.dart';
import '../../../shared/navigation/study_path_navigation.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/app_shell_app_bar.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/learning_path_tile.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/priority_topic_card.dart';

class LearnScreen extends ConsumerStatefulWidget {
  const LearnScreen({super.key});

  @override
  ConsumerState<LearnScreen> createState() => _LearnScreenState();
}

class _LearnScreenState extends ConsumerState<LearnScreen> {
  bool _loading = false;
  bool _generatingPath = false;
  String? _summary;
  String? _loadingTopic;

  Future<void> _generatePath() async {
    final l10n = context.l10n;
    if (await ref.read(learnerRepositoryProvider).hasActivePath()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.learnFinishCurrentPathFirst)),
      );
      return;
    }

    final providers = await ref.read(aiProvidersProvider.future);
    if (providers.isEmpty) {
      if (!mounted) return;
      context.push('/settings/providers');
      return;
    }
    setState(() {
      _loading = true;
      _generatingPath = true;
      _loadingTopic = l10n.learnYourLearningPath;
    });
    try {
      final id = await ref.read(learningOrchestratorProvider).generateLearningPathWithLlm();
      if (!mounted) return;
      context.push('/paths/$id');
      ref.invalidate(personalizationProvider);
    } catch (e) {
      if (mounted) await showAppErrorDialog(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _generatingPath = false;
          _loadingTopic = null;
        });
      }
    }
  }

  Future<void> _runDecision() async {
    final l10n = context.l10n;
    setState(() {
      _loading = true;
      _generatingPath = false;
    });
    try {
      final orch = ref.read(learningOrchestratorProvider);
      final decision = await orch.decideNext();
      // #region agent log
      AgentDebugLog.log(
        location: 'learn_screen.dart:_runDecision',
        message: 'Orchestrator decision',
        hypothesisId: 'H6',
        data: {
          'action': decision.action.name,
          'pathId': decision.pathId,
          'moduleIndex': decision.moduleIndex,
          'topic': decision.topic,
        },
      );
      // #endregion

      switch (decision.action) {
        case LearningAction.encourageBreak:
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(decision.reason)));
        case LearningAction.openPathModule:
          if (decision.pathId != null) {
            final idx = decision.moduleIndex ?? 0;
            context.push('/paths/${decision.pathId}?module=$idx');
          }
        case LearningAction.suggestPath:
          await _generatePath();
        case LearningAction.summarizeWeaknesses:
        case LearningAction.followUp:
          final text = await orch.summarizeWeaknesses();
          setState(() => _summary = text);
        case LearningAction.generateQuiz:
        case LearningAction.remedialQuiz:
          final providers = await ref.read(aiProvidersProvider.future);
          if (providers.isEmpty) {
            if (!mounted) return;
            context.push('/settings/providers');
            return;
          }
          setState(() => _loadingTopic = decision.topic);
          final quizId = await orch.runQuizGeneration(
            topic: decision.topic ?? l10n.learnPracticeFallback,
            questionCount: decision.questionCount,
            difficulty: decision.difficulty,
          );
          if (!mounted) return;
          context.push('/quiz/play/$quizId');
      }
      ref.invalidate(personalizationProvider);
      ref.invalidate(nextDecisionProvider);
    } catch (e) {
      if (mounted) await showAppErrorDialog(context, e);
    } finally {
      if (mounted) {
        setState(() {
          _loading = false;
          _generatingPath = false;
          _loadingTopic = null;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final layout = responsiveLayoutOf(context);
    final personalization = ref.watch(personalizationProvider);
    final decision = ref.watch(nextDecisionProvider);
    final pathsAsync = ref.watch(learnerRepositoryProvider).activePaths();

    return Stack(
      children: [
        Scaffold(
          appBar: AppShellAppBar(title: l10n.navLearn),
          body: personalization.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('$e')),
            data: (state) => ListView(
              padding: layout.pagePadding,
              children: [
                Text(
                  l10n.learnJourneyTitle,
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                SizedBox(height: layout.sectionGap * 0.5),
                FutureBuilder(
                  future: pathsAsync,
                  builder: (context, snapshot) {
                    final paths = snapshot.data ?? [];
                    final hasActivePath = paths.isNotEmpty;
                    final primary = hasActivePath ? paths.first : null;
                    final steps = primary != null
                        ? ref.read(learnerRepositoryProvider).pathSteps(primary)
                        : const [];

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (hasActivePath && primary != null) ...[
                          Text(l10n.learnYourPathSection, style: Theme.of(context).textTheme.titleLarge),
                          const SizedBox(height: 10),
                          AppCard(
                            onTap: () => context.push('/paths/${primary.uuid}?module=${primary.currentIndex}'),
                            child: Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: AppTheme.seedColor.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Icon(Icons.route_rounded, color: AppTheme.seedColor),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        l10n.learnContinuePath,
                                        style: const TextStyle(fontWeight: FontWeight.w700),
                                      ),
                                      Text(l10n.learnPathProgress(primary.title, primary.currentIndex, steps.length)),
                                    ],
                                  ),
                                ),
                                const Icon(Icons.chevron_right_rounded),
                              ],
                            ),
                          ),
                        ] else
                          PrimaryButton(
                            label: l10n.learnGeneratePath,
                            icon: Icons.route_rounded,
                            isLoading: _loading && _generatingPath,
                            onPressed: _loading ? null : _generatePath,
                          ),
                      ],
                    );
                  },
                ),
                SizedBox(height: layout.sectionGap),
                decision.when(
                  data: (d) => AppCard(
                    color: AppTheme.seedColor.withValues(alpha: 0.08),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(d.reason, style: const TextStyle(fontWeight: FontWeight.w600)),
                        if (d.topic != null) ...[
                          const SizedBox(height: 6),
                          Text(l10n.learnTopicLabel(d.topic!)),
                        ],
                        const SizedBox(height: 14),
                        PrimaryButton(
                          label: l10n.learnContinueLearning,
                          icon: Icons.play_arrow_rounded,
                          isLoading: _loading && !_generatingPath,
                          onPressed: _loading ? null : _runDecision,
                        ),
                      ],
                    ),
                  ),
                  loading: () => const AppCard(child: LinearProgressIndicator()),
                  error: (e, _) => AppCard(child: Text('$e')),
                ),
                SizedBox(height: layout.sectionGap),
                Text(l10n.learnQuickPracticeSection, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                Text(l10n.learnPriorityTopics, style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 10),
                if (state.weakTopics.isEmpty)
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.school_rounded, size: 48),
                        const SizedBox(height: 8),
                        Text(l10n.learnNoPriorityTopics),
                        const SizedBox(height: 10),
                        FutureBuilder(
                          future: pathsAsync,
                          builder: (context, snapshot) {
                            if (snapshot.data?.isNotEmpty ?? false) {
                              return const SizedBox.shrink();
                            }
                            return OutlinedButton(
                              onPressed: _generatePath,
                              child: Text(l10n.learnGenerateFirstPath),
                            );
                          },
                        ),
                      ],
                    ),
                  )
                else
                  ...state.weakTopics.take(3).map(
                        (topic) => Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: PriorityTopicCard(
                            topic: topic,
                            reason: l10n.learnNeedsAttentionReason,
                            onTap: () => openQuickQuizForTopic(context, topic: topic),
                          ),
                        ),
                      ),
                SizedBox(height: layout.sectionGap),
                Text(l10n.learnLearningPaths, style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 10),
                FutureBuilder(
                  future: pathsAsync,
                  builder: (context, snapshot) {
                    final paths = snapshot.data ?? [];
                    if (paths.isEmpty) {
                      return AppCard(child: Text(l10n.learnPathsEmpty));
                    }
                    return Column(
                      children: paths.map((path) {
                        final steps = ref.read(learnerRepositoryProvider).pathSteps(path);
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Hero(
                            tag: 'path-${path.uuid}',
                            child: LearningPathTile(
                              title: path.title,
                              progressLabel: l10n.learnModulesProgress(path.currentIndex, steps.length),
                              onTap: () => context.push('/paths/${path.uuid}'),
                            ),
                          ),
                        );
                      }).toList(),
                    );
                  },
                ),
                if (_summary != null) ...[
                  SizedBox(height: layout.sectionGap),
                  AppCard(child: Text(_summary!)),
                ],
              ],
            ),
          ),
        ),
        GenerationOverlay(
          visible: _loading,
          topic: _loadingTopic,
          forPath: _generatingPath,
        ),
      ],
    );
  }
}
