import 'package:isar_community/isar.dart';

part 'question.g.dart';

@collection
class Question {
  Id id = Isar.autoIncrement;

  @Index()
  late String quizUuid;

  late int orderIndex;
  late String text;

  /// JSON-encoded list of options
  late String optionsJson;

  late int correctIndex;
  String? explanation;

  /// Optional JSON list of {title,url} references (module / grounded quizzes).
  String? referencesJson;

  /// mcq | true_false | fill_blank | short_answer | behavioral
  late String type;

  String? userAnswer;
  bool? isCorrect;
  int? timeSpentMs;

  /// Optional rubric / model-answer JSON for interview short answers.
  String? rubricJson;

  /// AI rubric score 0 - 1 for open responses (interview drills).
  double? aiScore;
}
