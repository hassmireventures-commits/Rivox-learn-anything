import 'package:flutter_test/flutter_test.dart';

import 'package:ai_quiz_app/core/constants/ad_unit_ids.dart';
import 'package:ai_quiz_app/core/constants/app_constants.dart';
import 'package:flutter/foundation.dart';

void main() {
  group('Production AdMob IDs', () {
    test('app and unit IDs are baked production values', () {
      expect(
        AppConstants.prodAdmobAppId,
        'ca-app-pub-5325876102788151~7079657044',
      );
      expect(
        AppConstants.prodBannerAdUnitId,
        'ca-app-pub-5325876102788151/5482634804',
      );
      expect(
        AppConstants.prodInterstitialAdUnitId,
        'ca-app-pub-5325876102788151/3767097994',
      );
      expect(
        AppConstants.prodNativeAdUnitId,
        'ca-app-pub-5325876102788151/7017032152',
      );
      expect(
        AppConstants.prodRewardedAdUnitId,
        'ca-app-pub-5325876102788151/6867257254',
      );
      expect(
        AppConstants.prodRewardedInterstitialAdUnitId,
        'ca-app-pub-5325876102788151/5832808964',
      );
    });

    test('AdUnitIds resolve to production in release/profile', () {
      if (kDebugMode) return;
      expect(AdUnitIds.appId, AppConstants.prodAdmobAppId);
      expect(AdUnitIds.bannerAdUnitId, AppConstants.prodBannerAdUnitId);
      expect(
        AdUnitIds.interstitialAdUnitId,
        AppConstants.prodInterstitialAdUnitId,
      );
      expect(AdUnitIds.nativeAdUnitId, AppConstants.prodNativeAdUnitId);
      expect(AdUnitIds.rewardedAdUnitId, AppConstants.prodRewardedAdUnitId);
      expect(
        AdUnitIds.rewardedInterstitialAdUnitId,
        AppConstants.prodRewardedInterstitialAdUnitId,
      );
    });

    test('AdUnitIds use Google test IDs in debug', () {
      if (!kDebugMode) return;
      expect(AdUnitIds.usingTestAds, isTrue);
      expect(AdUnitIds.bannerAdUnitId, AdUnitIds.testBannerAdUnitId);
      expect(AdUnitIds.nativeAdUnitId, AdUnitIds.testNativeAdUnitId);
      expect(
        AdUnitIds.bannerAdUnitId,
        contains('ca-app-pub-3940256099942544'),
      );
    });

    test('AdUnitIds getters are wired', () {
      expect(AdUnitIds.hasRewardedAdUnitId, isTrue);
      expect(AdUnitIds.hasRewardedInterstitialAdUnitId, isTrue);
    });

    test('rewarded unit is not the interstitial unit', () {
      expect(
        AdUnitIds.rewardedAdUnitId,
        isNot(AdUnitIds.interstitialAdUnitId),
      );
    });

    test('no Google sample / test publisher IDs in production constants', () {
      const testPublisher = 'ca-app-pub-3940256099942544';
      expect(AppConstants.prodAdmobAppId.contains(testPublisher), isFalse);
      expect(AppConstants.prodBannerAdUnitId.contains(testPublisher), isFalse);
      expect(
        AppConstants.prodInterstitialAdUnitId.contains(testPublisher),
        isFalse,
      );
      expect(AppConstants.prodNativeAdUnitId.contains(testPublisher), isFalse);
      expect(AppConstants.prodRewardedAdUnitId.contains(testPublisher), isFalse);
      expect(
        AppConstants.prodRewardedInterstitialAdUnitId.contains(testPublisher),
        isFalse,
      );
    });

    test('Google test publisher IDs are defined for debug', () {
      expect(AdUnitIds.testBannerAdUnitId, contains('3940256099942544'));
      expect(AdUnitIds.testNativeAdUnitId, contains('3940256099942544'));
    });
  });
}
