import 'package:flutter/material.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/local/models/recommendation.dart';

/// Vertical list row inspired by the mockup recommendation cards.
class VerticalRecommendationCard extends StatelessWidget {
  const VerticalRecommendationCard({
    super.key,
    required this.item,
    this.onTap,
    this.accentIndex = 0,
  });

  final RecommendationItem item;
  final VoidCallback? onTap;
  final int accentIndex;

  static const _pastelAccents = [
    (Color(0xFFE8F4FD), Color(0xFF5B4BDB)),
    (Color(0xFFFFF0F0), Color(0xFFFF7675)),
    (Color(0xFFE8F8F5), Color(0xFF00B894)),
    (Color(0xFFFFF8E8), Color(0xFFE67E22)),
  ];

  @override
  Widget build(BuildContext context) {
    final accent = _pastelAccents[accentIndex % _pastelAccents.length];
    final tags = <String>[
      if (item.topic != null && item.topic!.isNotEmpty) item.topic!,
      _kindLabel(item.kind),
    ];

    return Material(
      color: AppTheme.cardSurface,
      borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.dashboardCardRadius),
                child: SizedBox(
                  width: 100,
                  height: 100,
                  child: _ArtworkBox(accent: accent),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: AppTheme.cardTitle(onColoredCard: false).copyWith(
                              color: AppTheme.purpleStart,
                            ),
                          ),
                        ),
                        Text(
                          '· ${(item.score * 100).round()}%',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTheme.cardSubtitle(),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.reason,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: AppTheme.cardSubtitle(),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 4,
                      children: [
                        for (final tag in tags)
                          _TagChip(label: tag, color: accent.$2),
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

  static String _kindLabel(String kind) => switch (kind) {
        'next_topic' => 'Practice',
        'remedial' => 'Remedial',
        'nudge' => 'Nudge',
        'break' => 'Break',
        'mock' => 'Mock exam',
        'interview' => 'Interview',
        'path' => 'Path',
        'layout' => 'Layout',
        _ => kind,
      };
}

class _ArtworkBox extends StatelessWidget {
  const _ArtworkBox({required this.accent});

  final (Color, Color) accent;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: accent.$1,
      child: Stack(
        clipBehavior: Clip.antiAlias,
        children: [
          Positioned(
            top: -8,
            right: -8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.$2.withValues(alpha: 0.35),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 12,
            left: 8,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent.$2.withValues(alpha: 0.2),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppTheme.chipLabel(color: color),
      ),
    );
  }
}
