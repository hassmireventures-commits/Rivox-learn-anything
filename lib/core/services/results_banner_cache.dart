import 'dart:async';

import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../constants/ad_unit_ids.dart';
import 'ads_init_service.dart';
import 'ad_load_logger.dart';

/// Preloads the quiz-results adaptive banner while the user is taking a quiz
/// so the ad is ready when they reach the results screen.
class ResultsBannerCache {
  ResultsBannerCache._();

  static BannerAd? _banner;
  static AdSize? _size;
  static bool _loading = false;

  static bool get hasReadyAd => _banner != null && _size != null;

  static void invalidate() => disposeUnused();

  static Future<void> preload(double width) async {
    if (width <= 0 || _loading || hasReadyAd) return;
    if (!await AdsInitService.ensureCanRequestAds()) return;

    _loading = true;
    try {
      final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(width.truncate());
      if (size == null) return;

      final completer = Completer<void>();
      _banner?.dispose();
      _banner = null;
      _size = null;

      final banner = BannerAd(
        adUnitId: AdUnitIds.bannerAdUnitId,
        size: size,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            _banner = ad as BannerAd;
            _size = size;
            AdLoadLogger.logSuccess(
              'ResultsBannerCache',
              unitId: AdUnitIds.bannerAdUnitId,
            );
            if (!completer.isCompleted) completer.complete();
          },
          onAdFailedToLoad: (ad, error) {
            AdLoadLogger.logFailure('ResultsBannerCache', error);
            ad.dispose();
            if (!completer.isCompleted) completer.complete();
          },
        ),
      );
      banner.load();
      await completer.future.timeout(
        const Duration(seconds: 20),
        onTimeout: () {},
      );
    } finally {
      _loading = false;
    }
  }

  /// Transfers ownership of a preloaded banner to the results widget.
  static ({BannerAd ad, AdSize size})? take() {
    final ad = _banner;
    final size = _size;
    if (ad == null || size == null) return null;
    _banner = null;
    _size = null;
    return (ad: ad, size: size);
  }

  static void disposeUnused() {
    _banner?.dispose();
    _banner = null;
    _size = null;
    _loading = false;
  }
}
