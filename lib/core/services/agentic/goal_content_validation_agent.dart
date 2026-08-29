import 'dart:convert';

import '../goal_topic_resolver.dart';
import '../llm_manager.dart';
import '../org_content_validator.dart';
import '../topic_goal_relevance.dart';
import 'goal_content_validation_result.dart';

/// Single gate for org/domain goal content — deterministic rules first, then a
/// lightweight LLM agent for borderline resolutions. Fail closed on ambiguity.
///
/// All open-knowledge articles, resolved goal topics, and generation topics for
/// opaque goals MUST pass through this agent before user display or LLM prompts.
class GoalContentValidationAgent {
  GoalContentValidationAgent({LlmManager? llmManager}) : _llm = llmManager;

  final LlmManager? _llm;

  /// Validates a Wikipedia / open-knowledge article candidate.
  GoalContentValidationResult validateOpenKnowledgeArticle({
    required String goal,
    required String title,
    required String summary,
  }) {
    if (!GoalTopicResolver.needsResolution(goal)) {
      return GoalContentValidationResult.approved('Not an org/domain goal');
    }
    if (OrgContentValidator.articleMatchesGoal(
      goal: goal,
      title: title,
      summary: summary,
    )) {
      return GoalContentValidationResult.approved(
        'Article matches org goal (deterministic)',
      );
    }
    return GoalContentValidationResult.rejected(
      'Article rejected for org goal "$goal": "$title" looks off-brand or unrelated',
    );
  }

  /// Validates a quiz/path/daily topic string against the learner goal.
  GoalContentValidationResult validateGenerationTopic({
    required String goal,
    required String topic,
    List<String> goalTopics = const [],
  }) {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) {
      return GoalContentValidationResult.rejected('Empty generation topic');
    }

    if (GoalTopicResolver.needsResolution(goal)) {
      if (!OrgContentValidator.articleMatchesGoal(
        goal: goal,
        title: trimmed,
        summary: '',
      )) {
        return GoalContentValidationResult.rejected(
          'Topic "$trimmed" fails org-brand validation for "$goal"',
        );
      }
    }

    final corpus = goalTopics.isEmpty ? [goal] : goalTopics;
    final primary = corpus.first;
    final relevance = TopicGoalRelevanceGate.evaluate(
      topic: trimmed,
      goalLabel: primary,
      goalTopics: corpus,
    );
    if (relevance.level == TopicGoalRelevance.offGoal) {
      return GoalContentValidationResult.rejected(
        'Topic "$trimmed" is off-goal for "$primary"',
      );
    }

    return GoalContentValidationResult.approved('Topic on-goal');
  }

  /// Validates a resolved goal before caching or feeding quiz/path/daily prompts.
  Future<GoalContentValidationResult> validateResolvedGoal(
    ResolvedGoalTopic resolved,
  ) async {
    final goal = resolved.original;
    if (!GoalTopicResolver.needsResolution(goal)) {
      return GoalContentValidationResult.approved('Not an org/domain goal');
    }

    final topicCheck = validateGenerationTopic(
      goal: goal,
      topic: resolved.effectiveTopic,
      goalTopics: [goal],
    );
    if (!topicCheck.approved) return topicCheck;

    final scopeSnippet = resolved.learningScope.length > 320
        ? resolved.learningScope.substring(0, 320)
        : resolved.learningScope;
    final scopeCheck = validateOpenKnowledgeArticle(
      goal: goal,
      title: resolved.effectiveTopic,
      summary: scopeSnippet,
    );
    if (!scopeCheck.approved) return scopeCheck;

    if (_needsAgentReview(resolved)) {
      return _agentReviewResolved(resolved);
    }

    return GoalContentValidationResult.approved(
      'Resolved goal passed deterministic validation',
    );
  }

  /// Returns a safe [ResolvedGoalTopic], falling back when validation fails.
  Future<ResolvedGoalTopic> ensureValidResolved(ResolvedGoalTopic candidate) async {
    final check = await validateResolvedGoal(candidate);
    if (check.approved) return candidate;
    return GoalTopicResolver.deterministicFallback(candidate.original);
  }

  bool _needsAgentReview(ResolvedGoalTopic resolved) {
    final topic = resolved.effectiveTopic.toLowerCase();
    final brand = GoalTopicResolver.brandLabel(resolved.original).toLowerCase();
    if (brand.isEmpty) return false;
    // Agent review when effective topic lacks explicit brand token (LLM may have drifted).
    final brandWord = RegExp(r'\b' + RegExp.escape(brand) + r'\b');
    return !brandWord.hasMatch(topic);
  }

  Future<GoalContentValidationResult> _agentReviewResolved(
    ResolvedGoalTopic resolved,
  ) async {
    final llm = _llm;
    if (llm == null) {
      // Fail closed: without agent, require brand in effective topic for org goals.
      return GoalContentValidationResult.rejected(
        'Borderline resolution lacks brand token; agent unavailable (fail closed)',
      );
    }

    try {
      final raw = await llm.completeJson(
        userPrompt: _agentPrompt(resolved),
        systemPrompt:
            'You validate whether study content matches a learner goal. '
            'Reject biographies, athletes, celebrities, or unrelated subjects '
            'that only share a similar name with a company/domain goal. '
            'Return one JSON object only.',
        recordBuiltinQuota: false,
        skipQuota: true,
      );
      final parsed = _parseAgentVerdict(raw);
      if (parsed == null) {
        return GoalContentValidationResult.rejected(
          'Agent returned invalid JSON (fail closed)',
        );
      }
      if (parsed) {
        return GoalContentValidationResult.approved(
          'Agent confirmed goal alignment',
          layer: GoalValidationLayer.agent,
        );
      }
      return GoalContentValidationResult.rejected(
        'Agent rejected: content does not match org/domain goal',
        layer: GoalValidationLayer.agent,
      );
    } catch (_) {
      return GoalContentValidationResult.rejected(
        'Agent review failed (fail closed)',
      );
    }
  }

  static String _agentPrompt(ResolvedGoalTopic resolved) => '''
Learner goal: "${resolved.original}"
Effective topic: "${resolved.effectiveTopic}"
Learning scope (excerpt): "${resolved.learningScope.length > 400 ? '${resolved.learningScope.substring(0, 397)}...' : resolved.learningScope}"

Question: Is this study content about the SAME organization, product, or domain as the learner goal?
Reject if it describes a different entity (e.g. a person whose name merely resembles the brand, unrelated history, unrelated science fields).

Return JSON: {"approved": true or false, "reason": "one short sentence"}
''';

  static bool? _parseAgentVerdict(String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final map = jsonDecode(raw.substring(start, end + 1));
      if (map is! Map) return null;
      final approved = map['approved'];
      if (approved is bool) return approved;
      if (approved is String) {
        final lower = approved.toLowerCase();
        if (lower == 'true') return true;
        if (lower == 'false') return false;
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
