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
}
