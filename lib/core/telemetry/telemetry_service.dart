import 'dart:convert';

import 'package:isar_community/isar.dart';
import 'package:uuid/uuid.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/telemetry_event.dart';

class TelemetryService {
  TelemetryService(this._isarService);

  final IsarService _isarService;
  final _uuid = const Uuid();
  String _sessionId = const Uuid().v4();

  Isar get _db => _isarService.db;

  void startSession() {
    _sessionId = _uuid.v4();
    emit('session_start');
  }

  Future<void> emit(String type, [Map<String, dynamic>? payload]) async {
    final event = TelemetryEvent()
      ..type = type
      ..payloadJson = jsonEncode(payload ?? {})
      ..sessionId = _sessionId
      ..timestamp = DateTime.now()
      ..synced = false;

    await _db.writeTxn(() async {
      await _db.telemetryEvents.put(event);
    });
  }

  Future<List<TelemetryEvent>> unsynced({int limit = 100}) async {
    return _db.telemetryEvents
        .filter()
        .syncedEqualTo(false)
        .sortByTimestamp()
        .limit(limit)
        .findAll();
  }

  Future<void> markSynced(List<int> ids) async {
    await _db.writeTxn(() async {
      for (final id in ids) {
        final event = await _db.telemetryEvents.get(id);
        if (event != null) {
          event.synced = true;
          await _db.telemetryEvents.put(event);
        }
      }
    });
  }

  Future<List<TelemetryEvent>> recent({int limit = 200}) async {
    return _db.telemetryEvents.where().sortByTimestampDesc().limit(limit).findAll();
  }
}
