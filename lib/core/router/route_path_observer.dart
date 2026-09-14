import 'package:flutter/widgets.dart';

/// The currently-topmost route's path (its `Page.name`, set to
/// `state.uri.toString()` by `_pushPage`/`_instantPage` in `app_router.dart`
/// — see those for why every page needs a real `name:`), or `null` when
/// nothing is pushed on top of the current shell tab (Home/Learn/History).
///
/// Reliable for BOTH imperative (`push`) and declarative (`go`) navigation,
/// unlike `appRouter.routerDelegate.currentConfiguration.uri`, which only
/// updates predictably for the latter — this observer hooks the underlying
/// `Navigator` directly (the same layer `FirebaseAnalyticsObserver` uses for
/// screen-view tracking), which fires for every push/pop regardless of how
/// it was triggered.
final ValueNotifier<String?> currentRoutePath = ValueNotifier<String?>(null);

class RoutePathObserver extends NavigatorObserver {
  /// Shadow copy of this navigator's route stack. Needed because a pop can
  /// reveal ANOTHER unnamed route, not the real underlying page — e.g. the
  /// notification-permission rationale dialog opens on top of the
  /// reminder-setup sheet (both unnamed); dismissing the dialog pops back to
  /// the sheet, not to `/welcome`. Naively using `previousRoute` directly (as
  /// an earlier version of this observer did) would read that sheet's own
  /// null name and incorrectly reset `currentRoutePath` to null. Walking this
  /// stack from the top down to the nearest *named* entry handles any depth
  /// of nested unnamed overlays, not just one.
  final List<Route<dynamic>> _stack = [];

  void _recompute() {
    for (final route in _stack.reversed) {
      final name = route.settings.name;
      if (name != null) {
        currentRoutePath.value = name;
        return;
      }
    }
    currentRoutePath.value = null;
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.add(route);
    _recompute();
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _recompute();
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _stack.remove(route);
    _recompute();
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (oldRoute != null) _stack.remove(oldRoute);
    if (newRoute != null) _stack.add(newRoute);
    _recompute();
  }
}
