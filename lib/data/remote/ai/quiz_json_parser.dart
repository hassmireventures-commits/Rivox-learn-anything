import 'dart:convert';

import '../../../core/error/app_exception.dart';
import 'ai_output_gate.dart';
import 'models/generated_quiz.dart';

class QuizJsonParser {
  static bool accepts(String content, {required int expectedCount}) {
    try {
      parse(content, expectedCount: expectedCount);
      return true;
    } catch (_) {
      return false;
    }
  }

  static GeneratedQuiz parse(String content, {required int expectedCount}) {
    final extracted = AiOutputGate.normalizeJsonText(content) ?? content;
    final cleaned = _stripCodeFences(extracted.trim());
    late final Map<String, dynamic> json;
    try {
      final decoded = jsonDecode(cleaned);
      if (decoded is Map<String, dynamic>) {
        json = decoded;
      } else if (decoded is Map) {
        json = Map<String, dynamic>.from(decoded);
      } else if (decoded is List) {
        // Some models return a bare questions array.
        json = {'questions': decoded};
      } else {
        throw const InvalidJsonException(
          'AI returned quiz data in an unexpected format. Try again.',
        );
      }
    } on FormatException {
      throw const InvalidJsonException(
        'AI returned malformed quiz JSON. Try again or switch AI provider in Settings.',
      );
    }

    try {
      final quiz = GeneratedQuiz.fromJson(json);
      if (quiz.questions.isEmpty) {
        throw const InvalidJsonException('No questions were generated.');
      }
      return _finalize(quiz.questions, expectedCount);
    } on FormatException catch (e) {
      throw InvalidJsonException(
        e.message.isEmpty
            ? 'AI returned invalid question data. Try again.'
            : 'Invalid quiz question: ${e.message}',
      );
    }
  }

  static GeneratedQuiz _finalize(
    List<GeneratedQuestion> questions,
    int expectedCount,
  ) {
    final unique = _dedupeQuestions(questions);

    if (unique.length < expectedCount) {
      final duplicateCount = questions.length - unique.length;
      final detail = duplicateCount > 0
          ? ' Found $duplicateCount duplicate question${duplicateCount == 1 ? '' : 's'}.'
          : '';
      throw InvalidJsonException(
        'Only ${unique.length} of $expectedCount questions were usable.$detail Try again.',
      );
    }

    final trimmed = unique.length > expectedCount
        ? unique.take(expectedCount).toList()
        : unique;
    return GeneratedQuiz(questions: trimmed);
  }

  /// Drops duplicate stems (case/spacing/punctuation insensitive), first wins.
  static List<GeneratedQuestion> _dedupeQuestions(
    List<GeneratedQuestion> questions,
  ) {
    final seen = <String>{};
    final out = <GeneratedQuestion>[];
    for (final q in questions) {
      final key = _questionKey(q.text);
      if (key.isEmpty || seen.add(key)) {
        out.add(q);
      }
    }
    return out;
  }

  static String _questionKey(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'\s+'), ' ')
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
  }

  static String _stripCodeFences(String input) {
    var text = input.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*', multiLine: true), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
    }
    text = text.trim();
    // Prefer a top-level array when the payload is a bare questions list.
    if (text.startsWith('[')) {
      final listEnd = text.lastIndexOf(']');
      if (listEnd > 0) {
        return text.substring(0, listEnd + 1);
      }
    }
    final start = text.indexOf('{');
    final end = text.lastIndexOf('}');
    if (start != -1 && end != -1 && end > start) {
      return text.substring(start, end + 1);
    }
    final listStart = text.indexOf('[');
    final listEnd = text.lastIndexOf(']');
    if (listStart != -1 && listEnd != -1 && listEnd > listStart) {
      return text.substring(listStart, listEnd + 1);
    }
    return text;
  }
}
