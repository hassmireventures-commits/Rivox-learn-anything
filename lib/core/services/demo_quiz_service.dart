import 'package:flutter/foundation.dart';

import '../../data/local/repositories/quiz_repository.dart';
import '../../data/remote/ai/models/generated_quiz.dart';
import '../../data/remote/ai/models/quiz_generation_request.dart';
import '../constants/quiz_kind.dart';

/// Offline sample quiz so new users can try the app without an API key.
class DemoQuizService {
  const DemoQuizService(this._quizRepository);

  final QuizRepository _quizRepository;

  static const _demoTopic = 'Getting started with Rivox';

  static final _demoQuiz = GeneratedQuiz(
    questions: [
      GeneratedQuestion(
        text: 'What does BYOK stand for in this app?',
        options: ['Bring Your Own Key', 'Build Your Own Quiz', 'Backup Your Knowledge', 'Browse Your Options'],
        correctIndex: 0,
        type: 'mcq',
        explanation: 'You add your own AI provider API key to generate quizzes.',
      ),
      GeneratedQuestion(
        text: 'Where are your quiz results stored?',
        options: ['On this device only', 'In the cloud only', 'On a shared server', 'Nowhere'],
        correctIndex: 0,
        type: 'mcq',
        explanation: 'Rivox is local-first - your data stays on your phone.',
      ),
      GeneratedQuestion(
        text: 'Learning paths help you study a topic step by step.',
        options: ['True', 'False'],
        correctIndex: 0,
        type: 'true_false',
      ),
      GeneratedQuestion(
        text: 'You need an internet connection to play a demo quiz.',
        options: ['True', 'False'],
        correctIndex: 1,
        type: 'true_false',
        explanation: 'The demo quiz works fully offline once loaded.',
      ),
      GeneratedQuestion(
        text: 'What is the minimum score to unlock the next module in a learning path?',
        options: ['40%', '60%', '80%', '100%'],
        correctIndex: 1,
        type: 'mcq',
        explanation: 'Module quizzes require at least 60% accuracy to advance.',
      ),
    ],
  );

  /// Exposed for critical-path unit tests (no Isar required).
  @visibleForTesting
  static GeneratedQuiz get sampleQuiz => _demoQuiz;

  Future<String> createDemoQuiz() async {
    final session = await _quizRepository.saveGeneratedQuiz(
      request: const QuizGenerationRequest(
        topic: _demoTopic,
        questionCount: 5,
        difficulty: 'easy',
        questionType: 'mixed',
        language: 'English',
        randomizeQuestions: false,
        randomizeOptions: true,
        generateExplanations: true,
      ),
      generated: _demoQuiz,
      source: 'demo',
      quizKind: QuizKind.demo,
    );
    return session.uuid;
  }
}
