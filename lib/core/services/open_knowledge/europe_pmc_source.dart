import 'dart:convert';

import 'package:dio/dio.dart';

import 'open_knowledge_cache.dart';
import 'open_knowledge_client.dart';
import 'open_knowledge_models.dart';

class EuropePmcSource {
  EuropePmcSource({Dio? dio}) : _dio = dio ?? OpenKnowledgeClient.create();

  final Dio _dio;

  Future<OpenKnowledgeHit?> findArticle(String topic) async {
    final q = topic.trim();
    if (q.isEmpty) return null;

    final cacheKey = 'epmc:$q';
    final cached = OpenKnowledgeCache.get<OpenKnowledgeHit>(cacheKey);
    if (cached != null) return cached;

    try {
      final uri = Uri.https('www.ebi.ac.uk', '/europepmc/webservices/rest/search', {
        'query': q,
        'format': 'json',
        'pageSize': '1',
        'resultType': 'core',
      });
      final res = await _dio.getUri(uri);
      final map = _asMap(res.data);
      if (map == null) return null;

      final results = map['resultList'] is Map
          ? (map['resultList'] as Map)['result']
          : null;
      if (results is! List || results.isEmpty) return null;
      final first = results.first;
      if (first is! Map) return null;
      final r = Map<String, dynamic>.from(first);

      final title = r['title']?.toString().trim() ?? '';
      final abstract = r['abstractText']?.toString().trim() ?? '';
      if (title.isEmpty) return null;

      final id = r['id']?.toString();
      final source = r['source']?.toString() ?? 'PMC';
      final url = id != null
          ? 'https://europepmc.org/article/${source.toUpperCase()}/$id'
          : null;

      final hit = OpenKnowledgeHit(
        source: 'Europe PMC',
        title: title,
        summary: abstract.isNotEmpty
            ? (abstract.length > 350 ? '${abstract.substring(0, 347)}...' : abstract)
            : 'Open-access life-sciences literature related to $q.',
        url: url,
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
