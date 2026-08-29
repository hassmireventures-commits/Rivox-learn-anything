import 'package:isar_community/isar.dart';

part 'ai_audit_event.g.dart';

@collection
class AiAuditEvent {
  Id id = Isar.autoIncrement;

  @Index()
  late String task;

  late String providerKey;
  late String strategyId;
  late int promptTokens;
  late int completionTokens;
  late int latencyMs;
  late bool success;
  late String policyVersion;

  /// JSON list of chunk IDs used for RAG
  String? ragChunkIdsJson;

  String? errorMessage;

  @Index()
  late DateTime timestamp;
}
