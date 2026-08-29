import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../error/app_exception.dart';
import 'built_in_ai_config.dart';

class BuiltInAiQuotaSnapshot {
  const BuiltInAiQuotaSnapshot({
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

  /// Back-compat alias used by older call sites / UI.
  DateTime get dayStartedAt => periodStartedAt;

  int get allowance =>
      BuiltInAiConfig.freeGenerationsPerDay + bonus;

  int get remaining => (allowance - used).clamp(0, allowance);

  bool get canGenerate => remaining > 0;

  bool get canWatchAd =>
      adsWatched < BuiltInAiConfig.maxRewardedAdsPerDay;

  DateTime get periodEndsAt =>
      periodStartedAt.add(const Duration(hours: 24));

  bool get isExpired => DateTime.now().isAfter(periodEndsAt) ||
      DateTime.now().isAtSameMomentAs(periodEndsAt);
}

/// Local Built-in AI quota (not BYOK). Rolling 24h window from period start.
class BuiltInAiQuota {
  BuiltInAiQuota._();
  static final instance = BuiltInAiQuota._();

  BuiltInAiQuotaSnapshot? _cache;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/built_in_ai_quota.json');
  }

  BuiltInAiQuotaSnapshot _freshPeriod([DateTime? at]) {
    return BuiltInAiQuotaSnapshot(
      used: 0,
      bonus: 0,
      adsWatched: 0,
      periodStartedAt: at ?? DateTime.now(),
    );
  }

  Future<BuiltInAiQuotaSnapshot> load() async {
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
          final started = DateTime.tryParse(
                json['periodStartedAt'] as String? ?? '',
              ) ??
              DateTime.tryParse(json['day'] as String? ?? '');
          if (started != null) {
            final snap = BuiltInAiQuotaSnapshot(
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

  /// Explicit restore for Workmanager / app resume. Returns true if reset.
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
      return DateTime.tryParse(json['periodStartedAt'] as String? ?? '') ??
          DateTime.tryParse(json['day'] as String? ?? '');
    } catch (_) {
      return null;
    }
  }

  Future<void> _persist(BuiltInAiQuotaSnapshot snap) async {
    _cache = snap;
    final file = await _file();
    await file.writeAsString(
      jsonEncode({
        'periodStartedAt': snap.periodStartedAt.toIso8601String(),
        // Keep legacy key for older readers.
        'day': snap.periodStartedAt.toIso8601String(),
        'used': snap.used,
        'bonus': snap.bonus,
        'adsWatched': snap.adsWatched,
      }),
    );
  }

  Future<void> ensureCanGenerate() async {
    await restoreIfExpired();
    final snap = await load();
    if (!snap.canGenerate) {
      throw const BuiltInQuotaExceededException();
    }
  }

  Future<void> recordGeneration() async {
    final snap = await load();
    final next = BuiltInAiQuotaSnapshot(
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
      BuiltInAiQuotaSnapshot(
        used: snap.used,
        bonus: snap.bonus + BuiltInAiConfig.bonusPerRewardedAd,
        adsWatched: snap.adsWatched + 1,
        periodStartedAt: snap.periodStartedAt,
      ),
    );
    return true;
  }
}
