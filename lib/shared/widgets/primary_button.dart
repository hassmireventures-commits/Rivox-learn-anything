import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.icon,
    this.isLoading = false,
    this.expanded = true,
    this.semanticsLoadingLabel,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isLoading;
  final bool expanded;

  /// Accessible label announced while [isLoading] is true.
  /// Defaults to [label] if not provided.
  final String? semanticsLoadingLabel;

  static const double _verticalPad = 16;

  @override
  Widget build(BuildContext context) {
    final onPrimaryColor = Theme.of(context).colorScheme.onPrimary;

    final spinner = SizedBox(
      key: const ValueKey('loading'),
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        color: onPrimaryColor,
      ),
    );

    // M3 icon CTAs use start 16 / end 24 so full-width icon+label looks centered.
    final iconStyle = FilledButton.styleFrom(
      padding: const EdgeInsetsDirectional.fromSTEB(16, _verticalPad, 24, _verticalPad),
    );
    final plainStyle = FilledButton.styleFrom(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: _verticalPad),
    );

    final Widget button;
    if (isLoading) {
      button = FilledButton(
        style: plainStyle,
        onPressed: null,
        child: spinner,
      );
    } else if (icon != null) {
      button = FilledButton.icon(
        style: iconStyle,
        onPressed: onPressed,
        icon: Icon(icon, size: 20),
        label: Text(label),
      );
    } else {
      button = FilledButton(
        style: plainStyle,
        onPressed: onPressed,
        child: Text(label),
      );
    }

    final wrapped = Semantics(
      button: true,
      enabled: !isLoading,
      label: isLoading ? (semanticsLoadingLabel ?? label) : label,
      child: AnimatedSwitcher(
        duration: AppTheme.motionFast,
        child: KeyedSubtree(
          key: ValueKey(isLoading ? 'loading' : 'idle'),
          child: button,
        ),
      ),
    );

    if (!expanded) return wrapped;
    return SizedBox(width: double.infinity, child: wrapped);
  }
}
