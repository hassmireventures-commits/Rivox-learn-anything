import '../../../core/services/language_exam_resources.dart';
import 'models/quiz_generation_request.dart';

/// IELTS / TOEFL / PTE-style items: a stimulus plus a real task, not facts about the test.
class LanguageExamPrompt {
  LanguageExamPrompt._();

  static bool applies(QuizGenerationRequest request) {
    return appliesTo(
      topic: request.topic,
      examName: request.examName,
      syllabusUnitTitles: request.syllabusUnitTitles,
    );
  }

  /// True when this quiz should be a language-exam paper.
  /// An IELTS goal does not rewrite an unrelated topic such as Python.
  static bool appliesTo({
    required String topic,
    String? examName,
    List<String> syllabusUnitTitles = const [],
  }) {
    if (LanguageExamResources.matches(topic)) return true;
    if (syllabusUnitTitles.any(LanguageExamResources.matches)) return true;
    if (!LanguageExamResources.matches(examName ?? '')) return false;
    final lower = topic.trim().toLowerCase();
    if (lower.isEmpty) return true;
    const sections = [
      'reading',
      'listening',
      'writing',
      'speaking',
      'task 1',
      'task 2',
      'academic',
      'general training',
    ];
    return sections.any(lower.contains);
  }

  static String block(QuizGenerationRequest request) {
    if (!applies(request)) return '';
    final label = _label(request);
    return '''
LANGUAGE EXAM — $label (real paper items, not trivia about the test):
Every question MUST be something a candidate would meet in $label: a short stimulus, then a task.
Spread the set across Reading, Listening, Writing, and Speaking. Do not make the whole quiz one section.

How to write each item. Put the material in "stimulus" and keep "text" as the task only:
${request.questionType == 'mixed' ? 'The requested format is mixed. Include type "mcq", type "true_false" (options ["True","False"] or ["True","False","Not Given"]), and type "fill_blank" (a sentence with _____). Do not make the whole paper multiple choice.\n' : ''}
- Reading: stimulus {"kind":"passage","title":"Reading","body":"50–90 word passage"}. text asks one real item (True/False/Not Given, matching heading, or detail). The correct option must follow only from that passage.
- Listening: stimulus {"kind":"transcript","title":"Conversation","body":"4–8 lines with speaker names"}. text asks for a detail, number, spelling, or speaker purpose. The app reads body aloud.
- Chart or table: stimulus kind "chart" or "table" with the actual numbers. text asks about that figure. Do not describe a figure that is not in stimulus.
- Writing: stimulus {"kind":"cue","title":"Task 2","body":"the essay question or chart task"}. text asks which option is the best thesis or overview for THAT task.
- Speaking: stimulus {"kind":"cue","title":"Cue card","body":"the Part 2 card"}. text asks which answer develops the bullet points.

FORBIDDEN (reject and rewrite if you were about to ask these):
- What the exam stands for, who owns it, the band-score table, test dates, fees, or which section tests listening.
- Definitions of the exam, its history, or "which of the following is a feature of $label".
- Questions that can be answered without reading the passage or transcript you wrote.

''';
  }

  static String _label(QuizGenerationRequest request) {
    final name = request.examName?.trim();
    if (name != null && name.isNotEmpty && LanguageExamResources.matches(name)) {
      return name;
    }
    final topic = request.topic.trim();
    if (LanguageExamResources.matches(topic)) return topic;
    return 'IELTS';
  }
}
