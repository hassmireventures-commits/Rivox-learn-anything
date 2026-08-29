import 'package:isar_community/isar.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/ai_usage_daily.dart';
import '../models/provider_usage.dart';

class UsageTracker {
  UsageTracker(this._isar);

  final IsarService _isar;
  final Map<String, ProviderUsage> _cache = {};

  Isar get _db => _isar.db;

  Future<void> init() async {
    await _ensureTodayCacheHydrated();
  }

  Future<void> _ensureTodayCacheHydrated() async {
    if (_cache.isNotEmpty) return;
    final today = _todayStart();
    final rows = await _db.aiUsageDailys.filter().dayEqualTo(today).findAll();
    for (final row in rows) {
      _cache[row.providerKey] = ProviderUsage(providerKey: row.providerKey)
        ..callCountToday = row.callCount
        ..successCountToday = row.successCount
        ..failureCountToday = row.failureCount
        ..rateLimitCountToday = row.rateLimitCount
        ..promptTokensToday = row.promptTokens
        ..completionTokensToday = row.completionTokens
        ..lastLatencyMs = row.lastLatencyMs
        ..dayStartedAt = today;
    }
  }

  DateTime _todayStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _monthStart() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  ProviderUsage _getOrCreate(String providerKey) {
    var usage = _cache[providerKey];
    if (usage == null) {
      usage = ProviderUsage(providerKey: providerKey)
        ..callCountToday = 0
        ..dayStartedAt = _todayStart()
        ..lastLatencyMs = 0;
      _cache[providerKey] = usage;
      return usage;
    }
    final today = _todayStart();
    if (usage.dayStartedAt.isBefore(today)) {
      usage
        ..callCountToday = 0
        ..successCountToday = 0
        ..failureCountToday = 0
        ..rateLimitCountToday = 0
        ..promptTokensToday = 0
        ..completionTokensToday = 0
        ..dayStartedAt = today;
    }
    return usage;
  }

  Future<void> recordCall({
    required String providerKey,
    required int latencyMs,
    required bool success,
    int promptTokens = 0,
    int completionTokens = 0,
  }) async {
    const maxField = 50000;
    final safePrompt = promptTokens.clamp(0, maxField);
    final safeCompletion = completionTokens.clamp(0, maxField);
    final usage = _getOrCreate(providerKey);
    usage
      ..callCountToday += 1
      ..lastCallAt = DateTime.now()
      ..lastLatencyMs = latencyMs
      ..lastPromptTokens = safePrompt
      ..lastCompletionTokens = safeCompletion
      ..promptTokensToday += safePrompt
      ..completionTokensToday += safeCompletion;
    if (success) {
      usage.successCountToday += 1;
    } else {
      usage.failureCountToday += 1;
    }

    await _persistRow(providerKey, usage);
  }

  Future<void> _persistRow(String providerKey, ProviderUsage usage) async {
    final today = _todayStart();
    var row = await _db.aiUsageDailys
        .filter()
        .providerKeyEqualTo(providerKey)
        .dayEqualTo(today)
        .findFirst();
    row ??= AiUsageDaily()
      ..providerKey = providerKey
      ..day = today
      ..successCount = 0
      ..failureCount = 0
      ..rateLimitCount = 0;
    row
      ..callCount = usage.callCountToday
      ..successCount = usage.successCountToday
      ..failureCount = usage.failureCountToday
      ..rateLimitCount = usage.rateLimitCountToday
      ..promptTokens = usage.promptTokensToday
      ..completionTokens = usage.completionTokensToday
      ..lastLatencyMs = usage.lastLatencyMs;
    await _db.writeTxn(() async {
      await _db.aiUsageDailys.put(row!);
    });
  }

  Future<void> recordRateLimit({
    required String providerKey,
    Duration? retryAfter,
  }) async {
    final usage = _getOrCreate(providerKey);
    // Cap stickiness - Gemini free-tier Retry-After can be huge; keep UX usable.
    final capped = retryAfter == null
        ? const Duration(seconds: 60)
        : (retryAfter > const Duration(seconds: 60)
            ? const Duration(seconds: 60)
            : retryAfter);
    final until = DateTime.now().add(capped);
    usage
      ..lastRateLimitAt = DateTime.now()
      ..retryAfterUntil = until
      ..rateLimitCountToday += 1;
    await _persistRow(providerKey, usage);
  }

  /// Clears sticky rate-limit windows so the user can retry after dismissing the dialog.
  Future<void> clearActiveRateLimits() async {
    final now = DateTime.now();
    for (final entry in _cache.entries) {
      final until = entry.value.retryAfterUntil;
      if (until != null && until.isAfter(now)) {
        entry.value.retryAfterUntil = null;
        await _persistRow(entry.key, entry.value);
      }
    }
  }

  Future<List<ProviderUsage>> allUsage() async {
    await _ensureTodayCacheHydrated();
    return _cache.values.toList();
  }

  Future<int> totalTokensToday() async {
    var total = 0;
    for (final u in _cache.values) {
      total += u.promptTokensToday + u.completionTokensToday;
    }
    if (total > 0) return total;
    final today = _todayStart();
    final rows = await _db.aiUsageDailys.filter().dayEqualTo(today).findAll();
    for (final r in rows) {
      total += r.promptTokens + r.completionTokens;
    }
    return total;
  }

  Future<LlmUsageSummary> summaryForDay(DateTime day) async {
    final dayStart = DateTime(day.year, day.month, day.day);
    final rows = await _db.aiUsageDailys.filter().dayEqualTo(dayStart).findAll();
    return _aggregateRows(rows);
  }

  Future<LlmUsageSummary> summaryForCurrentMonth() async {
    final monthStart = _monthStart();
    final rows = await _db.aiUsageDailys
        .filter()
        .dayGreaterThan(monthStart.subtract(const Duration(days: 1)))
        .findAll();
    final monthRows = rows.where((r) => r.day.year == monthStart.year && r.day.month == monthStart.month);
    return _aggregateRows(monthRows);
  }

  LlmUsageSummary _aggregateRows(Iterable<AiUsageDaily> rows) {
    var requests = 0;
    var successes = 0;
    var failures = 0;
    var rateLimits = 0;
    var tokens = 0;
    var latencySum = 0;
    var latencyCount = 0;
    for (final r in rows) {
      requests += r.callCount;
      successes += r.successCount;
      failures += r.failureCount;
      rateLimits += r.rateLimitCount;
      tokens += r.promptTokens + r.completionTokens;
      if (r.lastLatencyMs > 0) {
        latencySum += r.lastLatencyMs;
        latencyCount += 1;
      }
    }
    return LlmUsageSummary(
      requestCount: requests,
      successCount: successes,
      failureCount: failures,
      rateLimitCount: rateLimits,
      totalTokens: tokens,
      avgLatencyMs: latencyCount == 0 ? 0 : latencySum ~/ latencyCount,
    );
  }

  Future<ProviderUsage?> forProvider(String providerKey) async {
    return _cache[providerKey];
  }

  Future<ProviderUsage?> activeRateLimit() async {
    final now = DateTime.now();
    for (final u in _cache.values) {
      final until = u.retryAfterUntil;
      if (until != null && until.isAfter(now)) return u;
    }
    return null;
  }

  Future<void> clearCache() async {
    _cache.clear();
  }
}
