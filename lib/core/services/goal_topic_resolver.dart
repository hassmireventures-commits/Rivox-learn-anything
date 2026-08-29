import 'dart:convert';

import 'llm_manager.dart';
import 'open_knowledge/open_knowledge_service.dart';
import 'agentic/goal_content_validation_agent.dart';
import 'topic_grounding_service.dart';

/// Result of a lightweight LLM "think" step before generating quizzes/paths/daily picks.
class ResolvedGoalTopic {
  const ResolvedGoalTopic({
    required this.original,
    required this.effectiveTopic,
    required this.learningScope,
    this.avoid = const [],
  });

  final String original;
  final String effectiveTopic;
  final String learningScope;
  final List<String> avoid;

  String get promptBlock {
    final forbidden = avoid.isEmpty
        ? 'generic unrelated subjects'
        : avoid.join(', ');
    return '''
GOAL RESOLUTION (required think step — learner entered "$original"):
$learningScope
Effective topic label: $effectiveTopic
All generated content MUST match this scope. FORBIDDEN: $forbidden.
If the input is a company, product, or domain name, teach what that organization does — do NOT substitute a random unrelated field.
''';
  }
}

/// Detects opaque goals (domains, org names) and resolves them via web grounding
/// (homepage + Wikipedia) with LLM fallback when grounding is insufficient.
class GoalTopicResolver {
  GoalTopicResolver({
    required LlmManager llmManager,
    TopicGroundingService? groundingService,
    OpenKnowledgeService? openKnowledge,
  })  : _llm = llmManager,
        _grounding = groundingService ?? TopicGroundingService(),
        _openKnowledge = openKnowledge ?? OpenKnowledgeService();

  final LlmManager _llm;
  final TopicGroundingService _grounding;
  final OpenKnowledgeService _openKnowledge;
  late final GoalContentValidationAgent _validationAgent =
      GoalContentValidationAgent(llmManager: _llm);
  static final Map<String, ResolvedGoalTopic> _cache = {};

  static bool needsResolution(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return false;
    final lower = t.toLowerCase();

    if (RegExp(
      r'^(?:https?://)?(?:www\.)?[a-z0-9][-a-z0-9]*\.(?:ai|com|io|org|net|co|dev|app)(?:/|$)',
      caseSensitive: false,
    ).hasMatch(lower)) {
      return true;
    }

    if (lower.contains('.ai') ||
        lower.contains('.io') ||
        lower.contains('.com') ||
        lower.contains('.dev')) {
      return true;
    }

    // Single opaque token (no spaces) that is not a common study subject word.
    if (!t.contains(' ') && t.length >= 4) {
      if (RegExp(r'^[a-z0-9][-a-z0-9.]*$', caseSensitive: false).hasMatch(t) &&
          t.contains('.')) {
        return true;
      }
      // Brand-like single token: Elsai, OpenAI-style without TLD
      if (RegExp(r'^[A-Za-z][a-zA-Z0-9.-]{2,}$').hasMatch(t) &&
          t == t.toLowerCase() &&
          ! _commonSubjects.contains(lower)) {
        return t.contains('.') || lower.endsWith('ai');
      }
    }

    return false;
  }

  static const _commonSubjects = {
    'python', 'javascript', 'java', 'flutter', 'dart', 'react', 'biology',
    'chemistry', 'physics', 'math', 'history', 'english', 'marketing',
    'finance', 'medicine', 'nursing', 'law', 'design', 'music', 'art',
  };

  Future<ResolvedGoalTopic?> resolve(String raw) async {
    final trimmed = raw.trim();
    if (trimmed.isEmpty || !needsResolution(trimmed)) return null;

    final cacheKey = trimmed.toLowerCase();
    final cached = _cache[cacheKey];
    if (cached != null) return cached;

    final fromWeb = await _resolveFromWeb(trimmed);
    if (fromWeb != null) {
      final enriched = await _enrichWithOpenKnowledge(fromWeb);
      final validated = await _validationAgent.ensureValidResolved(enriched);
      _cache[cacheKey] = validated;
      return validated;
    }

    try {
      final rawJson = await _llm.completeJson(
        userPrompt: _prompt(trimmed),
        systemPrompt:
            'You infer what a learner wants to study from short or opaque goal labels '
            '(company names, product names, domains like elsai.ai). '
            'Use general knowledge; if unknown, infer from the name and domain. '
            'Respond with a single valid JSON object only. No markdown.',
        recordBuiltinQuota: false,
        skipQuota: true,
      );
      final parsed = _parse(trimmed, rawJson);
      if (parsed != null) {
        final enriched = await _enrichWithOpenKnowledge(parsed);
        final validated = await _validationAgent.ensureValidResolved(enriched);
        _cache[cacheKey] = validated;
        return validated;
      }
    } catch (_) {
      // Fall through to deterministic fallback.
    }

    final fallback = await _enrichWithOpenKnowledge(deterministicFallback(trimmed));
    _cache[cacheKey] = fallback;
    return fallback;
  }

  Future<ResolvedGoalTopic> _enrichWithOpenKnowledge(ResolvedGoalTopic base) async {
    try {
      final block = await _openKnowledge.gatherPromptContext(base.original);
      if (block.trim().isEmpty) return base;
      return ResolvedGoalTopic(
        original: base.original,
        effectiveTopic: base.effectiveTopic,
        learningScope: '${base.learningScope}\n\n$block',
        avoid: base.avoid,
      );
    } catch (_) {
      return base;
    }
  }

  /// Always succeeds for opaque org/domain goals when web + LLM are unavailable.
  static ResolvedGoalTopic deterministicFallback(String original) {
    final brand = TopicGroundingService.wikipediaSearchTerm(original);
    final label = brand.isEmpty
        ? original
        : '${brand[0].toUpperCase()}${brand.substring(1)}';
    final lower = original.toLowerCase();
    final isAiDomain = lower.contains('.ai') || lower.endsWith('ai');
    final scope = StringBuffer()
      ..write('The learner set "$original" as a study goal. ')
      ..write('Focus on what $label is, what it builds or offers, ')
      ..write('and skills someone needs to work with this organization. ');
    if (isAiDomain) {
      scope.write(
        'This appears to be an AI or technology company — teach its products and domain, '
        'not generic unrelated programming or ML trivia.',
      );
    } else {
      scope.write(
        'Do not substitute unrelated generic tutorials or random industry trivia.',
      );
    }
    return ResolvedGoalTopic(
      original: original,
      effectiveTopic: '$label — organization and products',
      learningScope: scope.toString(),
      avoid: TopicGroundingService.defaultAvoidList(original),
    );
  }

  /// Brand token extracted from a domain goal (e.g. elsai.ai → elsai).
  static String brandLabel(String raw) =>
      TopicGroundingService.wikipediaSearchTerm(raw);

  Future<ResolvedGoalTopic?> _resolveFromWeb(String trimmed) async {
    try {
      final facts = await _grounding.gather(trimmed);
      if (facts == null || !facts.isUsable) return null;

      final scope = TopicGroundingService.buildLearningScope(facts, trimmed);
      if (scope.length < 25) return null;

      final effectiveTopic =
          TopicGroundingService.buildEffectiveTopic(facts, trimmed);

      return ResolvedGoalTopic(
        original: trimmed,
        effectiveTopic: effectiveTopic,
        learningScope: scope,
        avoid: TopicGroundingService.defaultAvoidList(trimmed),
      );
    } catch (_) {
      return null;
    }
  }

  static String _prompt(String topic) => '''
The learner set this study goal: "$topic"

Think first: what do they most likely want to learn? If it is a company, startup, SaaS product, or domain name, describe what that organization/product does and what skills or knowledge someone studying it should focus on.

Return JSON only:
{
  "effectiveTopic": "short human-readable topic (5-12 words)",
  "learningScope": "2-4 sentences: what to teach, quiz, or recommend. Be specific to this org/product.",
  "avoid": ["list", "of", "irrelevant", "tangents", "to", "exclude"]
}

Example for "elsai.ai": effectiveTopic might be "Elsai AI platform and products", learningScope explains Elsai's AI/business focus — NOT generic web development or unrelated AI trivia.
''';

  static ResolvedGoalTopic? _parse(String original, String raw) {
    try {
      final start = raw.indexOf('{');
      final end = raw.lastIndexOf('}');
      if (start < 0 || end <= start) return null;
      final map = jsonDecode(raw.substring(start, end + 1));
      if (map is! Map) return null;
      final effective = map['effectiveTopic']?.toString().trim() ?? '';
      final scope = map['learningScope']?.toString().trim() ?? '';
      if (effective.isEmpty || scope.isEmpty) return null;
      final avoidRaw = map['avoid'];
      final avoid = <String>[];
      if (avoidRaw is List) {
        for (final item in avoidRaw) {
          final s = item.toString().trim();
          if (s.isNotEmpty) avoid.add(s);
        }
      }
      return ResolvedGoalTopic(
        original: original,
        effectiveTopic: effective,
        learningScope: scope,
        avoid: avoid,
      );
    } catch (_) {
      return null;
    }
  }

  /// Clears in-memory resolution cache (e.g. after full data reset).
  static void clearCache() => _cache.clear();
}
