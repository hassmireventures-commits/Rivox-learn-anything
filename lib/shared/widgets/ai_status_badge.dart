import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/services/ai_status_service.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

/// Small badge showing the current AI provider health.
/// Tapping it triggers an immediate re-check.
///
/// Designed to be placed in an AppBar's [actions] or a settings header.
class AiStatusBadge extends ConsumerWidget {
  const AiStatusBadge({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final statusState = ref.watch(aiStatusProvider);
    final notifier = ref.read(aiStatusProvider.notifier);

    final (color, icon, statusText) = switch (statusState.status) {
      AiProviderCheckStatus.connecting => (
          AppTheme.accentOrange,
          Icons.hourglass_top_rounded,
          l10n.aiStatusConnecting,
        ),
      AiProviderCheckStatus.online => (
          AppTheme.accentGreen,
          Icons.circle,
          l10n.aiStatusOnline,
        ),
      AiProviderCheckStatus.offline => (
          Colors.red,
          Icons.circle,
          l10n.aiStatusOffline,
        ),
    };

    final providerLine = statusState.providerName;
    final detailLine = statusState.detail;
    final checkedLine = statusState.lastChecked != null
        ? l10n.aiStatusCheckedAt(_formatTime(statusState.lastChecked!))
        : null;

    final tooltipLines = [
      if (providerLine != null) providerLine,
      statusText,
      if (detailLine != null) detailLine,
      if (checkedLine != null) checkedLine,
    ].join('\n');

    return Semantics(
      button: true,
      label: statusText,
      child: Tooltip(
        message: tooltipLines,
        preferBelow: true,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
          child: InkWell(
            onTap: notifier.checkNow,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  statusState.status == AiProviderCheckStatus.connecting
                      ? SizedBox(
                          width: 10,
                          height: 10,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: color,
                          ),
                        )
                      : Icon(icon, size: 10, color: color),
                  const SizedBox(width: 5),
              Text(
                statusText,
                style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }
}
