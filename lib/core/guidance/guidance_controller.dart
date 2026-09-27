import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'guidance_preferences_store.dart';

final guidancePreferencesProvider = FutureProvider<GuidancePreferences>((ref) async {
  return GuidancePreferencesStore.instance.load();
});

class GuidanceController extends Notifier<GuidancePreferences> {
  int _loadEpoch = 0;

  @override
  GuidancePreferences build() {
    _hydrate();
    return GuidancePreferencesStore.instance.current;
  }

  /// Loads disk prefs into [state]. A newer [_commit] or a later hydrate
  /// cancels an in-flight load so a dismiss is not overwritten by stale JSON.
  Future<void> _hydrate() async {
    final epoch = ++_loadEpoch;
    final loaded = await GuidancePreferencesStore.instance.load();
    if (epoch != _loadEpoch) return;
    state = loaded;
  }

  Future<void> refresh() => _hydrate();

  Future<void> _commit(GuidancePreferences next) async {
    _loadEpoch++;
    await GuidancePreferencesStore.instance.save(next);
    state = next;
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
    await _commit(next);
  }

  Future<void> resetWalkthrough() async {
    final next = GuidancePreferences(
      walkthroughCompletedAt: null,
      walkthroughVersion: 0,
      whatsNewSeenVersion: state.whatsNewSeenVersion,
      legalAcceptedVersion: state.legalAcceptedVersion,
      dismissedHintIds: state.dismissedHintIds,
    );
    await _commit(next);
  }

  Future<void> markWhatsNewSeen(String version) async {
    final next = GuidancePreferences(
      walkthroughCompletedAt: state.walkthroughCompletedAt,
      walkthroughVersion: state.walkthroughVersion,
      whatsNewSeenVersion: version,
      legalAcceptedVersion: state.legalAcceptedVersion,
      dismissedHintIds: state.dismissedHintIds,
    );
    await _commit(next);
  }

  Future<void> acceptLegal(String version) async {
    final next = GuidancePreferences(
      walkthroughCompletedAt: state.walkthroughCompletedAt,
      walkthroughVersion: state.walkthroughVersion,
      whatsNewSeenVersion: state.whatsNewSeenVersion,
      legalAcceptedVersion: version,
      dismissedHintIds: state.dismissedHintIds,
    );
    await _commit(next);
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
    await _commit(next);
  }
}

final guidanceControllerProvider =
    NotifierProvider<GuidanceController, GuidancePreferences>(GuidanceController.new);
