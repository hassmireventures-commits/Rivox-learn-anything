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
  });

  final String text;
  final List<String> options;
  final int correctIndex;
  final String type;
  final String? explanation;

  factory GeneratedQuestion.fromJson(Map<String, dynamic> json) {
    final text = json['text']?.toString() ?? json['question']?.toString();
    if (text == null || text.trim().isEmpty) {
      throw const FormatException('Question text is required');
    }

    final optionsRaw = json['options'];
    if (optionsRaw is! List || optionsRaw.length < 2) {
      throw const FormatException('Each question needs at least 2 options');
    }
    final options = optionsRaw.map((e) => e.toString()).toList();

    final correctIndex = json['correctIndex'] ?? json['correct_index'] ?? json['answerIndex'];
    if (correctIndex is! int || correctIndex < 0 || correctIndex >= options.length) {
      throw const FormatException('Invalid correctIndex');
    }

    final type = (json['type']?.toString() ?? 'mcq').toLowerCase();
    return GeneratedQuestion(
      text: text.trim(),
      options: options,
      correctIndex: correctIndex,
      type: type,
      explanation: json['explanation']?.toString(),
    );
  }
}
