import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';

/// Global, always-visible indicator shown on top of every screen while a
/// generation job is running in the background (i.e. the user navigated
/// away from the screen that started it) — so they're never tempted to
/// start another generation without realizing one is already in flight.
///
/// Deliberately only shows when `isRunning && !uiAttached`: the originating
/// screen already has its own full-screen [GenerationOverlay] while attached,
/// so this would just be redundant there.
class GenerationTopBanner extends ConsumerStatefulWidget {
  const GenerationTopBanner({super.key});

  @override
  ConsumerState<GenerationTopBanner> createState() => _GenerationTopBannerState();
}

class _GenerationTopBannerState extends ConsumerState<GenerationTopBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  )..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final job = ref.watch(generationJobServiceProvider);
    final show = job.isRunning && !job.uiAttached;

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
                        AnimatedBuilder(
                          animation: _spin,
                          builder: (context, child) => Transform.rotate(
                            angle: _spin.value * 2 * math.pi,
                            child: child,
                          ),
                          child: const Icon(
                            Icons.autorenew_rounded,
                            size: 16,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Flexible(
                          child: Text(
                            context.l10n.generationInProgressStrip,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                            overflow: TextOverflow.ellipsis,
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
    );
  }
}
