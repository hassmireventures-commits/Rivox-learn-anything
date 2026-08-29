import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';
import 'app_card.dart';

class PriorityTopicCard extends StatelessWidget {
  const PriorityTopicCard({
    super.key,
    required this.topic,
    required this.reason,
    this.onTap,
  });

  final String topic;
  final String reason;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.accentOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(Icons.flag_rounded, color: AppTheme.accentOrange),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(topic, style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(
                  reason,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded),
        ],
      ),
    );
  }
}
