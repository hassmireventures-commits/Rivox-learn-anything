import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/locale/app_localizations_ext.dart';

/// Confirms before opening an external browser for provider API key pages.
Future<bool> confirmAndLaunchExternalUrl(
  BuildContext context, {
  required String providerName,
  required Uri url,
}) async {
  final l10n = context.l10n;
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(l10n.externalLinkTitle),
      content: Text(l10n.externalLinkBody(providerName)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(l10n.externalLinkContinue),
        ),
      ],
    ),
  );
  if (confirmed != true || !context.mounted) return false;

  final canLaunch = await canLaunchUrl(url);
  if (!canLaunch) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.externalLinkFailed)),
      );
    }
    return false;
  }
  await launchUrl(url, mode: LaunchMode.externalApplication);
  return true;
}
