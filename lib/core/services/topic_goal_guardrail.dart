import 'dart:convert';
import 'dart:math' as math;

import 'llm_manager.dart';
import 'topic_goal_relevance.dart';

/// Assesses whether a quiz topic fits the learner's goals.
///
/// Fast local relatedness first; cheap AI JSON only when uncertain.
class TopicGoalGuardrail {
  TopicGoalGuardrail({required LlmManager llmManager}) : _llm = llmManager;

  final LlmManager _llm;

  /// Related tech stems / synonyms so Python ↔ PyTorch etc. pass without AI.
  static const Map<String, Set<String>> _relatedBuckets = {
    'python': {
      'python', 'pytorch', 'numpy', 'pandas', 'django', 'flask', 'fastapi',
      'sklearn', 'scikit', 'tensorflow', 'keras', 'matplotlib', 'scipy',
      'jupyter', 'pip', 'conda', 'asyncio', 'pytest',
    },
    'javascript': {
      'javascript', 'js', 'typescript', 'ts', 'node', 'nodejs', 'react',
      'vue', 'angular', 'nextjs', 'express', 'npm',
    },
    'java': {'java', 'spring', 'jvm', 'kotlin', 'maven', 'gradle', 'jakarta'},
    'flutter': {'flutter', 'dart', 'widget', 'riverpod', 'provider'},
    'aws': {'aws', 'bedrock', 'lambda', 's3', 'ec2', 'cloudformation', 'sagemaker'},
    'ml': {
      'ml', 'machine', 'learning', 'deep', 'neural', 'llm', 'nlp', 'cv',
      'transformer', 'embedding',
    },
  };

  Future<TopicGoalRelevanceResult> assess({
    required String topic,
    required String goalLabel,
    List<String> primaryTopics = const [],
    List<String> focusTitles = const [],
  }) async {
    final corpus = <String>[
      goalLabel,
      ...primaryTopics,
      ...focusTitles,
    ].where((s) => s.trim().isNotEmpty).toList();

    if (corpus.isEmpty) {
      return const TopicGoalRelevanceResult(
        level: TopicGoalRelevance.offGoal,
        score: 0,
      );
    }

    final local = TopicGoalRelevanceGate.evaluate(
      topic: topic,
      goalLabel: goalLabel,
      goalTopics: [...primaryTopics, ...focusTitles],
    );
    if (local.level == TopicGoalRelevance.onGoal) return local;

    if (_bucketRelated(topic, corpus)) {
      return const TopicGoalRelevanceResult(
        level: TopicGoalRelevance.onGoal,
        score: 0.85,
      );
    }

    // Uncertain — ask AI once.
    try {
      final raw = await _llm.completeJson(
        userPrompt: '''
Decide if this quiz topic fits the learner's study goals.
Goals: ${corpus.join('; ')}
Quiz topic: $topic
Related libraries/frameworks/subtopics of a goal count as related (e.g. PyTorch for Python).
Unrelated domains count as not related.

Return JSON only: {"related":true|false,"confidence":0.0-1.0,"reason":"short"}
''',
        systemPrompt:
            'You are a study-goal classifier. Respond with a single valid JSON object only.',
        recordBuiltinQuota: true,
      );
      return _parseAi(raw, fallback: local);
    } catch (_) {
      return local;
    }
  }

  static bool _bucketRelated(String topic, List<String> corpus) {
    final t = topic.toLowerCase();
    final cJoined = corpus.map((e) => e.toLowerCase()).join(' ');
    for (final entry in _relatedBuckets.entries) {
      final hitsTopic = entry.value.any((w) => t.contains(w));
      final hitsGoal = entry.value.any((w) => cJoined.contains(w)) ||
          cJoined.contains(entry.key);
      if (hitsTopic && hitsGoal) return true;
    }
    // Prefix / stem: python ⊂ pytorch already handled by contains in gate;
    // also check goal token as prefix of topic token.
    final topicTokens = t.split(RegExp(r'[^a-z0-9]+')).where((w) => w.length >= 3);
    final goalTokens = cJoined.split(RegExp(r'[^a-z0-9]+')).where((w) => w.length >= 3);
    for (final gt in goalTokens) {
      for (final tt in topicTokens) {
        if (tt.startsWith(gt) || gt.startsWith(tt)) return true;
        if (tt.length >= 4 && gt.length >= 4) {
          final n = math.min(4, math.min(tt.length, gt.length));
          if (tt.substring(0, n) == gt.substring(0, n)) return true;
        }
      }
    }
    return false;
  }

  static TopicGoalRelevanceResult _parseAi(
    String raw, {
    required TopicGoalRelevanceResult fallback,
  }) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return fallback;
      final map = jsonDecode(raw.substring(start, end + 1));
      if (map is! Map) return fallback;
      final related = map['related'] == true;
      final conf = (map['confidence'] is num)
          ? (map['confidence'] as num).toDouble()
          : (related ? 0.8 : 0.2);
      if (related) {
        return TopicGoalRelevanceResult(
          level: TopicGoalRelevance.onGoal,
          score: conf.clamp(0.35, 1.0),
        );
      }
      if (conf < 0.55) {
        return TopicGoalRelevanceResult(
          level: TopicGoalRelevance.borderline,
          score: conf,
        );
      }
      return TopicGoalRelevanceResult(
        level: TopicGoalRelevance.offGoal,
        score: conf,
      );
    } catch (_) {
      return fallback;
    }
  }
}
