import 'package:isar_community/isar.dart';

part 'health_snapshot.g.dart';

@collection
class HealthSnapshot {
  Id id = Isar.autoIncrement;

  late DateTime timestamp;
  late double errorRate;
  late double avgLatencyMs;
  late String circuitStatesJson;
  late bool degradeNonCriticalUi;
}
