import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/provider_guide_registry.dart';
import '../../../core/locale/app_localizations_ext.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/remote/ai/ai_provider.dart';
import '../../../l10n/app_localizations.dart';
import 'external_link_confirm_dialog.dart';

Future<void> showProviderGuideSheet(
  BuildContext context, {
  required AiProviderType type,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => ProviderGuideSheet(type: type),
  );
}

class ProviderGuideSheet extends StatelessWidget {
  const ProviderGuideSheet({super.key, required this.type});

  final AiProviderType type;

  String _resolveSummary(AppLocalizations l10n, ProviderGuide guide) {
    return switch (guide.summaryKey) {
      'providerGuideGeminiSummary' => l10n.providerGuideGeminiSummary,
      'providerGuideClaudeSummary' => l10n.providerGuideClaudeSummary,
      'providerGuideGrokSummary' => l10n.providerGuideGrokSummary,
      'providerGuideDeepSeekSummary' => l10n.providerGuideDeepSeekSummary,
      'providerGuideOpenRouterSummary' => l10n.providerGuideOpenRouterSummary,
      'providerGuideCustomSummary' => l10n.providerGuideCustomSummary,
      _ => l10n.providerGuideOpenAiSummary,
    };
  }

  String _resolveStep(AppLocalizations l10n, String key) {
    return switch (key) {
      'providerGuideStepSignUp' => l10n.providerGuideStepSignUp,
      'providerGuideStepBilling' => l10n.providerGuideStepBilling,
      'providerGuideStepGoogleAccount' => l10n.providerGuideStepGoogleAccount,
      'providerGuideStepCreateKey' => l10n.providerGuideStepCreateKey,
      'providerGuideStepPaste' => l10n.providerGuideStepPaste,
      'providerGuideStepCustomEndpoint' => l10n.providerGuideStepCustomEndpoint,
      _ => key,
    };
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final guide = ProviderGuideRegistry.forType(type);
    if (guide == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.providerGuideTitle(type.label),
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            _resolveSummary(l10n, guide),
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
          ),
          const SizedBox(height: 16),
          for (var i = 0; i < guide.stepKeys.length; i++)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 12,
                    backgroundColor: AppTheme.purpleStart.withValues(alpha: 0.15),
                    child: Text(
                      '${i + 1}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _resolveStep(l10n, guide.stepKeys[i]),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ),
                ],
              ),
            ),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: () => confirmAndLaunchExternalUrl(
              context,
              providerName: type.label,
              url: guide.apiKeyUrl,
            ),
            icon: const Icon(Icons.open_in_new_rounded),
            label: Text(l10n.providerGuideGetKey),
          ),
          const SizedBox(height: 8),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.providerGuideAlreadyHaveKey),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              context.push('/quiz/create');
            },
            child: Text(l10n.dashboardTryDemoQuiz),
          ),
        ],
      ),
    );
  }
}