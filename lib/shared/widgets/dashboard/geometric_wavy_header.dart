import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// Mockup-inspired gradient header with abstract geometric background shapes.
class GeometricWavyHeader extends StatelessWidget {
  const GeometricWavyHeader({
    super.key,
    required this.title,
    this.subtitle,
    this.actions = const [],
    this.height = 112,
    this.gradient = AppTheme.primaryPurpleGradient,
  });

  final String title;
  final String? subtitle;
  final List<Widget> actions;
  final double height;
  final Gradient gradient;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = Colors.white.withValues(alpha: 0.85);
    final topInset = MediaQuery.paddingOf(context).top;
    final totalHeight = height + topInset;

    return SizedBox(
      height: totalHeight,
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(bottom: Radius.circular(AppTheme.wavyHeaderRadius)),
        child: Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: isDark
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      AppTheme.purpleStart.withValues(alpha: 0.85),
                      AppTheme.purpleEnd.withValues(alpha: 0.7),
                    ],
                  )
                : gradient,
          ),
          child: Stack(
            clipBehavior: Clip.antiAlias,
            children: [
              Positioned(
                top: -20,
                right: -20,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 28,
                right: 40,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.08),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -24,
                left: -12,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white.withValues(alpha: 0.10),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.pageHorizontal,
                  topInset + 8,
                  AppTheme.pageHorizontal,
                  12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (subtitle != null) ...[
                                Text(
                                  subtitle!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: AppTheme.cardSubtitle(color: subtitleColor),
                                ),
                                const SizedBox(height: 2),
                              ],
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: AppTheme.sectionHeading(color: Colors.white).copyWith(
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ...actions,
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
