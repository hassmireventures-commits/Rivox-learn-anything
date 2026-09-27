import 'models/quiz_generation_request.dart';

/// Tells the model to classify the learner input, then pick the content shape.
/// Runs for names we have not hard-coded as well as ones we have.
class InputKindPrompt {
  InputKindPrompt._();

  static String quizBlock(QuizGenerationRequest request) {
    if (request.questionType == 'interview') return '';
    final known = _knownFacts(request);
    return '''
INPUT CHECK (do this before writing any question):
Read the topic and the facts below. Pick exactly one kind. A name you do not recognise is still an exam or a certification if that is what the words are.
$known
Kinds:
- language_test: a language proficiency exam, named or not
- certification: a professional certificate
- exam: any other test, entrance exam, licence, or competitive paper
- coding: a programming language, framework, or computing skill
- subject: a school or general subject, or anything that is none of the above

Then write every question in that kind only:
- language_test: put the passage, transcript, chart, table, or cue card in stimulus, and put only the task in text. Never what the test stands for, who owns it, or the fees.
- certification or exam: a problem a candidate would solve (scenario, calculation, or applied concept). If it needs a figure, put the figure in stimulus. Never the acronym, fees, dates, eligibility, or who awards it.
- coding: a short snippet, error, or concrete task. Never who created it or what the name stands for.
- subject: questions about that subject. Easy difficulty may be foundational inside the subject.

Do not change kind from one question to the next.

''';
  }

  /// Prepended to daily-article prompts that are not already pinned to a curated list.
  static String articleRules(String topic) => '''
INPUT CHECK for "$topic":
Decide the kind before you choose a URL: language_test, certification, exam, coding, or subject.
A name you do not recognise is still an exam or a certification when the words name one.
- language_test, certification, exam, or coding: a lesson that teaches a skill from the basics (a tutorial, a worked example, or the first chapter of an official guide). Do NOT use Wikipedia, wikiHow, or Britannica. Do NOT pick a page about fees, history, or what the name stands for.
- subject: an article about that subject. Wikipedia is allowed only for this kind.
''';

  /// Prepended to daily-video prompts that are not already pinned to a curated list.
  static String videoRules(String topic) => '''
INPUT CHECK for "$topic":
Decide the kind before you choose a video: language_test, certification, exam, coding, or subject.
A name you do not recognise is still an exam or a certification when the words name one.
- language_test, certification, exam, or coding: a lesson that teaches a skill from the basics. Not a video whose title is only "What is $topic", a fee chart, or a history of the awarding body.
- subject: a lesson about that subject.
''';

  static String pathRules(List<String> goals) {
    final label = goals.isEmpty ? 'the goal' : goals.join(', ');
    return '''
- INPUT CHECK: classify $label as language_test, certification, exam, coding, or subject before you write modules. An unrecognised exam or certificate name is still that kind.
- If the kind is language_test, certification, exam, or coding: module 1 is the first skill a candidate practices, not "what this exam is". Article URLs must be tutorials or official lessons, not a Wikipedia overview of the exam or the language.
- If the kind is subject: module 1 is the foundation of that subject, and Wikipedia is allowed when the title matches the module.
''';
  }

  static String _knownFacts(QuizGenerationRequest request) {
    final lines = <String>[];
    final mode = request.goalMode?.trim() ?? '';
    if (mode.isNotEmpty) {
      lines.add('Goal mode from the app: $mode (exam_prep means they are preparing for a test).');
    }
    final type = request.examType?.trim() ?? '';
    if (type.isNotEmpty) {
      lines.add(
        'Exam type flag from the app: $type (cert means certification; competitive, academic, and other are exams).',
      );
    }
    final name = request.examName?.trim() ?? '';
    if (name.isNotEmpty) lines.add('Exam or certificate name: $name.');
    if (request.learnerGoals.isNotEmpty) {
      lines.add('Learner goals: ${request.learnerGoals.join(', ')}.');
    }
    if (request.syllabusUnitTitles.isNotEmpty) {
      lines.add('Syllabus units: ${request.syllabusUnitTitles.join(', ')}.');
    }
    if (lines.isEmpty) {
      return 'The app did not set an exam flag. Judge from the topic text alone.';
    }
    return lines.join('\n');
  }
}
