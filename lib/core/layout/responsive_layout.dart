import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

enum ScreenTier { compact, phone, tablet }

class ResponsiveLayout {
  const ResponsiveLayout(this.width, this.height);

  final double width;
  final double height;

  ScreenTier get tier {
    if (width >= 600) return ScreenTier.tablet;
    if (width < 360) return ScreenTier.compact;
    return ScreenTier.phone;
  }

  /// Delegates to [AppTheme.pagePadding] - single source of truth.
  EdgeInsets get pagePadding {
    final density = switch (tier) {
      ScreenTier.compact => ContentDensity.compact,
      ScreenTier.phone => ContentDensity.comfortable,
      ScreenTier.tablet => ContentDensity.spacious,
    };
    return AppTheme.pagePadding(density);
  }

  /// Delegates to [AppTheme.sectionGap] - single source of truth.
  double get sectionGap {
    final density = switch (tier) {
      ScreenTier.compact => ContentDensity.compact,
      ScreenTier.phone => ContentDensity.comfortable,
      ScreenTier.tablet => ContentDensity.spacious,
    };
    return AppTheme.sectionGap(density);
  }

  int get statsColumns => tier == ScreenTier.tablet ? 4 : 2;

  bool get useTwoColumn => width >= 700;
}

ResponsiveLayout responsiveLayoutOf(BuildContext context) {
  final size = MediaQuery.sizeOf(context);
  return ResponsiveLayout(size.width, size.height);
}
