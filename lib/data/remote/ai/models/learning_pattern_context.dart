class LearningPatternContext {
  const LearningPatternContext({
    this.moduleTitle,
    this.pathPosition,
    this.pathLength,
    this.priorAccuracy,
    this.weakSubtopics = const [],
  });

  final String? moduleTitle;
  final int? pathPosition;
  final int? pathLength;
  final double? priorAccuracy;
  final List<String> weakSubtopics;
}
