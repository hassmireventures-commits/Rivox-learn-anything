import 'dart:io';

import 'package:collection/collection.dart';
import 'package:isar_community/isar.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import '../../../core/error/app_exception.dart';
import '../isar_service.dart';
import '../models/document_chunk.dart';
import '../models/knowledge_source.dart';
import '../models/user_website.dart';
import '../../vector/knowledge_vector_store.dart';
import '../../knowledge/chunking_strategy.dart';
import '../../knowledge/document_ingestion_service.dart';
import '../../knowledge/upload_validator.dart';
import '../../knowledge/website_indexer.dart';

class KnowledgeRepository {
  KnowledgeRepository(
    this._isar,
    this._vectorStore, {
    DocumentIngestionService? ingestion,
    ChunkingStrategy? chunking,
    WebsiteIndexer? websiteIndexer,
    UploadValidator? uploadValidator,
  })  : _ingestion = ingestion ?? const DocumentIngestionService(),
        _chunking = chunking ?? const ChunkingStrategy(),
        _websiteIndexer = websiteIndexer ?? const WebsiteIndexer(),
        _uploadValidator = uploadValidator ?? const UploadValidator();

  final IsarService _isar;
  final KnowledgeVectorStore _vectorStore;
  final DocumentIngestionService _ingestion;
  final ChunkingStrategy _chunking;
  final WebsiteIndexer _websiteIndexer;
  final UploadValidator _uploadValidator;
  final _uuid = const Uuid();

  Isar get _db => _isar.db;

  Future<List<KnowledgeSource>> sourcesForGoal(String goalMode) async {
    return _db.knowledgeSources.filter().goalModeEqualTo(goalMode).sortByCreatedAtDesc().findAll();
  }

  Future<List<KnowledgeSource>> enabledSourcesForGoal(String goalMode) async {
    final all = await sourcesForGoal(goalMode);
    return all.where((s) => s.enabled && s.status == 'indexed').toList();
  }

  Future<Set<String>> enabledSourceUuids(String goalMode) async {
    final sources = await enabledSourcesForGoal(goalMode);
    return sources.map((s) => s.uuid).toSet();
  }

  /// Map of sourceUuid → type for RAG boost (enabled + indexed only).
  Future<Map<String, String>> enabledSourceTypes(String goalMode) async {
    final sources = await enabledSourcesForGoal(goalMode);
    return {for (final s in sources) s.uuid: s.type};
  }

  Future<KnowledgeSource?> findByUrl({
    required String goalMode,
    required String url,
  }) async {
    final all = await sourcesForGoal(goalMode);
    final normalized = url.trim().toLowerCase();
    for (final s in all) {
      if ((s.url ?? '').trim().toLowerCase() == normalized) return s;
    }
    return null;
  }

  Future<KnowledgeSource> addFileSource({
    required String goalMode,
    required String type,
    required String title,
    required String sourceFilePath,
    required bool consent,
  }) async {
    final file = File(sourceFilePath);
    final bytes = await file.length();
    final validation = await _uploadValidator.validate(
      fileName: p.basename(sourceFilePath),
      byteLength: bytes,
    );
    if (!validation.ok) {
      throw LibraryException('invalidUpload', validation.reason);
    }

    final storedPath = await _copyToLibrary(sourceFilePath, type);
    final source = KnowledgeSource()
      ..uuid = _uuid.v4()
      ..goalMode = goalMode
      ..type = type
      ..title = title
      ..localPath = storedPath
      ..status = 'pending'
      ..consentAt = consent ? DateTime.now() : null
      ..enabled = true
      ..createdAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.knowledgeSources.put(source);
    });
    return source;
  }

  Future<KnowledgeSource> addWebsiteSource({
    required String goalMode,
    required String title,
    required String url,
    required bool consent,
  }) async {
    final uri = Uri.tryParse(url.trim());
    if (uri == null || uri.host.isEmpty || !uri.hasScheme) {
      throw const LibraryException('invalidUrl');
    }
    if (uri.scheme != 'https') {
      throw const LibraryException('httpsOnly');
    }

    final existing = await findByUrl(goalMode: goalMode, url: url);
    if (existing != null) {
      if (existing.status == 'indexed') return existing;
      existing
        ..title = title
        ..status = 'pending'
        ..statusMessage = null
        ..consentAt = consent ? DateTime.now() : existing.consentAt
        ..enabled = true;
      await _db.writeTxn(() async {
        await _db.knowledgeSources.put(existing);
      });
      return existing;
    }

    final source = KnowledgeSource()
      ..uuid = _uuid.v4()
      ..goalMode = goalMode
      ..type = 'website'
      ..title = title
      ..url = url.trim()
      ..domain = uri.host
      ..status = 'pending'
      ..consentAt = consent ? DateTime.now() : null
      ..enabled = true
      ..createdAt = DateTime.now();

    await _db.writeTxn(() async {
      await _db.knowledgeSources.put(source);
    });
    return source;
  }

  /// Indexes a website and only keeps allowlist entry on success.
  /// On failure, deletes the pending source so the UI does not show ghosts.
  Future<KnowledgeSource> addAndIndexWebsite({
    required String goalMode,
    required String title,
    required String url,
    required bool consent,
  }) async {
    final source = await addWebsiteSource(
      goalMode: goalMode,
      title: title,
      url: url,
      consent: consent,
    );
    try {
      await indexSource(source.uuid);
      final uri = Uri.parse(url.trim());
      await addUserWebsite(
        domain: uri.host,
        label: title.trim().isEmpty ? uri.host : title.trim(),
        goalMode: goalMode,
        startUrl: url.trim(),
      );
      final refreshed =
          await _db.knowledgeSources.filter().uuidEqualTo(source.uuid).findFirst();
      return refreshed ?? source;
    } catch (e) {
      await deleteSource(source.uuid);
      if (e is LibraryException) rethrow;
      throw LibraryException('indexFailed', e.toString());
    }
  }

  Future<void> indexSource(String sourceUuid) async {
    final source = await _db.knowledgeSources.filter().uuidEqualTo(sourceUuid).findFirst();
    if (source == null) return;

    source.status = 'indexing';
    source.statusMessage = null;
    await _db.writeTxn(() async {
      await _db.knowledgeSources.put(source);
    });

    try {
      await _vectorStore.deleteBySource(sourceUuid);
      String text;
      if (source.type == 'website' && source.url != null) {
        text = await _websiteIndexer.fetchAndExtract(source.url!);
      } else if (source.localPath != null) {
        text = await _ingestion.extractTextFromFile(source.localPath!);
      } else {
        throw const LibraryException('noContent');
      }

      if (source.type == 'resume' && !_looksLikeResume(text)) {
        throw const LibraryException('notResume');
      }
      if (source.type == 'jd' && !_looksLikeJd(text)) {
        throw const LibraryException('notJd');
      }

      final chunks = _chunking.chunkDocument(
        fullText: text,
        sourceType: source.type,
        title: source.title,
      );

      for (var i = 0; i < chunks.length; i++) {
        final c = chunks[i];
        await _vectorStore.upsertDocumentChunk(
          chunkId: '$sourceUuid:$i',
          sourceUuid: sourceUuid,
          text: c.text,
          citationLabel: c.citationLabel,
          page: c.page,
          section: c.section,
        );
      }

      source
        ..status = 'indexed'
        ..lastIndexedAt = DateTime.now()
        ..statusMessage = '${chunks.length} chunks';
      await _db.writeTxn(() async {
        await _db.knowledgeSources.put(source);
      });
    } catch (e) {
      source
        ..status = 'failed'
        ..statusMessage = e is LibraryException ? e.code : '$e';
      await _db.writeTxn(() async {
        await _db.knowledgeSources.put(source);
      });
      rethrow;
    }
  }

  bool _looksLikeResume(String text) {
    final lower = text.toLowerCase();
    const signals = [
      'experience',
      'education',
      'skills',
      'work history',
      'employment',
      'projects',
      'summary',
      'objective',
      'curriculum vitae',
      'cv',
      'resume',
    ];
    var hits = 0;
    for (final s in signals) {
      if (lower.contains(s)) hits++;
    }
    return hits >= 2 || text.length >= 400;
  }

  bool _looksLikeJd(String text) {
    final lower = text.toLowerCase();
    const signals = [
      'responsibilities',
      'requirements',
      'qualifications',
      'job description',
      'we are looking',
      'about the role',
      'about the company',
      'must have',
      'nice to have',
      'apply',
    ];
    var hits = 0;
    for (final s in signals) {
      if (lower.contains(s)) hits++;
    }
    return hits >= 2 || text.length >= 300;
  }

  /// Best-effort company name from indexed JD text.
  Future<String?> extractCompanyFromJd(String goalMode) async {
    final sources = await enabledSourcesForGoal(goalMode);
    final jd = sources.where((s) => s.type == 'jd').firstOrNull;
    if (jd == null) return null;
    final chunks = await _db.documentChunks
        .filter()
        .sourceUuidEqualTo(jd.uuid)
        .findAll();
    if (chunks.isEmpty) return null;
    final text = chunks.map((c) => c.text).join('\n');
    final companyLine = RegExp(
      r'(?:company|about\s+(?:the\s+)?company|employer)\s*[:\-]\s*([^\n\r.]{2,80})',
      caseSensitive: false,
    ).firstMatch(text);
    if (companyLine != null) return companyLine.group(1)?.trim();
    final atCompany = RegExp(
      r'\bat\s+([A-Z][A-Za-z0-9&.\- ]{1,40})\b',
    ).firstMatch(text);
    return atCompany?.group(1)?.trim();
  }

  Future<bool> hasIndexedType(String goalMode, String type) async {
    final sources = await enabledSourcesForGoal(goalMode);
    return sources.any((s) => s.type == type);
  }

  Future<void> deleteSource(String sourceUuid) async {
    await _vectorStore.deleteBySource(sourceUuid);
    await _db.writeTxn(() async {
      final source = await _db.knowledgeSources.filter().uuidEqualTo(sourceUuid).findFirst();
      if (source?.localPath != null) {
        final f = File(source!.localPath!);
        if (f.existsSync()) await f.delete();
      }
      final chunks = await _db.documentChunks.filter().sourceUuidEqualTo(sourceUuid).findAll();
      await _db.documentChunks.deleteAll(chunks.map((c) => c.id).toList());
      if (source != null) await _db.knowledgeSources.delete(source.id);
    });
  }

  Future<void> setSourceEnabled(String sourceUuid, bool enabled) async {
    final source = await _db.knowledgeSources.filter().uuidEqualTo(sourceUuid).findFirst();
    if (source == null) return;
    source.enabled = enabled;
    await _db.writeTxn(() async {
      await _db.knowledgeSources.put(source);
    });
  }

  Future<List<UserWebsite>> allWebsites() async {
    return _db.userWebsites.where().sortByCreatedAtDesc().findAll();
  }

  Future<bool> isUserAllowedHost(String host) async {
    final h = host.toLowerCase();
    final sites = await _db.userWebsites.filter().enabledEqualTo(true).findAll();
    return sites.any((s) => s.domain.toLowerCase() == h);
  }

  Future<UserWebsite> addUserWebsite({
    required String domain,
    required String label,
    required String goalMode,
    String? startUrl,
  }) async {
    final existing = await _db.userWebsites
        .filter()
        .domainEqualTo(domain.toLowerCase())
        .findFirst();
    if (existing != null) {
      existing
        ..label = label
        ..goalMode = goalMode
        ..startUrl = startUrl ?? existing.startUrl
        ..enabled = true;
      await _db.writeTxn(() async {
        await _db.userWebsites.put(existing);
      });
      return existing;
    }
    final site = UserWebsite()
      ..uuid = _uuid.v4()
      ..domain = domain.toLowerCase()
      ..label = label
      ..goalMode = goalMode
      ..startUrl = startUrl
      ..crawlMode = 'manual_refresh'
      ..enabled = true
      ..createdAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.userWebsites.put(site);
    });
    return site;
  }

  Future<void> deleteUserWebsite(String uuid) async {
    await _db.writeTxn(() async {
      final row = await _db.userWebsites.filter().uuidEqualTo(uuid).findFirst();
      if (row != null) await _db.userWebsites.delete(row.id);
    });
  }

  Future<List<DocumentChunk>> chunksForIds(List<String> chunkIds) async {
    final result = <DocumentChunk>[];
    for (final id in chunkIds) {
      final c = await _db.documentChunks.filter().chunkIdEqualTo(id).findFirst();
      if (c != null) result.add(c);
    }
    return result;
  }

  /// A handful of chunks across the given sources, for use as lightweight RAG
  /// context (e.g. flashcard generation) without a full vector-store retrieval.
  Future<List<DocumentChunk>> chunksForSources(
    Set<String> sourceUuids, {
    int limit = 20,
  }) async {
    if (sourceUuids.isEmpty) return [];
    final result = <DocumentChunk>[];
    for (final uuid in sourceUuids) {
      if (result.length >= limit) break;
      final chunks =
          await _db.documentChunks.filter().sourceUuidEqualTo(uuid).findAll();
      result.addAll(chunks);
    }
    if (result.length > limit) return result.sublist(0, limit);
    return result;
  }

  Future<String> _copyToLibrary(String sourcePath, String type) async {
    final dir = await getApplicationDocumentsDirectory();
    final libDir = Directory(p.join(dir.path, 'knowledge_library', type));
    if (!libDir.existsSync()) libDir.createSync(recursive: true);
    final name = '${_uuid.v4()}${p.extension(sourcePath)}';
    final dest = p.join(libDir.path, name);
    await File(sourcePath).copy(dest);
    return dest;
  }
}
