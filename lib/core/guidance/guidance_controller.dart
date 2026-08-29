import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'guidance_preferences_store.dart';

final guidancePreferencesProvider = FutureProvider<GuidancePreferences>((ref) async {
  return GuidancePreferencesStore.instance.load();
});

class GuidanceController extends Notifier<GuidancePreferences> {
  @override
  GuidancePreferences build() {
    GuidancePreferencesStore.instance.load().then((p) {
      if (state.walkthroughVersion == 0 && p.walkthroughVersion > 0) {
        state = p;
      }
    });
    return GuidancePreferencesStore.instance.current;
  }

  Future<void> refresh() async {
    state = await GuidancePreferencesStore.instance.load();
  }

  bool get shouldShowWalkthrough {
    final v = state.walkthroughVersion;
    return v < GuidancePreferencesStore.currentWalkthroughVersion;
  }

  bool shouldShowWhatsNew(String appVersion) {
    return state.whatsNewSeenVersion != appVersion;
  }

  Future<void> completeWalkthrough() async {
    final next = GuidancePreferences(
      walkthroughCompletedAt: DateTime.now(),
      walkthroughVersion: GuidancePreferencesStore.currentWalkthroughVersion,
      whatsNewSeenVersion: state.whatsNewSeenVersion,
      legalAcceptedVersion: state.legalAcceptedVersion,
      dismissedHintIds: state.dismissedHintIds,
    );
    await GuidancePreferencesStore.instance.save(next);
    state = next;
  }

  Future<void> resetWalkthrough() async {
    final next = GuidancePreferences(
      walkthroughCompletedAt: null,
      walkthroughVersion: 0,
      whatsNewSeenVersion: state.whatsNewSeenVersion,
      legalAcceptedVersion: state.legalAcceptedVersion,
      dismissedHintIds: state.dismissedHintIds,
    );
    await GuidancePreferencesStore.instance.save(next);
    state = next;
  }

  Future<void> markWhatsNewSeen(String version) async {
    final next = GuidancePreferences(
      walkthroughCompletedAt: state.walkthroughCompletedAt,
      walkthroughVersion: state.walkthroughVersion,
      whatsNewSeenVersion: version,
      legalAcceptedVersion: state.legalAcceptedVersion,
      dismissedHintIds: state.dismissedHintIds,
    );
    await GuidancePreferencesStore.instance.save(next);
    state = next;
  }

  Future<void> acceptLegal(String version) async {
    final next = GuidancePreferences(
      walkthroughCompletedAt: state.walkthroughCompletedAt,
      walkthroughVersion: state.walkthroughVersion,
      whatsNewSeenVersion: state.whatsNewSeenVersion,
      legalAcceptedVersion: version,
      dismissedHintIds: state.dismissedHintIds,
    );
    await GuidancePreferencesStore.instance.save(next);
    state = next;
  }

  Future<void> dismissHint(String hintId) async {
    if (state.dismissedHintIds.contains(hintId)) return;
    final next = GuidancePreferences(
      walkthroughCompletedAt: state.walkthroughCompletedAt,
      walkthroughVersion: state.walkthroughVersion,
      whatsNewSeenVersion: state.whatsNewSeenVersion,
      legalAcceptedVersion: state.legalAcceptedVersion,
      dismissedHintIds: [...state.dismissedHintIds, hintId],
    );
    await GuidancePreferencesStore.instance.save(next);
    state = next;
  }
}

final guidanceControllerProvider =
    NotifierProvider<GuidanceController, GuidancePreferences>(GuidanceController.new);
