import 'package:home_widget/home_widget.dart';

import '../constants/app_constants.dart';

/// B19 — Android home-screen widget showing the learner's current streak,
/// tapping through to Home. iOS WidgetKit is explicitly out of scope for
/// this v1 (per the backlog's own scoping), so this is a no-op on iOS —
/// `home_widget`'s Android channel calls simply return without effect on a
/// platform with no matching native provider registered.
///
/// Read-only glance data — this never writes anything back from the widget
/// into the app, and a failed update must never surface to the user (same
/// best-effort, catch-and-ignore convention as this app's other schedulers).
class HomeWidgetService {
  HomeWidgetService._();

  static const String _androidProviderName = 'StreakWidgetProvider';
  static const String _streakKey = 'currentStreak';
  static const String _deepLinkKey = 'deepLink';

  static Future<void> updateStreak(int currentStreak) async {
    try {
      await HomeWidget.saveWidgetData<int>(_streakKey, currentStreak);
      await HomeWidget.saveWidgetData<String>(
        _deepLinkKey,
        '${AppConstants.deepLinkScheme}://dashboard',
      );
      await HomeWidget.updateWidget(androidName: _androidProviderName);
    } catch (_) {
      // Best-effort; a missing/unpinned widget or platform without the
      // native provider must never surface an error to the user.
    }
  }
}
