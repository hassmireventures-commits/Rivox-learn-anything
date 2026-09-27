import 'package:ai_quiz_app/core/services/coding_tutorial_sources.dart';
import 'package:ai_quiz_app/core/services/exam_cert_resources.dart';
import 'package:ai_quiz_app/data/remote/ai/competitive_exam_prompt.dart';
import 'package:ai_quiz_app/data/remote/ai/models/quiz_generation_request.dart';
import 'package:ai_quiz_app/data/remote/ai/prompt_builder.dart';
import 'package:ai_quiz_app/data/remote/ai/skill_practice_prompt.dart';
import 'package:flutter_test/flutter_test.dart';

QuizGenerationRequest _req({
  String topic = 'Python',
  String difficulty = 'easy',
  String? examName,
  String? goalMode,
  String? examType,
  String questionType = 'mcq',
}) =>
    QuizGenerationRequest(
      topic: topic,
      difficulty: difficulty,
      questionCount: 5,
      language: 'English',
      questionType: questionType,
      randomizeQuestions: true,
      randomizeOptions: true,
      generateExplanations: true,
      examName: examName,
      goalMode: goalMode,
      examType: examType,
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('coding quizzes are snippet tasks, not history of the language', () async {
    final request = _req();
    expect(SkillPracticePrompt.applies(request), isTrue);
    expect(SkillPracticePrompt.block(request), contains('FORBIDDEN'));
    expect(SkillPracticePrompt.block(request), contains('stands for'));
    final prompt = await PromptBuilder.build(request);
    expect(prompt, contains('code snippet'));
    expect(prompt, isNot(contains('BEGINNER TRACK')));
  });

  test('JEE and AWS quizzes are paper items, and biology stays general', () async {
    final jee = _req(topic: 'JEE Main');
    expect(SkillPracticePrompt.block(jee), contains('not trivia about the exam'));
    expect(ExamCertResources.matches('logic gate'), isFalse);
    expect(ExamCertResources.matches('Azure DevOps'), isFalse);
    expect(ExamCertResources.matches('GATE CSE'), isTrue);

    final biology = await PromptBuilder.build(_req(topic: 'Photosynthesis'));
    expect(biology, contains('INPUT CHECK'));
    expect(biology, contains('BEGINNER TRACK'));
    expect(biology, contains('only when the input check classifies the topic as a subject'));
    expect(SkillPracticePrompt.applies(_req(topic: 'Photosynthesis')), isFalse);
  });

  test('an unlisted exam is classified before questions are written', () async {
    final prompt = await PromptBuilder.build(
      _req(topic: 'CA Foundation', examName: 'CA Foundation', examType: 'cert', goalMode: 'exam_prep'),
    );
    expect(prompt, contains('INPUT CHECK'));
    expect(prompt, contains('you do not recognise'));
    expect(prompt, contains('Exam type flag from the app: cert'));
    expect(prompt, isNot(contains('BEGINNER TRACK')));
  });

  test('easy reasoning papers stay syllogisms without the beginner track', () async {
    final request = _req(
      topic: 'Logical Reasoning',
      goalMode: 'exam_prep',
      examType: 'competitive',
      examName: 'SSC CGL',
    );
    expect(CompetitiveExamPrompt.isReasoningFocus(request), isTrue);
    expect(SkillPracticePrompt.applies(request), isFalse);
    final prompt = await PromptBuilder.build(request);
    expect(prompt, contains('Syllogism'));
    expect(prompt, isNot(contains('BEGINNER TRACK')));
  });

  test('daily lessons for coding and exams are tutorials, not Wikipedia', () {
    final python = CodingTutorialSources.nextArticle('Python');
    expect(python, isNotNull);
    expect(python!.url, contains('w3schools.com'));
    expect(python.url, isNot(contains('wikipedia')));

    final jee = ExamCertResources.nextArticle('NEET');
    expect(jee, isNotNull);
    expect(jee!.url, contains('khanacademy.org'));
    expect(jee.url, isNot(contains('wikipedia')));

    final aws = ExamCertResources.nextArticle('AWS SAA');
    expect(aws!.url, contains('docs.aws.amazon.com'));
    expect(aws.url, isNot(contains('wikipedia')));
  });
}
