import 'package:ai_quiz_app/core/services/built_in_chat_quota.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BuiltInChatQuotaSnapshot allowance/rollover/bonus math', () {
    test('allowance is freeMessagesPerDay plus any bonus', () {
      final snap = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: DateTime.now(),
      );
      expect(snap.allowance, BuiltInChatQuota.freeMessagesPerDay);

      final withBonus = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: BuiltInChatQuota.bonusPerRewardedAd * 2,
        adsWatched: 2,
        periodStartedAt: DateTime.now(),
      );
      expect(
        withBonus.allowance,
        BuiltInChatQuota.freeMessagesPerDay + BuiltInChatQuota.bonusPerRewardedAd * 2,
      );
    });

    test('remaining is clamped between 0 and allowance', () {
      final under = BuiltInChatQuotaSnapshot(
        used: BuiltInChatQuota.freeMessagesPerDay - 1,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: DateTime.now(),
      );
      expect(under.remaining, 1);
      expect(under.canSend, isTrue);

      final exact = BuiltInChatQuotaSnapshot(
        used: BuiltInChatQuota.freeMessagesPerDay,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: DateTime.now(),
      );
      expect(exact.remaining, 0);
      expect(exact.canSend, isFalse);

      // Even if `used` somehow exceeds allowance, remaining never goes negative.
      final over = BuiltInChatQuotaSnapshot(
        used: BuiltInChatQuota.freeMessagesPerDay + 50,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: DateTime.now(),
      );
      expect(over.remaining, 0);
      expect(over.canSend, isFalse);
    });

    test('canWatchAd is false once maxRewardedAdsPerDay is reached', () {
      final beforeCap = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: 0,
        adsWatched: BuiltInChatQuota.maxRewardedAdsPerDay - 1,
        periodStartedAt: DateTime.now(),
      );
      expect(beforeCap.canWatchAd, isTrue);

      final atCap = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: 0,
        adsWatched: BuiltInChatQuota.maxRewardedAdsPerDay,
        periodStartedAt: DateTime.now(),
      );
      expect(atCap.canWatchAd, isFalse);
    });

    test('isExpired is false within the 24h window and true after it elapses', () {
      final fresh = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: DateTime.now(),
      );
      expect(fresh.isExpired, isFalse);

      final almostExpired = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: DateTime.now().subtract(const Duration(hours: 23, minutes: 59)),
      );
      expect(almostExpired.isExpired, isFalse);

      final expired = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: DateTime.now().subtract(const Duration(hours: 24, minutes: 1)),
      );
      expect(expired.isExpired, isTrue);
    });

    test('periodEndsAt is exactly 24h after periodStartedAt', () {
      final start = DateTime(2026, 1, 1, 12);
      final snap = BuiltInChatQuotaSnapshot(
        used: 0,
        bonus: 0,
        adsWatched: 0,
        periodStartedAt: start,
      );
      expect(snap.periodEndsAt, start.add(const Duration(hours: 24)));
    });
  });
}
