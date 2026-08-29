import 'package:isar_community/isar.dart';

part 'syllabus.g.dart';

@collection
class Syllabus {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String title;

  DateTime? examDate;

  /// user | ai
  late String source;

  late DateTime createdAt;
  late DateTime updatedAt;
}
