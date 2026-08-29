import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_constants.dart';
import '../../../core/guidance/guidance_controller.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../shared/widgets/app_card.dart';

Future<void> showWhatsNewSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (ctx) => const WhatsNewSheet(),
  );
}

class WhatsNewSheet extends ConsumerWidget {
  const WhatsNewSheet({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l10n.whatsNewTitle, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          AppCard(child: Text(l10n.whatsNewDashboard)),
          const SizedBox(height: 8),
          AppCard(child: Text(l10n.whatsNewGuidance)),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () async {
              await ref.read(guidanceControllerProvider.notifier).markWhatsNewSeen(AppConstants.appVersion);
              if (context.mounted) Navigator.pop(context);
            },
            child: Text(l10n.commonDismiss),
          ),
        ],
      ),
    );
  }
}
