import 'package:isar_community/isar.dart';

part 'prompt_strategy.g.dart';

@collection
class PromptStrategy {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String strategyId;

  late String label;
  late double weight;
  late int attempts;
  late int successes;
  late double successRate;
  late DateTime updatedAt;
}
