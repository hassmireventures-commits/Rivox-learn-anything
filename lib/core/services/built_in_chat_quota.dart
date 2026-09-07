import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../error/app_exception.dart';

class BuiltInChatQuotaSnapshot {
  const BuiltInChatQuotaSnapshot({
    required this.used,
    required this.bonus,
    required this.adsWatched,
    required this.periodStartedAt,
  });

  final int used;
  final int bonus;
  final int adsWatched;

  /// Start of the current rolling 24h allowance window.
  final DateTime periodStartedAt;

  int get allowance => BuiltInChatQuota.freeMessagesPerDay + bonus;

  int get remaining => (allowance - used).clamp(0, allowance);

  bool get canSend => remaining > 0;

  bool get canWatchAd => adsWatched < BuiltInChatQuota.maxRewardedAdsPerDay;

  DateTime get periodEndsAt => periodStartedAt.add(const Duration(hours: 24));

  bool get isExpired =>
      DateTime.now().isAfter(periodEndsAt) ||
      DateTime.now().isAtSameMomentAs(periodEndsAt);
}

/// Local Built-in AI **chat** quota (B1). Structurally mirrors
/// `BuiltInAiQuota` (rolling 24h window, persisted JSON sidecar, rewarded-ad
/// bonus) but is a fully independent counter with its own state file — it
/// never reads or writes `BuiltInAiQuota`'s (generation) state. BYOK
/// (non-Built-in) providers are never limited by this.
class BuiltInChatQuota {
  BuiltInChatQuota._();
  static final instance = BuiltInChatQuota._();

  /// Free chat messages before rewarded ads are needed, per rolling 24h window.
  static const int freeMessagesPerDay = 8;

  /// Bonus chat messages granted per successful rewarded ad.
  static const int bonusPerRewardedAd = 3;

  /// Max rewarded ads that grant a chat bonus per rolling window.
  static const int maxRewardedAdsPerDay = 3;

  BuiltInChatQuotaSnapshot? _cache;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/built_in_chat_quota.json');
  }

  BuiltInChatQuotaSnapshot _freshPeriod([DateTime? at]) {
    return BuiltInChatQuotaSnapshot(
      used: 0,
      bonus: 0,
      adsWatched: 0,
      periodStartedAt: at ?? DateTime.now(),
    );
  }

  Future<BuiltInChatQuotaSnapshot> load() async {
    final now = DateTime.now();
    if (_cache != null) {
      if (_cache!.isExpired) {
        _cache = null;
      } else {
        return _cache!;
      }
    }
    try {
      final file = await _file();
      if (file.existsSync()) {
        final json = jsonDecode(await file.readAsString());
        if (json is Map<String, dynamic>) {
          final started = DateTime.tryParse(json['periodStartedAt'] as String? ?? '');
          if (started != null) {
            final snap = BuiltInChatQuotaSnapshot(
              used: (json['used'] as num?)?.toInt() ?? 0,
              bonus: (json['bonus'] as num?)?.toInt() ?? 0,
              adsWatched: (json['adsWatched'] as num?)?.toInt() ?? 0,
              periodStartedAt: started,
            );
            if (!snap.isExpired) {
              _cache = snap;
              return snap;
            }
            // Period elapsed — persist a fresh window so background restore sticks.
            final fresh = _freshPeriod(now);
            await _persist(fresh);
            return fresh;
          }
        }
      }
    } catch (_) {}
    final fresh = _freshPeriod(now);
    await _persist(fresh);
    return fresh;
  }

  /// Explicit restore for app resume. Returns true if the window was reset.
  Future<bool> restoreIfExpired() async {
    _cache = null;
    final before = await _readRawPeriodStart();
    final snap = await load();
    if (before == null) return false;
    return snap.periodStartedAt.isAfter(before);
  }

  Future<DateTime?> _readRawPeriodStart() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return null;
      final json = jsonDecode(await file.readAsString());
      if (json is! Map<String, dynamic>) return null;
      return DateTime.tryParse(json['periodStartedAt'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(BuiltInChatQuotaSnapshot snap) async {
    _cache = snap;
    final file = await _file();
    await file.writeAsString(
      jsonEncode({
        'periodStartedAt': snap.periodStartedAt.toIso8601String(),
        'used': snap.used,
        'bonus': snap.bonus,
        'adsWatched': snap.adsWatched,
      }),
    );
  }

  Future<void> ensureCanSend() async {
    await restoreIfExpired();
    final snap = await load();
    if (!snap.canSend) {
      throw const BuiltInChatQuotaExceededException();
    }
  }

  Future<void> recordSent() async {
    final snap = await load();
    final next = BuiltInChatQuotaSnapshot(
      used: snap.used + 1,
      bonus: snap.bonus,
      adsWatched: snap.adsWatched,
      periodStartedAt: snap.periodStartedAt,
    );
    await _persist(next);
  }

  /// Returns true if bonus was granted.
  Future<bool> grantAdBonus() async {
    final snap = await load();
    if (!snap.canWatchAd) return false;
    await _persist(
      BuiltInChatQuotaSnapshot(
        used: snap.used,
        bonus: snap.bonus + bonusPerRewardedAd,
        adsWatched: snap.adsWatched + 1,
        periodStartedAt: snap.periodStartedAt,
      ),
    );
    return true;
  }
}
