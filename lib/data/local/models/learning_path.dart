import 'package:isar_community/isar.dart';

part 'learning_path.g.dart';

@collection
class LearningPath {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;

  /// JSON list of topics in order
  late String topicsJson;

  /// active | completed | archived
  late String status;

  /// user | ai | ml
  late String source;

  late int currentIndex;
  late DateTime createdAt;
  DateTime? completedAt;
}
