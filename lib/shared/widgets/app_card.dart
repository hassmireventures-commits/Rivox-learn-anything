import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.onTap,
    this.color,
    this.margin,
    this.semanticsLabel,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final Color? color;
  final EdgeInsetsGeometry? margin;
  /// Accessible label announced by screen readers when [onTap] is provided.
  final String? semanticsLabel;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = color ?? (isDark ? const Color(0xFF1E1E28) : Colors.white);
    final radius = BorderRadius.circular(AppTheme.cardRadius);
    final shadow = [
      BoxShadow(
        color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
        blurRadius: 18,
        offset: const Offset(0, 8),
      ),
    ];

    // Non-tappable: simple container with shadow.
    if (onTap == null) {
      return Container(
        margin: margin,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: radius,
          boxShadow: shadow,
        ),
        child: ClipRRect(
          borderRadius: radius,
          child: Padding(padding: padding, child: child),
        ),
      );
    }

    // Tappable: correct Material → InkWell layering so ink renders ON the card.
    return Semantics(
      button: true,
      label: semanticsLabel,
      child: Container(
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: radius,
          boxShadow: shadow,
        ),
        child: Material(
          color: cardColor,
          borderRadius: radius,
          elevation: 0,
          child: InkWell(
            onTap: onTap,
            borderRadius: radius,
            child: Padding(padding: padding, child: child),
          ),
        ),
      ),
    );
  }
}
