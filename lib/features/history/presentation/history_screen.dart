import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/quiz_kind.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/locale/l10n_helpers.dart';
import '../../../core/providers/app_providers.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/services/notification_history_store.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/quiz_session.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/bottom_native_ad_slot.dart';
import '../../../shared/widgets/dashboard/dashboard_page_scaffold.dart';

enum _HistorySegment { quizzes, notifications }

class HistoryScreen extends ConsumerStatefulWidget {
  const HistoryScreen({super.key});

  @override
  ConsumerState<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends ConsumerState<HistoryScreen> {
  static const _pageSize = 20;

  final _searchController = TextEditingController();
  Timer? _debounce;
  String _search = '';
  String? _difficulty;
  String? _quizKind;
  List<QuizSession> _items = [];
  List<NotificationHistoryItem> _notifications = [];
  int _total = 0;
  bool _loading = true;
  bool _loadingMore = false;
  bool _hasMore = true;
  _HistorySegment _segment = _HistorySegment.quizzes;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final requested = GoRouterState.of(context).uri.queryParameters['segment'];
    if (requested == 'quizzes' && _segment != _HistorySegment.quizzes) {
      _segment = _HistorySegment.quizzes;
      _load(reset: true);
    } else if ((requested == 'daily' || requested == 'notifications') &&
        _segment != _HistorySegment.notifications) {
      _segment = _HistorySegment.notifications;
      _load(reset: true);
    }
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load({required bool reset}) async {
    if (_segment == _HistorySegment.notifications) {
      setState(() => _loading = true);
      final items = await NotificationHistoryStore.instance.list();
      if (!mounted) return;
      setState(() {
        _notifications = items;
        _loading = false;
      });
      return;
    }

    if (reset) {
      setState(() {
        _loading = true;
        _hasMore = true;
      });
    } else {
      if (_loadingMore || !_hasMore) return;
      setState(() => _loadingMore = true);
    }

    final repo = ref.read(quizRepositoryProvider);
    final offset = reset ? 0 : _items.length;
    final results = await Future.wait([
      repo.getHistory(
        search: _search,
        difficulty: _difficulty,
        quizKind: _quizKind,
        offset: offset,
        limit: _pageSize,
      ),
      if (reset)
        repo.countHistory(
          search: _search,
          difficulty: _difficulty,
          quizKind: _quizKind,
        ),
    ]);
    if (!mounted) return;

    final page = results[0] as List<QuizSession>;
    final total = reset ? results[1] as int : _total;
    setState(() {
      _total = total;
      _items = reset ? page : [..._items, ...page];
      _hasMore = _items.length < _total;
      _loading = false;
      _loadingMore = false;
    });
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      _search = value;
      _load(reset: true);
    });
  }

  bool _onScroll(ScrollNotification notification) {
    if (_segment != _HistorySegment.quizzes) return false;
    if (notification.metrics.pixels >= notification.metrics.maxScrollExtent - 240) {
      _load(reset: false);
    }
    return false;
  }

  Future<void> _delete(QuizSession session) async {
    await ref.read(quizRepositoryProvider).deleteQuiz(session.uuid);
    ref.invalidate(dashboardStatsProvider);
    await _load(reset: true);
  }

  Future<void> _clearAll() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        final dialogL10n = context.l10n;
        return AlertDialog(
          title: Text(dialogL10n.historyClearTitle),
          content: Text(dialogL10n.historyClearMessage),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: Text(dialogL10n.commonCancel)),
            FilledButton(onPressed: () => Navigator.pop(context, true), child: Text(dialogL10n.commonClear)),
          ],
        );
      },
    );
    if (confirmed != true) return;
    if (_segment == _HistorySegment.notifications) {
      await NotificationHistoryStore.instance.clear();
      await _load(reset: true);
      return;
    }
    await ref.read(quizRepositoryProvider).clearAll();
    await ref.read(statsRepositoryProvider).clearAll();
    ref.invalidate(dashboardStatsProvider);
    ref.invalidate(todaysDailyQuizOfferProvider);
    ref.invalidate(todaysDailyQuizProvider);
    await _load(reset: true);
  }

  Future<void> _openNotification(NotificationHistoryItem item) async {
    await NotificationHistoryStore.instance.markRead(item.id);
    if (!mounted) return;

    // Daily study only: open validated pack snapshot in-app, never quiz play.
    final pack = item.contentPackSnapshot;
    if (pack != null && pack.items.isNotEmpty) {
      context.push('/daily-content', extra: pack);
      await _load(reset: true);
      return;
    }
    if (item.kind == 'content' ||
        item.payload == '/daily-content' ||
        item.payload.trim().startsWith('{')) {
      context.push('/daily-content');
      await _load(reset: true);
      return;
    }
    // Legacy non-content rows should already be purged; ignore safely.
    await _load(reset: true);
  }

  Color _kindColor(String quizKind) => switch (quizKind) {
        QuizKind.mock => const Color(0xFFE67E22),
        QuizKind.interview => const Color(0xFF27AE60),
        QuizKind.module => AppTheme.accentBlue,
        QuizKind.multiplayer => AppTheme.accentPink,
        _ => AppTheme.seedColor,
      };

  Color get _studyColor => AppTheme.accentBlue;

  IconData get _studyIcon => Icons.menu_book_outlined;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    ref.listen<int>(learningDataEpochProvider, (prev, next) {
      if (prev != next) _load(reset: true);
    });
    final isQuizzes = _segment == _HistorySegment.quizzes;
    final canClear = isQuizzes ? _items.isNotEmpty : _notifications.isNotEmpty;

    return Column(
      children: [
        Expanded(
          child: Stack(
            children: [
              NotificationListener<ScrollNotification>(
                onNotification: _onScroll,
                child: DashboardPageScaffold(
                  title: l10n.navHistory,
                  subtitle: _loading
                      ? null
                      : isQuizzes
                          ? l10n.historySessionCount(_total)
                          : null,
                  embedInShell: true,
                  actions: [
                    dashboardHeaderSettingsAction(context),
                    IconButton(
                      onPressed: canClear ? _clearAll : null,
                      icon: Icon(
                        Icons.delete_sweep_rounded,
                        color: canClear ? Colors.white : Colors.white54,
                      ),
                      tooltip: l10n.historyClearAllTooltip,
                    ),
                  ],
                  onRefresh: () async {
                    bumpAdRefresh(ref);
                    await _load(reset: true);
                  },
                  slivers: [
                    SliverToBoxAdapter(
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(
                          AppTheme.pageHorizontal,
                          AppTheme.cardGap,
                          AppTheme.pageHorizontal,
                          8,
                        ),
                        child: SegmentedButton<_HistorySegment>(
                          showSelectedIcon: false,
                          segments: [
                            ButtonSegment(
                              value: _HistorySegment.quizzes,
                              label: Text(
                                l10n.historySegmentQuizzes,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            ButtonSegment(
                              value: _HistorySegment.notifications,
                              label: Text(
                                l10n.historySegmentNotifications,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                          selected: {_segment},
                          onSelectionChanged: (next) {
                            setState(() => _segment = next.first);
                            _load(reset: true);
                          },
                        ),
                      ),
                    ),
                    if (isQuizzes) ..._quizSlivers(l10n) else ..._notificationSlivers(l10n),
                    const SliverToBoxAdapter(
                      child: ScrollableNativeAdSlot(slotId: 'history'),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 24)),
                  ],
                ),
              ),
              if (isQuizzes && !_loading && _total > 0)
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 12,
                  child: Center(
                    child: _HistoryCountPill(
                      loaded: _items.length,
                      total: _total,
                      loading: _loadingMore,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  List<Widget> _quizSlivers(AppLocalizations l10n) {
    return [
      SliverToBoxAdapter(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pageHorizontal,
            0,
            AppTheme.pageHorizontal,
            8,
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: l10n.historySearchHint,
              prefixIcon: const Icon(Icons.search_rounded),
            ),
            onChanged: _onSearchChanged,
          ),
        ),
      ),
      SliverToBoxAdapter(
        child: Column(
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageHorizontal),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(l10n.historyFilterAll),
                    selected: _quizKind == null,
                    onSelected: (_) {
                      setState(() => _quizKind = null);
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(l10n.quizKindQuick),
                    selected: _quizKind == QuizKind.quick,
                    onSelected: (_) {
                      setState(() => _quizKind = QuizKind.quick);
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(l10n.quizKindModule),
                    selected: _quizKind == QuizKind.module,
                    onSelected: (_) {
                      setState(() => _quizKind = QuizKind.module);
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(l10n.quizKindMock),
                    selected: _quizKind == QuizKind.mock,
                    onSelected: (_) {
                      setState(() => _quizKind = QuizKind.mock);
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    label: Text(l10n.quizKindInterview),
                    selected: _quizKind == QuizKind.interview,
                    onSelected: (_) {
                      setState(() => _quizKind = QuizKind.interview);
                      _load(reset: true);
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.pageHorizontal),
              child: Row(
                children: [
                  FilterChip(
                    label: Text(l10n.difficultyAll),
                    selected: _difficulty == null,
                    onSelected: (_) {
                      setState(() => _difficulty = null);
                      _load(reset: true);
                    },
                  ),
                  const SizedBox(width: 8),
                  ...['easy', 'medium', 'hard', 'expert'].map(
                    (d) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(L10nHelpers.difficultyLabel(l10n, d)),
                        selected: _difficulty == d,
                        onSelected: (_) {
                          setState(() => _difficulty = d);
                          _load(reset: true);
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
      if (_loading)
        const SliverFillRemaining(
          child: Center(child: CircularProgressIndicator()),
        )
      else if (_items.isEmpty)
        SliverFillRemaining(
          child: _HistoryEmptyState(
            quizKind: _quizKind,
            hasSearch: _search.isNotEmpty,
            hasDifficulty: _difficulty != null,
          ),
        )
      else
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(
            AppTheme.pageHorizontal,
            0,
            AppTheme.pageHorizontal,
            72,
          ),
          sliver: SliverList.separated(
            itemCount: _items.length + (_loadingMore ? 1 : 0),
            separatorBuilder: (_, _) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index >= _items.length) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              final item = _items[index];
              return Dismissible(
                key: ValueKey(item.uuid),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.error,
                    borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
                  ),
                  child: const Icon(Icons.delete_rounded, color: Colors.white),
                ),
                onDismissed: (_) => _delete(item),
                child: _HistorySessionCard(
                  session: item,
                  kindColor: _kindColor(item.quizKind),
                  kindLabel: L10nHelpers.quizKindLabel(l10n, item.quizKind),
                  onTap: () => context.push('/quiz/results/${item.uuid}'),
                ),
              );
            },
          ),
        ),
    ];
  }

  List<Widget> _notificationSlivers(AppLocalizations l10n) {
    if (_loading) {
      return const [
        SliverFillRemaining(child: Center(child: CircularProgressIndicator())),
      ];
    }
    if (_notifications.isEmpty) {
      return [
        SliverFillRemaining(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.menu_book_outlined,
                    size: 56,
                    color: Theme.of(context).colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    l10n.historyNotificationsEmpty,
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ];
    }
    return [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(
          AppTheme.pageHorizontal,
          0,
          AppTheme.pageHorizontal,
          72,
        ),
        sliver: SliverList.separated(
          itemCount: _notifications.length,
          separatorBuilder: (_, _) => const SizedBox(height: 10),
          itemBuilder: (context, index) {
            final item = _notifications[index];
            final color = _studyColor;
            final theme = Theme.of(context);
            DateTime? created;
            try {
              created = DateTime.parse(item.createdAtIso).toLocal();
            } catch (_) {}
            final dateText = created != null
                ? DateFormat.yMMMd(Localizations.localeOf(context).toString())
                    .add_jm()
                    .format(created)
                : '';
            final snap = item.contentPackSnapshot;
            final displayTitle = snap?.article?.title.isNotEmpty == true
                ? snap!.article!.title
                : (snap?.video?.title.isNotEmpty == true
                    ? snap!.video!.title
                    : item.title);
            final displayBody = snap != null && snap.isComplete
                ? '${snap.article!.title} · ${snap.video!.title}'
                : (snap?.article?.summary.isNotEmpty == true
                    ? snap!.article!.summary
                    : (snap?.video?.summary.isNotEmpty == true
                        ? snap!.video!.summary
                        : item.body));
            return AppCard(
              padding: EdgeInsets.zero,
              onTap: () => _openNotification(item),
              child: Container(
                decoration: BoxDecoration(
                  border: Border(left: BorderSide(color: color, width: 4)),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                  child: Row(
                    children: [
                      Icon(_studyIcon, color: color),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              displayTitle,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontWeight: item.read ? FontWeight.w600 : FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              displayBody,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            if (dateText.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(
                                dateText,
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (!item.read)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: theme.colorScheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    ];
  }
}

class _HistoryCountPill extends StatelessWidget {
  const _HistoryCountPill({
    required this.loaded,
    required this.total,
    required this.loading,
  });

  final int loaded;
  final int total;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Material(
      color: Colors.transparent,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(alpha: 0.82),
          borderRadius: BorderRadius.circular(999),
          border: Border.all(
            color: theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (loading) ...[
                SizedBox(
                  width: 14,
                  height: 14,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
                const SizedBox(width: 8),
              ],
              Text(
                l10n.historyShowingCount(loaded, total),
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistorySessionCard extends StatelessWidget {
  const _HistorySessionCard({
    required this.session,
    required this.kindColor,
    required this.kindLabel,
    required this.onTap,
  });

  final QuizSession session;
  final Color kindColor;
  final String kindLabel;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final locale = Localizations.localeOf(context).toString();
    final accuracy = (session.accuracy ?? 0).round();
    final dateText = session.completedAt != null
        ? DateFormat.yMMMd(locale).add_jm().format(session.completedAt!)
        : '';
    final difficulty = L10nHelpers.difficultyLabel(l10n, session.difficulty);
    final scoreText = '${session.correctCount ?? 0}/${session.questionCount}';

    return AppCard(
      padding: EdgeInsets.zero,
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          border: Border(left: BorderSide(color: kindColor, width: 4)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          child: Row(
            children: [
              SizedBox(
                width: 44,
                height: 44,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CircularProgressIndicator(
                      value: accuracy / 100,
                      strokeWidth: 3,
                      backgroundColor: kindColor.withValues(alpha: 0.15),
                      color: kindColor,
                    ),
                    Text(
                      '$accuracy%',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: kindColor,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      session.topic,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: kindColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        kindLabel,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: kindColor,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    _HistoryMetaRow(
                      parts: [
                        difficulty,
                        scoreText,
                        if (dateText.isNotEmpty) dateText,
                      ],
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryMetaRow extends StatelessWidget {
  const _HistoryMetaRow({required this.parts});

  final List<String> parts;

  @override
  Widget build(BuildContext context) {
    final style = Theme.of(context).textTheme.bodySmall?.copyWith(
          color: Theme.of(context).colorScheme.onSurfaceVariant,
        );
    final children = <Widget>[];
    for (var i = 0; i < parts.length; i++) {
      if (i > 0) {
        children.add(Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6),
          child: Text('|', style: style),
        ));
      }
      children.add(Text(parts[i], style: style, maxLines: 1, overflow: TextOverflow.ellipsis));
    }
    return Row(children: children);
  }
}

class _HistoryEmptyState extends StatelessWidget {
  const _HistoryEmptyState({
    required this.quizKind,
    required this.hasSearch,
    required this.hasDifficulty,
  });

  final String? quizKind;
  final bool hasSearch;
  final bool hasDifficulty;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final filtered = quizKind != null || hasSearch || hasDifficulty;
    final message = filtered && quizKind != null
        ? l10n.historyEmptyFiltered(L10nHelpers.quizKindLabel(l10n, quizKind!))
        : l10n.historyEmpty;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
            ),
            if (!filtered) ...[
              const SizedBox(height: 8),
              Text(
                l10n.historyEmptyCta,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              FilledButton.icon(
                onPressed: () => context.push('/quiz/create'),
                icon: const Icon(Icons.add_rounded),
                label: Text(l10n.createQuizTitle),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
