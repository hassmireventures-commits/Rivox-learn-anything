import 'dart:convert';

import '../../../core/error/app_exception.dart';
import 'models/generated_quiz.dart';

class QuizJsonParser {
  static GeneratedQuiz parse(String content, {required int expectedCount}) {
    final cleaned = _stripCodeFences(content.trim());
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
        throw const InvalidJsonException();
      }
    } on FormatException {
      throw const InvalidJsonException();
    }

    try {
      final quiz = GeneratedQuiz.fromJson(json);
      if (quiz.questions.isEmpty) {
        throw const InvalidJsonException('No questions were generated.');
      }
      if (quiz.questions.length > expectedCount * 2) {
        // Guard against runaway payloads; keep the requested count.
        return GeneratedQuiz(questions: quiz.questions.take(expectedCount).toList());
      }
      return quiz;
    } on FormatException catch (e) {
      throw InvalidJsonException(e.message);
    }
  }

  static String _stripCodeFences(String input) {
    var text = input.trim();
    if (text.startsWith('```')) {
      text = text.replaceFirst(RegExp(r'^```(?:json)?\s*', multiLine: true), '');
      text = text.replaceFirst(RegExp(r'\s*```$'), '');
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
