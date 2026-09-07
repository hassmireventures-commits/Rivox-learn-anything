import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/providers/app_providers.dart';
import '../../core/services/ad_service.dart';
import '../../core/services/built_in_chat_quota.dart';
import '../../core/theme/app_theme.dart';

/// Shown when chat's own daily message quota (independent from the
/// generation quota — see `BuiltInChatQuota`) is exhausted. Mirrors
/// `built_in_quota_dialog.dart`'s shape/flow exactly, targeting the chat
/// quota's own singleton + ad-bonus mechanic instead.
Future<bool> showBuiltInChatQuotaDialog(BuildContext context) async {
  final result = await showModalBottomSheet<bool>(
    context: context,
    showDragHandle: true,
    isScrollControlled: true,
    builder: (ctx) => const _BuiltInChatQuotaSheet(),
  );
  return result == true;
}

class _BuiltInChatQuotaSheet extends ConsumerStatefulWidget {
  const _BuiltInChatQuotaSheet();

  @override
  ConsumerState<_BuiltInChatQuotaSheet> createState() => _BuiltInChatQuotaSheetState();
}

class _BuiltInChatQuotaSheetState extends ConsumerState<_BuiltInChatQuotaSheet> {
  bool _busy = false;
  String? _error;

  Future<void> _watchAd() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final quota = await BuiltInChatQuota.instance.load();
      if (!quota.canWatchAd) {
        setState(() => _error = 'You\'ve used all of today\'s bonus ads for chat.');
        return;
      }
      final ads = ref.read(adServiceProvider);
      final result = await ads.showRewarded();
      if (result != RewardedAdResult.earned) {
        if (mounted) {
          setState(() {
            _error = switch (result) {
              RewardedAdResult.notConfigured => 'Ads aren\'t available right now.',
              RewardedAdResult.timeout => 'The ad took too long to load. Try again.',
              RewardedAdResult.dismissed => 'Ad closed early — watch the full ad to earn more messages.',
              _ => 'Couldn\'t show an ad. Try again.',
            };
          });
        }
        return;
      }
      final granted = await BuiltInChatQuota.instance.grantAdBonus();
      if (!mounted) return;
      if (!granted) {
        setState(() => _error = 'You\'ve used all of today\'s bonus ads for chat.');
        return;
      }
      Navigator.of(context).pop(true);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
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
            'Daily chat limit reached',
            style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            'You\'ve used today\'s free chat messages. Watch a short ad for more, '
            'or add your own AI provider for unlimited chat.',
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
            label: const Text('Watch ad for more messages'),
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
            label: const Text('Use your own provider'),
          ),
          TextButton(
            onPressed: _busy ? null : () => Navigator.of(context).pop(false),
            child: const Text('Dismiss'),
          ),
        ],
      ),
    );
  }
}
