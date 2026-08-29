import 'models/quiz_generation_request.dart';

/// MCQ answer/explanation alignment rules — prevents correctIndex vs explanation drift.
class QuizConsistencyPrompt {
  QuizConsistencyPrompt._();

  static bool applies(QuizGenerationRequest request) =>
      request.questionType != 'interview';

  static String block(QuizGenerationRequest request) {
    if (!applies(request)) return '';
    if (!request.generateExplanations) {
      return '''
CONSISTENCY: correctIndex must be the zero-based index of the objectively true option. Scope qualifiers in the question ("internal", "largest overall", "primary", etc.) must match the keyed answer.
''';
    }
    return '''
QUIZ CONSISTENCY (verify every question before output):
- Cross-check correctIndex against explanation: the explanation MUST defend the option at correctIndex and debunk plausible distractors.
- Never key one answer while explaining a different option is correct.

Scope example — "largest organ":
- WRONG: correctIndex → Liver, explanation says skin covers the entire body.
- RIGHT: "What is the largest organ in the human body?" → options ["Skin","Liver","Heart","Lungs"], correctIndex 0, explanation "The skin is the largest organ overall. The liver is the largest internal organ only."

If the stem says "internal", "primary", "most common cause", etc., correctIndex and explanation must match that exact scope.
''';
  }
}
