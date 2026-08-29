import 'models/quiz_generation_request.dart';

/// Competitive-exam style guidance (SSC, Banking, RRB, CAT DILR, etc.).
class CompetitiveExamPrompt {
  CompetitiveExamPrompt._();

  static bool applies(QuizGenerationRequest request) {
    if (request.examType == 'competitive') return true;
    if (request.goalMode == 'exam_prep' && _isReasoningFocus(request)) return true;
    if (_isReasoningFocus(request)) return true;
    return request.goalMode == 'exam_prep' &&
        request.examType != null &&
        request.examType!.isNotEmpty;
  }

  static bool suppressBeginnerTrack(QuizGenerationRequest request) =>
      applies(request) && request.difficulty != 'easy';

  static String block(QuizGenerationRequest request) {
    if (!applies(request)) return '';

    final examLabel = _examLabel(request);
    final units = request.syllabusUnitTitles;
    final unitLine = units.isEmpty
        ? ''
        : 'Syllabus units for this paper: ${units.join(', ')}.\n';

    final reasoning = _isReasoningFocus(request);
    if (reasoning) {
      return '''
COMPETITIVE EXAM — LOGICAL / ANALYTICAL REASONING ($examLabel):
$unitLine
Mirror real mock papers (SSC CGL/CHSL, IBPS PO/Clerk, RRB NTPC/Clerk, LIC, CAT DILR). NOT school riddles, NOT trivia, NOT "what is logical reasoning" definitions.

Required question mix (spread across the set; vary types):
- Syllogism (2–3 statements, only/some/few, possibility cases)
- Coding–decoding (letter/number patterns, fictitious language, conditional rules)
- Blood relations (family tree, coded relations)
- Direction sense & distance (turns, shadow, final direction/distance)
- Seating arrangement (linear/circular/square; facing in/out)
- Puzzles (floor/flat, box, scheduling, day/month/year, comparison)
- Alphanumeric / number series (missing term, wrong term)
- Inequalities (direct or coded: A>B, ≥, ≤ chains)
- Order & ranking (positions from ends, total count)
- Statement–conclusion / assumption / argument / course of action
- Cause & effect; data sufficiency (2–3 statements)
- Input–output (word/number shifting) for hard/expert

Style rules:
- Each MCQ must be solvable in 1–2 minutes (medium) or 2–3 minutes (hard/expert) under exam pressure.
- Use multi-clue setups for puzzles/seating (at least 3 constraints when difficulty is medium+).
- Options must be plausible near-misses from the same reasoning family — not joke answers.
- ${_difficultyGuide(request.difficulty)}
- FORBIDDEN: coin riddles, lateral "trick" puzzles, primary-school logic, generic true/false trivia.

''';
    }

    return '''
COMPETITIVE EXAM PAPER ($examLabel):
$unitLine
Questions must match real $examLabel mock difficulty — application and exam phrasing, not textbook summaries.
Use multi-step problems where the syllabus expects them. Distractors should reflect common candidate mistakes.
${_difficultyGuide(request.difficulty)}
''';
  }

  static bool _isReasoningFocus(QuizGenerationRequest request) {
    final haystack = [
      request.topic,
      ...request.syllabusUnitTitles,
    ].join(' ').toLowerCase();
    if (haystack.contains('logical reasoning')) return true;
    if (haystack.contains('analytical reasoning')) return true;
    if (haystack.contains('reasoning ability')) return true;
    if (RegExp(r'\breasoning\b').hasMatch(haystack) &&
        !haystack.contains('quantitative') &&
        !haystack.contains('verbal ability') &&
        !haystack.contains('english')) {
      return true;
    }
    return false;
  }

  static String _examLabel(QuizGenerationRequest request) {
    final name = request.examName?.trim();
    if (name != null && name.isNotEmpty) return name;
    return switch (request.examType) {
      'competitive' => 'Competitive exam',
      'academic' => 'Academic entrance exam',
      'cert' => 'Certification exam',
      _ => 'Exam preparation',
    };
  }

  static String _difficultyGuide(String difficulty) {
    return switch (difficulty) {
      'easy' =>
        'Difficulty easy: single-step syllogisms, direct coding, simple direction/ranking — still exam-style wording.',
      'hard' =>
        'Difficulty hard: puzzles with 4+ constraints, coded inequalities, multi-layer blood relations, input–output.',
      'expert' =>
        'Difficulty expert: CAT DILR / mains-level puzzle sets, reverse syllogism, complex seating with extra variables.',
      _ =>
        'Difficulty medium: standard banking/SSC prelims — 2–3 clue puzzles, moderate coding, seating with 3–4 constraints.',
    };
  }
}
