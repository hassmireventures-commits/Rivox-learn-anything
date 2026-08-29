import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/ad_unit_ids.dart';
import '../../core/network/network_service.dart';
import '../../core/services/ad_load_logger.dart';
import '../../core/services/ads_init_service.dart';
import '../../core/services/ad_consent_service.dart';
import '../../core/services/results_banner_cache.dart';

/// Banner for quiz results. Preloaded during quiz play when possible.
/// Hides only when the device has no internet; keeps retrying while online.
class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key, this.forceFreshLoad = false});

  /// When true, skips the preload cache and always requests a new ad slot.
  final bool forceFreshLoad;

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  AdSize? _adSize;
  bool _loaded = false;
  bool _loading = false;
  bool _offline = false;
  int _attempts = 0;
  int _consentWaitAttempts = 0;
  Timer? _retryTimer;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySub;

  @override
  void initState() {
    super.initState();
    _connectivitySub = Connectivity().onConnectivityChanged.listen((_) {
      unawaited(_refreshConnectivity());
    });
    unawaited(_bootstrap());
  }

  Future<void> _bootstrap() async {
    await _refreshConnectivity();
    if (!mounted || _offline) return;

    if (widget.forceFreshLoad) {
      ResultsBannerCache.invalidate();
    } else {
      final cached = ResultsBannerCache.take();
      if (cached != null) {
        setState(() {
          _bannerAd = cached.ad;
          _adSize = cached.size;
          _loaded = true;
          _loading = false;
        });
        return;
      }
    }

    if (!mounted || _offline) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _offline || _loaded || _loading) return;
      _scheduleLoad(MediaQuery.sizeOf(context).width);
    });
  }

  Future<void> _refreshConnectivity() async {
    final online = await NetworkService.instance.hasConnection();
    if (!mounted) return;
    final wasOffline = _offline;
    if (_offline == !online) return;
    setState(() {
      _offline = !online;
      if (online) {
        _attempts = 0;
        _consentWaitAttempts = 0;
      }
    });
    if (online && wasOffline && !_loaded && !_loading) {
      final width = MediaQuery.sizeOf(context).width;
      _scheduleLoad(width);
    }
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _connectivitySub?.cancel();
    _bannerAd?.dispose();
    super.dispose();
  }

  void _scheduleRetry(double width) {
    if (_offline || _loaded || !mounted) return;
    _retryTimer?.cancel();
    final delayMs = (1000 * (_attempts.clamp(1, 10))).clamp(1000, 15000);
    _retryTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted && !_loaded && !_offline && !_loading) {
        _scheduleLoad(width);
      }
    });
  }

  Future<void> _scheduleLoad(double width) async {
    if (_offline || width <= 0 || _loading || _loaded) return;

    final canRequest = await AdsInitService.ensureCanRequestAds(
      forceConsentRetry: _consentWaitAttempts >= 5,
    );
    if (!mounted || _offline) return;
    if (!canRequest) {
      if (_consentWaitAttempts < 20) {
        _consentWaitAttempts++;
        _retryTimer?.cancel();
        _retryTimer = Timer(Duration(seconds: 2 * _consentWaitAttempts.clamp(1, 5)), () {
          if (mounted && !_loaded && !_offline) _scheduleLoad(width);
        });
      } else {
        AdConsentService.invalidateCachedDenial();
        _scheduleRetry(width);
      }
      return;
    }
    _consentWaitAttempts = 0;

    _loading = true;
    _attempts++;
    if (mounted) setState(() {});

    final size = await AdSize.getLargeAnchoredAdaptiveBannerAdSize(
      width.truncate(),
    );
    if (!mounted || _offline) {
      _loading = false;
      return;
    }
    if (size == null) {
      _loading = false;
      if (mounted) setState(() {});
      _scheduleRetry(width);
      return;
    }
    _adSize = size;

    final banner = BannerAd(
      adUnitId: AdUnitIds.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (!mounted) {
            ad.dispose();
            return;
          }
          AdLoadLogger.logSuccess(
            'BannerAd',
            unitId: AdUnitIds.bannerAdUnitId,
          );
          setState(() {
            _bannerAd?.dispose();
            _bannerAd = ad as BannerAd;
            _loaded = true;
            _loading = false;
          });
        },
        onAdFailedToLoad: (ad, error) {
          AdLoadLogger.logFailure('BannerAd', error);
          ad.dispose();
          if (!mounted) return;
          setState(() {
            _bannerAd = null;
            _loaded = false;
            _loading = false;
          });
          if (!_offline) _scheduleRetry(width);
        },
      ),
    );

    _bannerAd?.dispose();
    _bannerAd = banner;
    banner.load();
  }

  @override
  Widget build(BuildContext context) {
    if (_offline) return const SizedBox.shrink();

    final width = MediaQuery.sizeOf(context).width;
    if (!_loaded && !_loading) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scheduleLoad(width);
      });
    }

    if (_loaded && _bannerAd != null) {
      final height = _adSize!.height.toDouble();
      return ColoredBox(
        color: Theme.of(context).colorScheme.surface,
        child: SizedBox(
          height: height,
          width: double.infinity,
          child: Center(
            child: SizedBox(
              width: _bannerAd!.size.width.toDouble(),
              height: height,
              child: AdWidget(ad: _bannerAd!),
            ),
          ),
        ),
      );
    }

    // Online but still loading — reserve space, no placeholder text.
    final height = (_adSize ?? AdSize.banner).height.toDouble();
    return SizedBox(
      height: height,
      width: double.infinity,
      child: _loading
          ? const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          : null,
    );
  }
}
