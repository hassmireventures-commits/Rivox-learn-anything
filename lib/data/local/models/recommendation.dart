import 'package:isar_community/isar.dart';

part 'recommendation.g.dart';

@collection
class RecommendationItem {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  /// next_topic | remedial | path | break | layout | nudge
  late String kind;

  late String title;
  late String reason;
  late double score;
  String? topic;
  String? actionPayloadJson;

  late bool dismissed;
  late bool acted;
  late bool shown;
  late DateTime createdAt;
  DateTime? actedAt;
}
