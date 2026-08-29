import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/services/ai_status_service.dart';
import '../../core/theme/app_theme.dart';
import 'app_card.dart';

/// Home card: personalized AI brief, or “AI Offline” when the chat probe fails.
class AiStudyPulseCard extends ConsumerWidget {
  const AiStudyPulseCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    final pulse = ref.watch(aiStudyPulseProvider);

    return AppCard(
      onTap: () => ref.read(aiStudyPulseProvider.notifier).refresh(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.seedColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.auto_awesome_rounded,
              color: AppTheme.seedColor,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: pulse.when(
              loading: () => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.aiStudyPulseTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(minHeight: 3),
                  const SizedBox(height: 6),
                  Text(
                    l10n.aiStudyPulseLoading,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              error: (_, __) => _PulseBody(
                title: l10n.aiStudyPulseTitle,
                body: l10n.aiStatusOffline,
                offline: true,
                hint: l10n.aiStudyPulseTapRetry,
              ),
              data: (result) {
                if (!result.online || (result.message?.trim().isEmpty ?? true)) {
                  return _PulseBody(
                    title: l10n.aiStudyPulseTitle,
                    body: l10n.aiStatusOffline,
                    offline: true,
                    hint: l10n.aiStudyPulseTapRetry,
                  );
                }
                return _PulseBody(
                  title: l10n.aiStudyPulseTitle,
                  body: result.message!,
                  offline: false,
                  hint: l10n.aiStudyPulseTapRetry,
                );
              },
            ),
          ),
          Icon(
            Icons.refresh_rounded,
            size: 18,
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ],
      ),
    );
  }
}

class _PulseBody extends StatelessWidget {
  const _PulseBody({
    required this.title,
    required this.body,
    required this.offline,
    required this.hint,
  });

  final String title;
  final String body;
  final bool offline;
  final String hint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          body,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: offline ? Colors.red.shade400 : theme.colorScheme.onSurface,
            fontWeight: offline ? FontWeight.w600 : FontWeight.w500,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          hint,
          style: theme.textTheme.labelSmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}
