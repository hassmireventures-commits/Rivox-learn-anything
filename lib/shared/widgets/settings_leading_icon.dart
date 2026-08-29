import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

/// Brand-tinted leading icon matching Home AI brief / reminder styling.
class SettingsLeadingIcon extends StatelessWidget {
  const SettingsLeadingIcon(this.icon, {super.key, this.color});

  final IconData icon;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final tint = color ?? AppTheme.seedColor;
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(icon, color: tint, size: 22),
    );
  }
}
