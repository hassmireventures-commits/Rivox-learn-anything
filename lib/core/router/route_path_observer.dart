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
  void _update(Route<dynamic>? route) {
    currentRoutePath.value = route?.settings.name;
  }

  /// A modal bottom sheet / dialog is an unnamed overlay on top of whatever
  /// real page is underneath — it must never overwrite `currentRoutePath`
  /// with `null`, or it looks indistinguishable from genuinely resting on a
  /// shell tab (e.g. showing the global chat FAB over a reminder-setup sheet
  /// opened from onboarding, settings, or the dashboard). Only a route that
  /// carries a real `name:` (every actual page, per `_pushPage`/`_instantPage`
  /// in `app_router.dart`) is allowed to change the tracked path; an unnamed
  /// push/replace leaves it exactly as it was.
  void _updateIfNamed(Route<dynamic>? route) {
    if (route != null && route.settings.name == null) return;
    _update(route);
  }

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _updateIfNamed(route);

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _update(previousRoute);

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _update(previousRoute);

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) =>
      _updateIfNamed(newRoute);
}
