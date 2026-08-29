import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import 'ad_consent_service.dart';

/// Ensures the Mobile Ads SDK is initialized before any ad load request.
class AdsInitService {
  AdsInitService._();

  static Completer<void>? _initCompleter;
  static bool _initialized = false;

  static bool get isInitialized => _initialized;

  static Future<void> ensureMobileAdsInitialized() async {
    if (_initialized) return;
    if (_initCompleter != null) return _initCompleter!.future;
    final completer = Completer<void>();
    _initCompleter = completer;
    try {
      final initStatus = await MobileAds.instance.initialize();
      if (kDebugMode) {
        for (final entry in initStatus.adapterStatuses.entries) {
          debugPrint(
            '[AdMob] Adapter ${entry.key}: ${entry.value.state} '
            '${entry.value.description}',
          );
        }
      }
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(
          tagForChildDirectedTreatment: TagForChildDirectedTreatment.unspecified,
          maxAdContentRating: MaxAdContentRating.unspecified,
        ),
      );
      _initialized = true;
      completer.complete();
    } catch (e, st) {
      if (kDebugMode) {
        debugPrint('[AdMob] MobileAds.initialize failed: $e');
      }
      completer.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  /// SDK init (once) then UMP consent. Safe to call from bootstrap and widgets.
  static Future<bool> ensureCanRequestAds({bool forceConsentRetry = false}) async {
    if (forceConsentRetry) {
      AdConsentService.invalidateCachedDenial();
    }
    try {
      await ensureMobileAdsInitialized();
    } catch (_) {
      return false;
    }
    return AdConsentService.requestIfNeeded();
  }
}
