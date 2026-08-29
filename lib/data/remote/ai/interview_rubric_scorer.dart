import 'dart:convert';

import '../../../core/error/app_exception.dart';
import '../../../core/services/built_in_ai_config.dart';
import '../../../core/services/built_in_ai_quota.dart';
import 'ai_json_client.dart';
import 'ai_output_gate.dart';
import '../../local/models/ai_provider_config.dart';
import '../../local/models/question.dart';

/// Scores open interview answers against stored rubric / model answer.
class InterviewRubricScorer {
  const InterviewRubricScorer();

  Future<void> scoreOpenAnswers({
    required AiProviderConfig config,
    required String apiKey,
    required List<Question> questions,
    required String roleContext,
  }) async {
    final open = questions.where(_isOpen).toList();
    if (open.isEmpty) return;

    final isBuiltin = config.uuid == BuiltInAiConfig.uuid;

    for (final q in open) {
      final answer = (q.userAnswer ?? '').trim();
      if (answer.isEmpty) {
        q.aiScore = 0;
        q.isCorrect = false;
        continue;
      }

      // Fast lexical fallback when AI fails or Built-in quota is exhausted.
      double fallback() {
        final rubric = (q.rubricJson ?? q.explanation ?? '').toLowerCase();
        if (rubric.isEmpty) return answer.length >= 40 ? 0.55 : 0.35;
        final tokens = rubric
            .split(RegExp(r'[^a-z0-9]+'))
            .where((t) => t.length > 3)
            .toSet();
        if (tokens.isEmpty) return 0.5;
        final lower = answer.toLowerCase();
        final hits = tokens.where(lower.contains).length;
        return (hits / tokens.length).clamp(0.2, 0.95);
      }

      try {
        if (isBuiltin) {
          await BuiltInAiQuota.instance.ensureCanGenerate();
        }
        final raw = await AiJsonClient.complete(
          config: config,
          apiKey: apiKey,
          systemPrompt:
              'You are an interview judge. Respond with JSON only: {"score":0.0,"feedback":"..."}. score is 0 - 1. '
              'There is often no single 100% correct answer for experience, motivation, or company-fit questions. '
              'Score substance, relevance to the role, and honesty. Do not require the candidate to match a model answer word-for-word.',
          userPrompt: '''
Role / company context: $roleContext
Question: ${q.text}
Rubric / expected themes (not a single correct script): ${q.rubricJson ?? q.explanation ?? '(none)'}
Candidate answer: $answer

Judge like a senior interviewer. Reward specific experience and role-fit. Deduct for empty, off-topic, or generic answers.
''',
        );
        final map = jsonDecode(
          AiOutputGate.normalizeJsonText(raw) ?? _stripFences(raw),
        );
        if (map is Map) {
          final score = ((map['score'] as num?)?.toDouble() ?? fallback()).clamp(0.0, 1.0);
          q.aiScore = score;
          q.isCorrect = score >= 0.6;
          final feedback = map['feedback']?.toString();
          if (feedback != null && feedback.isNotEmpty) {
            q.explanation = feedback;
          }
          if (isBuiltin) {
            await BuiltInAiQuota.instance.recordGeneration();
          }
        } else {
          q.aiScore = fallback();
          q.isCorrect = (q.aiScore ?? 0) >= 0.6;
        }
      } on BuiltInQuotaExceededException {
        q.aiScore = fallback();
        q.isCorrect = (q.aiScore ?? 0) >= 0.6;
      } catch (_) {
        q.aiScore = fallback();
        q.isCorrect = (q.aiScore ?? 0) >= 0.6;
      }
    }
  }

  static bool _isOpen(Question q) {
    final t = q.type.toLowerCase();
    if (t == 'short_answer' || t == 'behavioral' || t == 'open') return true;
    try {
      final opts = jsonDecode(q.optionsJson);
      return opts is List && opts.length == 1 && opts.first.toString() == '__open__';
    } catch (_) {
      return false;
    }
  }

  static String _stripFences(String raw) {
    var s = raw.trim();
    if (s.startsWith('```')) {
      s = s.replaceFirst(RegExp(r'^```(?:json)?\s*'), '');
      s = s.replaceFirst(RegExp(r'\s*```$'), '');
    }
    return s.trim();
  }
}
