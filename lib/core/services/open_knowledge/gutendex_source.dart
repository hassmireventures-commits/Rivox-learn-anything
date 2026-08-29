import 'dart:convert';

import 'package:dio/dio.dart';

import 'open_knowledge_cache.dart';
import 'open_knowledge_client.dart';
import 'open_knowledge_models.dart';

class GutendexSource {
  GutendexSource({Dio? dio}) : _dio = dio ?? OpenKnowledgeClient.create();

  final Dio _dio;

  Future<OpenKnowledgeHit?> findBook(String topic) async {
    final q = topic.trim();
    if (q.isEmpty) return null;

    final cacheKey = 'gutendex:$q';
    final cached = OpenKnowledgeCache.get<OpenKnowledgeHit>(cacheKey);
    if (cached != null) return cached;

    try {
      final uri = Uri.https('gutendex.com', '/books/', {'search': q});
      final res = await _dio.getUri(uri);
      final map = _asMap(res.data);
      if (map == null) return null;

      final results = map['results'];
      if (results is! List || results.isEmpty) return null;
      final first = results.first;
      if (first is! Map) return null;
      final book = Map<String, dynamic>.from(first);

      final title = book['title']?.toString().trim() ?? '';
      if (title.isEmpty) return null;

      final authors = book['authors'];
      var author = 'Unknown author';
      if (authors is List && authors.isNotEmpty && authors.first is Map) {
        author = (authors.first as Map)['name']?.toString() ?? author;
      }

      final id = book['id'];
      final url = id != null ? 'https://www.gutenberg.org/ebooks/$id' : null;

      final hit = OpenKnowledgeHit(
        source: 'Gutendex',
        title: title,
        summary: 'Public-domain book by $author.',
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
