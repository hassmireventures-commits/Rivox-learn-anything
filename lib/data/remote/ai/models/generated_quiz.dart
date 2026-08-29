import 'dart:convert';

class GeneratedQuiz {
  const GeneratedQuiz({required this.questions});

  final List<GeneratedQuestion> questions;

  factory GeneratedQuiz.fromJson(Map<String, dynamic> json) {
    final list = json['questions'];
    if (list is! List || list.isEmpty) {
      throw const FormatException('Missing questions array');
    }
    return GeneratedQuiz(
      questions: list
          .map((e) => GeneratedQuestion.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList(),
    );
  }
}

class GeneratedQuestion {
  const GeneratedQuestion({
    required this.text,
    required this.options,
    required this.correctIndex,
    required this.type,
    this.explanation,
    this.referencesJson,
  });

  final String text;
  final List<String> options;
  final int correctIndex;
  final String type;
  final String? explanation;
  final String? referencesJson;

  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) {
    final text = json['text']?.toString() ??
        json['question_text']?.toString() ??
        json['question']?.toString();
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('Question text is required');
    }

    final type = (json['type']?.toString() ?? 'mcq').toLowerCase();
    final isOpen = type == 'short_answer' || type == 'behavioral' || type == 'open';

    final optionsRaw = json['options'];
    List<String> options;
    if (isOpen) {
      options = const ['__open__'];
    } else if (optionsRaw is Map) {
      options = _optionsFromLetterMap(optionsRaw);
      if (options.length < 2) {
        throw const FormatException('Each MCQ needs at least 2 options');
      }
    } else if (optionsRaw is List) {
      options = optionsRaw
          .map((e) => e.toString().trim())
          .where((s) => s.isNotEmpty)
          .toList();
      if (options.length < 2) {
        throw const FormatException('Each MCQ needs at least 2 options');
      }
    } else {
      throw const FormatException('Each question needs at least 2 options');
    }

    var correctIndex = json['correctIndex'] ?? json['correct_index'] ?? json['answerIndex'];
    if (correctIndex is String) {
      correctIndex = int.tryParse(correctIndex.trim());
    } else if (correctIndex is num && correctIndex is! int) {
      correctIndex = correctIndex.toInt();
    }
    final answerText = json['correctAnswer'] ??
        json['correct_answer'] ??
        json['answer'] ??
        json['correct'];
    if (answerText != null && !isOpen) {
      final answerStr = answerText.toString().trim();
      final letterIndex = _letterToIndex(answerStr);
      if (letterIndex != null) {
        correctIndex = letterIndex;
      } else {
        final idx = options.indexWhere(
          (o) => o.trim().toLowerCase() == answerStr.toLowerCase(),
        );
        if (idx >= 0) correctIndex = idx;
      }
    }
    if (isOpen) {
      correctIndex = 0;
    } else if (correctIndex is int &&
        correctIndex >= 1 &&
        correctIndex == options.length) {
      // 1-based last option (common LLM mistake).
      correctIndex = correctIndex - 1;
    } else if (correctIndex is! int ||
        correctIndex < 0 ||
        correctIndex >= options.length) {
      throw const FormatException('Invalid correctIndex');
    }

    final rubric = json['rubric'] ?? json['modelAnswer'] ?? json['model_answer'];
    final explanation = json['explanation']?.toString() ??
        (rubric != null ? rubric.toString() : null);

    String? referencesJson;
    final refs = json['references'] ?? json['sources'];
    if (refs is List && refs.isNotEmpty) {
      final cleaned = <Map<String, String>>[];
      for (final item in refs) {
        if (item is! Map) continue;
        final title = item['title']?.toString().trim() ?? '';
        final url = item['url']?.toString().trim() ?? '';
        if (title.isEmpty && url.isEmpty) continue;
        cleaned.add({'title': title.isEmpty ? url : title, 'url': url});
      }
      if (cleaned.isNotEmpty) {
        referencesJson = jsonEncode(cleaned);
      }
    }

    return GeneratedQuestion(
      text: text.trim(),
      options: options,
      correctIndex: correctIndex as int,
      type: isOpen ? (type == 'behavioral' ? 'behavioral' : 'short_answer') : type,
      explanation: explanation,
      referencesJson: referencesJson,
    );
  }

  static List<String> _optionsFromLetterMap(Map<dynamic, dynamic> raw) {
    const letters = ['A', 'B', 'C', 'D', 'E', 'F'];
    final options = <String>[];
    for (final letter in letters) {
      final value = raw[letter] ?? raw[letter.toLowerCase()];
      if (value == null) {
        if (options.isNotEmpty) break;
        continue;
      }
      final text = value.toString().trim();
      if (text.isEmpty) break;
      options.add(text);
    }
    return options;
  }

  static int? _letterToIndex(String value) {
    final letter = value.toUpperCase();
    if (letter.length != 1) return null;
    const map = {'A': 0, 'B': 1, 'C': 2, 'D': 3, 'E': 4, 'F': 5};
    return map[letter];
  }
}
