import 'package:isar_community/isar.dart';

part 'telemetry_event.g.dart';

@collection
class TelemetryEvent {
  Id id = Isar.autoIncrement;

  @Index()
  late String type;

  late String payloadJson;
  late String sessionId;

  @Index()
  late DateTime timestamp;

  late bool synced;
}
