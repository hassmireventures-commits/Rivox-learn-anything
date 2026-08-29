import 'package:isar_community/isar.dart';

part 'study_plan_item.g.dart';

@collection
class StudyPlanItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index()
  late String syllabusUuid;

  /// Calendar day (local midnight).
  @Index()
  late DateTime calendarDay;

  /// Focus unit - null for generic review blocks.
  String? unitUuid;

  late int plannedMinutes;

  late int completedMinutes;

  /// study | mock | review
  late String kind;

  late DateTime updatedAt;
}
