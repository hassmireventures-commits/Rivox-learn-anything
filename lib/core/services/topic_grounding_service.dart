import 'package:dio/dio.dart';

import 'goal_topic_resolver.dart';
import 'open_knowledge/wikipedia_source.dart';
import 'agentic/goal_content_validation_agent.dart';

/// Raw facts gathered from the public web (homepage + Wikipedia) before LLM use.
class TopicGroundingFacts {
  const TopicGroundingFacts({
    this.siteTitle,
    this.siteDescription,
    this.wikipediaTitle,
    this.wikipediaExtract,
    this.wikipediaUrl,
  });

  final String? siteTitle;
  final String? siteDescription;
  final String? wikipediaTitle;
  final String? wikipediaExtract;
  final String? wikipediaUrl;

  /// Enough real text to build a scope without asking the LLM.
  bool get isUsable {
    final wikiLen = wikipediaExtract?.trim().length ?? 0;
    final descLen = siteDescription?.trim().length ?? 0;
    final titleLen = siteTitle?.trim().length ?? 0;
    if (wikiLen >= 40) return true;
    if (descLen >= 25) return true;
    if (titleLen >= 4 && descLen >= 12) return true;
    return false;
  }

  bool get hasAnyContent =>
      (siteTitle?.trim().isNotEmpty ?? false) ||
      (siteDescription?.trim().isNotEmpty ?? false) ||
      (wikipediaExtract?.trim().isNotEmpty ?? false);

  String? get primaryTitle {
    final wiki = wikipediaTitle?.trim();
    if (wiki != null && wiki.isNotEmpty) return wiki;
    final site = siteTitle?.trim();
    if (site != null && site.isNotEmpty) return site;
    return null;
  }
}

/// Minimum-viable open web grounding: fetch a domain homepage and query Wikipedia.
/// Failures are silent; callers fall back to existing LLM resolution.
class TopicGroundingService {
  TopicGroundingService({Dio? dio, WikipediaSource? wikipedia})
      : _dio = dio ??
            Dio(
              BaseOptions(
                connectTimeout: const Duration(seconds: 8),
                receiveTimeout: const Duration(seconds: 8),
                followRedirects: true,
                maxRedirects: 5,
                headers: const {
                  'User-Agent': 'Rivox/1.0 (learning app; topic grounding)',
                  'Accept': 'text/html,application/json',
                },
                validateStatus: (s) => s != null && s < 400,
              ),
            ),
        _wikipedia = wikipedia ?? WikipediaSource();

  final Dio _dio;
  final WikipediaSource _wikipedia;
  static final GoalContentValidationAgent _validator =
      GoalContentValidationAgent();

  Future<TopicGroundingFacts?> gather(String rawGoal) async {
    final trimmed = rawGoal.trim();
    if (trimmed.isEmpty) return null;

    final domainUrl = normalizeDomainUrl(trimmed);
    final searchTerm = wikipediaSearchTerm(trimmed);

    String? siteTitle;
    String? siteDescription;
    if (domainUrl != null) {
      final host = domainUrl.replaceFirst('https://', '');
      final urls = [domainUrl, 'https://www.$host'];
      for (final url in urls) {
        final homepage = await _fetchHomepageMeta(url);
        siteTitle ??= homepage.title;
        siteDescription ??= homepage.description;
        if (siteTitle != null && siteDescription != null) break;
      }
    }

    String? wikiTitle;
    String? wikiExtract;
    String? wikiUrl;
    final isOrgGoal = GoalTopicResolver.needsResolution(trimmed);
    final wikiQueries = <String>[
      if (searchTerm.isNotEmpty && isOrgGoal) '$searchTerm company',
      if (searchTerm.isNotEmpty && isOrgGoal) '$searchTerm software',
      if (searchTerm.isNotEmpty) searchTerm,
      if (trimmed.toLowerCase().contains('.ai')) 'Artificial intelligence',
      if (searchTerm.isNotEmpty && trimmed.toLowerCase().contains('.ai'))
        '$searchTerm artificial intelligence',
      if (isOrgGoal) 'Startup company',
      if (isOrgGoal) 'Technology company',
    ];
    for (final q in wikiQueries) {
      final wiki = await findWikipediaArticle(q, validateForGoal: trimmed);
      if (wiki != null) {
        wikiTitle = wiki.title;
        wikiExtract = wiki.extract;
        wikiUrl = wiki.url;
        break;
      }
    }

    final facts = TopicGroundingFacts(
      siteTitle: siteTitle,
      siteDescription: siteDescription,
      wikipediaTitle: wikiTitle,
      wikipediaExtract: wikiExtract,
      wikipediaUrl: wikiUrl,
    );
    return facts.isUsable ? facts : null;
  }

  /// Public Wikipedia lookup for daily-pack fallbacks and org goals.
  Future<({String title, String extract, String url})?> findWikipediaArticle(
    String searchTerm, {
    String? validateForGoal,
  }) async {
    final candidates = await _wikipedia.searchArticles(searchTerm.trim(), limit: 5);
    for (final hit in candidates) {
      if (hit.url == null) continue;
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
      return (title: hit.title, extract: hit.summary, url: hit.url!);
    }
    return null;
  }

  /// Builds a human-readable scope block from grounded facts (no LLM).
  static String buildLearningScope(TopicGroundingFacts facts, String original) {
    final parts = <String>[];
    final wikiTitle = facts.wikipediaTitle?.trim();
    final wikiOk = wikiTitle != null &&
        wikiTitle.isNotEmpty &&
        _validator
            .validateOpenKnowledgeArticle(
              goal: original,
              title: wikiTitle,
              summary: facts.wikipediaExtract ?? '',
            )
            .approved;
    final siteTitle = facts.siteTitle?.trim();
    if (siteTitle != null && siteTitle.isNotEmpty) {
      parts.add('Focus for "$original": $siteTitle.');
    } else if (wikiOk) {
      parts.add('$wikiTitle is the focus for the learner\'s goal "$original".');
    } else {
      final brand = wikipediaSearchTerm(original);
      if (brand.isNotEmpty) {
        parts.add(
          'The learner wants to study $original ($brand): its products, mission, and relevant skills.',
        );
      }
    }
    final desc = facts.siteDescription?.trim();
    if (desc != null && desc.isNotEmpty) {
      parts.add(desc);
    }
    final wiki = facts.wikipediaExtract?.trim();
    if (wikiOk && wiki != null && wiki.isNotEmpty && wiki != desc) {
      parts.add(wiki);
    }
    var scope = parts.join(' ').replaceAll(RegExp(r'\s+'), ' ').trim();
    if (scope.length > 600) {
      scope = '${scope.substring(0, 597)}...';
    }
    return scope;
  }

  static String buildEffectiveTopic(TopicGroundingFacts facts, String original) {
    final site = facts.siteTitle?.trim();
    if (site != null && site.isNotEmpty && site.length <= 80) {
      return site;
    }
    final wikiTitle = facts.wikipediaTitle?.trim();
    if (wikiTitle != null &&
        wikiTitle.isNotEmpty &&
        _validator
            .validateOpenKnowledgeArticle(
              goal: original,
              title: wikiTitle,
              summary: facts.wikipediaExtract ?? '',
            )
            .approved) {
      return wikiTitle;
    }
    final brand = wikipediaSearchTerm(original);
    if (brand.isNotEmpty) {
      final label = '${brand[0].toUpperCase()}${brand.substring(1)}';
      return '$label — organization and products';
    }
    return original.replaceFirst(RegExp(r'^https?://'), '').replaceFirst(RegExp(r'^www\.'), '');
  }

  static List<String> defaultAvoidList(String original) {
    final lower = original.toLowerCase();
    final brand = wikipediaSearchTerm(original);
    final avoid = <String>[
      'generic unrelated subjects',
      'random trivia unrelated to this org or product',
      'biographies of people with similar names',
      'unrelated celebrities, athletes, or historical figures',
    ];
    if (brand.isNotEmpty) {
      avoid.add('any person named ${brand[0].toUpperCase()}${brand.substring(1)}* who is not this organization');
    }
    if (lower.contains('.ai') || lower.endsWith('ai')) {
      avoid.add('generic machine-learning trivia unrelated to this company');
      avoid.add('unrelated web development tutorials');
    }
    return avoid;
  }

  /// Normalizes `elsai.ai` / `https://elsai.ai` to a fetchable HTTPS URL.
  static String? normalizeDomainUrl(String raw) {
    var t = raw.trim();
    if (t.isEmpty) return null;
    t = t.replaceFirst(RegExp(r'^https?://'), '');
    t = t.replaceFirst(RegExp(r'^www\.'), '');
    final slash = t.indexOf('/');
    if (slash >= 0) t = t.substring(0, slash);
    if (!RegExp(
      r'^[a-z0-9][-a-z0-9.]*\.[a-z]{2,}$',
      caseSensitive: false,
    ).hasMatch(t)) {
      return null;
    }
    return 'https://$t';
  }

  /// Search term for Wikipedia opensearch / summary lookup.
  static String wikipediaSearchTerm(String raw) {
    var t = raw.trim();
    t = t.replaceFirst(RegExp(r'^https?://'), '');
    t = t.replaceFirst(RegExp(r'^www\.'), '');
    final slash = t.indexOf('/');
    if (slash >= 0) t = t.substring(0, slash);
    // Prefer brand label over full domain when TLD present.
    final dot = t.lastIndexOf('.');
    if (dot > 0 && dot < t.length - 2) {
      return t.substring(0, dot);
    }
    return t;
  }

  /// Extracts `<title>` and meta/OG description from HTML (unit-testable).
  static ({String? title, String? description}) parseHomepageMeta(String html) {
    if (html.trim().isEmpty) return (title: null, description: null);

    String? title;
    final titleMatch = RegExp(
      r'<title[^>]*>([\s\S]*?)</title>',
      caseSensitive: false,
    ).firstMatch(html);
    if (titleMatch != null) {
      title = _cleanHtmlText(titleMatch.group(1) ?? '');
    }

    String? description = _metaContent(html, 'og:description') ??
        _metaContent(html, 'description') ??
        _metaContent(html, 'twitter:description');

    final ogTitle = _metaContent(html, 'og:title');
    if ((title == null || title.length < 3) && ogTitle != null) {
      title = ogTitle;
    }

    return (title: title, description: description);
  }

  static String? _metaContent(String html, String name) {
    final patterns = [
      RegExp(
        '<meta[^>]+(?:name|property)=["\']$name["\'][^>]+content=["\']([^"\']*)["\']',
        caseSensitive: false,
      ),
      RegExp(
        '<meta[^>]+content=["\']([^"\']*)["\'][^>]+(?:name|property)=["\']$name["\']',
        caseSensitive: false,
      ),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(html);
      if (m != null) {
        final v = _cleanHtmlText(m.group(1) ?? '');
        if (v.isNotEmpty) return v;
      }
    }
    return null;
  }

  static String _cleanHtmlText(String raw) {
    return raw
        .replaceAll(RegExp(r'<[^>]+>'), ' ')
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  Future<({String? title, String? description})> _fetchHomepageMeta(String url) async {
    try {
      final res = await _dio.getUri(Uri.parse(url), options: Options(responseType: ResponseType.plain));
      final html = res.data?.toString() ?? '';
      if (html.length < 100) return (title: null, description: null);
      return parseHomepageMeta(html);
    } catch (_) {
      return (title: null, description: null);
    }
  }
}
