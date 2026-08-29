import 'learning_pattern_context.dart';

class QuizGenerationRequest {
  const QuizGenerationRequest({
    required this.topic,
    required this.questionCount,
    required this.difficulty,
    required this.questionType,
    required this.language,
    required this.randomizeQuestions,
    required this.randomizeOptions,
    required this.generateExplanations,
    this.timerSeconds,
    this.learningPattern,
    this.ragContextBlock = '',
    this.citationChunkIds = const [],
    this.learnerGoals = const [],
    this.skillLevel,
    this.interviewPersona,
    this.voiceInterviewOnly = false,
    this.goalMode,
    this.examType,
    this.examName,
    this.syllabusUnitTitles = const [],
    this.topicResolutionBlock = '',
  });

  final String topic;
  final int questionCount;
  final String difficulty;
  final String questionType;
  final String language;
  final bool randomizeQuestions;
  final bool randomizeOptions;
  final bool generateExplanations;
  final int? timerSeconds;
  final LearningPatternContext? learningPattern;
  final String ragContextBlock;
  final List<String> citationChunkIds;
  final List<String> learnerGoals;
  final double? skillLevel;
  /// `hr` or `tech` for voice / interview drills.
  final String? interviewPersona;
  /// When true, generate open/behavioral questions only (no MCQ) for voice mode.
  final bool voiceInterviewOnly;
  /// `learning` | `exam_prep` | `career`
  final String? goalMode;
  /// cert | competitive | academic | other
  final String? examType;
  final String? examName;
  final List<String> syllabusUnitTitles;
  /// LLM "think step" scope for opaque goals (domains, org names).
  final String topicResolutionBlock;
}
