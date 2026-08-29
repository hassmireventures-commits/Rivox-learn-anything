import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/locale/app_localizations_ext.dart';
import '../../../shared/widgets/app_card.dart';
import '../../../shared/widgets/guidance/provider_guide_sheet.dart';
import '../../../data/remote/ai/ai_provider.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Scaffold(
      appBar: AppBar(title: Text(l10n.helpCenterTitle)),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(l10n.helpCenterProviders, style: const TextStyle(fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                Text(l10n.supportFaqProvidersAnswer),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  children: [
                    for (final type in [
                      AiProviderType.openai,
                      AiProviderType.gemini,
                      AiProviderType.claude,
                    ])
                      ActionChip(
                        label: Text(type.label),
                        onPressed: () => showProviderGuideSheet(context, type: type),
                      ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.helpCenterPaths),
              subtitle: Text(l10n.learnYourLearningPath),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.go('/learn'),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.helpCenterGoals),
              subtitle: Text(l10n.dynamicAppBody),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/settings'),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.settingsSupportTitle),
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => context.push('/support'),
            ),
          ),
        ],
      ),
    );
  }
}
