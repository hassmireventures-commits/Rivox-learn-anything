import 'dart:convert';
import 'dart:math';

import 'package:isar_community/isar.dart';

import '../local/isar_service.dart';
import '../local/models/document_chunk.dart';
import '../local/models/embedding_chunk.dart';

class RetrievedChunk {
  const RetrievedChunk({
    required this.chunkId,
    required this.sourceUuid,
    required this.text,
    required this.score,
    this.citationLabel,
    this.page,
    this.section,
  });

  final String chunkId;
  final String sourceUuid;
  final String text;
  final double score;
  final String? citationLabel;
  final int? page;
  final String? section;
}

/// Local vector store for topics and document chunks (hash embeddings, offline-safe).
class KnowledgeVectorStore {
  KnowledgeVectorStore(this._isarService);

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

  Future<void> upsertDocumentChunk({
    required String chunkId,
    required String sourceUuid,
    required String text,
    String? citationLabel,
    int? page,
    String? section,
  }) async {
    final vector = embedText(text);
    final estimate = (text.length / 4).ceil();
    var row = await _db.documentChunks.filter().chunkIdEqualTo(chunkId).findFirst();
    row ??= DocumentChunk()..chunkId = chunkId;
    row
      ..sourceUuid = sourceUuid
      ..text = text
      ..citationLabel = citationLabel
      ..page = page
      ..section = section
      ..vectorJson = jsonEncode(vector)
      ..tokenEstimate = estimate
      ..updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.documentChunks.put(row!);
    });
  }

  Future<void> deleteBySource(String sourceUuid) async {
    await _db.writeTxn(() async {
      final chunks = await _db.documentChunks.filter().sourceUuidEqualTo(sourceUuid).findAll();
      final ids = chunks.map((c) => c.id).toList();
      await _db.documentChunks.deleteAll(ids);
    });
  }

  Future<List<({String topic, double score})>> similar(String topic, {int limit = 5}) =>
      similarTopics(topic, limit: limit);

  Future<List<({String topic, double score})>> similarTopics(String topic, {int limit = 5}) async {
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

  Future<List<RetrievedChunk>> retrieve({
    required String query,
    Set<String>? sourceUuids,
    Map<String, String>? sourceTypes,
    int limit = 8,
    int maxTokens = 3000,
    int priorityReserve = 4,
  }) async {
    final q = embedText(query);
    final all = await _db.documentChunks.where().findAll();
    final scored = <RetrievedChunk>[];
    for (final chunk in all) {
      if (sourceUuids != null && !sourceUuids.contains(chunk.sourceUuid)) continue;
      final vector = (jsonDecode(chunk.vectorJson) as List)
          .map((e) => (e as num).toDouble())
          .toList();
      var score = _cosine(q, vector);
      if (score <= 0.05) continue;
      final type = sourceTypes?[chunk.sourceUuid];
      score *= _typeBoost(type);
      scored.add(
        RetrievedChunk(
          chunkId: chunk.chunkId,
          sourceUuid: chunk.sourceUuid,
          text: chunk.text,
          score: score,
          citationLabel: chunk.citationLabel,
          page: chunk.page,
          section: chunk.section,
        ),
      );
    }
    scored.sort((a, b) => b.score.compareTo(a.score));

    // Prefer high-priority source types in the first reserved slots.
    final priority = <RetrievedChunk>[];
    final rest = <RetrievedChunk>[];
    for (final c in scored) {
      final type = sourceTypes?[c.sourceUuid];
      if (_isPriorityType(type)) {
        priority.add(c);
      } else {
        rest.add(c);
      }
    }
    final ordered = <RetrievedChunk>[
      ...priority.take(priorityReserve),
      ...rest,
      ...priority.skip(priorityReserve),
    ];

    final picked = <RetrievedChunk>[];
    final seen = <String>{};
    var tokens = 0;
    for (final c in ordered) {
      if (!seen.add(c.chunkId)) continue;
      final est = (c.text.length / 4).ceil();
      if (tokens + est > maxTokens && picked.isNotEmpty) break;
      picked.add(c);
      tokens += est;
      if (picked.length >= limit) break;
    }
    return picked;
  }

  double _typeBoost(String? type) {
    return switch (type) {
      'resume' => 1.45,
      'jd' => 1.35,
      'notes' || 'book' || 'syllabus_pdf' => 1.3,
      'website' => 1.1,
      _ => 1.0,
    };
  }

  bool _isPriorityType(String? type) {
    return type == 'resume' ||
        type == 'jd' ||
        type == 'notes' ||
        type == 'book' ||
        type == 'syllabus_pdf';
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

/// Back-compat alias - existing code imports LocalVectorStore.
typedef LocalVectorStore = KnowledgeVectorStore;
