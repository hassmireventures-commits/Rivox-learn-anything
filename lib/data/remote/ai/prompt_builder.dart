import 'competitive_exam_prompt.dart';
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
      'mcq' => 'All MCQ with exactly 4 options.',
      'true_false' => 'All True/False; options ["True","False"].',
      'fill_blank' => 'Fill-in-the-blank with 4 plausible options each.',
      'interview' => _interviewInstruction(
          request.interviewPersona,
          voiceOnly: request.voiceInterviewOnly,
        ),
      _ => 'Mix MCQ / TrueFalse / fill-blank; always include options arrays.',
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
    final competitiveNote = CompetitiveExamPrompt.block(request);
    final consistencyNote = QuizConsistencyPrompt.block(request);
    final specificityNote = TopicSpecificityPrompt.block(request);
    final resolutionNote = request.topicResolutionBlock.isNotEmpty
        ? '${request.topicResolutionBlock}\n'
        : '';
    final suppressBeginner = CompetitiveExamPrompt.suppressBeginnerTrack(request) ||
        TopicSpecificityPrompt.suppressBeginnerTrack(request);
    final beginnerNote = suppressBeginner
        ? ''
        : (difficulty == 'easy' || skill == null || skill < 0.5)
            ? 'BEGINNER TRACK: assume ZERO prior knowledge. Ask the most foundational questions within the EXACT subfield named in the topic — start from absolute basics, not intermediate concepts. No advanced jargon, no expert-only traps.\n'
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
$libraryNote$goalsNote$resolutionNote$specificityNote$competitiveNote$consistencyNote$beginnerNote
$explanationInstruction
$refsInstruction
$timerNote
$patternNote
Rules: correctIndex is 0-based and must match the true answer; unique plausible options with full answer text (never letter-only like "A","B","C","D"); return exactly $count questions.$consistencyVerify

Schema (questions array must contain exactly $count objects like this):
{"questions":[{"text":"What is 2+2?","options":["3","4","5","6"],"correctIndex":1,"type":"mcq","explanation":$explanationExample$refsExample}]}
''';
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
