import 'package:flutter/material.dart';

import '../../../core/locale/app_localizations_ext.dart';

Future<void> showDynamicAppExplainerSheet(
  BuildContext context, {
  required String goalMode,
}) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => DynamicAppExplainerSheet(goalMode: goalMode),
  );
}

class DynamicAppExplainerSheet extends StatelessWidget {
  const DynamicAppExplainerSheet({super.key, required this.goalMode});

  final String goalMode;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final detail = switch (goalMode) {
      'exam_prep' => l10n.dynamicAppExam,
      'career' => l10n.dynamicAppCareer,
      _ => l10n.dynamicAppLearning,
    };

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.dynamicAppTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(l10n.dynamicAppBody),
          const SizedBox(height: 12),
          Text(detail, style: Theme.of(context).textTheme.bodyMedium),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.commonDismiss),
          ),
        ],
      ),
    );
  }
}
