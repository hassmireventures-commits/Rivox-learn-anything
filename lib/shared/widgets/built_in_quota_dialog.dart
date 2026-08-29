import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/providers/app_providers.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/built_in_ai_quota.dart';
import '../../core/theme/app_theme.dart';

/// Shown when Built-in AI daily generations are exhausted.
Future<bool> showBuiltInQuotaDialog(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => const _BuiltInQuotaSheet(),
  );
  return result == true;
}

class _BuiltInQuotaSheet extends ConsumerStatefulWidget {
  const _BuiltInQuotaSheet();

  @override
  ConsumerState<_BuiltInQuotaSheet> createState() => _BuiltInQuotaSheetState();
}

class _BuiltInQuotaSheetState extends ConsumerState<_BuiltInQuotaSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _watchAd() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final quota = await BuiltInAiQuota.instance.load();
      if (!quota.canWatchAd) {
        setState(() => _error = context.l10n.builtinQuotaAdsExhausted);
        return;
      }
      final ads = ref.read(adServiceProvider);
      final result = await ads.showRewarded();
      if (result != RewardedAdResult.earned) {
        if (mounted) {
          final l10n = context.l10n;
          setState(() {
            _error = switch (result) {
              RewardedAdResult.notConfigured => l10n.builtinQuotaAdNotConfigured,
              RewardedAdResult.timeout => l10n.builtinQuotaAdTimeout,
              RewardedAdResult.dismissed => l10n.builtinQuotaAdDismissed,
              _ => l10n.builtinQuotaAdFailed,
            };
          });
        }
        return;
      }
      final granted = await BuiltInAiQuota.instance.grantAdBonus();
      if (!mounted) return;
      if (!granted) {
        setState(() => _error = context.l10n.builtinQuotaAdsExhausted);
        return;
      }
      ref.invalidate(builtInQuotaProvider);
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Padding(
      padding: EdgeInsets.fromLTRB(
        AppTheme.pageHorizontal,
        8,
        AppTheme.pageHorizontal,
        24 + MediaQuery.paddingOf(context).bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            l10n.builtinQuotaTitle,
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.builtinQuotaBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _busy ? null : _watchAd,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.smart_display_rounded),
            label: Text(l10n.builtinQuotaWatchAd),
          ),
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: _busy
                ? null
                : () {
                    Navigator.of(context).pop(false);
                    context.push('/settings/providers');
                  },
            icon: const Icon(Icons.key_rounded),
            label: Text(l10n.builtinQuotaUseOwnProvider),
          ),
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: Text(l10n.commonDismiss),
          ),
        ],
      ),
    );
  }
}
