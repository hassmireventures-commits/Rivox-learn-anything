import 'package:flutter/material.dart';

/// Subtle slide-up + fade transition used for pushed routes on Android.
/// Mimics Material 3 "forward" motion while staying lightweight.
class SlideUpPageTransitionsBuilder extends PageTransitionsBuilder {
  const SlideUpPageTransitionsBuilder();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeOutCubic;
    final fade = CurvedAnimation(parent: animation, curve: curve);
    final slide = Tween<Offset>(
      begin: const Offset(0, 0.04),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(position: slide, child: child),
    );
  }
}
