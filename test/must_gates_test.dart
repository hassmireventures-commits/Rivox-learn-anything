import 'package:ai_quiz_app/core/constants/app_constants.dart';
import 'package:ai_quiz_app/core/error/app_exception.dart';
import 'package:ai_quiz_app/core/services/app_logger.dart';
import 'package:ai_quiz_app/core/services/demo_quiz_service.dart';
import 'package:ai_quiz_app/data/local/isar_service.dart';
import 'package:ai_quiz_app/data/local/repositories/quiz_repository.dart';
import 'package:ai_quiz_app/data/remote/ai/competitive_exam_prompt.dart';
import 'package:ai_quiz_app/data/remote/ai/models/quiz_generation_request.dart';
import 'package:ai_quiz_app/data/remote/ai/prompt_builder.dart';
import 'package:ai_quiz_app/data/remote/ai/quiz_json_parser.dart';
import 'package:ai_quiz_app/data/remote/analytics/anon_analytics_sync.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group('Demo quiz critical path', () {
    test('demo sample is playable MCQ/TF with valid indices', () {
      final quiz = DemoQuizService.sampleQuiz;
      expect(quiz.questions, isNotEmpty);
      expect(quiz.questions.length, 5);
      for (final q in quiz.questions) {
        expect(q.text, isNotEmpty);
        expect(q.options, isNotEmpty);
        expect(q.correctIndex, inInclusiveRange(0, q.options.length - 1));
        expect(q.options.toSet().length, q.options.length, reason: 'options must be unique');
      }
      expect(quiz.questions.any((q) => q.type == 'mcq'), isTrue);
      expect(quiz.questions.any((q) => q.type == 'true_false'), isTrue);
    });

    test('quiz play and results routes are absolute paths', () {
      const play = '/quiz/play/demo-id';
      const results = '/quiz/results/demo-id';
      expect(play.startsWith('/quiz/play/'), isTrue);
      expect(results.startsWith('/quiz/results/'), isTrue);
    });
  });

  group('PromptBuilder', () {
    test('states exact question count and format in mandatory block', () async {
      const request = QuizGenerationRequest(
        topic: 'Photosynthesis',
        questionCount: 20,
        difficulty: 'medium',
        questionType: 'mcq',
        language: 'English',
        randomizeQuestions: true,
        randomizeOptions: true,
        generateExplanations: true,
      );
      final prompt = await PromptBuilder.build(request);
      expect(prompt, contains('exactly 20 items'));
      expect(prompt, contains('app only allows: 5, 10, 15, 20'));
      expect(prompt, contains('User-selected count: 20'));
      expect(prompt, contains('Topic: Photosynthesis'));
      expect(prompt, contains('Difficulty: medium'));
      expect(prompt, contains('All MCQ with exactly 4 options'));
      expect(prompt, contains('return exactly 20 questions'));
    });

    test('includes answer/explanation consistency rules for MCQ', () async {
      const request = QuizGenerationRequest(
        topic: 'Human anatomy',
        questionCount: 5,
        difficulty: 'medium',
        questionType: 'mcq',
        language: 'English',
        randomizeQuestions: false,
        randomizeOptions: false,
        generateExplanations: true,
      );
      final prompt = await PromptBuilder.build(request);
      expect(prompt, contains('QUIZ CONSISTENCY'));
      expect(prompt, contains('largest organ'));
      expect(prompt, contains('correctIndex against explanation'));
    });

    test('skips consistency block for interview quizzes', () async {
      const request = QuizGenerationRequest(
        topic: 'Software engineer',
        questionCount: 5,
        difficulty: 'medium',
        questionType: 'interview',
        language: 'English',
        randomizeQuestions: false,
        randomizeOptions: false,
        generateExplanations: true,
        interviewPersona: 'tech',
      );
      final prompt = await PromptBuilder.build(request);
      expect(prompt, isNot(contains('Cross-check correctIndex')));
    });
  });

  group('QuizJsonParser', () {
    test('parses letter-keyed options and correct_answer', () {
      const raw = '''
{"questions":[{"question_number":1,"question_text":"What is the largest organ in the human body?","options":{"A":"Skin","B":"Liver","C":"Heart","D":"Lungs"},"correct_answer":"A","explanation":"The skin is the largest organ overall.","type":"mcq"}]}
''';
      final quiz = QuizJsonParser.parse(raw, expectedCount: 1);
      final q = quiz.questions.first;
      expect(q.text, contains('largest organ'));
      expect(q.options.first, 'Skin');
      expect(q.correctIndex, 0);
    });

    test('parses fenced JSON object', () {
      const raw = '''
```json
{"questions":[{"text":"2+2?","options":["3","4","5","6"],"correctIndex":1,"type":"mcq"}]}
```
''';
      final quiz = QuizJsonParser.parse(raw, expectedCount: 1);
      expect(quiz.questions, hasLength(1));
      expect(quiz.questions.first.correctIndex, 1);
      expect(quiz.questions.first.options[1], '4');
    });

    test('parses bare questions array', () {
      const raw =
          '[{"text":"T/F","options":["True","False"],"correctIndex":0,"type":"true_false"}]';
      final quiz = QuizJsonParser.parse(raw, expectedCount: 1);
      expect(quiz.questions, hasLength(1));
      expect(quiz.questions.first.type, 'true_false');
    });

    test('trims over-count to expectedCount', () {
      final questions = List.generate(
        8,
        (i) =>
            '{"text":"Q$i","options":["a","b","c","d"],"correctIndex":0,"type":"mcq"}',
      ).join(',');
      final quiz = QuizJsonParser.parse(
        '{"questions":[$questions]}',
        expectedCount: 3,
      );
      expect(quiz.questions, hasLength(3));
    });

    test('trims modest over-count (23 → 20)', () {
      final questions = List.generate(
        23,
        (i) =>
            '{"text":"Question $i","options":["a","b","c","d"],"correctIndex":0,"type":"mcq"}',
      ).join(',');
      final quiz = QuizJsonParser.parse(
        '{"questions":[$questions]}',
        expectedCount: 20,
      );
      expect(quiz.questions, hasLength(20));
    });

    test('trims larger over-count (24 → 20)', () {
      final questions = List.generate(
        24,
        (i) =>
            '{"text":"Question $i","options":["a","b","c","d"],"correctIndex":0,"type":"mcq"}',
      ).join(',');
      final quiz = QuizJsonParser.parse(
        '{"questions":[$questions]}',
        expectedCount: 20,
      );
      expect(quiz.questions, hasLength(20));
    });

    test('accepts exact count with unique stems', () {
      final questions = List.generate(
        20,
        (i) =>
            '{"text":"Question $i","options":["a","b","c","d"],"correctIndex":0,"type":"mcq"}',
      ).join(',');
      final quiz = QuizJsonParser.parse(
        '{"questions":[$questions]}',
        expectedCount: 20,
      );
      expect(quiz.questions, hasLength(20));
    });

    test('rejects duplicate stems when too few unique remain', () {
      const dup =
          '{"text":"What is 2+2?","options":["3","4","5","6"],"correctIndex":1,"type":"mcq"}';
      const unique =
          '{"text":"What is 3+3?","options":["5","6","7","8"],"correctIndex":1,"type":"mcq"}';
      expect(
        () => QuizJsonParser.parse(
          '{"questions":[$dup,$dup,$unique]}',
          expectedCount: 3,
        ),
        throwsA(isA<InvalidJsonException>()),
      );
    });

    test('throws when duplicates leave too few unique questions', () {
      const dup =
          '{"text":"Same?","options":["a","b","c","d"],"correctIndex":0,"type":"mcq"}';
      expect(
        () => QuizJsonParser.parse(
          '{"questions":[$dup,$dup]}',
          expectedCount: 2,
        ),
        throwsA(isA<InvalidJsonException>()),
      );
    });

    test('throws when MCQ has only one option', () {
      const raw =
          '{"questions":[{"text":"Only one?","options":["solo"],"correctIndex":0,"type":"mcq"}]}';
      expect(
        () => QuizJsonParser.parse(raw, expectedCount: 1),
        throwsA(isA<Exception>()),
      );
    });

    test('throws on invalid JSON', () {
      expect(
        () => QuizJsonParser.parse('not json', expectedCount: 1),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('QuizRepository MCQ options', () {
    test('ensureMinChoiceOptions pads a single stored option', () {
      final padded = QuizRepository.ensureMinChoiceOptions([
        'A quarter and a nickel',
      ]);
      expect(padded.length, greaterThanOrEqualTo(2));
      expect(padded.first, 'A quarter and a nickel');
    });
  });

  group('CompetitiveExamPrompt', () {
    test('detects logical reasoning topics', () {
      const request = QuizGenerationRequest(
        topic: 'Logical Reasoning',
        questionCount: 10,
        difficulty: 'medium',
        questionType: 'mcq',
        language: 'English',
        randomizeQuestions: true,
        randomizeOptions: true,
        generateExplanations: true,
        goalMode: 'exam_prep',
        examType: 'competitive',
        examName: 'SSC CGL',
      );
      expect(CompetitiveExamPrompt.applies(request), isTrue);
      final block = CompetitiveExamPrompt.block(request);
      expect(block, contains('Syllogism'));
      expect(block, contains('FORBIDDEN'));
    });
  });

  group('AppLogger scrubbing', () {
    test('redacts OpenAI-style keys', () {
      final scrubbed = AppLogger.scrub('key=sk-abcdefghijklmnopqrstuvwxyz123456');
      expect(scrubbed, isNot(contains('sk-abcdefghijklmnop')));
      expect(scrubbed, contains('[REDACTED]'));
    });

    test('invokes crash sink on error', () {
      String? seen;
      AppLogger.crashSink = (tag, message, {error, stack, extras}) {
        seen = '$tag:$message';
      };
      AppLogger.error('Test', 'boom sk-abcdefghijklmnopqrstuvwxyz123456');
      expect(seen, isNotNull);
      expect(seen, contains('Test'));
      expect(seen, isNot(contains('sk-abcdefgh')));
      AppLogger.crashSink = null;
    });
  });

  group('Isar schema version', () {
    test('schemaVersion is positive', () {
      expect(IsarService.schemaVersion, greaterThan(0));
    });
  });

  group('Firestore analytics gate', () {
    test('cloud writes enabled by default after rules deploy', () {
      expect(AnonAnalyticsSync.cloudWritesEnabled, isTrue);
    });
  });

  group('Legal URLs', () {
    test('do not use example.com', () {
      expect(AppConstants.privacyPolicyUrl.contains('example.com'), isFalse);
      expect(AppConstants.termsUrl.contains('example.com'), isFalse);
    });
  });

  group('App branding', () {
    test('app name is Rivox', () {
      expect(AppConstants.appName, 'Rivox');
    });
  });
}
