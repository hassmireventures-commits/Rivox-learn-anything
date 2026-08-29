import 'dart:async';

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
  });

  final bool visible;
  final String? topic;
  final bool forPath;

  @override
  State<GenerationOverlay> createState() => _GenerationOverlayState();
}

class _GenerationOverlayState extends State<GenerationOverlay> with TickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final AnimationController _rotateController;
  Timer? _messageTimer;
  int _messageIndex = 0;
  List<String> _messages = const [];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
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
      _startMessages();
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

  @override
  void dispose() {
    _messageTimer?.cancel();
    _pulseController.dispose();
    _rotateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.visible) return const SizedBox.shrink();
    if (_messages.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return AbsorbPointer(
      child: Container(
        color: Colors.black.withValues(alpha: 0.45),
        child: Center(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 32),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.cardRadius),
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
                              child: const Icon(Icons.auto_awesome_rounded, size: 36, color: AppTheme.seedColor),
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
                  child: Text(
                    _messages[_messageIndex],
                    key: ValueKey(_messageIndex),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                  ),
                ),
                if (widget.topic != null) ...[
                  const SizedBox(height: 12),
                  Chip(
                    label: Text(widget.topic!),
                    backgroundColor: AppTheme.seedColor.withValues(alpha: 0.12),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
