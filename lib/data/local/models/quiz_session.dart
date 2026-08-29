import 'package:isar_community/isar.dart';

part 'quiz_session.g.dart';

@collection
class QuizSession {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String uuid;

  @Index(caseSensitive: false)
  late String topic;

  @Index()
  late String difficulty;

  /// mcq | true_false | fill_blank | mixed
  late String questionType;

  late int questionCount;
  /// Per-question timer (legacy / quick quizzes). Ignored when [examDurationSeconds] is set.
  int? timerSeconds;
  late String language;
  late bool randomizeQuestions;
  late bool randomizeOptions;
  late bool generateExplanations;

  int? score;
  int? correctCount;
  int? wrongCount;
  double? accuracy;
  int? timeTakenSeconds;

  @Index()
  late DateTime startedAt;

  @Index()
  DateTime? completedAt;

  /// solo | multiplayer
  late String source;

  /// quick | module | multiplayer | daily | demo | mock | interview
  @Index()
  String quizKind = 'quick';

  String? roomId;
  String? pathId;
  int? moduleIndex;
  int? promptTokens;
  int? completionTokens;

  /// Whole-exam countdown for timed mocks (seconds).
  int? examDurationSeconds;

  /// Pass threshold 0 - 100 for mocks (default 60 - 70).
  int? passPercent;

  String? syllabusUuid;

  /// JSON list of syllabus unit UUIDs included in this mock.
  String? unitFilterJson;

  /// 1-based attempt number for this syllabus/topic series.
  int? attemptNumber;

  /// Denormalized score percent (0 - 100), same as accuracy for mock trend charts.
  double? scorePercent;

  /// JSON list of RAG citation chunk IDs used for this quiz.
  String? citationChunkIdsJson;
}
