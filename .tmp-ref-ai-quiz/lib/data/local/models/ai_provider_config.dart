import 'package:isar_community/isar.dart';

part 'ai_provider_config.g.dart';

@collection
class AiProviderConfig {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String name;

  /// openai | gemini | claude | grok | deepseek | openrouter | custom
  late String providerType;

  String? baseUrl;
  late String defaultModel;
  late bool isDefault;
  late DateTime createdAt;
}
