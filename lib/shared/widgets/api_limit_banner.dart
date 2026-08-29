import 'dart:async';

import 'package:flutter/material.dart';

import '../../core/error/app_exception.dart';
import '../../core/locale/app_localizations_ext.dart';
import '../../core/theme/app_theme.dart';
import 'api_limit_dialog.dart';
import 'app_card.dart';

/// Home / dashboard banner with a live API rate-limit countdown.
class ApiLimitCountdownBanner extends StatefulWidget {
  const ApiLimitCountdownBanner({
    super.key,
    required this.providerName,
    required this.retryAfterUntil,
    this.onExpired,
  });

  final String providerName;
  final DateTime retryAfterUntil;
  final VoidCallback? onExpired;

  @override
  State<ApiLimitCountdownBanner> createState() => _ApiLimitCountdownBannerState();
}

class _ApiLimitCountdownBannerState extends State<ApiLimitCountdownBanner> {
  Timer? _timer;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _updateRemaining();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateRemaining());
  }

  @override
  void didUpdateWidget(covariant ApiLimitCountdownBanner oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.retryAfterUntil != widget.retryAfterUntil) {
      _updateRemaining();
    }
  }

  void _updateRemaining() {
    final next = widget.retryAfterUntil.difference(DateTime.now());
    final clamped = next.isNegative ? Duration.zero : next;
    if (!mounted) return;
    if (clamped == Duration.zero && _remaining > Duration.zero) {
      widget.onExpired?.call();
    }
    setState(() => _remaining = clamped);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_remaining <= Duration.zero) return const SizedBox.shrink();

    final l10n = context.l10n;
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.cardGap),
      child: AppCard(
        color: AppTheme.accentOrange.withValues(alpha: 0.12),
        onTap: () => showApiLimitDialog(
          context,
          RateLimitException(
            providerName: widget.providerName,
            retryAfter: _remaining,
          ),
        ),
        child: Row(
          children: [
            const Icon(Icons.speed_rounded, color: AppTheme.accentOrange),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                l10n.dashboardApiLimitBanner(
                  _remaining.inMinutes,
                  _remaining.inSeconds % 60,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
