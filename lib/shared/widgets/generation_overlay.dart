import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/locale/l10n_helpers.dart';
import '../../core/theme/app_theme.dart';

class GenerationOverlay extends StatefulWidget {
  const GenerationOverlay({
    super.key,
    required this.visible,
    this.topic,
    this.forPath = false,
    this.onCancel,
    this.onContinueInBackground,
  });

  final bool visible;
  final String? topic;
  final bool forPath;
  final VoidCallback? onCancel;
  final VoidCallback? onContinueInBackground;

  @override
  State<GenerationOverlay> createState() => _GenerationOverlayState();
}

class _GenerationOverlayState extends State<GenerationOverlay> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  late final AnimationController _revealController;
  Timer? _messageTimer;
  Timer? _backgroundHintTimer;
  int _messageIndex = 0;
  List<String> _messages = const [];
  bool _showBackgroundAction = false;

  static const _backgroundHintDelay = Duration.zero;

  @override
  void initState() {
    super.initState();
    // Pulse and rotate controllers are started only when the overlay becomes
    // visible - never ticking at idle (saves CPU/battery on every host screen).
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _revealController = AnimationController(
      vsync: this,
      duration: AppTheme.motionSlow,
    );
    if (widget.visible) {
      _revealController.forward();
      _pulseController.repeat(reverse: true);
      _rotateController.repeat();
      _startMessages();
      if (widget.onContinueInBackground != null) {
        _showBackgroundAction = true;
      }
      _startBackgroundHintTimer();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final l10n = context.l10n;
    _messages = widget.forPath
        ? L10nHelpers.pathGenerationMessages(l10n)
        : L10nHelpers.quizGenerationMessages(l10n);
  }

  @override
  void didUpdateWidget(covariant GenerationOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.visible && !oldWidget.visible) {
      _messageIndex = 0;
      _showBackgroundAction = widget.onContinueInBackground != null;
      _revealController.forward(from: 0);
      _pulseController.repeat(reverse: true);
      _rotateController.repeat();
      _startMessages();
      _startBackgroundHintTimer();
    } else if (!widget.visible && oldWidget.visible) {
      _revealController.reverse();
      _pulseController
        ..stop()
        ..value = 0;
      _rotateController
        ..stop()
        ..value = 0;
      _messageTimer?.cancel();
      _backgroundHintTimer?.cancel();
      _showBackgroundAction = false;
    }
    if (widget.forPath != oldWidget.forPath) {
      final l10n = context.l10n;
      _messages = widget.forPath
          ? L10nHelpers.pathGenerationMessages(l10n)
          : L10nHelpers.quizGenerationMessages(l10n);
    }
  }

  void _startMessages() {
    _messageTimer?.cancel();
    if (_messages.isEmpty) return;
    _messageTimer = Timer.periodic(const Duration(milliseconds: 2500), (_) {
      if (!mounted) return;
      setState(() {
        _messageIndex = (_messageIndex + 1) % _messages.length;
      });
    });
  }

  void _startBackgroundHintTimer() {
    _backgroundHintTimer?.cancel();
    if (widget.onContinueInBackground == null) return;
    _backgroundHintTimer = Timer(_backgroundHintDelay, () {
      if (!mounted || !widget.visible) return;
      setState(() => _showBackgroundAction = true);
    });
  }

  @override
  void dispose() {
    _messageTimer?.cancel();
    _backgroundHintTimer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    _revealController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // TweenAnimationBuilder drives visibility now; keep the overlay in the
    // tree until it has been invisible long enough to finish animating out.
    // _revealController.isDismissed is used as a proxy for "animation done".
    if (!widget.visible && _revealController.status == AnimationStatus.dismissed) {
      return const SizedBox.shrink();
    }
    if (_messages.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Positioned.fill(
      child: IgnorePointer(
        ignoring: !widget.visible,
        child: TweenAnimationBuilder<double>(
        tween: Tween<double>(begin: 0, end: widget.visible ? 1 : 0),
        duration: AppTheme.motionSlow,
        curve: Curves.easeOutCubic,
        builder: (context, t, child) {
          return Opacity(
            opacity: t,
            child: Stack(
              fit: StackFit.expand,
              children: [
                ClipRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10 * t, sigmaY: 10 * t),
                    child: AbsorbPointer(
                      absorbing: widget.visible,
                      child: ColoredBox(
                        color: Colors.black.withValues(alpha: 0.52 * t),
                      ),
                    ),
                  ),
                ),
                if (child != null)
                  Transform.scale(
                    scale: 0.96 + (0.04 * t),
                    child: child,
                  ),
              ],
            ),
          );
        },
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.seedColor.withValues(alpha: 0.18),
                  blurRadius: 32,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedBuilder(
                  animation: Listenable.merge([_pulseController, _rotateController]),
                  builder: (context, child) {
                    final scale = 1 + (_pulseController.value * 0.08);
                    return Transform.scale(
                      scale: scale,
                      child: Transform.rotate(
                        angle: _rotateController.value * 6.28,
                        child: Container(
                          width: 88,
                          height: 88,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: SweepGradient(
                              colors: [
                                AppTheme.seedColor,
                                AppTheme.accentBlue,
                                AppTheme.accentPink,
                                AppTheme.seedColor,
                              ],
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.auto_awesome_rounded,
                                size: 36,
                                color: AppTheme.seedColor,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                AnimatedSwitcher(
                  duration: AppTheme.motionMedium,
                  child: Semantics(
                    liveRegion: true,
                    label: _messages[_messageIndex],
                    child: Text(
                      _messages[_messageIndex],
                      key: ValueKey(_messageIndex),
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
                if (widget.topic != null) ...[
                  const SizedBox(height: 12),
                  Material(
                    type: MaterialType.transparency,
                    child: Chip(
                      label: Text(widget.topic!),
                      backgroundColor: AppTheme.seedColor.withValues(alpha: 0.12),
                    ),
                  ),
                ],
                if (widget.onCancel != null ||
                    (widget.onContinueInBackground != null && _showBackgroundAction)) ...[
                  const SizedBox(height: 20),
                  if (widget.onContinueInBackground != null && _showBackgroundAction)
                    FilledButton.tonalIcon(
                      onPressed: widget.onContinueInBackground,
                      icon: const Icon(Icons.phone_android_rounded, size: 18),
                      label: Text(context.l10n.generationContinueBackground),
                    ),
                  if (widget.onCancel != null) ...[
                    if (widget.onContinueInBackground != null && _showBackgroundAction)
                      const SizedBox(height: 4),
                    TextButton.icon(
                      onPressed: widget.onCancel,
                      icon: const Icon(Icons.close_rounded, size: 18),
                      label: Text(context.l10n.generationCancel),
                    ),
                  ],
                ],
              ],
            ),
          ),
        ),
      ),
      ),
    );
  }
}
