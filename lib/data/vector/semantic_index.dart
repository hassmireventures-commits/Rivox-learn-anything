import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';

import '../../core/services/nvidia/nvidia_ai_config.dart';
import '../../core/services/nvidia/nvidia_client.dart';

/// Turns texts into NVIDIA Nemotron embeddings (2048-d). Queries and
/// passages use different `input_type`s, as the model expects.
class EmbeddingService {
  EmbeddingService({NvidiaClient? client}) : _client = client ?? NvidiaClient();

  final NvidiaClient _client;

  static const int batchSize = 16;

  /// Characters sent per text; chunks are already short, this is a guard.
  static const int maxChars = 6000;

  static bool get isAvailable => NvidiaAiConfig.isAvailable(NvidiaCapability.embeddings);

  Future<List<Float32List>> embed(List<String> texts, {required bool query}) async {
    final out = <Float32List>[];
    for (var i = 0; i < texts.length; i += batchSize) {
      final batch = texts
          .sublist(i, min(i + batchSize, texts.length))
          .map((t) => t.length > maxChars ? t.substring(0, maxChars) : t)
          .toList();
      final data = await _client.postJson(
        '${NvidiaAiConfig.chatBaseUrl}/embeddings',
        {
          'model': NvidiaAiConfig.embeddingModel,
          'input': batch,
          'input_type': query ? 'query' : 'passage',
          'encoding_format': 'float',
          'truncate': 'END',
        },
        capability: NvidiaCapability.embeddings,
        timeout: const Duration(seconds: 20),
      );
      final rows = data['data'];
      if (rows is! List || rows.length != batch.length) {
        throw const NvidiaUnavailableException('Embedding response did not match the request.');
      }
      final sorted = rows.whereType<Map>().toList()
        ..sort((a, b) => ((a['index'] as num?) ?? 0).compareTo((b['index'] as num?) ?? 0));
      for (final row in sorted) {
        final vec = (row['embedding'] as List).map((e) => (e as num).toDouble()).toList();
        out.add(Float32List.fromList(vec));
      }
    }
    return out;
  }
}

/// A chunk the semantic stage can score.
class SemanticCandidate {
  const SemanticCandidate({required this.chunkId, required this.text});
  final String chunkId;
  final String text;
}

/// Semantic re-scoring for library RAG. The local 32-d hash vectors only
/// match shared words ("squat depth" never finds "how low to go"); this
/// stage embeds the query and the learner's chunks with Nemotron and
/// scores by meaning. Chunk vectors are cached on device as raw Float32
/// files, keyed by chunk id and a hash of the text, so each chunk is
/// embedded once and an edited chunk is re-embedded automatically.
class SemanticIndex {
  SemanticIndex({EmbeddingService? embedder, Future<Directory> Function()? cacheDir})
      : _embedder = embedder ?? EmbeddingService(),
        _cacheDir = cacheDir ?? _defaultDir;

  final EmbeddingService _embedder;
  final Future<Directory> Function() _cacheDir;
  final Map<String, Float32List> _memory = {};

  /// New chunks embedded per query; the rest keep their local score until a
  /// later query or [warmUp] reaches them, so one query never stalls.
  static const int maxNewPerQuery = 48;

  static Future<Directory> _defaultDir() async {
    final base = await getApplicationDocumentsDirectory();
    final dir = Directory('${base.path}/semantic_index');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  /// FNV-1a over chunk id and text: stable across runs, unlike hashCode.
  @visibleForTesting
  static String cacheKey(String chunkId, String text) {
    // FNV-1a 64-bit offset basis 0xcbf29ce484222325 as a signed int (the
    // hex literal does not fit Dart's signed 64-bit range). Native int
    // multiplication wraps mod 2^64, which is what FNV needs.
    var h = -3750763034362895579;
    for (final unit in '$chunkId\u0000$text'.codeUnits) {
      h ^= unit;
      h *= 0x100000001b3;
    }
    return h.toUnsigned(64).toRadixString(16);
  }

  Future<Float32List?> _load(String key) async {
    final mem = _memory[key];
    if (mem != null) return mem;
    try {
      final file = File('${(await _cacheDir()).path}/$key.f32');
      if (!file.existsSync()) return null;
      final bytes = await file.readAsBytes();
      final vec = bytes.buffer.asFloat32List(bytes.offsetInBytes, bytes.lengthInBytes ~/ 4);
      _memory[key] = vec;
      return vec;
    } catch (_) {
      return null;
    }
  }

  Future<void> _store(String key, Float32List vec) async {
    _memory[key] = vec;
    try {
      await File('${(await _cacheDir()).path}/$key.f32').writeAsBytes(vec.buffer.asUint8List());
    } catch (_) {}
  }

  /// Ensures vectors exist for up to [budget] of [candidates]. Returns the
  /// vectors that are available (cached or newly made), by chunk id.
  Future<Map<String, Float32List>> _vectorsFor(List<SemanticCandidate> candidates, int budget) async {
    final out = <String, Float32List>{};
    final missing = <SemanticCandidate>[];
    for (final c in candidates) {
      final vec = await _load(cacheKey(c.chunkId, c.text));
      if (vec != null) {
        out[c.chunkId] = vec;
      } else if (missing.length < budget) {
        missing.add(c);
      }
    }
    if (missing.isNotEmpty) {
      final vecs = await _embedder.embed(missing.map((c) => c.text).toList(), query: false);
      for (var i = 0; i < missing.length; i++) {
        await _store(cacheKey(missing[i].chunkId, missing[i].text), vecs[i]);
        out[missing[i].chunkId] = vecs[i];
      }
    }
    return out;
  }

  /// Cosine similarity of [query] against each candidate that has (or can
  /// get, within budget) a vector. Candidates without a vector are absent
  /// from the result; the caller keeps their local score.
  Future<Map<String, double>> score(String query, List<SemanticCandidate> candidates) async {
    if (candidates.isEmpty || query.trim().isEmpty) return const {};
    final q = (await _embedder.embed([query], query: true)).first;
    final vectors = await _vectorsFor(candidates, maxNewPerQuery);
    return {for (final e in vectors.entries) e.key: cosine(q, e.value)};
  }

  /// Background indexing after a library upload, so the first question
  /// about it is already semantic. Best effort, never throws.
  Future<void> warmUp(List<SemanticCandidate> candidates) async {
    try {
      await _vectorsFor(candidates, candidates.length);
    } catch (_) {}
  }

  static double cosine(List<double> a, List<double> b) {
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
