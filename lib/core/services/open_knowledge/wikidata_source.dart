import 'dart:convert';

import 'package:dio/dio.dart';

import 'open_knowledge_cache.dart';
import 'open_knowledge_client.dart';
import 'open_knowledge_models.dart';

class WikidataSource {
  WikidataSource({Dio? dio}) : _dio = dio ?? OpenKnowledgeClient.create();

  final Dio _dio;

  Future<OpenKnowledgeHit?> findEntity(String searchTerm) async {
    final q = searchTerm.trim();
    if (q.isEmpty) return null;

    final cacheKey = 'wikidata:$q';
    final cached = OpenKnowledgeCache.get<OpenKnowledgeHit>(cacheKey);
    if (cached != null) return cached;

    try {
      final uri = Uri.https('www.wikidata.org', '/w/api.php', {
        'action': 'wbsearchentities',
        'search': q,
        'language': 'en',
        'format': 'json',
        'limit': '1',
      });
      final res = await _dio.getUri(uri);
      final map = _asMap(res.data);
      if (map == null) return null;
      final search = map['search'];
      if (search is! List || search.isEmpty) return null;
      final first = search.first;
      if (first is! Map) return null;
      final entity = Map<String, dynamic>.from(first);
      final label = entity['label']?.toString().trim() ?? '';
      final description = entity['description']?.toString().trim() ?? '';
      if (label.isEmpty) return null;

      final hit = OpenKnowledgeHit(
        source: 'Wikidata',
        title: label,
        summary: description.isNotEmpty
            ? description
            : 'Structured entity related to $q.',
        url: entity['concepturi']?.toString(),
      );
      OpenKnowledgeCache.set(cacheKey, hit);
      return hit;
    } catch (_) {
      return null;
    }
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
