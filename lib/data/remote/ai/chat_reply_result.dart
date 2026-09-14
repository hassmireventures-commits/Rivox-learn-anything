/// Screens chat is allowed to suggest jumping to. Keyed by the exact
/// human-readable name the model is instructed to use in "navigateTo" (see
/// `ChatService`'s system prompt), mapped to the real app route. Deliberately
/// an explicit allowlist rather than trusting a raw path string from the
/// model: only parameterless, generally-useful destinations are included
/// (no quiz/path detail screens, which need an id chat doesn't have; no
/// onboarding/splash; no cloud-backup screen, which is feature-flagged off).
class ChatNavigationTargets {
  ChatNavigationTargets._();

  static const Map<String, String> routes = {
    'Home': '/dashboard',
    'Learn': '/learn',
    'History': '/history',
    'Library': '/library',
    'Flashcards': '/flashcards',
    'Create Quiz': '/quiz/create',
    "Today's Pick": '/daily-content',
    'Saved Articles': '/saved-articles',
    'Skill Matrix': '/career/matrix',
    'Voice Interview': '/career/voice-interview',
    'Study Plan': '/exam/plan',
    'Settings': '/settings',
    'AI Providers': '/settings/providers',
    'Help Center': '/help',
    'Support': '/support',
  };

  /// Case-insensitive lookup (the model doesn't always match casing exactly).
  /// Returns the canonical `(name, route)` pair, or null if unrecognized.
  static (String, String)? match(String name) {
    final lower = name.toLowerCase();
    for (final entry in routes.entries) {
      if (entry.key.toLowerCase() == lower) return (entry.key, entry.value);
    }
    return null;
  }
}

/// A quiz/path/video/navigation proposal the assistant attached inline in a
/// chat reply, never executed by the assistant itself (see `ChatService`'s
/// system prompt: propose, never perform). Persisted via the existing,
/// previously-unused `ChatMessage.contextRef` field so the chip survives app
/// restart/history reload.
class ChatProposedAction {
  const ChatProposedAction.quiz({
    required this.topic,
    this.questionCount,
    this.difficulty,
  })  : kind = 'quiz',
        pathModuleCount = null,
        route = null;

  const ChatProposedAction.path({
    required this.topic,
    this.pathModuleCount,
  })  : kind = 'path',
        questionCount = null,
        difficulty = null,
        route = null;

  /// Never a specific video pick (the model has no way to verify a real
  /// video/ID exists), just a topic to search YouTube for. See
  /// `ChatActionChip`'s video branch: it opens a YouTube search results URL,
  /// never a synthesized watch link.
  const ChatProposedAction.video({required this.topic})
      : kind = 'video',
        questionCount = null,
        difficulty = null,
        pathModuleCount = null,
        route = null;

  /// [topic] holds the destination's display name (e.g. "Library"); [route]
  /// its real app path. Both always come from [ChatNavigationTargets], never
  /// directly from raw model output.
  const ChatProposedAction.navigate({required this.topic, required String this.route})
      : kind = 'navigate',
        questionCount = null,
        difficulty = null,
        pathModuleCount = null;

  /// 'quiz' | 'path' | 'video' | 'navigate'
  final String kind;
  final String topic;
  final int? questionCount;
  final String? difficulty;
  final int? pathModuleCount;
  final String? route;

  bool get isQuiz => kind == 'quiz';
  bool get isPath => kind == 'path';
  bool get isVideo => kind == 'video';
  bool get isNavigate => kind == 'navigate';

  Map<String, dynamic> toJson() => {
        'kind': kind,
        'topic': topic,
        if (questionCount != null) 'questionCount': questionCount,
        if (difficulty != null) 'difficulty': difficulty,
        if (pathModuleCount != null) 'pathModuleCount': pathModuleCount,
        if (route != null) 'route': route,
      };

  /// Defensively decodes a previously-persisted action. Returns null on any
  /// malformed/legacy/unrecognized input rather than throwing, a proposal
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
        case 'navigate':
          // Re-validate against the current allowlist rather than trusting
          // the persisted route string as-is; a route can be renamed/removed
          // in a later app version after this was saved.
          final match = ChatNavigationTargets.match(topic);
          if (match == null) return null;
          return ChatProposedAction.navigate(topic: match.$1, route: match.$2);
        default:
          return null;
      }
    } catch (_) {
      return null;
    }
  }
}

/// One verified public-source hit (Wikipedia, arXiv, etc.) offered as a real,
/// tappable link alongside a reply, never a model-invented one. See
/// `ChatService.sendMessage`: these come straight from `OpenKnowledgeService`,
/// never from the model's own JSON output, so there is no hallucination risk
/// on the link itself.
class ChatSourceSuggestion {
  const ChatSourceSuggestion({required this.title, required this.url, required this.source});

  final String title;
  final String url;
  final String source;

  Map<String, dynamic> toJson() => {'title': title, 'url': url, 'source': source};

  static ChatSourceSuggestion? fromJson(Map<String, dynamic> json) {
    final title = (json['title'] as String?)?.trim();
    final url = (json['url'] as String?)?.trim();
    final source = (json['source'] as String?)?.trim();
    if (title == null || title.isEmpty || url == null || url.isEmpty) return null;
    return ChatSourceSuggestion(title: title, url: url, source: source ?? '');
  }
}

/// Result of a single chat turn: the reply text (always present, always
/// safe to show), an optional proposed action, and optional real source
/// links to show alongside it.
class ChatReplyResult {
  const ChatReplyResult({
    required this.reply,
    this.action,
    this.sources = const [],
  });

  final String reply;
  final ChatProposedAction? action;
  final List<ChatSourceSuggestion> sources;
}
