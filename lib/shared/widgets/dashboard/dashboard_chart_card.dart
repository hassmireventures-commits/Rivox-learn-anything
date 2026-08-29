import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';

/// White card shell with fixed aspect-ratio chart area.
class DashboardChartCard extends StatelessWidget {
  const DashboardChartCard({
    super.key,
    required this.title,
    required this.child,
    this.aspectRatio = 1.7,
  });

  final String title;
  final Widget child;
  final double aspectRatio;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1A1A24) : AppTheme.cardSurface,
        borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.25 : 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTheme.cardTitle(onColoredCard: false),
              ),
              const SizedBox(height: 8),
              AspectRatio(
                aspectRatio: aspectRatio,
                child: child,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
