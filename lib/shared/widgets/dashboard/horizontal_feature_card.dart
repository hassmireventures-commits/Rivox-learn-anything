import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

enum HorizontalFeatureCardVariant { primary, secondary }

/// Horizontal discovery card - primary gradient or secondary white with abstract art.
class HorizontalFeatureCard extends StatelessWidget {
  const HorizontalFeatureCard({
    super.key,
    required this.title,
    this.subtitle,
    this.pillLabel,
    this.width = 260,
    this.height = 200,
    this.variant = HorizontalFeatureCardVariant.primary,
    this.gradient = AppTheme.secondaryCoralGradient,
    this.accentIndex = 0,
    this.leading,
    this.onTap,
    this.footer,
  });

  final String title;
  final String? subtitle;
  final String? pillLabel;
  final double width;
  final double height;
  final HorizontalFeatureCardVariant variant;
  final Gradient gradient;
  final int accentIndex;
  final Widget? leading;
  final VoidCallback? onTap;
  final Widget? footer;

  static const _pastelAccents = [
    (Color(0xFFE8F4FD), Color(0xFF74B9FF)),
    (Color(0xFFE8F8F5), Color(0xFF00B894)),
    (Color(0xFFFFF0F0), Color(0xFFFF7675)),
    (Color(0xFFFFF8E8), Color(0xFFFDCB6E)),
  ];

  @override
  Widget build(BuildContext context) {
    final isPrimary = variant == HorizontalFeatureCardVariant.primary;
    final onColored = isPrimary;
    final radius = BorderRadius.circular(AppTheme.dashboardCardRadius);
    final accent = _pastelAccents[accentIndex % _pastelAccents.length];

    final content = Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (leading != null) leading!,
          const Spacer(),
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: AppTheme.cardTitle(onColoredCard: onColored),
          ),
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle!,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: AppTheme.cardSubtitle(
                color: onColored ? Colors.white.withValues(alpha: 0.85) : AppTheme.mutedSlate,
              ),
            ),
          ],
          if (pillLabel != null) ...[
            const SizedBox(height: 8),
            _CountPill(label: pillLabel!, onColored: onColored, accent: accent.$2),
          ],
          if (footer != null) ...[
            const SizedBox(height: 8),
            footer!,
          ],
        ],
      ),
    );

    final child = SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: radius,
        child: isPrimary
            ? Container(
                decoration: BoxDecoration(gradient: gradient),
                child: content,
              )
            : Container(
                decoration: BoxDecoration(
                  color: AppTheme.cardSurface,
                  borderRadius: radius,
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    _AbstractArtBackground(accent: accent),
                    content,
                  ],
                ),
              ),
      ),
    );

    if (onTap == null) return child;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: child,
      ),
    );
  }
}

class _CountPill extends StatelessWidget {
  const _CountPill({
    required this.label,
    required this.onColored,
    required this.accent,
  });

  final String label;
  final bool onColored;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: onColored
            ? Colors.white.withValues(alpha: 0.22)
            : accent.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.chipLabel(
          color: onColored ? Colors.white : accent,
        ),
      ),
    );
  }
}

class _AbstractArtBackground extends StatelessWidget {
  const _AbstractArtBackground({required this.accent});

  final (Color, Color) accent;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.antiAlias,
      children: [
        Positioned(
          top: -12,
          right: -12,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.$1,
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 8,
          right: 24,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: accent.$2.withValues(alpha: 0.25),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
