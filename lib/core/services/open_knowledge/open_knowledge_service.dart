import 'package:flutter/foundation.dart';

import '../goal_topic_resolver.dart';
import '../agentic/goal_content_validation_agent.dart';
import '../topic_grounding_service.dart';
import 'arxiv_source.dart';
import 'europe_pmc_source.dart';
import 'gutendex_source.dart';
import 'open_knowledge_models.dart';
import 'wikipedia_source.dart';
import 'wikidata_source.dart';

/// Routes topics to free/open knowledge APIs and builds LLM prompt context.
class OpenKnowledgeService {
  OpenKnowledgeService({
    WikipediaSource? wikipedia,
    WikidataSource? wikidata,
    ArxivSource? arxiv,
    EuropePmcSource? europePmc,
    GutendexSource? gutendex,
  })  : _wikipedia = wikipedia ?? WikipediaSource(),
        _wikidata = wikidata ?? WikidataSource(),
        _arxiv = arxiv ?? ArxivSource(),
        _europePmc = europePmc ?? EuropePmcSource(),
        _gutendex = gutendex ?? GutendexSource();

  final WikipediaSource _wikipedia;
  final WikidataSource _wikidata;
  final ArxivSource _arxiv;
  final EuropePmcSource _europePmc;
  final GutendexSource _gutendex;
  static final GoalContentValidationAgent _validator =
      GoalContentValidationAgent();

  /// Collects verified public-source snippets for prompt injection.
  Future<List<OpenKnowledgeHit>> gatherHits(String topic) async {
    final trimmed = topic.trim();
    if (trimmed.isEmpty) return const [];

    final lower = trimmed.toLowerCase();
    final hits = <OpenKnowledgeHit>[];
    final seen = <String>{};

    Future<void> add(Future<OpenKnowledgeHit?> future) async {
      final hit = await future;
      if (hit == null) return;
      final key = '${hit.source}:${hit.title}'.toLowerCase();
      if (!seen.add(key)) return;
      hits.add(hit);
    }

    if (GoalTopicResolver.needsResolution(trimmed)) {
      final brand = TopicGroundingService.wikipediaSearchTerm(trimmed);
      final wikiQueries = [
        if (brand.isNotEmpty) '$brand company',
        if (brand.isNotEmpty) '$brand software',
        if (brand.isNotEmpty) brand,
      ];
      for (final q in wikiQueries) {
        final candidates = await _wikipedia.searchArticles(q, limit: 5);
        for (final hit in candidates) {
          if (!_validator
              .validateOpenKnowledgeArticle(
                goal: trimmed,
                title: hit.title,
                summary: hit.summary,
              )
              .approved) {
            continue;
          }
          final key = '${hit.source}:${hit.title}'.toLowerCase();
          if (seen.add(key)) hits.add(hit);
          break;
        }
        if (hits.any((h) => h.source == 'Wikipedia')) break;
      }
      if (brand.isNotEmpty) await add(_wikidata.findEntity(brand));
    } else {
      await add(_wikipedia.findArticle(trimmed));
    }

    if (_isBiomedical(lower)) {
      await add(_europePmc.findArticle(trimmed));
    }
    if (_isStem(lower)) {
      await add(_arxiv.findPaper(trimmed));
    }
    if (_isLiterature(lower)) {
      await add(_gutendex.findBook(trimmed));
    }

    return hits;
  }

  /// Prompt block for quiz/path/daily generation (empty when all sources fail).
  Future<String> gatherPromptContext(String topic) async {
    final hits = await gatherHits(topic);
    if (hits.isEmpty) return '';
    final lines = hits.map((h) => h.promptLine).join('\n');
    return '''
OPEN KNOWLEDGE (verified public sources — prefer over guessing):
$lines
''';
  }

  /// Wikipedia article suitable for daily-pack allowlist (en.wikipedia.org only).
  Future<({String title, String extract, String url})?> findAllowlistedWikiArticle(
    String searchTerm, {
    String? validateForGoal,
  }) async {
    final candidates = await _wikipedia.searchArticles(searchTerm, limit: 5);
    for (final hit in candidates) {
      if (hit.url == null || !hit.url!.contains('en.wikipedia.org')) continue;
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

  static bool _isBiomedical(String lower) =>
      lower.contains('biomedical') ||
      lower.contains('bio medical') ||
      lower.contains('bio-medical') ||
      lower.contains('medicine') ||
      lower.contains('clinical') ||
      (lower.contains('bio') && lower.contains('medical'));

  static bool _isStem(String lower) {
    const keys = [
      'math', 'physics', 'chemistry', 'biology', 'machine learning', 'deep learning',
      'neural', 'quantum', 'algorithm', 'statistics', 'data science', 'engineering',
      'computer science', 'arxiv', 'stem',
    ];
    return keys.any(lower.contains);
  }

  static bool _isLiterature(String lower) {
    const keys = [
      'literature', 'novel', 'poetry', 'shakespeare', 'classic book', 'gutenberg',
      'author', 'fiction',
    ];
    return keys.any(lower.contains);
  }

  @visibleForTesting
  static bool topicIsBiomedical(String topic) => _isBiomedical(topic.toLowerCase());

  @visibleForTesting
  static bool topicIsStem(String topic) => _isStem(topic.toLowerCase());

  @visibleForTesting
  static bool topicIsLiterature(String topic) => _isLiterature(topic.toLowerCase());
}
