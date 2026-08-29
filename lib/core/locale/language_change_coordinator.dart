import 'package:flutter/material.dart';

import '../constants/supported_languages.dart';
import '../locale/app_localizations_ext.dart';
import 'locale_font_store.dart';

/// Confirm language change, optionally download script fonts, then apply.
class LanguageChangeCoordinator {
  LanguageChangeCoordinator._();

  /// Returns the code to apply, or null if the user cancelled / font download failed.
  static Future<String?> confirmAndPrepare(
    BuildContext context, {
    required String currentCode,
    required String nextCode,
  }) async {
    final normalized = SupportedLanguages.normalizeCode(nextCode);
    if (normalized == SupportedLanguages.normalizeCode(currentCode)) {
      return normalized;
    }

    final lang = SupportedLanguages.find(normalized);
    final label = lang == null
        ? normalized
        : '${lang.nativeName} (${lang.englishName})';
    final l10n = context.l10n;

    final change = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.languageChangeConfirmTitle),
        content: Text(l10n.languageChangeConfirmBody(label)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.languageChangeConfirmAction),
          ),
        ],
      ),
    );
    if (change != true || !context.mounted) return null;

    if (LocaleFontStore.needsScriptFont(normalized)) {
      final already = await LocaleFontStore.isReady(normalized);
      if (!already) {
        if (!context.mounted) return null;
        final download = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: Text(l10n.languageFontDownloadTitle),
            content: Text(l10n.languageFontDownloadBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text(l10n.commonCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                child: Text(l10n.languageFontDownloadAction),
              ),
            ],
          ),
        );
        if (download != true || !context.mounted) return null;
      }

      if (!context.mounted) return null;
      showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => PopScope(
          canPop: false,
          child: AlertDialog(
            content: Row(
              children: [
                const CircularProgressIndicator(),
                const SizedBox(width: 20),
                Expanded(child: Text(l10n.languageFontDownloadProgress)),
              ],
            ),
          ),
        ),
      );

      final ok = await LocaleFontStore.preloadFor(normalized);
      if (context.mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!ok) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(l10n.languageFontDownloadFailed)),
          );
        }
        return null;
      }
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.languageFontDownloadSuccess)),
        );
      }
    }

    return normalized;
  }
}
