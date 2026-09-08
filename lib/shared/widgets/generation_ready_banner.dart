import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/app_providers.dart';
import '../../core/router/app_router.dart';
import '../../core/services/generation_job_service.dart';
import '../../core/theme/app_theme.dart';

/// Global, always-visible "your quiz/path is ready" indicator — the missing
/// companion to [GenerationTopBanner] (which only ever covered the
/// "generating" state). Shown whenever a job finished successfully while
/// the user was away from wherever it started (`!uiAttached`, same guard
/// `GenerationTopBanner` uses), regardless of which screen triggered it —
/// this is the single place "ready" surfaces globally, so chat-triggered
/// generations get the exact same treatment as Create Quiz/Learn-path ones.
///
/// Tapping opens the result and calls [GenerationJobService.clearTerminalState]
/// so this can never get stuck showing a stale "ready" state forever; the
/// dismiss (X) button clears it without navigating.
class GenerationReadyBanner extends ConsumerWidget {
  const GenerationReadyBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final job = ref.watch(generationJobServiceProvider);
    final show = !job.isRunning &&
        !job.uiAttached &&
        !job.userCancelled &&
        job.successRoute != null;

    final label = switch (job.kind) {
      GenerationJobKind.path => 'Learning path ready — tap to open',
      GenerationJobKind.quiz => 'Quiz ready — tap to open',
      _ => 'Ready — tap to open',
    };

    return IgnorePointer(
      ignoring: !show,
      child: SafeArea(
        bottom: false,
        child: Align(
          alignment: Alignment.topCenter,
          child: AnimatedSlide(
            duration: const Duration(milliseconds: 280),
            curve: Curves.easeOutCubic,
            offset: show ? Offset.zero : const Offset(0, -1.4),
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 200),
              opacity: show ? 1 : 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: show
                        ? () async {
                            final route = job.successRoute;
                            job.clearTerminalState();
                            if (route == null) return;
                            try {
                              // Use the raw router directly (same mechanism
                              // notification taps already rely on
                              // successfully — see
                              // NotificationService._navigateFromNotification)
                              // rather than context.push from this
                              // above-the-router overlay context, which has
                              // been unreliable here.
                              final needsShell = route.startsWith('/quiz/') ||
                                  route.startsWith('/paths/');
                              if (needsShell) {
                                appRouter.go('/dashboard');
                                await Future<void>.delayed(Duration.zero);
                              }
                              appRouter.push(route);
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text("Couldn't open that: $e")),
                                );
                              }
                            }
                          }
                        : null,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: const LinearGradient(
                          colors: [AppTheme.purpleStart, AppTheme.purpleEnd],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.18),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.check_circle_rounded, size: 16, color: Colors.white),
                          const SizedBox(width: 10),
                          Flexible(
                            child: Text(
                              label,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 6),
                          InkWell(
                            borderRadius: BorderRadius.circular(12),
                            onTap: show ? () => job.clearTerminalState() : null,
                            child: const Padding(
                              padding: EdgeInsets.all(2),
                              child: Icon(Icons.close_rounded, size: 16, color: Colors.white),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
