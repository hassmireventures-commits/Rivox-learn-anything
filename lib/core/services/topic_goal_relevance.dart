import 'dart:math' as math;

import 'goal_topic_resolver.dart';

/// Scores how well a quiz topic matches the learner's active goal.
enum TopicGoalRelevance { onGoal, borderline, offGoal }

class TopicGoalRelevanceResult {
  const TopicGoalRelevanceResult({
    required this.level,
    required this.score,
  });

  final TopicGoalRelevance level;
  final double score;
}

class TopicGoalRelevanceGate {
  TopicGoalRelevanceGate._();

  /// Token overlap + substring heuristics against goal label and topic list.
  static TopicGoalRelevanceResult evaluate({
    required String topic,
    required String goalLabel,
    List<String> goalTopics = const [],
  }) {
    final t = _normalize(topic);
    if (t.isEmpty) {
      return const TopicGoalRelevanceResult(level: TopicGoalRelevance.offGoal, score: 0);
    }
    final corpus = <String>[
      goalLabel,
      ...goalTopics,
    ].map(_normalize).where((s) => s.isNotEmpty).toList();
    if (corpus.isEmpty) {
      // Goals are mandatory — empty corpus is off-goal.
      return const TopicGoalRelevanceResult(level: TopicGoalRelevance.offGoal, score: 0);
    }

    final topicTokens = _tokens(t);
    if (topicTokens.isEmpty) {
      return const TopicGoalRelevanceResult(level: TopicGoalRelevance.offGoal, score: 0);
    }

    // Org/domain goals (elsai.ai): quiz on the same org or its resolved label is on-goal.
    for (final c in corpus) {
      if (!GoalTopicResolver.needsResolution(c)) continue;
      final normGoal = _normalize(c);
      if (t == normGoal || t.contains(normGoal) || normGoal.contains(t)) {
        return const TopicGoalRelevanceResult(level: TopicGoalRelevance.onGoal, score: 0.92);
      }
      final brand = GoalTopicResolver.brandLabel(c);
      if (brand.length >= 3 &&
          (t.contains(brand) || topicTokens.contains(brand))) {
        return const TopicGoalRelevanceResult(level: TopicGoalRelevance.onGoal, score: 0.88);
      }
    }

    var best = 0.0;
    for (final c in corpus) {
      if (t.contains(c) || c.contains(t)) {
        best = math.max(best, 0.95);
        continue;
      }
      final cTokens = _tokens(c);
      if (cTokens.isEmpty) continue;
      final inter = topicTokens.intersection(cTokens).length;
      final union = topicTokens.union(cTokens).length;
      final jaccard = union == 0 ? 0.0 : inter / union;
      // Boost shared meaningful stems (len >= 4).
      final strong = topicTokens.where((x) => x.length >= 4).toSet()
          .intersection(cTokens.where((x) => x.length >= 4).toSet())
          .length;
      final score = (jaccard * 0.7) + (strong > 0 ? 0.3 : 0.0);
      best = math.max(best, score);
    }

    if (best >= 0.35) {
      return TopicGoalRelevanceResult(level: TopicGoalRelevance.onGoal, score: best);
    }
    if (best >= 0.12) {
      return TopicGoalRelevanceResult(level: TopicGoalRelevance.borderline, score: best);
    }
    return TopicGoalRelevanceResult(level: TopicGoalRelevance.offGoal, score: best);
  }

  static String _normalize(String input) =>
      input.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s+]'), ' ').trim();

  static Set<String> _tokens(String input) {
    const stop = {
      'a', 'an', 'the', 'and', 'or', 'of', 'to', 'for', 'in', 'on', 'with', 'my',
      'learn', 'learning', 'study', 'quiz', 'about', 'basics', 'intro', 'introduction',
    };
    return input
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 2 && !stop.contains(w))
        .toSet();
  }
}
