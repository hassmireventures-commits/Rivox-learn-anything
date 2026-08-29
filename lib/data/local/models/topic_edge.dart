import 'package:isar_community/isar.dart';

part 'topic_edge.g.dart';

@collection
class TopicEdge {
  Id id = Isar.autoIncrement;

  @Index()
  late String fromTopic;

  @Index()
  late String toTopic;

  /// related | prerequisite | weak_after
  late String relation;

  late double weight;
  late DateTime updatedAt;
}
