class OutputValidationResult {
  const OutputValidationResult({required this.valid, this.reason});

  final bool valid;
  final String? reason;
}

class OutputValidator {
  const OutputValidator();

  OutputValidationResult validateQuizJson(Map<String, dynamic> json) {
    final questions = json['questions'];
    if (questions is! List || questions.isEmpty) {
      return const OutputValidationResult(valid: false, reason: 'No questions in response.');
    }
    for (final q in questions) {
      if (q is! Map) {
        return const OutputValidationResult(valid: false, reason: 'Invalid question shape.');
      }
      final text = q['text']?.toString().trim() ?? '';
      if (text.isEmpty || text.length < 3) {
        return const OutputValidationResult(valid: false, reason: 'Empty question text.');
      }
      if (_isPlaceholder(text)) {
        return const OutputValidationResult(valid: false, reason: 'Placeholder question detected.');
      }
    }
    return const OutputValidationResult(valid: true);
  }

  OutputValidationResult validatePathJson(Map<String, dynamic> json) {
    final steps = json['steps'];
    if (steps is! List || steps.isEmpty) {
      return const OutputValidationResult(valid: false, reason: 'No path steps in response.');
    }
    for (final step in steps) {
      if (step is! Map) {
        return const OutputValidationResult(valid: false, reason: 'Invalid step shape.');
      }
      final title = step['title']?.toString().trim() ?? '';
      if (title.isEmpty || _isPlaceholder(title)) {
        return const OutputValidationResult(valid: false, reason: 'Invalid step title.');
      }
    }
    return const OutputValidationResult(valid: true);
  }

  bool _isPlaceholder(String text) {
    final lower = text.toLowerCase();
    return lower.contains('lorem ipsum') ||
        lower.contains('placeholder') ||
        lower == 'string' ||
        lower == 'question text';
  }
}
