import 'dart:convert';

import 'package:dio/dio.dart';

import 'open_knowledge_cache.dart';
import 'open_knowledge_client.dart';
import 'open_knowledge_models.dart';

class WikipediaSource {
  WikipediaSource({Dio? dio}) : _dio = dio ?? OpenKnowledgeClient.create();

  final Dio _dio;

  Future<OpenKnowledgeHit?> findArticle(String searchTerm) async {
    final hits = await searchArticles(searchTerm, limit: 1);
    return hits.isEmpty ? null : hits.first;
  }

  /// Returns up to [limit] Wikipedia articles for a search term (newest API order).
  Future<List<OpenKnowledgeHit>> searchArticles(
    String searchTerm, {
    int limit = 5,
  }) async {
    final q = searchTerm.trim();
    if (q.isEmpty) return const [];

    final cacheKey = 'wiki-search:$q:$limit';
    final cached = OpenKnowledgeCache.get<List<OpenKnowledgeHit>>(cacheKey);
    if (cached != null) return cached;

    try {
      final summaries = await _fetchSummaries(q, limit: limit);
      final hits = <OpenKnowledgeHit>[];
      for (final summary in summaries) {
        hits.add(
          OpenKnowledgeHit(
            source: 'Wikipedia',
            title: summary.title,
            summary: summary.extract.length > 400
                ? '${summary.extract.substring(0, 397)}...'
                : summary.extract,
            url: summary.url,
          ),
        );
      }
      if (hits.isNotEmpty) OpenKnowledgeCache.set(cacheKey, hits);
      return hits;
    } catch (_) {
      return const [];
    }
  }

  Future<List<({String title, String extract, String url})>> _fetchSummaries(
    String searchTerm, {
    required int limit,
  }) async {
    final searchUri = Uri.https('en.wikipedia.org', '/w/api.php', {
      'action': 'opensearch',
      'search': searchTerm,
      'limit': '$limit',
      'namespace': '0',
      'format': 'json',
    });
    final searchRes = await _dio.getUri(searchUri);
    final titles = _parseOpensearchTitles(searchRes.data);
    if (titles == null || titles.isEmpty) return const [];

    final results = <({String title, String extract, String url})>[];
    for (final rawTitle in titles) {
      final title = rawTitle.toString().trim();
      if (title.isEmpty) continue;
      final summary = await _fetchSummaryForTitle(title);
      if (summary != null) results.add(summary);
    }
    return results;
  }

  Future<({String title, String extract, String url})?> _fetchSummaryForTitle(
    String title,
  ) async {
    final summaryUri = Uri.parse(
      'https://en.wikipedia.org/api/rest_v1/page/summary/${Uri.encodeComponent(title)}',
    );
    final summaryRes = await _dio.getUri(summaryUri);
    final map = _asMap(summaryRes.data);
    if (map == null) return null;
    if (map['type']?.toString() == 'disambiguation') return null;

    final extract = map['extract']?.toString().trim() ?? '';
    if (extract.length < 40) return null;

    final pageTitle = map['title']?.toString().trim() ?? title;
    final pageUrl = map['content_urls'] is Map
        ? (map['content_urls'] as Map)['desktop'] is Map
            ? ((map['content_urls'] as Map)['desktop'] as Map)['page']?.toString()
            : null
        : null;

    return (
      title: pageTitle,
      extract: extract,
      url: pageUrl ??
          'https://en.wikipedia.org/wiki/${Uri.encodeComponent(pageTitle.replaceAll(' ', '_'))}',
    );
  }

  List<dynamic>? _parseOpensearchTitles(dynamic data) {
    if (data is List && data.length >= 2 && data[1] is List) {
      return data[1] as List;
    }
    if (data is String) {
      final decoded = jsonDecode(data);
      if (decoded is List && decoded.length >= 2 && decoded[1] is List) {
        return decoded[1] as List;
      }
    }
    return null;
  }

  Map<String, dynamic>? _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    if (data is String) {
      try {
        final decoded = jsonDecode(data);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }
}
