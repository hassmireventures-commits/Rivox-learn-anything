import 'package:flutter/material.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/theme/app_theme.dart';
import 'dynamic_app_explainer_sheet.dart';

class AdaptiveUiBanner extends StatelessWidget {
  const AdaptiveUiBanner({super.key, required this.goalMode});

  final String goalMode;

  String _goalLabel(dynamic l10n) => switch (goalMode) {
        'exam_prep' => l10n.goalModeExamPrep,
        'career' => l10n.goalModeCareer,
        _ => l10n.goalModeLearning,
      };

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Material(
      color: AppTheme.purpleStart.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => showDynamicAppExplainerSheet(context, goalMode: goalMode),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            children: [
              Icon(Icons.auto_awesome_rounded, size: 20, color: AppTheme.purpleStart),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.learnAdaptiveBanner(_goalLabel(l10n)),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
              Icon(Icons.chevron_right_rounded, color: AppTheme.mutedSlate),
            ],
          ),
        ),
      ),
    );
  }
}
