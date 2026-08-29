import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/health_snapshot.dart';
import 'circuit_breaker.dart';

class HealthMonitor {
  HealthMonitor(this._isarService, this._circuitBreaker);

  final IsarService _isarService;
  final CircuitBreaker _circuitBreaker;

  final List<int> _latencies = [];
  int _errors = 0;
  int _total = 0;

  Isar get _db => _isarService.db;

  void record({required int latencyMs, required bool success}) {
    _total++;
    if (!success) _errors++;
    _latencies.add(latencyMs);
    if (_latencies.length > 50) _latencies.removeAt(0);
  }

  double get errorRate => _total == 0 ? 0 : _errors / _total;

  double get avgLatencyMs {
    if (_latencies.isEmpty) return 0;
    return _latencies.reduce((a, b) => a + b) / _latencies.length;
  }

  bool get degradeNonCriticalUi => errorRate > 0.35 || avgLatencyMs > 8000;

  Future<void> persist() async {
    final snap = HealthSnapshot()
      ..timestamp = DateTime.now()
      ..errorRate = errorRate
      ..avgLatencyMs = avgLatencyMs
      ..circuitStatesJson = jsonEncode(_circuitBreaker.snapshot())
      ..degradeNonCriticalUi = degradeNonCriticalUi;
    await _db.writeTxn(() async {
      await _db.healthSnapshots.put(snap);
    });
  }
}
