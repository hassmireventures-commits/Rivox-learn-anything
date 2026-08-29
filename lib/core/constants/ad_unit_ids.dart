import 'package:flutter/foundation.dart';

import 'app_constants.dart';

/// AdMob unit IDs — production in release/profile; Google test IDs in debug.
class AdUnitIds {
  AdUnitIds._();

  /// Official Google sample IDs (safe for dev/emulator; always fill in debug).
  static const String testAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';
  static const String testInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/1033173712';
  static const String testNativeAdUnitId =
      'ca-app-pub-3940256099942544/2247696110';
  static const String testRewardedAdUnitId =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testRewardedInterstitialAdUnitId =
      'ca-app-pub-3940256099942544/5354046379';

  static bool get usingTestAds => kDebugMode;

  static String get appId =>
      usingTestAds ? testAppId : AppConstants.prodAdmobAppId;

  static String get bannerAdUnitId =>
      usingTestAds ? testBannerAdUnitId : AppConstants.prodBannerAdUnitId;

  static String get interstitialAdUnitId => usingTestAds
      ? testInterstitialAdUnitId
      : AppConstants.prodInterstitialAdUnitId;

  static String get nativeAdUnitId =>
      usingTestAds ? testNativeAdUnitId : AppConstants.prodNativeAdUnitId;

  static String get rewardedAdUnitId => usingTestAds
      ? testRewardedAdUnitId
      : AppConstants.prodRewardedAdUnitId;

  static String get rewardedInterstitialAdUnitId => usingTestAds
      ? testRewardedInterstitialAdUnitId
      : AppConstants.prodRewardedInterstitialAdUnitId;

  static bool get hasRewardedAdUnitId => rewardedAdUnitId.isNotEmpty;

  static bool get hasRewardedInterstitialAdUnitId =>
      rewardedInterstitialAdUnitId.isNotEmpty;
}
