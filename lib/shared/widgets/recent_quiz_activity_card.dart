import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/locale/l10n_helpers.dart';
import '../../core/theme/app_theme.dart';
import '../../data/local/models/quiz_session.dart';
import 'app_card.dart';

class RecentQuizActivityCard extends StatelessWidget {
  const RecentQuizActivityCard({
    super.key,
    required this.session,
    required this.locale,
    required this.onTap,
  });

  final QuizSession session;
  final String locale;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final accuracy = (session.accuracy ?? 0).round();
    final completedAt = session.completedAt;
    final dateLabel = completedAt != null ? DateFormat.MMMd(locale).format(completedAt) : '';
    final difficulty = L10nHelpers.difficultyLabel(l10n, session.difficulty);
    final score = '${session.correctCount ?? 0}/${session.questionCount}';

    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          SizedBox(
            width: 52,
            height: 52,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: accuracy / 100,
                  strokeWidth: 5,
                  backgroundColor: AppTheme.seedColor.withValues(alpha: 0.12),
                  color: accuracy >= 60 ? AppTheme.accentGreen : AppTheme.accentOrange,
                ),
                Text(
                  '$accuracy%',
                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  session.topic,
                  style: const TextStyle(fontWeight: FontWeight.w700),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.dashboardRecentQuizRow(difficulty, score, dateLabel),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.resultsMeta(difficulty, session.questionCount),
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}
