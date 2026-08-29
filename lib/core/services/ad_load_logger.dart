import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Structured AdMob load failure logging for banner/native/interstitial.
class AdLoadLogger {
  AdLoadLogger._();

  /// Human-readable label for [LoadAdError.code] (Android/iOS AdMob SDK).
  static String codeLabel(int code) {
    return switch (code) {
      0 => 'INTERNAL_ERROR',
      1 => 'INVALID_REQUEST',
      2 => 'NETWORK_ERROR',
      3 => 'NO_FILL',
      4 => 'APP_ID_MISSING',
      8 => 'AD_ALREADY_USED',
      9 => 'MEDIATION_NO_FILL',
      _ => 'UNKNOWN($code)',
    };
  }

  static String describe(String placement, LoadAdError error) {
    final response = error.responseInfo?.responseId;
    final responseBit =
        response != null && response.isNotEmpty ? ' responseId=$response' : '';
    return '$placement ${codeLabel(error.code)} '
        '(code=${error.code}, domain=${error.domain}): ${error.message}'
        '$responseBit';
  }

  static void logFailure(String placement, LoadAdError error) {
    if (!kDebugMode) return;
    debugPrint('[AdMob] ${describe(placement, error)}');
  }

  static void logSuccess(String placement, {String? unitId}) {
    if (!kDebugMode) return;
    final unit = unitId != null ? ' unit=$unitId' : '';
    debugPrint('[AdMob] $placement loaded$unit');
  }
}
