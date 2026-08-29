import 'package:isar_community/isar.dart';

part 'learner_profile.g.dart';

@collection
class LearnerProfile {
  Id id = Isar.autoIncrement;

  /// beginner | intermediate | advanced
  late String layoutMode;

  /// compact | comfortable | spacious
  late String density;

  /// auto | beginner | intermediate | advanced (user override; auto = ML decides)
  late String layoutModeOverride;

  /// JSON list of goal topics
  late String goalsJson;

  int? dailyMinutesGoal;
  DateTime? examDate;

  /// quiz | interactive | article | video (preference weights as JSON map)
  late String preferredFormatsJson;

  /// Goal mode: 'learning' | 'exam_prep' | 'career'
  late String goalMode;

  /// Free-text context for the goal: exam name (exam_prep) or target role (career)
  late String goalContext;

  /// Optional exam category: cert | competitive | academic | other
  String? examType;

  /// Optional seniority for career prep: junior | mid | senior
  String? roleSeniority;

  /// JSON list of nav destination ids
  late String navOrderJson;

  /// JSON map destination -> affinity score
  late String navAffinityJson;

  late double skillLevel;
  late bool helpImproveOptIn;
  DateTime? lastLayoutChangeAt;
  late DateTime updatedAt;
}
