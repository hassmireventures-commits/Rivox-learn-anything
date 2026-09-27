import 'competitive_exam_prompt.dart';
import 'input_kind_prompt.dart';
import 'language_exam_prompt.dart';
import 'skill_practice_prompt.dart';
import 'quiz_consistency_prompt.dart';
import 'topic_specificity_prompt.dart';
import 'models/learning_pattern_context.dart';
import 'models/quiz_generation_request.dart';

import '../../../core/ai_platform/ai_policy_registry.dart';
import '../../../core/ai_platform/prompt_firewall.dart';
import '../../../core/constants/app_constants.dart';

class PromptBuilder {
  static final _firewall = const PromptFirewall();

  static Future<String> build(QuizGenerationRequest request) async {
    final policy = await AiPolicyRegistry.load();
    final topicResult = await _firewall.sanitize(request.topic, policy: policy);
    final topic = topicResult.sanitized;
    final language = _sanitize(request.language);
    final difficulty = _sanitize(request.difficulty);

    final typeInstruction = switch (request.questionType) {
      'mcq' => 'All MCQ with exactly 4 options. Set type to "mcq" on every question.',
      'true_false' =>
        'All True/False; options ["True","False"]. Set type to "true_false" on every question.',
      'fill_blank' =>
        'Fill-in-the-blank: each stem contains _____ and exactly 4 short options. Set type to "fill_blank" on every question.',
      'interview' => _interviewInstruction(
          request.interviewPersona,
          voiceOnly: request.voiceInterviewOnly,
        ),
      _ => _mixedInstruction(request.questionCount),
    };

    final explanationInstruction = request.generateExplanations
        ? 'Non-empty short explanation per question (never null).'
        : 'Set explanation to null.';

    final refsInstruction = request.ragContextBlock.isNotEmpty
        ? 'When RAG/resources are provided, each question MUST include references: [{"title":"...","url":"..."}] citing those sources.'
        : '';
    final libraryNote = request.ragContextBlock.isNotEmpty
        ? 'Library excerpts (resume, job description, notes) are highest priority; lightly normalize messy formatting but do not invent facts. '
            'Test skills, tools, and experience described in those excerpts. NEVER ask about the resume file name, upload, document title, or formatting.\n'
        : '';

    final timerNote = request.timerSeconds != null
        ? 'Timer ${request.timerSeconds}s - keep questions concise.'
        : '';

    final patternNote = _patternBlock(request.learningPattern, difficulty);
    final skill = request.skillLevel;
    final inputKindNote = InputKindPrompt.quizBlock(request);
    final skillPracticeNote = SkillPracticePrompt.block(request);
    final competitiveNote = skillPracticeNote.isNotEmpty
        ? ''
        : CompetitiveExamPrompt.block(request);
    final languageExamNote = LanguageExamPrompt.block(request);
    final consistencyNote = QuizConsistencyPrompt.block(request);
    final specificityNote = TopicSpecificityPrompt.block(request);
    final resolutionNote = request.topicResolutionBlock.isNotEmpty
        ? '${request.topicResolutionBlock}\n'
        : '';
    final suppressBeginner = CompetitiveExamPrompt.suppressBeginnerTrack(request) ||
        TopicSpecificityPrompt.suppressBeginnerTrack(request) ||
        LanguageExamPrompt.applies(request) ||
        SkillPracticePrompt.applies(request);
    final beginnerNote = suppressBeginner
        ? ''
        : (difficulty == 'easy' || skill == null || skill < 0.5)
            ? 'BEGINNER TRACK: use this only when the input check classifies the topic as a subject. Assume ZERO prior knowledge and ask foundational questions within that subject, not a different field. If the check says language_test, certification, exam, or coding, ignore this track and write practice items instead.\n'
            : '';
    final ragBlock = request.ragContextBlock.isNotEmpty ? '${request.ragContextBlock}\n\n' : '';
    final goalsNote = request.learnerGoals.isEmpty
        ? ''
        : 'Learner goals (stay on-topic; related libraries/frameworks OK; do not invent unrelated domains): ${request.learnerGoals.join(', ')}.\n';

    final explanationExample = request.generateExplanations
        ? '"Because 2+2 equals 4."'
        : 'null';
    final refsExample = request.ragContextBlock.isNotEmpty
        ? ',"references":[{"title":"Source","url":"https://example.com"}]'
        : '';
    final schemaExample = request.questionType == 'mixed'
        ? '{"questions":[{"text":"What is 2+2?","options":["3","4","5","6"],"correctIndex":1,"type":"mcq","explanation":$explanationExample$refsExample},{"text":"2+2 equals 4.","options":["True","False"],"correctIndex":0,"type":"true_false","explanation":$explanationExample},{"text":"2+2 equals _____.","options":["3","4","5","6"],"correctIndex":1,"type":"fill_blank","explanation":$explanationExample}]}'
        : '{"questions":[{"text":"What is 2+2?","options":["3","4","5","6"],"correctIndex":1,"type":"mcq","explanation":$explanationExample$refsExample}]}';
    final count = request.questionCount;
    final allowedCounts = AppConstants.questionCounts.join(', ');
    final consistencyVerify = consistencyNote.isNotEmpty
        ? ' Before output, verify each explanation matches the option at correctIndex (see QUIZ CONSISTENCY above).'
        : '';

    return '''
${ragBlock}Quiz generator. Reply with VALID JSON only (no markdown).

MANDATORY (must satisfy every line — wrong counts are rejected):
- User-selected count: $count (app only allows: $allowedCounts)
- questions array length: exactly $count items — no more, no fewer
- Topic: $topic
- Difficulty: $difficulty
- Question format: $typeInstruction
- Language: $language (all question and option text in this language)
- Unique question stems only (no duplicate or near-duplicate questions)
- Every marked-correct answer must be factually accurate and verifiable, not a plausible-sounding guess. If you are not confident an answer is objectively true, pick a different, more well-established question instead of guessing.
- Add "stimulus" ONLY when the candidate must read or hear material that is not the question itself (a passage, a conversation, a chart, a table, or a cue card). Omit "stimulus" on every other question.
- stimulus.kind is one of: passage, transcript, chart, table, cue.
- passage, transcript, or cue: {"kind":"passage","title":"short label","body":"the full text the candidate needs"}
- chart: {"kind":"chart","title":"Average temperature","unit":"°C","points":[{"label":"London","value":8},{"label":"Cairo","value":22}]}
- table: {"kind":"table","title":"Weekend visitors","columns":["Place","Saturday"],"rows":[["Museum","120"]]}
- Never write "see the chart", "the table below", "listen to the audio", or "read the passage" unless that material is inside stimulus. The app draws charts and tables and reads transcripts aloud. Do not invent an audio file or an image.
$libraryNote$goalsNote$resolutionNote$inputKindNote$specificityNote$competitiveNote$languageExamNote$skillPracticeNote$consistencyNote$beginnerNote
$explanationInstruction
$refsInstruction
$timerNote
$patternNote
Rules: correctIndex is 0-based and must match the objectively true, verifiable answer (never a confident-sounding but incorrect one); unique plausible options with full answer text (never letter-only like "A","B","C","D"); return exactly $count questions.$consistencyVerify

Schema (questions array must contain exactly $count objects. A mixed example shows one of each shape; still return exactly $count questions, not 3):
$schemaExample
''';
  }

  static String _mixedInstruction(int count) {
    if (count < 3) {
      return 'Mix the formats. Use at least two of mcq (exactly 4 options), true_false (options exactly ["True","False"]), and fill_blank (the stem contains _____ and exactly 4 short options). Set "type" on every question. Do not make every question an MCQ.';
    }
    final trueFalse = (count / 3).floor().clamp(1, count - 2).toInt();
    final fillBlank = (count / 3).floor().clamp(1, count - trueFalse - 1).toInt();
    final mcq = count - trueFalse - fillBlank;
    return 'Mix formats across all $count questions: $mcq with type "mcq" (exactly 4 options), $trueFalse with type "true_false" (options exactly ["True","False"]), and $fillBlank with type "fill_blank" (the stem contains _____ and exactly 4 short options). Set "type" on every question to mcq, true_false, or fill_blank. A set that is all MCQ is invalid.';
  }

  static String _interviewInstruction(String? persona, {bool voiceOnly = false}) {
    if (voiceOnly) {
      return switch (persona) {
        'hr' =>
          'Voice interview — ALL open behavioral/STAR questions ONLY. Every question MUST use options ["__open__"], correctIndex 0, type "behavioral" or "short_answer", rubric in explanation. NO MCQ, NO true/false, NO multiple choice. '
              'Focus on leadership, teamwork, conflict, motivation, and role fit. Pull achievements from resume/JD when provided.',
        'tech' =>
          'Voice interview — ALL open technical/behavioral questions ONLY. Every question MUST use options ["__open__"], correctIndex 0, rubric in explanation. NO MCQ. '
              'Ask about architecture, debugging, trade-offs, system design, and hands-on experience.',
        _ =>
          'Voice interview — ALL open questions ONLY (options ["__open__"], correctIndex 0, rubric in explanation). NO MCQ.',
      };
    }
    return switch (persona) {
      'hr' =>
        'HR / behavioral interview: ~75% STAR behavioral open questions (options ["__open__"], correctIndex 0, rubric in explanation); ~25% culture-fit or situational MCQ (4 options). '
            'Focus on leadership, teamwork, conflict, motivation, and role fit. Pull achievements from resume/JD when provided.',
      'tech' =>
        'Technical interview: ~65% technical MCQ (4 options) on tools, systems, and problem-solving; ~35% technical open questions (options ["__open__"], correctIndex 0, rubric in explanation) on architecture, debugging, or trade-offs.',
      _ =>
        'Interview mix: ~40% short_answer/behavioral (options ["__open__"], correctIndex 0, rubric in explanation); ~60% technical MCQ (4 options). '
            'Questions must be 10/10 hiring quality for the target role. Pull keywords, tools, companies, and achievements from resume/JD excerpts when provided. '
            'Open questions may be about experience or the target company — include a rubric of themes, not one scripted answer.',
    };
  }

  static String _sanitize(String input) {
    return input
        .replaceAll(RegExp(r'[\u0000-\u001F\u007F]'), ' ')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  static String _patternBlock(LearningPatternContext? pattern, String difficulty) {
    if (pattern == null) return '';
    final accuracy = pattern.priorAccuracy;
    var style = 'Adapt to learner module.';
    if (accuracy != null) {
      if (accuracy < 0.6) {
        style = 'Low accuracy (${(accuracy * 100).round()}%): remedial/simpler.';
      } else if (accuracy > 0.85) {
        style = 'Strong accuracy (${(accuracy * 100).round()}%): deeper $difficulty items.';
      }
    }
    final module = pattern.moduleTitle;
    final position = pattern.pathPosition;
    final length = pattern.pathLength;
    final weak = pattern.weakSubtopics.isEmpty ? '' : pattern.weakSubtopics.join(', ');
    final buf = StringBuffer('Pattern: $style');
    if (module != null) buf.write(' Module: $module.');
    if (position != null && length != null) {
      buf.write(' Progress: ${position + 1}/$length.');
    }
    if (weak.isNotEmpty) buf.write(' Weak: $weak.');
    return '$buf\n';
  }
}
