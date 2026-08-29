import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../locale/locale_font_store.dart';
import 'slide_page_transitions.dart';

enum ContentDensity { compact, comfortable, spacious }

class AppTheme {
  static const Color seedColor = Color(0xFF6B5BFF);
  static const Color accentPink = Color(0xFFFF6B9D);
  static const Color accentTeal = Color(0xFF00B4D8);
  static const Color accentOrange = Color(0xFFFDCB6E);
  static const Color accentGreen = Color(0xFF00B894);
  static const Color accentBlue = Color(0xFF74B9FF);
  static const Color brandGold = Color(0xFFC9A962);

  // Dashboard-inspired palette (presentation layer).
  static const Color purpleStart = Color(0xFF00B4D8);
  static const Color purpleEnd = Color(0xFF9D4EDD);
  static const Color coralStart = Color(0xFFFF6B6B);
  static const Color coralEnd = Color(0xFFFFB199);
  static const Color charcoal = Color(0xFF2D3436);
  static const Color mutedSlate = Color(0xFF636E72);
  static const Color cardSurface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFDFCFF);
  static const Color sectionAccent = Color(0xFFFF7675);

  static const double dashboardCardRadius = 16;
  static const double wavyHeaderRadius = 36;
  static const double pageHorizontal = 24;
  static const double cardGap = 16;

  static const double cardRadius = 22;
  static const double buttonRadius = 16;

  static Color get scaffoldTint => Colors.blueGrey.withValues(alpha: 0.04);

  static const LinearGradient primaryPurpleGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [purpleStart, purpleEnd],
  );

  static const LinearGradient secondaryCoralGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [coralStart, coralEnd],
  );

  static const LinearGradient accentBlueGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF74B9FF), Color(0xFF81ECEC)],
  );

  static TextStyle sectionHeading({Color? color}) => GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: color ?? charcoal,
      );

  static TextStyle cardTitle({required bool onColoredCard}) => GoogleFonts.poppins(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: onColoredCard ? Colors.white : charcoal,
      );

  static TextStyle cardSubtitle({Color? color}) => GoogleFonts.poppins(
        fontSize: 13,
        fontWeight: FontWeight.normal,
        color: color ?? mutedSlate,
      );

  static TextStyle chipLabel({required Color color}) => GoogleFonts.poppins(
        fontSize: 11,
        fontWeight: FontWeight.bold,
        color: color,
      );

  static List<BoxShadow> bottomNavShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.10),
      blurRadius: 10,
      offset: const Offset(0, -2),
    ),
  ];
  static const Duration motionFast = Duration(milliseconds: 180);
  static const Duration motionMedium = Duration(milliseconds: 280);
  static const Duration motionSlow = Duration(milliseconds: 420);

  static EdgeInsets pagePadding(ContentDensity density) => switch (density) {
        ContentDensity.compact => const EdgeInsets.fromLTRB(14, 10, 14, 20),
        ContentDensity.comfortable => const EdgeInsets.fromLTRB(20, 16, 20, 28),
        ContentDensity.spacious => const EdgeInsets.fromLTRB(24, 20, 24, 36),
      };

  static double sectionGap(ContentDensity density) => switch (density) {
        ContentDensity.compact => 12,
        ContentDensity.comfortable => 20,
        ContentDensity.spacious => 28,
      };

  static ThemeData light({
    ContentDensity density = ContentDensity.comfortable,
    String? languageCode,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.light,
      primary: purpleStart,
      secondary: coralStart,
      tertiary: accentTeal,
    );
    return _build(colorScheme, Brightness.light, density, languageCode);
  }

  static ThemeData dark({
    ContentDensity density = ContentDensity.comfortable,
    String? languageCode,
  }) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: Brightness.dark,
      primary: purpleEnd,
      secondary: coralStart,
      tertiary: accentTeal,
    ).copyWith(
      // Stronger secondary text for Settings ExpansionTiles / captions.
      onSurfaceVariant: const Color(0xFFB8B4C8),
      surface: const Color(0xFF101018),
    );
    return _build(colorScheme, Brightness.dark, density, languageCode);
  }

  static ThemeData _build(
    ColorScheme colorScheme,
    Brightness brightness,
    ContentDensity density,
    String? languageCode,
  ) {
    final base = GoogleFonts.poppinsTextTheme(
      brightness == Brightness.light ? ThemeData.light().textTheme : ThemeData.dark().textTheme,
    );
    final textTheme = base.apply(
      fontFamilyFallback: LocaleFontStore.fallbackFamiliesFor(languageCode),
    );
    final verticalPad = switch (density) {
      ContentDensity.compact => 12.0,
      ContentDensity.comfortable => 16.0,
      ContentDensity.spacious => 18.0,
    };

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: brightness == Brightness.light
          ? const Color(0xFFF5F4FB)
          : const Color(0xFF101018),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: Colors.transparent,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          color: colorScheme.onSurface,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(cardRadius)),
        color: brightness == Brightness.light ? Colors.white : const Color(0xFF1A1A24),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 0,
          // No horizontal padding here - M3 defaults (24 / icon 16 - 24) stay intact.
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          minimumSize: Size(64, 40 + (verticalPad - 12) * 2),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          minimumSize: Size(64, 40 + (verticalPad - 12) * 2),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(buttonRadius)),
          textStyle: textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
          minimumSize: Size(64, 40 + (verticalPad - 12) * 2),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: brightness == Brightness.light
            ? colorScheme.surfaceContainerHighest.withValues(alpha: 0.45)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: verticalPad),
        labelStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        floatingLabelStyle: textTheme.bodySmall?.copyWith(color: colorScheme.primary),
        hintStyle: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurfaceVariant),
        prefixIconColor: colorScheme.onSurfaceVariant,
        suffixIconColor: colorScheme.onSurfaceVariant,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.outlineVariant),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.error, width: 2),
        ),
      ),
      chipTheme: ChipThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: colorScheme.onSurfaceVariant,
        textColor: colorScheme.onSurface,
        titleTextStyle: textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.w600,
          color: colorScheme.onSurface,
        ),
        subtitleTextStyle: textTheme.bodyMedium?.copyWith(
          fontWeight: FontWeight.w500,
          color: colorScheme.onSurfaceVariant,
        ),
      ),
      expansionTileTheme: ExpansionTileThemeData(
        textColor: colorScheme.onSurface,
        collapsedTextColor: colorScheme.onSurface,
        iconColor: colorScheme.onSurfaceVariant,
        collapsedIconColor: colorScheme.onSurfaceVariant,
        tilePadding: const EdgeInsets.symmetric(horizontal: 4),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: density == ContentDensity.compact ? 64 : 72,
        backgroundColor: brightness == Brightness.light ? cardSurface : const Color(0xFF1A1A24),
        indicatorColor: purpleStart.withValues(alpha: 0.15),
        labelTextStyle: WidgetStatePropertyAll(
          textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      // Tab switches (StatefulShellRoute) use NoTransitionPage directly in the
      // router, so shell tabs stay instant.  All pushed routes get a platform-
      // appropriate slide-up / cupertino-slide transition here.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: SlideUpPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
