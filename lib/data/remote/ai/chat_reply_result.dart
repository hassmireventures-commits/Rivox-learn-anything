/// A quiz or learning-path generation the assistant proposed inline in a
/// chat reply — never executed by the assistant itself (see
/// `ChatService`'s system prompt: propose, never perform). Persisted via
/// the existing, previously-unused `ChatMessage.contextRef` field so the
/// action chip survives app restart/history reload.
class ChatProposedAction {
  const ChatProposedAction.quiz({
    required this.topic,
    this.questionCount,
    this.difficulty,
  })  : kind = 'quiz',
        pathModuleCount = null;

  const ChatProposedAction.path({
    required this.topic,
    this.pathModuleCount,
  })  : kind = 'path',
        questionCount = null,
        difficulty = null;

  /// Never a specific video pick (the model has no way to verify a real
  /// video/ID exists), just a topic to search YouTube for. See
  /// `ChatActionChip`'s video branch: it opens a YouTube search results URL,
  /// never a synthesized watch link.
  const ChatProposedAction.video({required this.topic})
      : kind = 'video',
        questionCount = null,
        difficulty = null,
        pathModuleCount = null;

  /// 'quiz' | 'path' | 'video'
  final String kind;
  final String topic;
  final int? questionCount;
  final String? difficulty;
  final int? pathModuleCount;

  bool get isQuiz => kind == 'quiz';
  bool get isPath => kind == 'path';
  bool get isVideo => kind == 'video';

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'topic': topic,
        if (questionCount != null) 'questionCount': questionCount,
        if (difficulty != null) 'difficulty': difficulty,
        if (pathModuleCount != null) 'pathModuleCount': pathModuleCount,
      };

  /// Defensively decodes a previously-persisted action. Returns null on any
  /// malformed/legacy/unrecognized input rather than throwing — a proposal
  /// chip that can't be reconstructed just doesn't render, it never crashes
  /// the chat history.
  static ChatProposedAction? fromJson(Map<String, dynamic> json) {
    try {
      final kind = json['kind'] as String?;
      final topic = (json['topic'] as String?)?.trim();
      if (topic == null || topic.isEmpty) return null;
      switch (kind) {
        case 'quiz':
          return ChatProposedAction.quiz(
            topic: topic,
            questionCount: (json['questionCount'] as num?)?.toInt(),
            difficulty: json['difficulty'] as String?,
          );
        case 'path':
          return ChatProposedAction.path(
            topic: topic,
            pathModuleCount: (json['pathModuleCount'] as num?)?.toInt(),
          );
        case 'video':
          return ChatProposedAction.video(topic: topic);
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }
}

/// Result of a single chat turn: the reply text (always present, always
/// safe to show) plus an optional proposed action.
class ChatReplyResult {
  const ChatReplyResult({required this.reply, this.action});

  final String reply;
  final ChatProposedAction? action;
}
