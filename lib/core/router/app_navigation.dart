import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Paths that live inside the bottom-nav `StatefulShellRoute` (see
/// `app_router.dart`). These must be reached with `go`, never `push`: pushing
/// a shell branch from a root-level route (chat, settings, a quiz) builds a
/// second shell around the same branch `GlobalKey` navigator, which renders
/// the tab bar over a blank body.
const Set<String> kShellTabPaths = {'/dashboard', '/learn', '/history'};

/// True when [route] (query string allowed) targets a bottom-nav tab.
bool isShellTabRoute(String route) {
  final path = Uri.tryParse(route)?.path ?? route;
  return kShellTabPaths.contains(path);
}

/// Opens [route] the right way for its kind: switches tab for shell routes,
/// pushes everything else on top of the current stack.
void openAppRoute(BuildContext context, String route) {
  if (isShellTabRoute(route)) {
    context.go(route);
  } else {
    context.push(route);
  }
}
