/// Ties a generation topic to the learner's goal and, for a module quiz, to
/// the path it belongs to, BEFORE anything is generated or looked up.
///
/// Why: a module title on its own is often ambiguous. "Advanced English" in an
/// IELTS path was sent bare to Wikipedia, which returned "Advance (English
/// automobile)", and the quiz came back about a 1900s car. Every lookup and
/// prompt now sees "Advanced English (IELTS)" plus an explicit instruction to
/// read the module in the sense of the goal.
class LearningContext {
  const LearningContext({
    required this.topic,
    required this.generationTopic,
    this.goal = '',
    this.pathFocus = '',
  });

  /// What the caller asked for, unchanged (the module or quiz title).
  final String topic;

  /// Topic used for lookups and the prompt. Equals [topic] unless the module
  /// needs its goal or path attached to be unambiguous.
  final String generationTopic;

  /// Learner goal (e.g. "IELTS"), empty when unknown.
  final String goal;

  /// Focus of the learning path this module belongs to, empty when the quiz
  /// is not a module quiz.
  final String pathFocus;

  bool get isAnchored => generationTopic != topic;

  /// Words shorter than this are ignored when checking whether a topic
  /// already mentions its anchor.
  static const int _minTokenLength = 3;

  static const Set<String> _stopWords = {
    'and', 'the', 'for', 'with', 'from', 'into', 'your', 'path', 'module',
    'learn', 'learning', 'course', 'guide', 'basics', 'intro', 'introduction',
    'advanced', 'beginner', 'intermediate', 'practice', 'prep', 'preparation',
  };

  /// Builds the context. [pathTitle] may carry the legacy "Path: " prefix.
  /// The anchor is attached only for module quizzes ([isModule]); a quick
  /// quiz the learner typed themselves keeps its exact wording, and only
  /// gets the goal as a hint in [promptBlock].
  static LearningContext compose({
    required String topic,
    String? goal,
    String? pathTitle,
    bool isModule = false,
  }) {
    final cleanTopic = topic.trim();
    final cleanGoal = (goal ?? '').trim();
    final cleanPath = _stripPathPrefix(pathTitle ?? '');

    var generationTopic = cleanTopic;
    if (isModule && cleanTopic.isNotEmpty) {
      final anchor = cleanGoal.isNotEmpty ? cleanGoal : cleanPath;
      if (anchor.isNotEmpty && !mentions(cleanTopic, anchor)) {
        generationTopic = '$cleanTopic ($anchor)';
      }
    }
    return LearningContext(
      topic: cleanTopic,
      generationTopic: generationTopic,
      goal: cleanGoal,
      pathFocus: cleanPath,
    );
  }

  /// True when [text] already contains every meaningful word of [anchor]
  /// (whole-word, case-insensitive), e.g. "IELTS Reading" mentions "IELTS".
  static bool mentions(String text, String anchor) {
    final words = tokens(text);
    final anchorWords = tokens(anchor);
    if (anchorWords.isEmpty) return true;
    return anchorWords.every(words.contains);
  }

  static Set<String> tokens(String text) => text
      .toLowerCase()
      .split(RegExp(r'[^a-z0-9+#]+'))
      .where((w) => w.length >= _minTokenLength && !_stopWords.contains(w))
      .toSet();

  static String _stripPathPrefix(String title) =>
      title.trim().replaceFirst(RegExp(r'^path:\s*', caseSensitive: false), '').trim();

  /// Prompt section telling the model how to read the topic. Empty when
  /// there is no goal or path to anchor to.
  String get promptBlock {
    if (goal.isEmpty && pathFocus.isEmpty) return '';
    final buffer = StringBuffer('LEARNING CONTEXT (read the topic in this sense):\n');
    if (goal.isNotEmpty) buffer.writeln('- Learner goal: $goal');
    if (pathFocus.isNotEmpty) buffer.writeln('- Learning path: $pathFocus');
    buffer.writeln('- This quiz: $topic');
    final scope = goal.isNotEmpty ? goal : pathFocus;
    if (pathFocus.isNotEmpty) {
      buffer.writeln(
        '"$topic" is a module of the path above. Every question must test '
        '"$topic" as a step toward $scope, at the level that goal needs.',
      );
    } else {
      buffer.writeln(
        'If "$topic" has more than one meaning, use the one that fits $scope.',
      );
    }
    buffer.writeln(
      'Never read a word in the title as a product, brand, vehicle, company, '
      'place, or person unless the goal is about that thing. Reference '
      'material that is about a different sense of the words must be ignored.',
    );
    return buffer.toString();
  }
}
