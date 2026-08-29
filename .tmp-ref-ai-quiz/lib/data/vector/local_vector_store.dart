import 'dart:convert';
import 'dart:math';

import 'package:isar_community/isar.dart';

import '../local/isar_service.dart';
import '../local/models/embedding_chunk.dart';

/// Lightweight local embedding via hashing (offline-safe fallback).
class LocalVectorStore {
  LocalVectorStore(this._isarService);

  final IsarService _isarService;
  static const _dims = 32;

  Isar get _db => _isarService.db;

  List<double> embedText(String text) {
    final vector = List<double>.filled(_dims, 0);
    final tokens = text.toLowerCase().split(RegExp(r'[^a-z0-9]+')).where((t) => t.isNotEmpty);
    for (final token in tokens) {
      final hash = token.hashCode;
      final idx = hash.abs() % _dims;
      vector[idx] += 1;
      vector[(idx + 1) % _dims] += 0.5;
    }
    final norm = sqrt(vector.fold<double>(0, (a, b) => a + b * b));
    if (norm == 0) return vector;
    return vector.map((v) => v / norm).toList();
  }

  Future<void> upsertTopic(String topic) async {
    final vector = embedText(topic);
    var chunk = await _db.embeddingChunks.filter().chunkIdEqualTo('topic:$topic').findFirst();
    chunk ??= EmbeddingChunk()..chunkId = 'topic:$topic';
    chunk
      ..topic = topic
      ..vectorJson = jsonEncode(vector)
      ..updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.embeddingChunks.put(chunk!);
    });
  }

  Future<List<({String topic, double score})>> similar(String topic, {int limit = 5}) async {
    final query = embedText(topic);
    final all = await _db.embeddingChunks.where().findAll();
    final scored = <({String topic, double score})>[];
    for (final chunk in all) {
      if (chunk.topic.toLowerCase() == topic.toLowerCase()) continue;
      final vector = (jsonDecode(chunk.vectorJson) as List)
          .map((e) => (e as num).toDouble())
          .toList();
      scored.add((topic: chunk.topic, score: _cosine(query, vector)));
    }
    scored.sort((a, b) => b.score.compareTo(a.score));
    return scored.take(limit).toList();
  }

  double _cosine(List<double> a, List<double> b) {
    final n = min(a.length, b.length);
    var dot = 0.0;
    var na = 0.0;
    var nb = 0.0;
    for (var i = 0; i < n; i++) {
      dot += a[i] * b[i];
      na += a[i] * a[i];
      nb += b[i] * b[i];
    }
    if (na == 0 || nb == 0) return 0;
    return dot / (sqrt(na) * sqrt(nb));
  }
}
