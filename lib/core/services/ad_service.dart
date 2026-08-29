import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_unit_ids.dart';

/// Manages ad loading and display.
///
/// Extends [ChangeNotifier] so that Riverpod's [ChangeNotifierProvider] can
/// rebuild any widget that watches [adServiceProvider] whenever ad readiness
/// changes (e.g. when an interstitial finishes loading).
///
/// Call [notifySdkReady] once [MobileAds.instance.initialize()] has completed
/// so that any live [AdService] instance starts loading ads.
class AdService extends ChangeNotifier {
  AdService();

  // Allows app_bootstrap.dart to trigger ad loading without needing a
  // Riverpod ref at bootstrap time.
  static final List<AdService> _instances = [];

  static void notifySdkReady() {
    for (final instance in _instances) {
      if (!instance._loadingInterstitial && !instance._interstitialReady) {
        instance.onSdkReady();
      }
    }
  }

  InterstitialAd? _interstitialAd;
  bool _loadingInterstitial = false;
  bool _interstitialReady = false;

  bool get loadingInterstitial => _loadingInterstitial;
  bool get interstitialReady => _interstitialReady;

  RewardedAd? _rewardedAd;
  RewardedInterstitialAd? _rewardedInterstitialAd;
  bool _loadingRewarded = false;
  bool _rewardedReady = false;

  bool get loadingRewarded => _loadingRewarded;
  bool get rewardedReady => _rewardedReady;

  BannerAd? _bannerAd;
  bool _bannerReady = false;
  bool get bannerReady => _bannerReady;

  @override
  void dispose() {
    _instances.remove(this);
    _interstitialAd?.dispose();
    _rewardedAd?.dispose();
    _rewardedInterstitialAd?.dispose();
    _bannerAd?.dispose();
    _interstitialAd = null;
    _rewardedAd = null;
    _rewardedInterstitialAd = null;
    _bannerAd = null;
    super.dispose();
  }

  /// Register this instance so [notifySdkReady] can reach it.
  /// Called once from [adServiceProvider] after construction.
  void init() {
    _instances.add(this);
  }

  /// Call this once MobileAds.instance.initialize() has completed.
  void onSdkReady() {
    _debugLog('AdService: SDK ready - loading interstitial + rewarded interstitial');
    loadInterstitial();
    loadRewarded();
  }

  void loadInterstitial({VoidCallback? onReady, VoidCallback? onFailed}) {
    if (_loadingInterstitial) return;
    _setLoadingInterstitial(true);
    _setInterstitialReady(false);

    InterstitialAd.load(
      adUnitId: AdUnitIds.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd?.dispose();
          _interstitialAd = ad;
          _debugLog('AdService: Interstitial loaded');
          _setLoadingInterstitial(false);
          _setInterstitialReady(true);
          onReady?.call();
        },
        onAdFailedToLoad: (error) {
          _debugLog('AdService: Interstitial failed - ${error.code}: ${error.message}');
          _setLoadingInterstitial(false);
          _setInterstitialReady(false);
          onFailed?.call();
        },
      ),
    );
  }

  Future<bool> showInterstitial({VoidCallback? onDismissed}) async {
    var ad = _interstitialAd;
    if (ad == null) {
      if (!_loadingInterstitial) {
        loadInterstitial();
      }
      final deadline = DateTime.now().add(const Duration(seconds: 12));
      while (DateTime.now().isBefore(deadline) && _interstitialAd == null) {
        if (!_loadingInterstitial && _interstitialAd == null) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      ad = _interstitialAd;
      if (ad == null) {
        loadInterstitial();
        return false;
      }
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        _setInterstitialReady(false);
        loadInterstitial();
        onDismissed?.call();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _debugLog('AdService: Interstitial failed to show - ${error.message}');
        ad.dispose();
        _interstitialAd = null;
        _setInterstitialReady(false);
        loadInterstitial();
      },
    );

    await ad.show();
    _setInterstitialReady(false);
    return true;
  }

  void loadRewarded({VoidCallback? onReady, VoidCallback? onFailed}) {
    if (_loadingRewarded) return;
    if (!AdUnitIds.hasRewardedInterstitialAdUnitId &&
        !AdUnitIds.hasRewardedAdUnitId) {
      _debugLog('AdService: Rewarded skipped - no production rewarded unit');
      _loadingRewarded = false;
      _rewardedReady = false;
      notifyListeners();
      onFailed?.call();
      return;
    }
    _loadingRewarded = true;
    _rewardedReady = false;
    notifyListeners();

    // AI Providers / quota unlock: production rewarded interstitial first.
    if (AdUnitIds.hasRewardedInterstitialAdUnitId) {
      RewardedInterstitialAd.load(
        adUnitId: AdUnitIds.rewardedInterstitialAdUnitId,
        request: const AdRequest(),
        rewardedInterstitialAdLoadCallback: RewardedInterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _rewardedInterstitialAd?.dispose();
            _rewardedInterstitialAd = ad;
            _debugLog('AdService: Rewarded interstitial loaded');
            _loadingRewarded = false;
            _rewardedReady = true;
            notifyListeners();
            onReady?.call();
          },
          onAdFailedToLoad: (error) {
            _debugLog(
              'AdService: Rewarded interstitial failed - ${error.code}: ${error.message}',
            );
            _loadRewardedFallback(onReady: onReady, onFailed: onFailed);
          },
        ),
      );
      return;
    }
    _loadRewardedFallback(onReady: onReady, onFailed: onFailed);
  }

  void _loadRewardedFallback({VoidCallback? onReady, VoidCallback? onFailed}) {
    if (!AdUnitIds.hasRewardedAdUnitId) {
      _loadingRewarded = false;
      _rewardedReady = false;
      notifyListeners();
      onFailed?.call();
      return;
    }
    RewardedAd.load(
      adUnitId: AdUnitIds.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd?.dispose();
          _rewardedAd = ad;
          _debugLog('AdService: Rewarded loaded');
          _loadingRewarded = false;
          _rewardedReady = true;
          notifyListeners();
          onReady?.call();
        },
        onAdFailedToLoad: (error) {
          _debugLog('AdService: Rewarded failed - ${error.code}: ${error.message}');
          _loadingRewarded = false;
          _rewardedReady = false;
          notifyListeners();
          onFailed?.call();
        },
      ),
    );
  }

  /// Shows a production rewarded interstitial (AI Providers / quota unlock).
  /// Falls back to the production rewarded unit if that format does not fill.
  Future<RewardedAdResult> showRewarded() async {
    if (!AdUnitIds.hasRewardedInterstitialAdUnitId &&
        !AdUnitIds.hasRewardedAdUnitId) {
      return RewardedAdResult.notConfigured;
    }

    if (_rewardedInterstitialAd == null && _rewardedAd == null) {
      if (!_loadingRewarded) {
        loadRewarded();
      }
      final deadline = DateTime.now().add(const Duration(seconds: 12));
      while (DateTime.now().isBefore(deadline) &&
          _rewardedInterstitialAd == null &&
          _rewardedAd == null) {
        if (!_loadingRewarded &&
            _rewardedInterstitialAd == null &&
            _rewardedAd == null) {
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 200));
      }
      if (_rewardedInterstitialAd == null && _rewardedAd == null) {
        return DateTime.now().isAfter(deadline)
            ? RewardedAdResult.timeout
            : RewardedAdResult.loadFailed;
      }
    }

    if (_rewardedInterstitialAd != null) {
      return _showLoadedRewardedInterstitial();
    }
    return _showLoadedRewarded();
  }

  Future<RewardedAdResult> _showLoadedRewardedInterstitial() async {
    final ad = _rewardedInterstitialAd;
    if (ad == null) return RewardedAdResult.loadFailed;
    final completer = Completer<RewardedAdResult>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedInterstitialAd = null;
        _rewardedReady = false;
        notifyListeners();
        loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(
            earned ? RewardedAdResult.earned : RewardedAdResult.dismissed,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _debugLog(
          'AdService: Rewarded interstitial failed to show - ${error.message}',
        );
        ad.dispose();
        _rewardedInterstitialAd = null;
        _rewardedReady = false;
        notifyListeners();
        loadRewarded();
        if (!completer.isCompleted) completer.complete(RewardedAdResult.loadFailed);
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
      },
    );
    _rewardedReady = false;
    notifyListeners();
    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => earned ? RewardedAdResult.earned : RewardedAdResult.timeout,
    );
  }

  Future<RewardedAdResult> _showLoadedRewarded() async {
    final ad = _rewardedAd;
    if (ad == null) return RewardedAdResult.loadFailed;
    final completer = Completer<RewardedAdResult>();
    var earned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _rewardedAd = null;
        _rewardedReady = false;
        notifyListeners();
        loadRewarded();
        if (!completer.isCompleted) {
          completer.complete(
            earned ? RewardedAdResult.earned : RewardedAdResult.dismissed,
          );
        }
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        _debugLog('AdService: Rewarded failed to show - ${error.message}');
        ad.dispose();
        _rewardedAd = null;
        _rewardedReady = false;
        notifyListeners();
        loadRewarded();
        if (!completer.isCompleted) completer.complete(RewardedAdResult.loadFailed);
      },
    );

    await ad.show(
      onUserEarnedReward: (ad, reward) {
        earned = true;
      },
    );
    _rewardedReady = false;
    notifyListeners();
    return completer.future.timeout(
      const Duration(minutes: 5),
      onTimeout: () => earned ? RewardedAdResult.earned : RewardedAdResult.timeout,
    );
  }

  BannerAd? loadBanner({
    required void Function(BannerAd ad) onLoaded,
    VoidCallback? onFailed,
  }) {
    _bannerAd?.dispose();
    _setBannerReady(false);
    final ad = BannerAd(
      adUnitId: AdUnitIds.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          _debugLog('AdService: Banner loaded');
          _setBannerReady(true);
          onLoaded(ad as BannerAd);
        },
        onAdFailedToLoad: (ad, error) {
          _debugLog('AdService: Banner failed - ${error.code}: ${error.message}');
          ad.dispose();
          _setBannerReady(false);
          onFailed?.call();
        },
      ),
    );
    _bannerAd = ad;
    ad.load();
    return ad;
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  void _setLoadingInterstitial(bool value) {
    if (_loadingInterstitial == value) return;
    _loadingInterstitial = value;
    notifyListeners();
  }

  void _setInterstitialReady(bool value) {
    if (_interstitialReady == value) return;
    _interstitialReady = value;
    notifyListeners();
  }

  void _setBannerReady(bool value) {
    if (_bannerReady == value) return;
    _bannerReady = value;
    notifyListeners();
  }

  static void _debugLog(String message) {
    if (kDebugMode) debugPrint(message);
  }
}

/// Outcome of [AdService.showRewarded] for unlock UX messaging.
enum RewardedAdResult {
  earned,
  dismissed,
  notConfigured,
  timeout,
  loadFailed,
}
