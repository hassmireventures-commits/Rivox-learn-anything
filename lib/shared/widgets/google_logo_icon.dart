import 'package:flutter/material.dart';

/// Google's official "Sign in with Google" icon-only mark (Android + Web,
/// Square, no baked-in text so our own localized label can sit next to it).
/// Swaps between the light/dark asset to match Google's own branding rules
/// for contrast against the surface it's drawn on.
class GoogleLogoIcon extends StatelessWidget {
  const GoogleLogoIcon({super.key, this.size = 20});

  final double size;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Image.asset(
      isDark
          ? 'assets/branding/google_signin_dark.png'
          : 'assets/branding/google_signin_light.png',
      width: size,
      height: size,
    );
  }
}
