import '../../../core/services/coding_tutorial_sources.dart';
import '../../../core/services/exam_cert_resources.dart';
import 'competitive_exam_prompt.dart';
import 'language_exam_prompt.dart';
import 'models/quiz_generation_request.dart';

/// Practice items for coding and for exams or certifications.
/// Language papers and SSC-style reasoning keep their own prompts.
class SkillPracticePrompt {
  SkillPracticePrompt._();

  static bool applies(QuizGenerationRequest request) {
    if (request.questionType == 'interview') return false;
    if (LanguageExamPrompt.applies(request)) return false;
    if (CompetitiveExamPrompt.isReasoningFocus(request)) return false;
    if (CodingTutorialSources.isCodingTopic(request.topic)) return true;
    if (ExamCertResources.matches(request.topic)) return true;
    if (ExamCertResources.matches(request.examName ?? '')) return true;
    if (request.syllabusUnitTitles.any(ExamCertResources.matches)) return true;
    return request.goalMode == 'exam_prep' &&
        request.examType != null &&
        request.examType!.isNotEmpty;
  }

  static String block(QuizGenerationRequest request) {
    if (!applies(request)) return '';
    final label = _label(request);
    final coding = CodingTutorialSources.isCodingTopic(request.topic);
    if (coding) {
      return '''
PRACTICE ITEMS — $label (solve a task, do not describe the language):
Every question MUST include a short code snippet, error message, or concrete task in the question text.
Ask the candidate to predict output, find the bug, choose the fix, or name the complexity of THAT snippet.
At easy difficulty, use a few lines on variables, conditions, loops, or a function call. Still a task, not a definition.

FORBIDDEN (reject and rewrite if you were about to ask these):
- Who created $label, what the name stands for, its history, or which company owns it.
- "Which of the following is a feature of $label" with no code to look at.
- Questions that can be answered without reading the snippet you wrote.

''';
    }
    return '''
PRACTICE ITEMS — $label (a real paper item, not trivia about the exam):
Every question MUST be something a candidate would solve: a short scenario, a calculation, or an applied concept from the syllabus.
At easy difficulty, use one step from the basics of the syllabus. Still a problem, not a definition of the exam.

FORBIDDEN (reject and rewrite if you were about to ask these):
- What the exam or certification stands for, who conducts it, fees, dates, eligibility, or how many papers it has.
- The history of the awarding body, or "which of the following is a feature of $label".
- Questions that only need the name of the exam, not the subject it tests.

''';
  }

  static String _label(QuizGenerationRequest request) {
    final name = request.examName?.trim();
    if (name != null && name.isNotEmpty && ExamCertResources.matches(name)) {
      return name;
    }
    final topic = request.topic.trim();
    if (topic.isNotEmpty) return topic;
    return 'this exam';
  }
}
