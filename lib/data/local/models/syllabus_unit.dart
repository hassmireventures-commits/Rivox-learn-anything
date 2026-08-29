import 'package:isar_community/isar.dart';

part 'syllabus_unit.g.dart';

@collection
class SyllabusUnit {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String syllabusUuid;

  late String title;

  late int orderIndex;

  /// Relative importance 0 - 1 (equal weights when bootstrapped).
  late double weight;

  /// Mastery 0 - 1, synced from TopicNode evidence.
  late double mastery;

  DateTime? lastPracticedAt;

  String? pathId;

  /// JSON list of topic keys that feed this unit.
  late String topicKeysJson;

  late DateTime updatedAt;
}
