class AppConstants {
  static const String appName = 'Rivox';
  static const String appFullTitle = 'Rivox - The AI App for Learning Anything';
  static const String organizationName = 'Hassmire Ventures';
  static const String organizationTagline = 'The AI App for Learning Anything';
  static const String brandingLogoAsset = 'assets/branding/rivox_logo.png';
  static const String featureGraphicAsset = 'assets/branding/rivox_feature_graphic.png';
  static const String organizationLogoAsset = 'assets/branding/hassmire_logo.png';
  static const String appVersion = '1.0.5';
  static const String deepLinkScheme = 'learnanything';
  /// Official Play Store listing. Used in share/rate and challenge promo text.
  static const String playStoreUrl =
      'https://play.google.com/store/apps/details?id=com.aiquiz.ai_quiz_app';
  /// Hosted legal pages (Firebase Hosting). In-app copies live under assets/legal/.
  /// Switch back to https://learnanything.app/... after custom domain DNS is live.
  static const String privacyPolicyUrl =
      'https://learn-anything-43970.web.app/privacy';
  static const String termsUrl = 'https://learn-anything-43970.web.app/terms';
  static const String supportEmail = 'hassmireventures@gmail.com';
  static const List<String> defaultNavOrder = [
    'home',
    'learn',
    'history',
    'settings',
  ];
  static const String analyticsSalt = 'learn_anything_v1';

  // Production AdMob IDs (release/profile). Debug builds use [AdUnitIds] test IDs.
  static const String prodAdmobAppId = 'ca-app-pub-5325876102788151~7079657044';
  static const String prodBannerAdUnitId = 'ca-app-pub-5325876102788151/5482634804';
  static const String prodInterstitialAdUnitId = 'ca-app-pub-5325876102788151/3767097994';
  static const String prodNativeAdUnitId = 'ca-app-pub-5325876102788151/7017032152';
  /// Rewarded unit only — never reuse interstitial.
  static const String prodRewardedAdUnitId =
      'ca-app-pub-5325876102788151/6867257254';
  static const String prodRewardedInterstitialAdUnitId =
      'ca-app-pub-5325876102788151/5832808964';

  /// Legacy aliases — prefer [AdUnitIds].
  static const String admobAppId = prodAdmobAppId;
  static const String bannerAdUnitId = prodBannerAdUnitId;
  static const String interstitialAdUnitId = prodInterstitialAdUnitId;
  static const String nativeAdUnitId = prodNativeAdUnitId;
  static const String rewardedAdUnitId = prodRewardedAdUnitId;

  static const List<int> questionCounts = [5, 10, 15, 20];
  static const List<int> timerOptions = [15, 30, 45, 60, 90, 120];

  static const List<String> languages = [
    'English',
    'Tamil',
    'Hindi',
    'Telugu',
    'Bengali',
    'Malayalam',
    'Marathi',
    'Spanish',
    'French',
    'German',
    'Arabic',
    'Portuguese',
    'Chinese',
    'Japanese',
  ];

  static const int historyPageSize = 20;
}
