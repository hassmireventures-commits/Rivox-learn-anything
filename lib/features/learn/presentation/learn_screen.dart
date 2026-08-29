import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/ai_platform/ai_consent_gate.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/ai_platform_providers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_ai_quota.dart';
import '../../../core/services/generation_job_service.dart';
import '../../../core/services/generation_sizing.dart';
import '../../../core/services/learner_goal_guard.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/learning_path.dart';
import '../../../data/remote/ai/learning_orchestrator.dart';
import '../../../shared/navigation/study_path_navigation.dart';
import '../../../shared/widgets/ai_status_badge.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/built_in_quota_dialog.dart';
import '../../../shared/widgets/guidance/adaptive_ui_banner.dart';
import '../../../shared/widgets/guidance/empty_state_guide.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/dashboard/dashboard_page_scaffold.dart';
import '../../../shared/widgets/dashboard/dashboard_section_header.dart';
import '../../../shared/widgets/dashboard/horizontal_feature_card.dart';
import '../../../shared/widgets/generation_job_overlay_binding.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/goal_required_dialog.dart';
import '../../../shared/widgets/learning_path_tile.dart';
import '../../../shared/widgets/primary_button.dart';

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
  int _pathModuleCount = 6;
  late Future<List<LearningPath>> _pathsFuture;
  late Future<List<LearningPath>> _completedPathsFuture;

  @override
  void initState() {
    super.initState();
    _pathsFuture = ref.read(learnerRepositoryProvider).activePaths();
    _completedPathsFuture = ref.read(learnerRepositoryProvider).completedPaths();
    WidgetsBinding.instance.addPostFrameCallback((_) => _handleLearnQuery());
  }

  Future<void> _handleLearnQuery() async {
    if (!mounted) return;
    final qp = GoRouterState.of(context).uri.queryParameters;
    if (qp['generatePath'] == '1') {
      await _generatePath();
    } else if (qp['fromContent'] == '1') {
      await _generatePathFromContent();
    }
  }

  Future<void> _refresh() async {
    ref.invalidate(personalizationProvider);
    ref.invalidate(nextDecisionProvider);
    setState(() {
      _pathsFuture = ref.read(learnerRepositoryProvider).activePaths();
      _completedPathsFuture = ref.read(learnerRepositoryProvider).completedPaths();
    });
  }

  /// After popping a path detail route: refresh lists, clear stuck overlay flags,
  /// and soft-refresh personalization without blocking the tab with a spinner.
  void _onReturnFromPath() {
    if (!mounted) return;
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy) {
      job.clearTerminalState();
    }
    setState(() {
      _loading = false;
      _generatingPath = false;
      _loadingTopic = null;
      _pathsFuture = ref.read(learnerRepositoryProvider).activePaths();
      _completedPathsFuture =
          ref.read(learnerRepositoryProvider).completedPaths();
    });
    ref.invalidate(personalizationProvider);
    ref.invalidate(nextDecisionProvider);
  }

  Future<void> _pushPath(String location) {
    return context.push(location).then((_) => _onReturnFromPath());
  }

  void _clearLoading() {
    if (!mounted) return;
    setState(() {
      _loading = false;
      _generatingPath = false;
      _loadingTopic = null;
    });
  }

  Future<bool> _ensureEngineReady() async {
    try {
      await ref.read(llmManagerProvider).validateReady();
      return true;
    } catch (e) {
      if (!mounted) return false;
      // No usable engine - send user to providers to configure one.
      context.push('/settings/providers');
      return false;
    }
  }

  Future<void> _showError(Object e) async {
    _clearLoading();
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy) {
      job.clearTerminalState();
    }
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    if (e is BuiltInQuotaExceededException) {
      final unlocked = await showBuiltInQuotaDialog(context);
      if (!mounted) return;
      _clearLoading();
      if (unlocked) {
        // Retry path once after rewarded unlock — without remounting a stuck overlay first.
        await _generatePath(fromQuotaRetry: true);
      }
      return;
    }
    await showAppErrorDialog(
      context,
      e,
      onRateLimitDismissed: () async {
        await ref.read(usageTrackerProvider).clearActiveRateLimits();
        ref.invalidate(activeRateLimitProvider);
      },
      onRetry: () => _generatePath(),
    );
    if (mounted) _clearLoading();
  }

  Future<void> _generatePath({
    bool fromQuotaRetry = false,
    String? generationMode,
  }) async {
    final l10n = context.l10n;
    if (await ref.read(learnerRepositoryProvider).hasActivePath()) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.learnFinishCurrentPathFirst)),
      );
      return;
    }

    final job = ref.read(generationJobServiceProvider);
    if (job.isBusy) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.generationJobInProgress)),
      );
      return;
    }

    final profile = await ref.read(learnerProfileProvider.future);
    final repo = ref.read(learnerRepositoryProvider);
    if (!LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: repo)) {
      if (!mounted) return;
      await showGoalRequiredDialog(context);
      return;
    }

    if (!await _ensureEngineReady()) return;
    if (!mounted) return;

    final providers = await ref.read(aiProvidersProvider.future);
    final active = GenerationSizing.pickActiveCloudProvider(providers);
    final isBuiltin = GenerationSizing.isBuiltinProvider(active);

    // Preflight quota BEFORE startPath so GenerationOverlay never mounts on quota fail.
    if (!fromQuotaRetry && (isBuiltin || active?.uuid == BuiltInAiConfig.uuid)) {
      try {
        await BuiltInAiQuota.instance.ensureCanGenerate();
      } on BuiltInQuotaExceededException {
        if (!mounted) return;
        _clearLoading();
        await WidgetsBinding.instance.endOfFrame;
        if (!mounted) return;
        final unlocked = await showBuiltInQuotaDialog(context);
        if (!mounted) return;
        if (unlocked) {
          await _generatePath(fromQuotaRetry: true);
        }
        return;
      }
    }

    final moduleCount = GenerationSizing.clampPathModuleCount(
      moduleCount: _pathModuleCount,
      isBuiltin: isBuiltin,
    );
    if (isBuiltin && moduleCount != _pathModuleCount && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.generationBuiltinPathClamped)),
      );
    }

    try {
      setState(() => _generatingPath = true);
      await job.startPath(moduleCount: moduleCount, generationMode: generationMode);
      if (!mounted) return;
      final latest = ref.read(generationJobServiceProvider);
      final route = latest.successRoute;
      final cancelled = latest.userCancelled;
      if (route != null && !cancelled && latest.uiAttached) {
        await _pushPath(route);
      }
    } on GenerationTimeoutException catch (_) {
      await _showError(GenerationTimeoutException(l10n.pathGenerationTimeout));
    } catch (e) {
      await _showError(e);
    } finally {
      if (mounted) {
        _clearLoading();
        setState(() {
          _pathsFuture = ref.read(learnerRepositoryProvider).activePaths();
          _completedPathsFuture =
              ref.read(learnerRepositoryProvider).completedPaths();
        });
      }
    }
  }

  Future<void> _generatePathFromContent({bool fromQuotaRetry = false}) async {
    final l10n = context.l10n;
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    final sources =
        await ref.read(knowledgeRepositoryProvider).enabledSourcesForGoal(profile.goalMode);
    if (sources.isEmpty) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.learnFromMyContentNeedLibrary)),
      );
      context.push('/library?goal=${profile.goalMode}');
      return;
    }

    final consent = AiConsentGate.instance.current;
    if (consent.generationMode != 'grounded' || !consent.sendChunksToProvider) {
      await AiConsentGate.instance.save(
        AiConsentPreferences(
          piiUploadConsent: consent.piiUploadConsent,
          sendChunksToProvider: true,
          generationMode: 'grounded',
          economyMode: consent.economyMode,
          transparencySeen: consent.transparencySeen,
        ),
      );
    }

    await _generatePath(fromQuotaRetry: fromQuotaRetry, generationMode: 'grounded');
  }

  void _cancelGeneration() {
    ref.read(generationJobServiceProvider).cancel();
  }

  void _continuePathInBackground() {
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy || job.kind != GenerationJobKind.path) return;
    job.continueInBackground();
    _clearLoading();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generationRunningInBackground)),
    );
  }

  void _onLeaveWhileGenerating() {
    if (!mounted) return;
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy || job.kind != GenerationJobKind.path) return;
    if (job.uiAttached) {
      job.continueInBackground();
    }
    _clearLoading();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generationRunningInBackground)),
    );
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

      switch (decision.action) {
        case LearningAction.encourageBreak:
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(decision.reason)));
        case LearningAction.openPathModule:
          if (decision.pathId != null) {
            final idx = decision.moduleIndex ?? 0;
            await _pushPath('/paths/${decision.pathId}?module=$idx');
          }
        case LearningAction.suggestPath:
          await _generatePath();
        case LearningAction.summarizeWeaknesses:
        case LearningAction.followUp:
          final text = await orch.summarizeWeaknesses();
          setState(() => _summary = text);
        case LearningAction.generateQuiz:
        case LearningAction.remedialQuiz:
          if (!await _ensureEngineReady()) return;
          if (!mounted) return;
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
      await _showError(e);
    } finally {
      _clearLoading();
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final layout = responsiveLayoutOf(context);
    final personalization = ref.watch(personalizationProvider);
    final decision = ref.watch(nextDecisionProvider);
    final learner = ref.watch(learnerProfileProvider).asData?.value;
    final goalMode = learner?.goalMode ?? 'learning';
    final goalLabel = personalization.asData?.value.goalContextLabel ?? '';
    final subtitle = goalLabel.isNotEmpty ? goalLabel : null;
    final dueFlashcards = ref.watch(flashcardsDueCountProvider(goalMode)).asData?.value ?? 0;
    final genJob = ref.watch(generationJobServiceProvider);
    final overlayState = watchGenerationJobOverlay(ref, GenerationJobKind.path);
    final pathJobBlocking = overlayState.showOverlay;
    final showPathOverlay = overlayState.showOverlay;
    final showPathStrip = overlayState.showStrip;

    ref.listen<int>(learningDataEpochProvider, (prev, next) {
      if (prev != next) _refresh();
    });

    ref.listen<GenerationJobService>(generationJobServiceProvider, (prev, next) {
      if (!mounted) return;
      if (prev?.uiAttached == true &&
          !next.uiAttached &&
          next.kind == GenerationJobKind.path) {
        _clearLoading();
      }
    });
    listenGenerationJobBackgroundSuccess(ref, GenerationJobKind.path, onSuccess: (route) {
      if (!mounted) return;
      _pushPath(route);
    });

    return PopScope(
      canPop: true,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop && pathJobBlocking) _onLeaveWhileGenerating();
      },
      child: Stack(
      children: [
        Positioned.fill(
          child: personalization.when(
          skipLoadingOnReload: true,
          loading: () => DashboardPageScaffold(
            title: l10n.navLearn,
            subtitle: subtitle,
            actions: [const AiStatusBadge(), dashboardHeaderSettingsAction(context)],
            embedInShell: true,
            onRefresh: _refresh,
            slivers: const [
              SliverFillRemaining(
                child: Center(
                  child: CircularProgressIndicator(color: AppTheme.seedColor),
                ),
              ),
            ],
          ),
          error: (e, _) => DashboardPageScaffold(
            title: l10n.navLearn,
            subtitle: subtitle,
            actions: [const AiStatusBadge(), dashboardHeaderSettingsAction(context)],
            embedInShell: true,
            onRefresh: _refresh,
            slivers: [
              SliverFillRemaining(child: Center(child: Text('$e'))),
            ],
          ),
          data: (state) => DashboardPageScaffold(
            title: l10n.navLearn,
            subtitle: subtitle,
            actions: [const AiStatusBadge(), dashboardHeaderSettingsAction(context)],
            embedInShell: true,
            onRefresh: _refresh,
            slivers: [
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageHorizontal),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    AdaptiveUiBanner(goalMode: goalMode),
                    SizedBox(height: layout.sectionGap * 0.5),
                    AppCard(
                      onTap: () => context.push('/library?goal=$goalMode'),
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.folder_open_rounded),
                        title: Text(l10n.libraryOpenHub),
                        subtitle: Text(l10n.librarySubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                      ),
                    ),
                    SizedBox(height: layout.sectionGap * 0.5),
                    AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.bookmarks_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(l10n.savedArticlesTitle),
                        subtitle: Text(l10n.savedArticlesSubtitle),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/saved-articles'),
                      ),
                    ),
                    SizedBox(height: layout.sectionGap * 0.5),
                    AppCard(
                      child: ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(
                          Icons.style_rounded,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                        title: Text(l10n.flashcardsTitle),
                        subtitle: Text(l10n.flashcardsDueCount(dueFlashcards)),
                        trailing: const Icon(Icons.chevron_right_rounded),
                        onTap: () => context.push('/flashcards?goal=$goalMode'),
                      ),
                    ),
                    SizedBox(height: layout.sectionGap * 0.5),
                    Text(
                      l10n.learnJourneyTitle,
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
                    ),
                    SizedBox(height: layout.sectionGap * 0.5),
                    FutureBuilder(
                      future: _pathsFuture,
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
                              DashboardSectionHeader(title: l10n.learnYourPathSection),
                              const SizedBox(height: 10),
                              AppCard(
                                onTap: () => _pushPath('/paths/${primary.uuid}?module=${primary.currentIndex}'),
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
                            ] else ...[
                              Text(l10n.pathDepthTitle, style: Theme.of(context).textTheme.titleSmall),
                              const SizedBox(height: 8),
                              SegmentedButton<int>(
                                showSelectedIcon: false,
                                segments: [
                                  ButtonSegment(
                                    value: 4,
                                    label: Text(
                                      l10n.pathDepthLight,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: 5,
                                    label: Text(
                                      l10n.pathDepthStandard,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  ButtonSegment(
                                    value: 6,
                                    label: Text(
                                      l10n.pathDepthDeep,
                                      maxLines: 1,
                                      softWrap: false,
                                      overflow: TextOverflow.ellipsis,
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                ],
                                selected: {_pathModuleCount},
                                onSelectionChanged: (v) => setState(() => _pathModuleCount = v.first),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                l10n.pathDepthLessons(_pathModuleCount),
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              if (showPathStrip) ...[
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
                                      if (genJob.successRoute != null)
                                        TextButton(
                                          onPressed: () => _pushPath(genJob.successRoute!),
                                          child: Text(l10n.generationOpenWhenReady),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              PrimaryButton(
                                label: l10n.learnGeneratePath,
                                icon: Icons.route_rounded,
                                isLoading: showPathOverlay,
                                onPressed: (_loading || pathJobBlocking) ? null : _generatePath,
                              ),
                              const SizedBox(height: 12),
                              AppCard(
                                onTap: (_loading || pathJobBlocking)
                                    ? null
                                    : _generatePathFromContent,
                                child: ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    Icons.auto_stories_rounded,
                                    color: AppTheme.seedColor.withValues(alpha: 0.9),
                                  ),
                                  title: Text(
                                    l10n.learnFromMyContentTitle,
                                    style: const TextStyle(fontWeight: FontWeight.w700),
                                  ),
                                  subtitle: Text(l10n.learnFromMyContentSubtitle),
                                  trailing: const Icon(Icons.chevron_right_rounded),
                                ),
                              ),
                            ],
                          ],
                        );
                      },
                    ),
                    SizedBox(height: layout.sectionGap),
                    decision.when(
                      skipLoadingOnReload: true,
                      data: (d) {
                        final muted = Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                            );
                        return AppCard(
                          color: AppTheme.seedColor.withValues(alpha: 0.08),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(d.reason, style: muted),
                              if (d.topic != null) ...[
                                const SizedBox(height: 6),
                                Text(l10n.learnTopicLabel(d.topic!), style: muted),
                              ],
                              const SizedBox(height: 14),
                              PrimaryButton(
                                label: l10n.learnContinueLearning,
                                icon: Icons.play_arrow_rounded,
                                isLoading: _loading && !_generatingPath,
                                onPressed: (_loading || pathJobBlocking) ? null : _runDecision,
                              ),
                            ],
                          ),
                        );
                      },
                      loading: () => AppCard(
                        child: LinearProgressIndicator(
                          valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.seedColor),
                        ),
                      ),
                      error: (e, _) => AppCard(child: Text('$e')),
                    ),
                    SizedBox(height: layout.sectionGap),
                    DashboardSectionHeader(title: l10n.learnQuickPracticeSection),
                    const SizedBox(height: 4),
                    Text(
                      l10n.learnPriorityTopics,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                    ),
                    const SizedBox(height: 10),
                    if (state.weakTopics.isEmpty)
                      AppCard(
                        child: EmptyStateGuide(
                          hintId: 'learn_no_weak_topics',
                          icon: Icons.school_rounded,
                          title: l10n.learnNoPriorityTopics,
                          body: l10n.dynamicAppBody,
                          actionLabel: l10n.learnGenerateFirstPath,
                          onAction: _generatePath,
                        ),
                      )
                    else
                      SizedBox(
                        height: 200,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: state.weakTopics.take(3).length,
                          separatorBuilder: (_, _) => const SizedBox(width: 12),
                          itemBuilder: (context, index) {
                            final topic = state.weakTopics[index];
                            return HorizontalFeatureCard(
                              height: 200,
                              width: 260,
                              variant: HorizontalFeatureCardVariant.secondary,
                              accentIndex: index,
                              title: topic,
                              subtitle: l10n.learnNeedsAttentionReason,
                              onTap: () => openQuickQuizForTopic(context, topic: topic),
                            );
                          },
                        ),
                      ),
                    SizedBox(height: layout.sectionGap),
                    DashboardSectionHeader(title: l10n.learnLearningPaths),
                    const SizedBox(height: 10),
                    FutureBuilder(
                      future: _pathsFuture,
                      builder: (context, snapshot) {
                        final paths = snapshot.data ?? [];
                        if (paths.isEmpty) {
                          return AppCard(
                            child: EmptyStateGuide(
                              hintId: 'learn_no_paths',
                              icon: Icons.route_outlined,
                              title: l10n.learnPathsEmpty,
                              body: l10n.helpCenterPaths,
                              actionLabel: l10n.learnGeneratePath,
                              onAction: _generatePath,
                            ),
                          );
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
                                  onTap: () => _pushPath('/paths/${path.uuid}'),
                                ),
                              ),
                            );
                          }).toList(),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    FutureBuilder(
                      future: _completedPathsFuture,
                      builder: (context, snapshot) {
                        final past = snapshot.data ?? [];
                        if (past.isEmpty) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            DashboardSectionHeader(title: l10n.learnPastPathsTitle),
                            const SizedBox(height: 10),
                            ...past.map((path) {
                              final steps =
                                  ref.read(learnerRepositoryProvider).pathSteps(path);
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: LearningPathTile(
                                  title: path.title,
                                  progressLabel: l10n.learnModulesProgress(
                                    path.currentIndex,
                                    steps.length,
                                  ),
                                  onTap: () => _pushPath('/paths/${path.uuid}'),
                                ),
                              );
                            }),
                          ],
                        );
                      },
                    ),
                    if (_summary != null) ...[
                      SizedBox(height: layout.sectionGap),
                      AppCard(child: Text(_summary!)),
                    ],
                    SizedBox(height: AppTheme.cardGap),
                  ]),
                ),
              ),
            ],
          ),
        ),
        ),
        GenerationOverlay(
          visible: (_loading && !_generatingPath) || showPathOverlay,
          topic: showPathOverlay || pathJobBlocking ? genJob.topic : _loadingTopic,
          forPath: _generatingPath || pathJobBlocking,
          onCancel: () {
            if (pathJobBlocking) {
              _cancelGeneration();
            }
            _clearLoading();
          },
          onContinueInBackground: pathJobBlocking ? _continuePathInBackground : null,
        ),
      ],
    ),
    );
  }
}
