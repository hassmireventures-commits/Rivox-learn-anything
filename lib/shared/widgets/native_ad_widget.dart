import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../core/constants/ad_unit_ids.dart';
import '../../core/services/ad_consent_service.dart';
import '../../core/services/ad_load_logger.dart';
import '../../core/services/ads_init_service.dart';
import '../../core/theme/app_theme.dart';

/// Medium native template ad for bottom slots (History, results, reader, etc.).
class NativeAdWidget extends StatefulWidget {
  const NativeAdWidget({super.key});

  static const double slotHeight = 320;

  @override
  State createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends State<NativeAdWidget> {
  NativeAd? _nativeAd;
  bool _loaded = false;
  bool _loading = false;
  int _attempts = 0;
  int _consentWaitAttempts = 0;
  Timer? _retryTimer;

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  @override
  void dispose() {
    _retryTimer?.cancel();
    _nativeAd?.dispose();
    super.dispose();
  }

  void _scheduleRetry() {
    if (_loaded || !mounted) return;
    _retryTimer?.cancel();
    final delayMs = (1500 * (_attempts.clamp(1, 8))).clamp(1500, 12000);
    _retryTimer = Timer(Duration(milliseconds: delayMs), () {
      if (mounted && !_loaded && !_loading) unawaited(_load());
    });
  }

  Future<void> _load() async {
    if (_loading || _loaded || !mounted) return;

    final canRequest = await AdsInitService.ensureCanRequestAds(
      forceConsentRetry: _consentWaitAttempts >= 5,
    );
    if (!mounted) return;
    if (!canRequest) {
      if (_consentWaitAttempts < 15) {
        _consentWaitAttempts++;
        _scheduleRetry();
      } else {
        AdConsentService.invalidateCachedDenial();
        _consentWaitAttempts = 0;
        _scheduleRetry();
      }
      return;
    }
    _consentWaitAttempts = 0;

    _loading = true;
    _attempts++;
    if (mounted) setState(() {});

    _nativeAd?.dispose();
    final surface = Theme.of(context).colorScheme.surface;
    final ad = NativeAd(
      adUnitId: AdUnitIds.nativeAdUnitId,
      nativeAdOptions: NativeAdOptions(
        videoOptions: VideoOptions(startMuted: true),
      ),
      listener: NativeAdListener(
        onAdLoaded: (loaded) {
          if (!mounted) {
            loaded.dispose();
            return;
          }
          AdLoadLogger.logSuccess(
            'NativeAd',
            unitId: AdUnitIds.nativeAdUnitId,
          );
          setState(() {
            _nativeAd = loaded as NativeAd;
            _loaded = true;
            _loading = false;
          });
        },
        onAdFailedToLoad: (failed, error) {
          AdLoadLogger.logFailure('NativeAd', error);
          failed.dispose();
          if (!mounted) return;
          setState(() {
            _nativeAd = null;
            _loaded = false;
            _loading = false;
          });
          _scheduleRetry();
        },
      ),
      request: const AdRequest(),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: surface,
        cornerRadius: AppTheme.cardRadius,
      ),
    );
    _nativeAd = ad;
    ad.load();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final slot = SizedBox(
      height: NativeAdWidget.slotHeight,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppTheme.cardRadius),
        child: _loaded && _nativeAd != null
            ? AdWidget(ad: _nativeAd!)
            : Center(
                child: _loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        Icons.ads_click_outlined,
                        color: theme.colorScheme.onSurfaceVariant.withValues(
                          alpha: 0.35,
                        ),
                      ),
              ),
      ),
    );

    return slot;
  }
}
