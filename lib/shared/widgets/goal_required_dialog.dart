import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/app_localizations_ext.dart';

Future<void> showGoalRequiredDialog(BuildContext context) async {
  final l10n = context.l10n;
  await showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.goalRequiredTitle),
      content: Text(l10n.goalRequiredBody),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: Text(l10n.commonDismiss),
        ),
        FilledButton(
          onPressed: () {
            Navigator.pop(ctx);
            context.push('/settings');
          },
          child: Text(l10n.goalRequiredOpenSettings),
        ),
      ],
    ),
  );
}
