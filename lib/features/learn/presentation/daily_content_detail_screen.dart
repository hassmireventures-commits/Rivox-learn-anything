import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/services/daily_content_scheduler.dart';
import '../../../core/services/daily_content_service.dart';
import '../../../core/services/generation_job_service.dart';
import '../../../core/services/learner_goal_guard.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';
import '../../../data/remote/ai/resource_link_validator.dart';
import '../../../core/error/app_exception.dart';
import '../../../shared/widgets/api_limit_dialog.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_native_ad_slot.dart';
import '../../../shared/widgets/generation_overlay.dart';
import '../../../shared/widgets/goal_required_dialog.dart';
import '../../../shared/widgets/in_app_youtube_player.dart';
import '../../../shared/widgets/primary_button.dart';
import 'resource_webview_args.dart';

/// Detail screen for today's validated learning pack (article + video).
class DailyContentDetailScreen extends ConsumerStatefulWidget {
  const DailyContentDetailScreen({
    super.key,
    this.initialPack,
    this.initialItem,
  });

  final DailyContentPack? initialPack;
  final DailyContentItem? initialItem;

  @override
  ConsumerState<DailyContentDetailScreen> createState() =>
      _DailyContentDetailScreenState();
}

class _DailyContentDetailScreenState extends ConsumerState<DailyContentDetailScreen> {
  DailyContentPack? _pack;
  bool _loading = true;
  bool _videoFailed = false;
  bool _videoActive = false;
  bool _videoSearchOnly = false;
  bool _fromSnapshot = false;

  @override
  void initState() {
    super.initState();
    final pack = widget.initialPack ??
        (widget.initialItem != null
            ? DailyContentPack(
                dateKey: widget.initialItem!.dateKey,
                topic: widget.initialItem!.topic,
                article: widget.initialItem!.type == 'article'
                    ? widget.initialItem
                    : null,
                video: widget.initialItem!.type == 'video'
                    ? widget.initialItem
                    : null,
              )
            : null);
    if (pack != null && pack.items.isNotEmpty) {
      _fromSnapshot = true;
      _pack = pack;
      _loading = false;
      unawaited(_markPackOpened());
      unawaited(_prepareVideoDisplay(pack));
    } else {
      _load();
    }
  }

  Future<void> _prepareVideoDisplay(DailyContentPack pack) async {
    final video = pack.video;
    if (video == null) return;
    final topic = pack.topic.isNotEmpty ? pack.topic : video.title;
    final id = video.youtubeVideoId ??
        ResourceLinkValidator.extractYouTubeId(video.url);
    if (id == null || id.isEmpty) {
      if (mounted) setState(() => _videoSearchOnly = true);
      return;
    }
    final accepted = await ResourceLinkValidator.acceptYouTubeForTopic(id, topic);
    if (!mounted) return;
    if (accepted == null) {
      setState(() => _videoSearchOnly = true);
    }
  }

  Future<void> _markPackOpened() async {
    await ref.read(dailyContentSchedulerProvider).markOpenedToday();
  }

  Future<void> _load({bool forceGenerate = false}) async {
    if (_fromSnapshot && !forceGenerate) return;
    setState(() => _loading = true);
    try {
      final service = ref.read(dailyContentServiceProvider);
      var pack = await service.findTodaysPack();
      if (pack == null && !forceGenerate) {
        final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
        final repo = ref.read(learnerRepositoryProvider);
        if (LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: repo)) {
          final job = ref.read(generationJobServiceProvider);
          if (!job.isBusy) {
            await _generatePack();
            return;
          }
        }
        if (!mounted) return;
        setState(() {
          _pack = null;
          _loading = false;
        });
        return;
      }
      if (pack == null || forceGenerate) {
        await _generatePack();
        return;
      }
      if (!mounted) return;
      setState(() {
        _pack = pack;
        _loading = false;
        _videoFailed = false;
        _videoActive = false;
        _videoSearchOnly = false;
      });
      unawaited(_markPackOpened());
      if (pack != null) unawaited(_prepareVideoDisplay(pack));
    } catch (_) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  Future<void> _generatePack() async {
    final l10n = context.l10n;
    final profile = await ref.read(learnerRepositoryProvider).getOrCreateProfile();
    final repo = ref.read(learnerRepositoryProvider);
    if (!LearnerGoalGuard.hasUsableGoal(profile, learnerRepository: repo)) {
      if (!mounted) return;
      setState(() => _loading = false);
      await showGoalRequiredDialog(context);
      return;
    }

    final job = ref.read(generationJobServiceProvider);
    if (job.isBusy) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.generationJobInProgress)),
      );
      return;
    }

    // Daily pack uses skipQuota on the LLM call; do not block on Built-in quota here.

    _fromSnapshot = false;
    setState(() => _loading = false);

    try {
      await job.startDailyContent(
        generate: () async {
          // Call service directly — avoid scheduler `_running` race with
          // background trySchedule(force) kicked off from Save Goal.
          await ref.read(dailyContentSchedulerProvider).resetAttemptState();
          final pack =
              await ref.read(dailyContentServiceProvider).ensureTodaysContent();
          if (pack == null) {
            throw const ProviderUnavailableException(
              'Could not find a valid article and video. Check your goals and AI connection, then try again.',
            );
          }
          return pack;
        },
      );
    } catch (e) {
      if (!mounted) return;
      await ref.read(dailyContentSchedulerProvider).resetAttemptState();
      final jobNow = ref.read(generationJobServiceProvider);
      if (!jobNow.isBusy) jobNow.clearTerminalState();
      await showAppErrorDialog(context, e, onRetry: () => _generatePack());
    }
  }

  void _continueInBackground() {
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy || job.kind != GenerationJobKind.dailyContent) return;
    job.continueInBackground();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(context.l10n.generationRunningInBackground)),
    );
    if (context.canPop()) {
      context.pop();
    }
  }

  void _cancelGeneration() {
    final job = ref.read(generationJobServiceProvider);
    if (!job.isBusy || job.kind != GenerationJobKind.dailyContent) return;
    job.cancel();
  }

  Future<void> _openArticleInApp(DailyContentItem item) async {
    if (!mounted) return;
    openResourceInApp(
      context,
      url: item.url,
      title: item.title,
      topic: item.topic,
    );
  }

  Future<void> _toggleArticleBookmark(DailyContentItem item) async {
    final store = ref.read(articleBookmarkStoreProvider);
    final wasSaved = store.isBookmarked(item.url);
    await store.toggle(url: item.url, title: item.title, topic: item.topic);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          wasSaved
              ? context.l10n.articleBookmarkRemoved
              : context.l10n.articleBookmarkSaved,
        ),
      ),
    );
  }

  Future<void> _openExternally(DailyContentItem item) async {
    final uri = Uri.tryParse(item.url);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final job = ref.watch(generationJobServiceProvider);
    final generating =
        job.isRunning && job.kind == GenerationJobKind.dailyContent && job.uiAttached;
    final showStrip =
        job.isBusy && job.kind == GenerationJobKind.dailyContent && !job.uiAttached;

    ref.listen<GenerationJobService>(generationJobServiceProvider, (prev, next) {
      if (next.kind != GenerationJobKind.dailyContent) return;
      if (next.successRoute != null &&
          (prev?.successRoute == null || prev?.successRoute != next.successRoute)) {
        ref.read(dailyContentServiceProvider).findTodaysPack().then((pack) {
          if (!mounted) return;
          setState(() {
            _pack = pack;
            _loading = false;
            _videoFailed = false;
            _videoActive = false;
            _videoSearchOnly = false;
          });
          unawaited(_markPackOpened());
          if (pack != null) unawaited(_prepareVideoDisplay(pack));
          next.clearTerminalState();
        });
      }
      if (next.errorMessage != null &&
          prev?.errorMessage == null &&
          next.uiAttached &&
          !next.userCancelled) {
        final msg = next.errorMessage!;
        next.clearTerminalState();
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;
          showAppErrorDialog(
            context,
            ProviderUnavailableException(msg),
            onRetry: () => _generatePack(),
          );
        });
      }
    });

    ref.listen<int>(learningDataEpochProvider, (prev, next) {
      if (prev != next && !_fromSnapshot) {
        _load();
      }
    });

    final pack = _pack;
    final article = pack?.article;
    final video = pack?.video;

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.dailyContentDetailTitle),
      ),
      body: Stack(
        children: [
          _loading
              ? const Center(child: CircularProgressIndicator())
              : pack == null || pack.items.isEmpty
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _EmptyState(
                          generating: generating,
                          onRetry: () => _generatePack(),
                        ),
                        const ScrollableNativeAdSlot(slotId: 'daily_content'),
                      ],
                    )
                  : ListView(
                      padding: const EdgeInsets.all(16),
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
                                    style: theme.textTheme.bodyMedium,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppTheme.cardGap),
                        ],
                        if (pack.topic.isNotEmpty)
                          Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              pack.topic,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        if (article != null) ...[
                          _ResourceHeader(
                            chip: l10n.dailyContentTypeArticle,
                            title: article.title,
                            summary: article.summary,
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: FilledButton.icon(
                                  onPressed: () => _openArticleInApp(article),
                                  icon: const Icon(Icons.menu_book_rounded),
                                  label: Text(l10n.dailyContentOpenArticle),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _openExternally(article),
                                  icon: const Icon(Icons.open_in_new_rounded),
                                  label: Text(l10n.dailyContentOpenExternally),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Consumer(
                                builder: (context, ref, _) {
                                  final saved = ref
                                      .watch(articleBookmarkStoreProvider)
                                      .isBookmarked(article.url);
                                  return IconButton.filledTonal(
                                    tooltip: saved
                                        ? l10n.articleBookmarkRemove
                                        : l10n.articleBookmarkSave,
                                    onPressed: () => _toggleArticleBookmark(article),
                                    icon: Icon(
                                      saved
                                          ? Icons.bookmark_rounded
                                          : Icons.bookmark_border_rounded,
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: AppTheme.cardGap),
                        ],
                        if (video != null) ...[
                          _ResourceHeader(
                            chip: l10n.dailyContentTypeVideo,
                            title: video.title,
                            summary: _videoSubtitleLabel(l10n, pack),
                            summaryStyle: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 12),
                          InAppYoutubePlayer(
                            videoId: _videoSearchOnly ? null : _validatedVideoId(video),
                            title: pack.topic.isNotEmpty ? pack.topic : video.title,
                            failed: _videoFailed,
                            isActive: _videoActive,
                            onActivate: () => setState(() => _videoActive = true),
                            onDeactivate: () => setState(() => _videoActive = false),
                            onError: () => setState(() {
                              _videoFailed = true;
                              _videoActive = false;
                              _videoSearchOnly = true;
                            }),
                          ),
                          if (!_videoSearchOnly && !_videoFailed) ...[
                            const SizedBox(height: 8),
                            OutlinedButton.icon(
                              onPressed: () => _openExternally(video),
                              icon: const Icon(Icons.open_in_new_rounded),
                              label: Text(l10n.dailyContentOpenExternally),
                            ),
                          ],
                        ],
                        const ScrollableNativeAdSlot(slotId: 'daily_content'),
                      ],
                    ),
          GenerationOverlay(
            visible: generating,
            topic: l10n.dailyContentDetailTitle,
            onCancel: _cancelGeneration,
            onContinueInBackground: _continueInBackground,
          ),
        ],
      ),
    );
  }

  String? _validatedVideoId(DailyContentItem video) {
    final id = video.youtubeVideoId ??
        ResourceLinkValidator.extractYouTubeId(video.url);
    return id;
  }

  String _videoSubtitleLabel(AppLocalizations l10n, DailyContentPack pack) {
    var label = pack.topic.trim();
    if (label.isEmpty) {
      final profile = ref.read(learnerProfileProvider).asData?.value;
      if (profile != null) {
        final goals = ref.read(learnerRepositoryProvider).goalsOf(profile);
        if (goals.isNotEmpty) label = goals.first.trim();
      }
    }
    if (label.isEmpty) return l10n.dailyContentVideoSubtitleForGoal;
    return l10n.dailyContentVideoSubtitle(label);
  }
}

class _ResourceHeader extends StatelessWidget {
  const _ResourceHeader({
    required this.chip,
    required this.title,
    required this.summary,
    this.summaryStyle,
  });

  final String chip;
  final String title;
  final String summary;
  final TextStyle? summaryStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Chip(
            label: Text(chip),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(height: 12),
          Text(
            title,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          if (summary.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              summary,
              style: summaryStyle ?? theme.textTheme.bodyLarge,
            ),
          ],
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.generating, required this.onRetry});

  final bool generating;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.menu_book_outlined,
              size: 48,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              generating ? l10n.dailyContentGenerating : l10n.dailyContentEmpty,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            if (generating)
              const CircularProgressIndicator()
            else
              PrimaryButton(
                label: l10n.dailyContentGenerate,
                icon: Icons.auto_awesome_rounded,
                onPressed: onRetry,
              ),
          ],
        ),
      ),
    );
  }
}
