import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/locale/app_localizations_ext.dart';
import '../../core/providers/app_providers.dart';
import '../../core/theme/app_theme.dart';
import 'native_ad_widget.dart';

/// Inline native ad for scrollable feeds — dismissible, remounts on ad refresh epoch.
class ScrollableNativeAdSlot extends ConsumerStatefulWidget {
  const ScrollableNativeAdSlot({super.key, required this.slotId});

  final String slotId;

  @override
  ConsumerState<ScrollableNativeAdSlot> createState() =>
      _ScrollableNativeAdSlotState();
}

class _ScrollableNativeAdSlotState extends ConsumerState<ScrollableNativeAdSlot> {
  bool _dismissed = false;

  @override
  Widget build(BuildContext context) {
    final epoch = ref.watch(adRefreshEpochProvider);
    ref.listen<int>(adRefreshEpochProvider, (previous, next) {
      if (previous != next && _dismissed) {
        setState(() => _dismissed = false);
      }
    });

    if (_dismissed) return const SizedBox.shrink();

    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppTheme.pageHorizontal,
        AppTheme.cardGap,
        AppTheme.pageHorizontal,
        AppTheme.cardGap,
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          NativeAdWidget(key: ValueKey('native_${widget.slotId}_$epoch')),
          Positioned(
            top: 6,
            right: 6,
            child: Material(
              color: theme.colorScheme.surface.withValues(alpha: 0.94),
              shape: const CircleBorder(),
              elevation: 2,
              shadowColor: Colors.black26,
              child: IconButton(
                tooltip: context.l10n.commonDismiss,
                icon: Icon(
                  Icons.close_rounded,
                  size: 20,
                  color: theme.colorScheme.onSurface,
                ),
                onPressed: () => setState(() => _dismissed = true),
                visualDensity: VisualDensity.compact,
                padding: const EdgeInsets.all(4),
                constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
              ),
            ),
          ),
        ],
      ),
    );
  }
}