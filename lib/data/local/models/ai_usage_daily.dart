import 'package:isar_community/isar.dart';

part 'ai_usage_daily.g.dart';

@collection
class AiUsageDaily {
  Id id = Isar.autoIncrement;

  @Index()
  late String providerKey;

  @Index()
  late DateTime day;

  late int callCount;
  late int successCount;
  late int failureCount;
  late int rateLimitCount;
  late int promptTokens;
  late int completionTokens;
  late int lastLatencyMs;
}
