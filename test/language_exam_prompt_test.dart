import 'package:ai_quiz_app/core/services/language_exam_resources.dart';
import 'package:ai_quiz_app/data/remote/ai/competitive_exam_prompt.dart';
import 'package:ai_quiz_app/data/remote/ai/language_exam_prompt.dart';
import 'package:ai_quiz_app/data/remote/ai/models/quiz_generation_request.dart';
import 'package:flutter_test/flutter_test.dart';

QuizGenerationRequest _req({
  String topic = 'IELTS',
  String? examName,
  String? goalMode,
  String? examType,
}) =>
    QuizGenerationRequest(
      topic: topic,
      difficulty: 'easy',
      questionCount: 5,
      language: 'English',
      questionType: 'mcq',
      randomizeQuestions: true,
      randomizeOptions: true,
      generateExplanations: true,
      examName: examName,
      goalMode: goalMode,
      examType: examType,
      learnerGoals: const ['IELTS'],
    );

void main() {
  test('IELTS quiz prompt demands a passage, not exam trivia', () {
    final block = LanguageExamPrompt.block(_req());
    expect(block, contains('FORBIDDEN'));
    expect(block, contains('stands for'));
    expect(block, contains('50–90 word passage'));
    expect(LanguageExamPrompt.applies(_req(topic: 'Python')), isFalse);
    expect(
      LanguageExamPrompt.applies(_req(topic: 'Python', examName: 'IELTS')),
      isFalse,
    );
    expect(
      LanguageExamPrompt.applies(_req(topic: 'Reading', examName: 'IELTS')),
      isTrue,
    );
  });

  test('IELTS is not treated as an SSC reasoning paper', () {
    final request = _req(
      goalMode: 'exam_prep',
      examType: 'academic',
      examName: 'IELTS Academic',
    );
    expect(LanguageExamPrompt.applies(request), isTrue);
    expect(CompetitiveExamPrompt.applies(request), isFalse);
  });

  test('daily articles for IELTS start with reading skills, not Wikipedia', () {
    final first = LanguageExamResources.nextArticle('IELTS');
    expect(first.url, contains('ieltsliz.com'));
    expect(first.url, contains('reading'));
    expect(first.url, isNot(contains('wikipedia')));

    final second = LanguageExamResources.nextArticle(
      'TOEFL',
      excludeUrls: {first.url},
    );
    expect(second.url, contains('listening'));
    expect(second.url, isNot(contains('wikipedia')));
  });
}
