import 'package:isar_community/isar.dart';

part 'career_skill.g.dart';

@collection
class CareerSkill {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String roleTitle;

  late String title;

  /// technical | behavioral | tool | domain
  late String category;

  /// Target proficiency 0 - 1.
  late double targetLevel;

  /// Current proficiency 0 - 1 (from TopicNode / drills).
  late double currentLevel;

  /// Topic string used to join TopicNode evidence.
  late String evidenceTopic;

  late int orderIndex;

  /// Optional relative weight; default 1.0.
  late double weight;

  late DateTime updatedAt;
}
