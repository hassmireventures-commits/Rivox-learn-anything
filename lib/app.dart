import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/constants/supported_languages.dart';
import 'core/providers/app_providers.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'l10n/app_localizations.dart';

class AiQuizApp extends ConsumerWidget {
  const AiQuizApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final locale = ref.watch(localeProvider);
    final langCode = locale.languageCode;
    final shipLocales = SupportedLanguages.all.map((l) => l.locale).toList();

    return MaterialApp.router(
      title: AppConstants.appName,
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(languageCode: langCode),
      darkTheme: AppTheme.dark(languageCode: langCode),
      themeMode: themeMode,
      locale: locale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: shipLocales,
      localeListResolutionCallback: (locales, supported) {
        // Prefer the explicit app locale (first in [locales] when MaterialApp.locale is set).
        for (final preferred in locales ?? const <Locale>[]) {
          for (final s in supported) {
            if (s.languageCode == preferred.languageCode) return s;
          }
        }
        return const Locale('en');
      },
      localeResolutionCallback: (preferred, supported) {
        if (preferred != null) {
          for (final s in supported) {
            if (s.languageCode == preferred.languageCode) return s;
          }
        }
        return const Locale('en');
      },
      routerConfig: appRouter,
    );
  }
}
