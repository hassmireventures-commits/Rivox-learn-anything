import 'package:isar_community/isar.dart';

part 'topic_node.g.dart';

@collection
class TopicNode {
  Id id = Isar.autoIncrement;

  @Index(unique: true, caseSensitive: false)
  late String topic;

  late double strength;
  late int attempts;
  late int correctCount;
  late double totalTimeSeconds;
  DateTime? lastSeenAt;
  late DateTime updatedAt;
}
