import 'dart:convert';

/// One multiple-choice question inside a [ChatInlineQuiz].
class ChatInlineQuestion {
  const ChatInlineQuestion({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    this.explanation = '',
  });

  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  Map<String, dynamic> toJson() => {
        'question': prompt,
        'options': options,
        'answerIndex': correctIndex,
        if (explanation.isNotEmpty) 'explanation': explanation,
      };

  /// Lenient decode of one model-written question. Accepts the answer as an
  /// index ("answerIndex"/"answer" number) or as the text of the correct
  /// option ("answer" string). Returns null for anything the card cannot
  /// render honestly: no prompt, fewer than 2 or more than 6 options,
  /// duplicate options, or an answer that does not point at an option.
  static ChatInlineQuestion? fromJson(Map<String, dynamic> json) {
    final prompt = (json['question'] ?? json['prompt'])?.toString().trim() ?? '';
    final rawOptions = json['options'];
    if (prompt.isEmpty || rawOptions is! List) return null;
    final options = rawOptions
        .map((o) => o?.toString().trim() ?? '')
        .where((o) => o.isNotEmpty)
        .toList();
    if (options.length < 2 || options.length > ChatInlineQuiz.maxOptions) return null;
    if (options.map((o) => o.toLowerCase()).toSet().length != options.length) return null;

    int? correct;
    final rawAnswer = json['answerIndex'] ?? json['answer'];
    if (rawAnswer is num) {
      correct = rawAnswer.toInt();
    } else if (rawAnswer is String) {
      // Option text wins over a numeric reading: with options like
      // ["3", "4", "5"], an answer of "4" means the option, not index 4.
      final text = rawAnswer.trim().toLowerCase();
      final byText = options.indexWhere((o) => o.toLowerCase() == text);
      correct = byText >= 0 ? byText : int.tryParse(text);
    }
    if (correct == null || correct < 0 || correct >= options.length) return null;

    return ChatInlineQuestion(
      prompt: prompt,
      options: options,
      correctIndex: correct,
      explanation: json['explanation']?.toString().trim() ?? '',
    );
  }
}

/// A short, interactive check-your-understanding quiz rendered as a form
/// directly inside a chat reply (the in-chat counterpart of the full quiz
/// flow). Unlike `ChatProposedAction.quiz`, nothing is generated or saved as
/// a quiz session: the questions arrive with the reply itself and the
/// learner's picks are persisted alongside them in `ChatMessage.contextRef`
/// (under [contextKey]) so the card restores already answered after reload.
class ChatInlineQuiz {
  const ChatInlineQuiz({
    required this.topic,
    required this.questions,
    this.answers = const [],
  });

  static const int maxQuestions = 5;
  static const int maxOptions = 6;
  static const String contextKey = 'inlineQuiz';

  final String topic;
  final List<ChatInlineQuestion> questions;

  /// Learner's chosen option per question, null while unanswered.
  final List<int?> answers;

  int? answerFor(int questionIndex) =>
      questionIndex < answers.length ? answers[questionIndex] : null;

  int get answeredCount => answers.whereType<int>().length;

  bool get isComplete => answeredCount == questions.length;

  int get score {
    var correct = 0;
    for (var i = 0; i < questions.length; i++) {
      if (answerFor(i) == questions[i].correctIndex) correct++;
    }
    return correct;
  }

  /// Questions the learner got wrong, as (index, question) pairs.
  List<(int, ChatInlineQuestion)> get missed => [
        for (var i = 0; i < questions.length; i++)
          if (answerFor(i) != null && answerFor(i) != questions[i].correctIndex)
            (i, questions[i]),
      ];

  /// Returns a copy with [option] locked in for [questionIndex]. A question
  /// that already has an answer keeps it (answers are final, like the real
  /// quiz flow), so this is safe against double taps.
  ChatInlineQuiz withAnswer(int questionIndex, int option) {
    if (questionIndex < 0 || questionIndex >= questions.length) return this;
    if (option < 0 || option >= questions[questionIndex].options.length) return this;
    if (answerFor(questionIndex) != null) return this;
    final next = List<int?>.generate(questions.length, answerFor);
    next[questionIndex] = option;
    return ChatInlineQuiz(topic: topic, questions: questions, answers: next);
  }

  Map<String, dynamic> toJson() => {
        'topic': topic,
        'questions': questions.map((q) => q.toJson()).toList(),
        if (answeredCount > 0) 'answers': List<int?>.generate(questions.length, answerFor),
      };

  /// Defensive decode for both fresh model output and persisted history.
  /// Invalid questions are dropped individually; returns null only when no
  /// renderable question is left. Never throws.
  static ChatInlineQuiz? fromJson(Object? raw) {
    try {
      if (raw is! Map) return null;
      final json = Map<String, dynamic>.from(raw);
      final rawQuestions = json['questions'];
      if (rawQuestions is! List) return null;
      final questions = rawQuestions
          .whereType<Map>()
          .map((m) => ChatInlineQuestion.fromJson(Map<String, dynamic>.from(m)))
          .whereType<ChatInlineQuestion>()
          .take(maxQuestions)
          .toList();
      if (questions.isEmpty) return null;

      final rawAnswers = json['answers'];
      final answers = List<int?>.generate(questions.length, (i) {
        if (rawAnswers is! List || i >= rawAnswers.length) return null;
        final a = rawAnswers[i];
        if (a is! num) return null;
        final idx = a.toInt();
        return idx >= 0 && idx < questions[i].options.length ? idx : null;
      });

      final topic = json['topic']?.toString().trim() ?? '';
      return ChatInlineQuiz(topic: topic, questions: questions, answers: answers);
    } catch (_) {
      return null;
    }
  }

  /// Reads the quiz out of a persisted `ChatMessage.contextRef`, if any.
  static ChatInlineQuiz? fromContextRef(String? contextRef) {
    if (contextRef == null || contextRef.isEmpty) return null;
    try {
      final decoded = jsonDecode(contextRef);
      if (decoded is! Map) return null;
      return fromJson(decoded[contextKey]);
    } catch (_) {
      return null;
    }
  }

  /// Compact plain-text summary folded into the chat prompt's conversation
  /// history, so the model can follow up on "explain question 2" or "why
  /// was I wrong" without the full card JSON.
  String toHistorySummary() {
    final progress = isComplete
        ? 'score $score/${questions.length}'
        : '$answeredCount/${questions.length} answered';
    final buffer = StringBuffer(
      '[In-chat quiz${topic.isEmpty ? '' : ' on $topic'}, $progress]',
    );
    for (var i = 0; i < questions.length; i++) {
      final q = questions[i];
      final picked = answerFor(i);
      final String status;
      if (picked == null) {
        status = 'unanswered';
      } else if (picked == q.correctIndex) {
        status = 'learner answered correctly';
      } else {
        status = 'learner picked "${q.options[picked]}", wrong';
      }
      buffer.write('\nQ${i + 1}: ${q.prompt} (correct: "${q.options[q.correctIndex]}"; $status)');
    }
    return buffer.toString();
  }
}

/// Short tappable follow-ups shown under the latest reply (quick replies, as
/// in ChatGPT/Claude). Normalized: trimmed, de-duplicated, length capped, at
/// most [max] entries.
class ChatSuggestedReplies {
  ChatSuggestedReplies._();

  static const int max = 3;
  static const int maxLength = 80;
  static const String contextKey = 'suggestions';

  static List<String> normalize(Object? raw) {
    if (raw is! List) return const [];
    final seen = <String>{};
    final out = <String>[];
    for (final item in raw) {
      final text = item?.toString().trim() ?? '';
      if (text.isEmpty || text.length > maxLength) continue;
      if (!seen.add(text.toLowerCase())) continue;
      out.add(text);
      if (out.length == max) break;
    }
    return out;
  }
}
