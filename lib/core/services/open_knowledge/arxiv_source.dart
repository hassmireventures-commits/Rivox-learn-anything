import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import 'open_knowledge_cache.dart';
import 'open_knowledge_client.dart';
import 'open_knowledge_models.dart';

class ArxivSource {
  ArxivSource({Dio? dio}) : _dio = dio ?? OpenKnowledgeClient.create();

  final Dio _dio;

  Future<OpenKnowledgeHit?> findPaper(String topic) async {
    final q = topic.trim();
    if (q.isEmpty) return null;

    final cacheKey = 'arxiv:$q';
    final cached = OpenKnowledgeCache.get<OpenKnowledgeHit>(cacheKey);
    if (cached != null) return cached;

    try {
      final uri = Uri.https('export.arxiv.org', '/api/query', {
        'search_query': 'all:${q.replaceAll(' ', '+')}',
        'start': '0',
        'max_results': '1',
      });
      final res = await _dio.getUri(
        uri,
        options: Options(responseType: ResponseType.plain),
      );
      final xml = res.data?.toString() ?? '';
      if (xml.isEmpty || !xml.contains('<entry>')) return null;

      final title = _tagText(xml, 'title');
      final summary = _tagText(xml, 'summary');
      final id = _tagText(xml, 'id');
      if (title.isEmpty || summary.isEmpty) return null;

      final hit = OpenKnowledgeHit(
        source: 'arXiv',
        title: title,
        summary: summary.length > 350
            ? '${summary.substring(0, 347).replaceAll(RegExp(r'\s+'), ' ')}...'
            : summary,
        url: id.isNotEmpty ? id : null,
      );
      OpenKnowledgeCache.set(cacheKey, hit);
      return hit;
    } catch (_) {
      return null;
    }
  }

  static String _tagText(String xml, String tag) {
    final match = RegExp('<$tag[^>]*>([\\s\\S]*?)</$tag>', caseSensitive: false)
        .firstMatch(xml);
    if (match == null) return '';
    return match.group(1)?.replaceAll(RegExp(r'\s+'), ' ').trim() ?? '';
  }

  @visibleForTesting
  static String parseTagTextForTest(String xml, String tag) => _tagText(xml, tag);
}
