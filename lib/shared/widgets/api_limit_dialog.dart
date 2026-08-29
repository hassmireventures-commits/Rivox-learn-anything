import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/error/app_exception.dart';
import '../../core/locale/app_localizations_ext.dart';
import '../../core/theme/app_theme.dart';
import '../../data/remote/ai/provider_error_mapper.dart';
import '../../l10n/app_localizations.dart';
import 'built_in_quota_dialog.dart';

Future<void> showApiLimitDialog(
  BuildContext context,
  RateLimitException error, {
  bool hasFallback = false,
  VoidCallback? onUseFallback,
  VoidCallback? onDismissed,
}) {
  final l10n = context.l10n;
  return showGeneralDialog<void>(
    context: context,
    barrierDismissible: true,
    barrierLabel: l10n.apiLimitBarrierLabel,
    barrierColor: Colors.black54,
    transitionDuration: AppTheme.motionMedium,
    pageBuilder: (context, animation, secondaryAnimation) {
      return _ApiLimitDialogBody(
        error: error,
        hasFallback: hasFallback,
        onUseFallback: onUseFallback,
        onDismissed: onDismissed,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(parent: animation, curve: Curves.easeOutBack);
      return FadeTransition(
        opacity: animation,
        child: ScaleTransition(scale: Tween<double>(begin: 0.85, end: 1).animate(curve), child: child),
      );
    },
  ).whenComplete(() {
    onDismissed?.call();
  });
}

Future<void> showAppErrorDialog(
  BuildContext context,
  Object error, {
  Future<void> Function()? onRateLimitDismissed,
  bool hasFallback = false,
  VoidCallback? onUseFallback,
  VoidCallback? onRetry,
}) async {
  Object mapped = error;
  if (error is DioException) {
    mapped = ProviderErrorMapper.map(error);
  }
  if (mapped is RateLimitException) {
    await showApiLimitDialog(
      context,
      mapped,
      hasFallback: hasFallback,
      onUseFallback: onUseFallback,
      onDismissed: () {
        onRateLimitDismissed?.call();
      },
    );
    return;
  }
  if (mapped is BuiltInQuotaExceededException) {
    await showBuiltInQuotaDialog(context);
    return;
  }
  if (!context.mounted) return;
  final message = mapped is AppException
      ? mapped.message
      : 'Something went wrong. Please try again.';
  final l10n = context.l10n;
  await showDialog<void>(
    context: context,
    barrierDismissible: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return AlertDialog(
        title: Text(l10n.errorSomethingWentWrong),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(l10n.commonDismiss),
          ),
          if (onRetry != null)
            FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                onRetry();
              },
              child: Text(l10n.errorTryAgain),
            ),
        ],
        titleTextStyle: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: theme.colorScheme.onSurface,
        ),
        contentTextStyle: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.onSurface,
        ),
      );
    },
  );
}

class _ApiLimitDialogBody extends StatefulWidget {
  const _ApiLimitDialogBody({
    required this.error,
    required this.hasFallback,
    this.onUseFallback,
    this.onDismissed,
  });

  final RateLimitException error;
  final bool hasFallback;
  final VoidCallback? onUseFallback;
  final VoidCallback? onDismissed;

  @override
  State<_ApiLimitDialogBody> createState() => _ApiLimitDialogBodyState();
}

class _ApiLimitDialogBodyState extends State<_ApiLimitDialogBody> {
  late DateTime _until;
  Duration _remaining = Duration.zero;

  @override
  void initState() {
    super.initState();
    _until = widget.error.retryAfterUntil ??
        DateTime.now().add(widget.error.retryAfter ?? const Duration(minutes: 1));
    _tick();
  }

  void _tick() {
    setState(() {
      _remaining = _until.difference(DateTime.now());
      if (_remaining.isNegative) _remaining = Duration.zero;
    });
    if (_remaining > Duration.zero) {
      Future<void>.delayed(const Duration(seconds: 1), () {
        if (mounted) _tick();
      });
    }
  }

  String _format(AppLocalizations l10n, Duration d) {
    final m = d.inMinutes;
    final s = d.inSeconds % 60;
    if (m > 0) return l10n.durationMinutesSeconds(m, s);
    return l10n.durationSecondsOnly(s);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final theme = Theme.of(context);
    return Center(
      child: Material(
        color: Colors.transparent,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppTheme.cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.accentOrange.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.speed_rounded, size: 40, color: AppTheme.accentOrange),
              ),
              const SizedBox(height: 16),
              Text(
                l10n.apiLimitTitle,
                style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                widget.error.providerName,
                style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
              ),
              const SizedBox(height: 12),
              Text(
                widget.error.message,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodyMedium,
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _remaining > Duration.zero
                      ? l10n.apiLimitTryAgainIn(_format(l10n, _remaining))
                      : l10n.apiLimitTryAgainNow,
                  style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.push('/settings/providers');
                  },
                  icon: const Icon(Icons.add_circle_outline_rounded),
                  label: Text(l10n.apiLimitAddProvider),
                ),
              ),
              if (widget.hasFallback && widget.onUseFallback != null) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      widget.onUseFallback!();
                    },
                    child: Text(l10n.apiLimitUseFallback),
                  ),
                ),
              ],
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: Text(l10n.commonDismiss),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
