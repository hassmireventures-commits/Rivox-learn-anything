import 'models/learning_pattern_context.dart';
import 'models/quiz_generation_request.dart';

class PromptBuilder {
  static String build(QuizGenerationRequest request) {
    final topic = _sanitize(request.topic);
    final language = _sanitize(request.language);
    final difficulty = _sanitize(request.difficulty);

    final typeInstruction = switch (request.questionType) {
      'mcq' => 'All questions must be multiple choice with exactly 4 options.',
      'true_false' => 'All questions must be True/False with options ["True", "False"].',
      'fill_blank' =>
        'All questions must be fill-in-the-blank style, still with 4 plausible options.',
      _ =>
        'Mix of MCQ, True/False, and fill-in-the-blank. Always provide options arrays.',
    };

    final explanationInstruction = request.generateExplanations
        ? 'Include a concise explanation for each question.'
        : 'Set explanation to null for each question.';

    final timerNote = request.timerSeconds != null
        ? 'Each question will have a ${request.timerSeconds}-second timer, so keep questions concise.'
        : 'No timer is enabled.';

    final patternNote = _patternBlock(request.learningPattern, difficulty);

    return '''
You are a quiz generator. Create a high-quality quiz and respond with VALID JSON ONLY.
Do not include markdown, code fences, or any text outside the JSON object.

Requirements:
- Topic: $topic
- Difficulty: $difficulty
- Number of questions: ${request.questionCount}
- Language: $language
- Question types: $typeInstruction
- $explanationInstruction
- $timerNote
$patternNote
- correctIndex must be the zero-based index of the correct option
- Options must be unique and plausible
- Questions must be accurate and non-ambiguous
- Exactly ${request.questionCount} items in the questions array

Return exactly this JSON shape:
{
  "questions": [
    {
      "text": "Question text",
      "options": ["A", "B", "C", "D"],
      "correctIndex": 0,
      "type": "mcq",
      "explanation": "Why the answer is correct"
    }
  ]
}
''';
  }

  static String _sanitize(String input) {
    // Strip control characters and collapse whitespace; never log secrets here.
    return input
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _patternBlock(LearningPatternContext? pattern, String difficulty) {
    if (pattern == null) return '';
    final accuracy = pattern.priorAccuracy;
    var style = '- Adapt questions to the learner module context.';
    if (accuracy != null) {
      if (accuracy < 0.6) {
        style =
            '- Learner accuracy on this topic is low (${(accuracy * 100).round()}%). Use remedial, foundational questions with simpler wording.';
      } else if (accuracy > 0.85) {
        style =
            '- Learner accuracy is strong (${(accuracy * 100).round()}%). Include deeper, application-focused questions at $difficulty level.';
      }
    }
    final module = pattern.moduleTitle;
    final position = pattern.pathPosition;
    final length = pattern.pathLength;
    final weak = pattern.weakSubtopics.isEmpty ? '' : pattern.weakSubtopics.join(', ');
    return '''
Learning pattern:
$style
${module != null ? '- Current module: $module' : ''}
${position != null && length != null ? '- Path progress: module ${position + 1} of $length' : ''}
${weak.isNotEmpty ? '- Extra focus on weak areas: $weak' : ''}
''';
  }
}
