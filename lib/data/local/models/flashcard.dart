import 'package:isar_community/isar.dart';

part 'flashcard.g.dart';

@collection
class Flashcard {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  late String front;
  late String back;

  /// Optional detailed reasoning behind [back] — why it's the answer, not
  /// just what it is. Null for cards created before this field existed.
  String? explanation;

  /// 'library' | 'mistake'
  @Index()
  late String sourceType;

  /// chunkId (library) or source Question.uuid (mistake) — informational only.
  String? sourceRef;

  @Index(caseSensitive: false)
  late String goalMode;

  @Index()
  late DateTime createdAt;

  DateTime? lastReviewedAt;

  @Index()
  late DateTime nextReviewAt;

  double easeFactor = 2.5;
  int intervalDays = 0;
  int repetitions = 0;
}
