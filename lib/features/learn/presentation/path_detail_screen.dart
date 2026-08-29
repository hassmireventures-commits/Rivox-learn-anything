import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/network/network_service.dart';
import '../../../core/services/generation_job_service.dart';
import '../../../core/services/module_notes_cache.dart';
import '../../../core/services/study_session_tracker.dart';
import '../../../core/services/youtube_reject_store.dart';
import '../../../core/constants/official_learning_domains.dart';
import '../../../core/constants/quiz_kind.dart';
import '../../../core/layout/responsive_layout.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/learning_path.dart';
import '../../../data/local/repositories/learner_repository.dart';
import '../../../data/remote/ai/models/learning_pattern_context.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/in_app_youtube_player.dart';
import '../../../shared/widgets/primary_button.dart';
import 'resource_webview_args.dart';

class PathDetailScreen extends ConsumerStatefulWidget {
  const PathDetailScreen({super.key, required this.pathId});

  final String pathId;

  @override
  ConsumerState<PathDetailScreen> createState() => _PathDetailScreenState();
}

class _PathDetailScreenState extends ConsumerState<PathDetailScreen> {
  final Set<int> _expanded = {};
  final Map<int, bool> _videoErrors = {};
  final Map<int, ModuleNotesCacheEntry> _cachedNotes = {};
  int? _activeVideoIndex;
  bool _summarizing = false;
  int? _summarizingIndex;
  late Future<LearningPath?> _pathFuture;
  Future<List<PathStepData>>? _stepsFuture;

  @override
  void initState() {
    super.initState();
    _pathFuture = ref.read(learnerRepositoryProvider).getPath(widget.pathId);
    StudySessionTracker.instance.beginStudy();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final module = GoRouterState.of(context).uri.queryParameters['module'];
      final index = int.tryParse(module ?? '');
      if (index != null && mounted) {
        setState(() => _expanded.add(index));
      }
    });
  }

  void _refreshPath() {
    setState(() {
      _pathFuture = ref.read(learnerRepositoryProvider).getPath(widget.pathId);
      _stepsFuture = null;
    });
  }

  @override
  void dispose() {
    _activeVideoIndex = null;
    StudySessionTracker.instance.endStudy();
    super.dispose();
  }

  Future<void> _practiceModule(PathStepData step, int index, int total) async {
    final job = ref.read(generationJobServiceProvider);
    if (job.isBusy) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.generationJobInProgress)),
      );
      return;
    }

    try {
      await NetworkService.instance.ensureConnected();
      final weak = await ref.read(learnerRepositoryProvider).weakTopics(limit: 3);
      final node = await ref.read(learnerRepositoryProvider).allTopics();
      final match = node.where((n) => n.topic.toLowerCase() == step.title.toLowerCase()).firstOrNull;
      final accuracy = match != null && match.attempts > 0 ? match.correctCount / match.attempts : null;

      await job.startQuiz(
        topic: step.title,
        questionCount: 20,
        difficulty: step.difficulty,
        quizKind: QuizKind.module,
        pathId: widget.pathId,
        moduleIndex: index,
        learningPattern: LearningPatternContext(
          moduleTitle: step.title,
          pathPosition: index,
          pathLength: total,
          priorAccuracy: accuracy,
          weakSubtopics: weak.map((e) => e.topic).toList(),
        ),
      );
      if (!mounted) return;
      final latest = ref.read(generationJobServiceProvider);
      final route = latest.successRoute;
      if (route != null && !latest.userCancelled && latest.uiAttached) {
        context.push(route).then((_) {
          if (mounted) _refreshPath();
        });
      }
    } catch (e) {
      if (mounted) {
        await WidgetsBinding.instance.endOfFrame;
        if (mounted) await showAppErrorDialog(context, e);
      }
    }
  }

  void _cancelGeneration() {
    ref.read(generationJobServiceProvider).cancel();
  }

  void _continueInBackground() {
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy || job.kind != GenerationJobKind.quiz) return;
    job.continueInBackground();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generationRunningInBackground)),
    );
    if (context.canPop()) {
      context.pop();
    }
  }

  void _markVideoError(int index, {String? videoId}) {
    if (_videoErrors[index] == true) return;
    if (videoId != null && videoId.isNotEmpty) {
      YoutubeRejectStore.reject(videoId, reason: 'playback_error');
    }
    setState(() {
      _videoErrors[index] = true;
      if (_activeVideoIndex == index) {
        _activeVideoIndex = null;
      }
    });
  }

  Future<void> _summarizeModule(PathStepData step, int index, {bool regenerate = false}) async {
    final l10n = context.l10n;
    if (!regenerate) {
      final mem = _cachedNotes[index];
      if (mem != null && mem.notes.isNotEmpty) {
        await _showNotesSheet(mem, step: step, index: index);
        return;
      }
      final disk = await ModuleNotesCache.load(widget.pathId, index);
      if (disk != null && mounted) {
        setState(() => _cachedNotes[index] = disk);
        await _showNotesSheet(disk, step: step, index: index);
        return;
      }
    }
    if (_summarizing) return;
    setState(() {
      _summarizing = true;
      _summarizingIndex = index;
    });
    try {
      await NetworkService.instance.ensureConnected();
      final result = await ref.read(learningOrchestratorProvider).summarizeModule(
            moduleTitle: step.title,
            moduleSummary: step.summary,
            youtubeVideoId: step.youtubeVideoId,
            resources: step.resources,
          );
      if (!mounted) return;
      final entry = ModuleNotesCacheEntry(
        notes: result.notes,
        usedTranscript: result.usedTranscript,
      );
      await ModuleNotesCache.save(widget.pathId, index, entry);
      setState(() => _cachedNotes[index] = entry);
      await _showNotesSheet(entry, step: step, index: index);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.moduleSummaryFailed)),
      );
    } finally {
      if (mounted) {
        setState(() {
          _summarizing = false;
          _summarizingIndex = null;
        });
      }
    }
  }

  Future<void> _showNotesSheet(
    ModuleNotesCacheEntry entry, {
    required PathStepData step,
    required int index,
  }) async {
    final l10n = context.l10n;
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) {
        final sheetTheme = Theme.of(ctx);
        return SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
              left: 20,
              right: 20,
              bottom: MediaQuery.viewInsetsOf(ctx).bottom + 20,
              top: 8,
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.sizeOf(ctx).height * 0.75,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    l10n.moduleSummaryTitle,
                    style: sheetTheme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Expanded(
                    child: Markdown(
                      data: entry.notes,
                      selectable: true,
                      styleSheet: MarkdownStyleSheet.fromTheme(sheetTheme).copyWith(
                        h1: sheetTheme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: AppTheme.seedColor,
                        ),
                        h2: sheetTheme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                        h3: sheetTheme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                        p: sheetTheme.textTheme.bodyMedium,
                        code: sheetTheme.textTheme.bodySmall?.copyWith(
                          fontFamily: 'monospace',
                          backgroundColor: sheetTheme.colorScheme.surfaceContainerHighest,
                        ),
                        codeblockDecoration: BoxDecoration(
                          color: sheetTheme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        blockquoteDecoration: BoxDecoration(
                          border: Border(
                            left: BorderSide(color: AppTheme.seedColor, width: 3),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    entry.usedTranscript
                        ? l10n.moduleNotesFromTranscriptFooter
                        : l10n.moduleNotesNoTranscriptFooter,
                    style: sheetTheme.textTheme.bodySmall?.copyWith(
                      color: sheetTheme.colorScheme.onSurfaceVariant,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(ctx);
                        _summarizeModule(step, index, regenerate: true);
                      },
                      icon: const Icon(Icons.refresh_rounded, size: 20),
                      label: Text(l10n.moduleNotesRegenerate),
                    ),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: Text(l10n.commonDismiss),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final layout = responsiveLayoutOf(context);
    final genJob = ref.watch(generationJobServiceProvider);
    final quizJobRunning =
        genJob.isRunning && genJob.kind == GenerationJobKind.quiz;
    final showOverlay = quizJobRunning && genJob.uiAttached;
    final showStrip = quizJobRunning && !genJob.uiAttached;

    ref.listen<int>(learningDataEpochProvider, (prev, next) {
      if (prev != next) _refreshPath();
    });

    ref.listen<GenerationJobService>(generationJobServiceProvider, (prev, next) {
      if (!mounted) return;
      if (prev?.isRunning == true &&
          !next.isRunning &&
          next.kind == GenerationJobKind.quiz &&
          !next.uiAttached &&
          !next.userCancelled &&
          next.successRoute != null) {
        context.push(next.successRoute!).then((_) {
          if (mounted) _refreshPath();
        });
      }
    });

    return FutureBuilder(
      future: _pathFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return Scaffold(
            body: Center(
              child: CircularProgressIndicator(
                color: AppTheme.seedColor,
              ),
            ),
          );
        }
        final path = snapshot.data;
        if (path == null) {
          return Scaffold(
            appBar: AppBar(),
            body: Center(child: Text(l10n.pathNotFound)),
          );
        }
        final repo = ref.read(learnerRepositoryProvider);
        final stepsFuture = _stepsFuture ??= repo.pathStepsAsync(path);
        return FutureBuilder(
          future: stepsFuture,
          builder: (context, stepsSnapshot) {
            if (stepsSnapshot.connectionState != ConnectionState.done &&
                stepsSnapshot.data == null) {
              return Scaffold(
                appBar: AppBar(title: Text(path.title)),
                body: const Center(
                  child: CircularProgressIndicator(color: AppTheme.seedColor),
                ),
              );
            }
            final steps = stepsSnapshot.data ?? repo.pathSteps(path);

            return Stack(
              children: [
                Scaffold(
                  appBar: AppBar(title: Text(path.title)),
                  body: ListView(
                    physics: (showOverlay || _activeVideoIndex != null)
                        ? const NeverScrollableScrollPhysics()
                        : const AlwaysScrollableScrollPhysics(),
                    padding: layout.pagePadding,
                    children: [
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
                              if (genJob.successRoute != null)
                                TextButton(
                                  onPressed: () => context
                                      .push(genJob.successRoute!)
                                      .then((_) {
                                    if (mounted) _refreshPath();
                                  }),
                                  child: Text(l10n.generationOpenWhenReady),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),
                      ],
                      AppCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              l10n.pathProgressHeader(
                                path.currentIndex,
                                steps.length,
                                '',
                              ),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.w700,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            LinearProgressIndicator(
                              value: steps.isEmpty ? 0 : path.currentIndex / steps.length,
                              backgroundColor:
                                  Theme.of(context).colorScheme.surfaceContainerHighest,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppTheme.seedColor),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              l10n.learnModulesProgress(path.currentIndex, steps.length),
                              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: layout.sectionGap),
                      if (path.status == 'completed') ...[
                        AppCard(
                          color: AppTheme.seedColor.withValues(alpha: 0.08),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                l10n.pathCompletedGenerateAnotherTitle,
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                l10n.pathCompletedGenerateAnotherBody,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                                    ),
                              ),
                              const SizedBox(height: 14),
                              PrimaryButton(
                                label: l10n.pathCompletedGenerateAnotherCta,
                                icon: Icons.route_rounded,
                                onPressed: () {
                                  context.pop();
                                  context.go('/learn?generatePath=1');
                                },
                              ),
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: () => context.pop(),
                                child: Text(l10n.pathCompletedDismiss),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: layout.sectionGap),
                      ],
                      ...steps.asMap().entries.map((entry) {
                        final index = entry.key;
                        final step = entry.value;
                        final unlocked = repo.isModuleUnlocked(path, index);
                        final done = index < path.currentIndex;
                        final current = index == path.currentIndex;
                        final expanded = _expanded.contains(index);
                        final status = L10nHelpers.pathModuleStatus(l10n, done: done, current: current);

                        return Padding(
                          padding: EdgeInsets.only(bottom: layout.sectionGap * 0.75),
                          child: AppCard(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                ListTile(
                                  contentPadding: EdgeInsets.zero,
                                  leading: Icon(
                                    !unlocked
                                        ? Icons.lock_rounded
                                        : done
                                            ? Icons.check_circle_rounded
                                            : current
                                                ? Icons.play_circle_fill_rounded
                                                : Icons.circle_outlined,
                                  ),
                                  title: Text(step.title, style: const TextStyle(fontWeight: FontWeight.w700)),
                                  subtitle: Text(
                                    unlocked
                                        ? l10n.pathModuleSubtitle(
                                            L10nHelpers.difficultyLabel(l10n, step.difficulty),
                                            step.estimatedMinutes,
                                            status,
                                          )
                                        : l10n.pathModuleLocked,
                                  ),
                                  trailing: IconButton(
                                    icon: Icon(expanded ? Icons.expand_less : Icons.expand_more),
                                    onPressed: () {
                                      if (!unlocked) {
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          SnackBar(content: Text(l10n.pathModuleLocked)),
                                        );
                                        return;
                                      }
                                      setState(() {
                                        if (expanded) {
                                          _expanded.remove(index);
                                          if (_activeVideoIndex == index) {
                                            _activeVideoIndex = null;
                                          }
                                        } else {
                                          _expanded.add(index);
                                        }
                                      });
                                    },
                                  ),
                                ),
                                if (step.summary.isNotEmpty) Text(step.summary),
                                if (expanded && unlocked) ...[
                                  const SizedBox(height: 12),
                                  InAppYoutubePlayer(
                                    videoId: step.youtubeVideoId,
                                    title: step.title,
                                    failed: _videoErrors[index] ?? false,
                                    isActive: _activeVideoIndex == index,
                                    onActivate: () => setState(() => _activeVideoIndex = index),
                                    onDeactivate: () => setState(() {
                                      if (_activeVideoIndex == index) {
                                        _activeVideoIndex = null;
                                      }
                                    }),
                                    onError: () => _markVideoError(
                                      index,
                                      videoId: step.youtubeVideoId,
                                    ),
                                  ),
                                  ...step.resources.map(
                                    (r) => ListTile(
                                      contentPadding: EdgeInsets.zero,
                                      leading: Icon(r.type == 'video' ? Icons.play_circle : Icons.menu_book_rounded),
                                      title: Text(r.title),
                                      subtitle: Text(r.domain),
                                      onTap: () {
                                        final uri = Uri.parse(r.url);
                                        if (OfficialLearningDomains.isAllowedDoc(uri.host)) {
                                          openResourceInApp(
                                            context,
                                            url: r.url,
                                            title: r.title,
                                          );
                                        } else {
                                          launchUrl(uri, mode: LaunchMode.externalApplication);
                                        }
                                      },
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: (_summarizing && _summarizingIndex == index)
                                          ? null
                                          : () => _summarizeModule(step, index),
                                      icon: (_summarizing && _summarizingIndex == index)
                                          ? const SizedBox(
                                              width: 18,
                                              height: 18,
                                              child: CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.notes_rounded, size: 20),
                                      label: Text(
                                        (_summarizing && _summarizingIndex == index)
                                            ? l10n.moduleSummaryLoading
                                            : l10n.moduleSummarize,
                                      ),
                                    ),
                                  ),
                                ],
                                if (current && path.status == 'active') ...[
                                  const SizedBox(height: 10),
                                  SizedBox(
                                    width: double.infinity,
                                    child: OutlinedButton.icon(
                                      onPressed: quizJobRunning || genJob.isBusy
                                          ? null
                                          : () => _practiceModule(step, index, steps.length),
                                      icon: const Icon(Icons.quiz_rounded, size: 20),
                                      label: Text(l10n.pathModuleQuiz),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
                GenerationOverlay(
                  visible: showOverlay,
                  topic: genJob.topic ??
                      (steps.isNotEmpty && path.currentIndex < steps.length
                          ? steps[path.currentIndex].title
                          : null),
                  onCancel: _cancelGeneration,
                  onContinueInBackground: _continueInBackground,
                ),
              ],
            );
          },
        );
      },
    );
  }
}
