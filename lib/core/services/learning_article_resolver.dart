import '../../data/remote/ai/resource_link_validator.dart';
import 'agentic/goal_content_validation_agent.dart';
import 'coding_tutorial_sources.dart';
import 'goal_topic_resolver.dart';
import 'open_knowledge/wikipedia_source.dart';
import 'topic_grounding_service.dart';

/// Reachable allowlisted article resolved for any learning topic.
class ResolvedLearningArticle {
  const ResolvedLearningArticle({
    required this.title,
    required this.url,
    required this.summary,
    this.score = 0,
  });

  final String title;
  final String url;
  final String summary;
  final int score;
}

/// Internal candidate before reachability validation.
class ArticleCandidate {
  const ArticleCandidate({
    required this.title,
    required this.url,
    required this.summary,
    required this.source,
    this.queryRank = 0,
    this.resultRank = 0,
  });

  final String title;
  final String url;
  final String summary;
  final String source;
  final int queryRank;
  final int resultRank;
}

/// Goal-aware article resolution for paths, daily packs, and fallbacks.
/// Gathers candidates from multiple allowlisted sources, scores by relevance,
/// and returns the top reachable match — not Wikipedia-first.
class LearningArticleResolver {
  LearningArticleResolver._();

  static final WikipediaSource _wikipedia = WikipediaSource();
  static final GoalContentValidationAgent _validator =
      GoalContentValidationAgent();

  /// Finds the highest-scoring reachable article for [topic].
  static Future<ResolvedLearningArticle?> resolve({
    required String topic,
    String goalContext = '',
    String pathTitle = '',
    Set<String> excludeUrls = const {},
  }) async {
    final ranked = await resolveRanked(
      topic: topic,
      goalContext: goalContext,
      pathTitle: pathTitle,
      excludeUrls: excludeUrls,
      limit: 1,
    );
    return ranked.isEmpty ? null : ranked.first;
  }

  /// Returns up to [limit] top-scoring reachable articles (deduped by URL).
  static Future<List<ResolvedLearningArticle>> resolveRanked({
    required String topic,
    String goalContext = '',
    String pathTitle = '',
    Set<String> excludeUrls = const {},
    int limit = 3,
  }) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty || limit < 1) return const [];

    final validateGoal = _validationGoal(goalContext, trimmedTopic);
    final condensed = condenseLearningTitle(trimmedTopic);
    final candidates = await gatherCandidates(
      topic: trimmedTopic,
      goalContext: goalContext,
      pathTitle: pathTitle,
      validateForGoal: validateGoal,
    );

    final scored = <({ArticleCandidate candidate, int score})>[];
    for (final c in candidates) {
      if (excludeUrls.contains(c.url)) continue;
      scored.add((
        candidate: c,
        score: scoreCandidate(
          candidate: c,
          topic: trimmedTopic,
          goalContext: goalContext,
          condensedTopic: condensed,
        ),
      ));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));

    final out = <ResolvedLearningArticle>[];
    final seenUrls = <String>{};
    for (final entry in scored) {
      if (out.length >= limit) break;
      final c = entry.candidate;
      if (!seenUrls.add(c.url)) continue;

      if (validateGoal != null &&
          !_validator
              .validateOpenKnowledgeArticle(
                goal: validateGoal,
                title: c.title,
                summary: c.summary,
              )
              .approved) {
        continue;
      }

      final accepted = await ResourceLinkValidator.acceptDailyResource(
        type: 'article',
        url: c.url,
        topic: trimmedTopic,
        title: c.title,
        trustedFallback: true,
      );
      if (!accepted.ok) continue;

      out.add(ResolvedLearningArticle(
        title: c.title,
        url: accepted.url,
        summary: c.summary,
        score: entry.score,
      ));
    }
    return out;
  }

  /// Collects article candidates from tutorials, Wikipedia, and heuristic allowlisted URLs.
  static Future<List<ArticleCandidate>> gatherCandidates({
    required String topic,
    String goalContext = '',
    String pathTitle = '',
    String? validateForGoal,
  }) async {
    final trimmedTopic = topic.trim();
    if (trimmedTopic.isEmpty) return const [];

    final condensed = condenseLearningTitle(trimmedTopic);
    final out = <ArticleCandidate>[];
    final seenUrls = <String>{};

    void add(ArticleCandidate c) {
      if (!seenUrls.add(c.url)) return;
      out.add(c);
    }

    final codingSeed = CodingTutorialSources.isCodingTopic(trimmedTopic)
        ? trimmedTopic
        : (CodingTutorialSources.isCodingTopic(goalContext) ? goalContext : '');

    if (codingSeed.isNotEmpty) {
      final codingArticles = CodingTutorialSources.articleCandidates(codingSeed);
      for (var i = 0; i < codingArticles.length; i++) {
        final c = codingArticles[i];
        add(ArticleCandidate(
          title: c.title,
          url: c.url,
          summary: c.summary,
          source: _hostSource(c.url),
          queryRank: 0,
          resultRank: i,
        ));
      }
    }

    final queries = buildSearchQueries(
      topic: trimmedTopic,
      goalContext: goalContext,
      pathTitle: pathTitle,
    );
    for (var qi = 0; qi < queries.length; qi++) {
      final hits = await _wikipedia.searchArticles(queries[qi], limit: 5);
      for (var ri = 0; ri < hits.length; ri++) {
        final hit = hits[ri];
        final url = hit.url;
        if (url == null) continue;
        if (validateForGoal != null &&
            !_validator
                .validateOpenKnowledgeArticle(
                  goal: validateForGoal,
                  title: hit.title,
                  summary: hit.summary,
                )
                .approved) {
          continue;
        }
        add(ArticleCandidate(
          title: hit.title,
          url: url,
          summary: hit.summary,
          source: 'wikipedia',
          queryRank: qi,
          resultRank: ri,
        ));
      }
    }

    for (final h in _heuristicCandidates(condensed, trimmedTopic, goalContext)) {
      add(h);
    }

    return out;
  }

  /// Ranks a candidate for [topic] with optional [goalContext].
  static int scoreCandidate({
    required ArticleCandidate candidate,
    required String topic,
    String goalContext = '',
    required String condensedTopic,
  }) {
    var score = 0;
    final haystack = '${candidate.title} ${candidate.url} ${candidate.summary}';
    final host = Uri.tryParse(candidate.url)?.host ?? '';

    score += _overlapScore(condensedTopic, haystack) * 12;
    score += _overlapScore(topic, haystack) * 8;
    if (goalContext.trim().isNotEmpty) {
      score += _overlapScore(goalContext, haystack) * 6;
    }

    score += _sourceBonus(host, candidate.source, topic, goalContext, haystack);
    score -= candidate.queryRank * 4;
    score -= candidate.resultRank * 2;

    if (ResourceLinkValidator.isHomepageUrl(candidate.url)) score -= 40;
    if (!_hasRealArticlePath(candidate.url)) score -= 25;

    return score;
  }

  static int _sourceBonus(
    String host,
    String source,
    String topic,
    String goal,
    String haystack,
  ) {
    final h = host.toLowerCase();
    final context = '${topic.trim()} ${goal.trim()}'.toLowerCase();
    final coding =
        CodingTutorialSources.isCodingTopic(topic) ||
        CodingTutorialSources.isCodingTopic(goal);

    final topicOverlap = _overlapScore(topic, haystack);
    if (topicOverlap >= 2 &&
        (h.contains('learn.microsoft.com') ||
            h.contains('docs.') ||
            h.contains('developer.') ||
            h.endsWith('.gov') ||
            h.endsWith('.edu'))) {
      return 26;
    }

    if (coding) {
      if (h.contains('geeksforgeeks') ||
          h.contains('w3schools') ||
          h.contains('mozilla') ||
          h.contains('realpython') ||
          h.contains('javascript.info') ||
          h.contains('python.org') ||
          h.contains('dart.dev') ||
          h.contains('flutter.dev') ||
          h.contains('react.dev')) {
        return 22;
      }
      if (h.contains('freecodecamp') ||
          h.contains('tutorialspoint') ||
          h.contains('programiz')) {
        return 18;
      }
    }

    if (_looksBusiness(context)) {
      if (h.contains('investopedia')) return 20;
      if (h.contains('britannica')) return 16;
    }

    if (_looksMedical(context)) {
      if (h.contains('khanacademy')) return 18;
      if (h.contains('openstax')) return 16;
    }

    if (_looksHistory(context) && h.contains('britannica')) return 18;
    if (_looksPractical(context) &&
        (h.contains('wikihow') || h.contains('howtogeek'))) {
      return 16;
    }

    if (h.contains('britannica')) return 14;
    if (h.contains('khanacademy')) return 14;
    if (h.contains('openstax')) return 14;
    if (h.endsWith('.edu') || h.endsWith('.gov')) return 16;
    if (h.contains('wikihow') || h.contains('howtogeek')) return 12;
    if (source == 'wikipedia' || h.contains('wikipedia')) return 10;

    return 6;
  }

  static bool _looksBusiness(String lower) =>
      lower.contains('business') ||
      lower.contains('finance') ||
      lower.contains('invest') ||
      lower.contains('market') ||
      lower.contains('account') ||
      lower.contains('econom');

  static bool _looksMedical(String lower) =>
      lower.contains('medical') ||
      lower.contains('clinical') ||
      lower.contains('health') ||
      lower.contains('dental') ||
      lower.contains('dentist') ||
      lower.contains('nurs') ||
      lower.contains('medicine');

  static bool _looksHistory(String lower) =>
      lower.contains('history') || lower.contains('historical');

  static bool _looksPractical(String lower) =>
      lower.contains('how to') ||
      lower.contains('become a') ||
      lower.contains('career') ||
      lower.contains('practice');

  static List<ArticleCandidate> _heuristicCandidates(
    String condensed,
    String topic,
    String goalContext,
  ) {
    if (condensed.isEmpty) return const [];

    final out = <ArticleCandidate>[];
    final slug = _wikiSlug(condensed);
    final investSlug = condensed.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]'), '');
    final wikiHowSlug = _wikihowSlug(condensed);

    out.add(ArticleCandidate(
      title: condensed,
      url: 'https://en.wikipedia.org/wiki/$slug',
      summary: 'Free overview related to $topic.',
      source: 'wikipedia',
      queryRank: 5,
      resultRank: 0,
    ));

    if (investSlug.length >= 4) {
      out.add(ArticleCandidate(
        title: '$condensed — Investopedia',
        url: 'https://www.investopedia.com/terms/$investSlug.asp',
        summary: 'Business and finance vocabulary for $condensed.',
        source: 'investopedia',
        queryRank: 6,
        resultRank: 0,
      ));
    }

    if (wikiHowSlug.isNotEmpty) {
      out.add(ArticleCandidate(
        title: 'Learn $condensed',
        url: 'https://www.wikihow.com/$wikiHowSlug',
        summary: 'Practical steps for learning $condensed.',
        source: 'wikihow',
        queryRank: 6,
        resultRank: 1,
      ));
    }

    if (goalContext.trim().isNotEmpty &&
        goalContext.toLowerCase() != condensed.toLowerCase()) {
      final goalSlug = _wikiSlug(goalContext.trim());
      out.add(ArticleCandidate(
        title: goalContext.trim(),
        url: 'https://en.wikipedia.org/wiki/$goalSlug',
        summary: 'Foundations for ${goalContext.trim()}.',
        source: 'wikipedia',
        queryRank: 4,
        resultRank: 0,
      ));
    }

    return out;
  }

  static String _wikihowSlug(String phrase) {
    return phrase
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .map((w) {
          if (w.length == 1) return w.toUpperCase();
          return '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}';
        })
        .join('-');
  }

  static String _hostSource(String url) {
    final host = Uri.tryParse(url)?.host.toLowerCase() ?? '';
    if (host.contains('geeksforgeeks')) return 'geeksforgeeks';
    if (host.contains('w3schools')) return 'w3schools';
    if (host.contains('mozilla')) return 'mdn';
    if (host.contains('realpython')) return 'realpython';
    if (host.contains('python.org')) return 'python-docs';
    return host;
  }

  static bool _hasRealArticlePath(String url) {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    const shallow = {'search', 'docs', 'documentation', 'learn', 'en', 'subjects'};
    final meaningful = uri.pathSegments.where((s) {
      if (s.isEmpty) return false;
      final lower = s.toLowerCase();
      return lower.length >= 2 && !shallow.contains(lower);
    });
    return meaningful.isNotEmpty;
  }

  static int _overlapScore(String needle, String haystack) {
    final n = _tokens(needle);
    final h = _tokens(haystack);
    if (n.isEmpty || h.isEmpty) return 0;
    final inter = n.intersection(h).length;
    if (inter >= 2) return 3;
    if (inter >= 1) return 2;
    for (final t in n.where((w) => w.length >= 4)) {
      for (final w in h) {
        if (w.startsWith(t) || t.startsWith(w)) return 1;
      }
    }
    return 0;
  }

  static Set<String> _tokens(String input) {
    const stop = {
      'a', 'an', 'the', 'and', 'or', 'of', 'to', 'for', 'in', 'on', 'with',
      'intro', 'introduction', 'basics', 'foundation', 'foundations', 'module',
      'learn', 'learning', 'tutorial', 'course', 'part', 'how', 'what', 'your',
    };
    return input
        .toLowerCase()
        .replaceAll(RegExp(r'[^a-z0-9\s+]'), ' ')
        .split(RegExp(r'\s+'))
        .where((w) => w.length >= 3 && !stop.contains(w))
        .toSet();
  }

  /// Ordered, deduped Wikipedia search queries for any learning topic.
  static List<String> buildSearchQueries({
    required String topic,
    String goalContext = '',
    String pathTitle = '',
  }) {
    final queries = <String>[];
    void add(String q) {
      final t = q.trim();
      if (t.isEmpty) return;
      if (!queries.any((e) => e.toLowerCase() == t.toLowerCase())) {
        queries.add(t);
      }
    }

    final condensed = condenseLearningTitle(topic);
    add(topic);
    if (condensed != topic) add(condensed);

    // Multi-word goals (products, tools, careers): broaden Wikipedia search.
    if (topic.contains(' ') && condensed.length >= 4) {
      add('$condensed overview');
      add('$condensed software');
    }

    final goal = goalContext.trim();
    final path = pathTitle.trim();
    if (goal.isNotEmpty && goal.toLowerCase() != topic.toLowerCase()) {
      add(goal);
      add('$goal $condensed');
      add('$goal $topic');
    }
    if (path.isNotEmpty &&
        path.toLowerCase() != topic.toLowerCase() &&
        path.toLowerCase() != goal.toLowerCase()) {
      add('$path $condensed');
    }

    final orgSeed = goal.isNotEmpty ? goal : topic;
    if (GoalTopicResolver.needsResolution(orgSeed)) {
      final brand = TopicGroundingService.wikipediaSearchTerm(orgSeed);
      if (brand.isNotEmpty) {
        add('$brand company');
        add('$brand software');
        add(brand);
      }
      if (orgSeed.toLowerCase().contains('.ai')) {
        add('Artificial intelligence');
      }
    }

    return queries;
  }

  /// Strips common module filler so search hits the subject (e.g. "Dental anatomy").
  static String condenseLearningTitle(String title) {
    var t = title.trim();
    t = t.replaceFirst(
      RegExp(r'^(module\s*\d+[:\.]?\s*)', caseSensitive: false),
      '',
    );
    t = t.replaceFirst(
      RegExp(
        r'^(introduction to|intro to|basics of|fundamentals of|overview of|getting started with|understanding)\s+',
        caseSensitive: false,
      ),
      '',
    );
    return t.trim().isEmpty ? title.trim() : t.trim();
  }

  static String? _validationGoal(String goalContext, String topic) {
    if (goalContext.isNotEmpty && GoalTopicResolver.needsResolution(goalContext)) {
      return goalContext;
    }
    if (GoalTopicResolver.needsResolution(topic)) return topic;
    return null;
  }

  static String _wikiSlug(String topic) {
    final t = topic.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (t.isEmpty) return '';
    return t.replaceAll(' ', '_');
  }
}
