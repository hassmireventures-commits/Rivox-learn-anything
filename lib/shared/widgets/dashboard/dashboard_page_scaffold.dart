import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/theme/app_theme.dart';
import 'geometric_wavy_header.dart';

/// Settings gear for dashboard-style page headers.
Widget dashboardHeaderSettingsAction(BuildContext context) {
  final l10n = context.l10n;
  return IconButton(
    tooltip: l10n.settingsTooltip,
    icon: const Icon(Icons.settings_outlined, color: Colors.white),
    onPressed: () => context.push('/settings'),
  );
}

/// Shared dashboard-style page shell with notch-safe header and sliver body.
class DashboardPageScaffold extends StatelessWidget {
  const DashboardPageScaffold({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.leading,
    this.onRefresh,
    required this.slivers,
    this.headerGradient = AppTheme.primaryPurpleGradient,
    this.headerHeight = 112,
    this.embedInShell = false,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final Widget? leading;
  final Future<void> Function()? onRefresh;
  final List<Widget> slivers;
  final Gradient headerGradient;
  final double headerHeight;
  /// When true, omits the inner [Scaffold] so tab pages inside [AppShell] match Home layout.
  final bool embedInShell;

  @override
  Widget build(BuildContext context) {
    final headerActions = <Widget>[
      if (leading != null) leading!,
      ...actions,
    ];

    final scrollView = CustomScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: slivers,
    );

    final scrollBody = onRefresh == null
        ? scrollView
        : RefreshIndicator(
            onRefresh: onRefresh!,
            color: AppTheme.seedColor,
            child: scrollView,
          );

    final body = Column(
      children: [
        GeometricWavyHeader(
          title: title,
          subtitle: subtitle,
          actions: headerActions,
          gradient: headerGradient,
          height: headerHeight,
        ),
        Expanded(child: scrollBody),
      ],
    );

    if (embedInShell) return body;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: body,
    );
  }
}

/// Animated section wrapper for subtle entrance on first paint.
class DashboardAnimatedSection extends StatefulWidget {
  const DashboardAnimatedSection({
    super.key,
    required this.child,
    this.delayMs = 0,
  });

  final Widget child;
  final int delayMs;

  @override
  State<DashboardAnimatedSection> createState() => _DashboardAnimatedSectionState();
}

class _DashboardAnimatedSectionState extends State<DashboardAnimatedSection>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _opacity;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 420),
    );
    _opacity = CurvedAnimation(parent: _controller, curve: Curves.easeOut);
    _slide = Tween<Offset>(begin: const Offset(0, 0.04), end: Offset.zero).animate(_opacity);
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _controller.forward();
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: SlideTransition(position: _slide, child: widget.child),
    );
  }
}
