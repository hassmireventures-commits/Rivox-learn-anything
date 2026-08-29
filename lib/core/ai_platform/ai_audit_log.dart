import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/ai_audit_event.dart';

class AiAuditLog {
  AiAuditLog(this._isarService);

  final IsarService _isarService;

  Isar get _db => _isarService.db;

  Future<void> record({
    required String task,
    required String providerKey,
    String strategyId = 'standard',
    int promptTokens = 0,
    int completionTokens = 0,
    int latencyMs = 0,
    bool success = true,
    required String policyVersion,
    List<String>? ragChunkIds,
    String? errorMessage,
  }) async {
    final event = AiAuditEvent()
      ..task = task
      ..providerKey = providerKey
      ..strategyId = strategyId
      ..promptTokens = promptTokens
      ..completionTokens = completionTokens
      ..latencyMs = latencyMs
      ..success = success
      ..policyVersion = policyVersion
      ..ragChunkIdsJson = ragChunkIds == null ? null : jsonEncode(ragChunkIds)
      ..errorMessage = errorMessage
      ..timestamp = DateTime.now();

    await _db.writeTxn(() async {
      await _db.aiAuditEvents.put(event);
    });
  }

  Future<List<AiAuditEvent>> recent({int limit = 100}) async {
    return _db.aiAuditEvents.where().sortByTimestampDesc().limit(limit).findAll();
  }

  Future<int> totalTokensToday() async {
    final start = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);
    final events = await _db.aiAuditEvents
        .filter()
        .timestampGreaterThan(start)
        .findAll();
    var total = 0;
    for (final e in events) {
      total += e.promptTokens + e.completionTokens;
    }
    return total;
  }
}
