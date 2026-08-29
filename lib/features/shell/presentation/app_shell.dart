import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/providers/home_refresh.dart';
import '../../../core/services/built_in_ai_quota.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/guidance/guidance_controller.dart';
import '../../../core/guidance/guidance_preferences_store.dart';
import '../../../core/guidance/tour_steps.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../features/guidance/presentation/coach_mark_tour.dart';
import '../../../features/guidance/presentation/whats_new_sheet.dart';
import '../../../shared/widgets/main_bottom_nav.dart';

class AppShell extends ConsumerStatefulWidget {
  const AppShell({
    super.key,
    required this.navigationShell,
  });

  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<AppShell> createState() => _AppShellState();
}

class _AppShellState extends ConsumerState<AppShell> with WidgetsBindingObserver {
  bool _tourScheduled = false;
  DateTime? _lastHomeBackAt;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeStartTour());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      BuiltInAiQuota.instance.restoreIfExpired().then((_) {
        if (mounted) ref.invalidate(builtInQuotaProvider);
      });
      syncCalendarDayIfNeeded(ref);
    }
  }

  Future<void> _maybeStartTour() async {
    if (_tourScheduled || !mounted) return;
    await GuidancePreferencesStore.instance.load();
    final guidance = ref.read(guidanceControllerProvider);
    if (ref.read(guidanceControllerProvider.notifier).shouldShowWhatsNew(AppConstants.appVersion)) {
      await Future<void>.delayed(const Duration(milliseconds: 400));
      if (!mounted) return;
      await showWhatsNewSheet(context);
    }
    if (guidance.walkthroughVersion >= GuidancePreferencesStore.currentWalkthroughVersion) {
      return;
    }
    if (widget.navigationShell.currentIndex != 0) return;

    _tourScheduled = true;
    await Future<void>.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    final l10n = context.l10n;
    final steps = <TourStepDefinition>[
      TourStepDefinition(
        targetKey: tourHomeTabKey,
        title: l10n.tourHomeTitle,
        description: l10n.tourHomeBody,
        align: ContentAlign.top,
      ),
      TourStepDefinition(
        targetKey: tourLearnTabKey,
        title: l10n.tourLearnTitle,
        description: l10n.tourLearnBody,
        align: ContentAlign.top,
      ),
      TourStepDefinition(
        targetKey: tourHistoryTabKey,
        title: l10n.tourHistoryTitle,
        description: l10n.tourHistoryBody,
        align: ContentAlign.top,
      ),
    ];

    startCoachMarkTour(
      context,
      steps: steps,
      onComplete: () => ref.read(guidanceControllerProvider.notifier).completeWalkthrough(),
    );
  }

  void _onTap(int branchIndex) {
    widget.navigationShell.goBranch(
      branchIndex,
      initialLocation: branchIndex == widget.navigationShell.currentIndex,
    );
  }

  void _onShellBack() {
    final shell = widget.navigationShell;
    if (shell.currentIndex != 0) {
      shell.goBranch(0);
      return;
    }
    final now = DateTime.now();
    final last = _lastHomeBackAt;
    if (last != null && now.difference(last) < const Duration(seconds: 2)) {
      SystemNavigator.pop();
      return;
    }
    _lastHomeBackAt = now;
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(content: Text(context.l10n.shellTapAgainToExit)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _onShellBack();
      },
      child: Scaffold(
        body: widget.navigationShell,
        bottomNavigationBar: MainBottomNav(
          currentBranchIndex: widget.navigationShell.currentIndex,
          onBranchSelected: _onTap,
        ),
      ),
    );
  }
}
