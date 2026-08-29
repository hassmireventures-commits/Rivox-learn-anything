import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:uuid/uuid.dart';

import 'daily_content_service.dart';

/// Local JSON store for daily study content history (not Isar — avoids schema regen).
class NotificationHistoryItem {
  const NotificationHistoryItem({
    required this.id,
    required this.kind,
    required this.title,
    required this.body,
    required this.payload,
    required this.createdAtIso,
    required this.read,
  });

  final String id;

  /// Only `content` is stored going forward (legacy qotd/generation purged on load).
  final String kind;
  final String title;
  final String body;

  /// Route `/daily-content` or JSON snapshot of a [DailyContentPack].
  final String payload;
  final String createdAtIso;
  final bool read;

  NotificationHistoryItem copyWith({bool? read}) => NotificationHistoryItem(
        id: id,
        kind: kind,
        title: title,
        body: body,
        payload: payload,
        createdAtIso: createdAtIso,
        read: read ?? this.read,
      );

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind,
        'title': title,
        'body': body,
        'payload': payload,
        'createdAtIso': createdAtIso,
        'read': read,
      };

  factory NotificationHistoryItem.fromJson(Map<String, dynamic> json) {
    return NotificationHistoryItem(
      id: json['id']?.toString() ?? '',
      kind: json['kind']?.toString() ?? 'content',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      payload: json['payload']?.toString() ?? '',
      createdAtIso: json['createdAtIso']?.toString() ?? '',
      read: json['read'] == true,
    );
  }

  /// Parses a pack snapshot (or legacy single-item) from [payload].
  DailyContentPack? get contentPackSnapshot {
    final raw = payload.trim();
    if (!raw.startsWith('{')) return null;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! Map) return null;
      final map = Map<String, dynamic>.from(decoded);
      map.remove('route');
      final pack = DailyContentPack.fromJson(map);
      if (pack.items.isEmpty) return null;
      return pack;
    } catch (_) {
      return null;
    }
  }

  /// Legacy single-item snapshot (first item in pack).
  DailyContentItem? get contentSnapshot {
    final pack = contentPackSnapshot;
    if (pack == null) return null;
    return pack.article ?? pack.video;
  }

  static String payloadForPack(DailyContentPack pack) {
    return jsonEncode({
      'route': '/daily-content',
      ...pack.toJson(),
    });
  }

  static String payloadForContent(DailyContentItem item) {
    return payloadForPack(
      DailyContentPack(
        dateKey: item.dateKey,
        topic: item.topic,
        article: item.type == 'article' ? item : null,
        video: item.type == 'video' ? item : null,
      ),
    );
  }

  /// Date key used for same-day dedupe (snapshot `date` or created day).
  String get contentDateKey {
    final pack = contentPackSnapshot;
    if (pack != null && pack.dateKey.isNotEmpty) return pack.dateKey;
    try {
      final decoded = jsonDecode(payload);
      if (decoded is Map) {
        final d = decoded['date']?.toString();
        if (d != null && d.isNotEmpty) return d;
      }
    } catch (_) {}
    try {
      final created = DateTime.parse(createdAtIso).toLocal();
      return '${created.year}-${created.month}-${created.day}';
    } catch (_) {
      return '';
    }
  }
}

class NotificationHistoryStore {
  NotificationHistoryStore._();
  static final instance = NotificationHistoryStore._();

  static const _fileName = 'notification_history_v1.json';
  static const _maxItems = 100;
  final _uuid = const Uuid();

  List<NotificationHistoryItem>? _cache;

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  Future<List<NotificationHistoryItem>> _load() async {
    if (_cache != null) return _cache!;
    try {
      final file = await _file();
      if (!await file.exists()) {
        _cache = [];
        return _cache!;
      }
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is List) {
        final all = decoded
            .whereType<Map>()
            .map((e) => NotificationHistoryItem.fromJson(Map<String, dynamic>.from(e)))
            .toList();
        final contentOnly = all.where((e) => e.kind == 'content').toList();
        _cache = contentOnly;
        // Purge legacy qotd/generation rows from disk.
        if (contentOnly.length != all.length) {
          await _persist(contentOnly);
        }
      } else {
        _cache = [];
      }
    } catch (_) {
      _cache = [];
    }
    return _cache!;
  }

  Future<void> _persist(List<NotificationHistoryItem> items) async {
    _cache = items;
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(items.map((e) => e.toJson()).toList()));
    } catch (_) {}
  }

  Future<NotificationHistoryItem> add({
    required String kind,
    required String title,
    required String body,
    String payload = '',
  }) async {
    // History segment is daily study only.
    if (kind != 'content') {
      return NotificationHistoryItem(
        id: '',
        kind: kind,
        title: title,
        body: body,
        payload: payload,
        createdAtIso: DateTime.now().toUtc().toIso8601String(),
        read: true,
      );
    }

    final items = await _load();
    final item = NotificationHistoryItem(
      id: _uuid.v4(),
      kind: kind,
      title: title,
      body: body,
      payload: payload,
      createdAtIso: DateTime.now().toUtc().toIso8601String(),
      read: false,
    );

    final dateKey = item.contentDateKey;
    final next = <NotificationHistoryItem>[item];
    for (final existing in items) {
      if (dateKey.isNotEmpty && existing.contentDateKey == dateKey) {
        continue; // Dedupe same-day pick (foreground + Workmanager).
      }
      next.add(existing);
    }
    if (next.length > _maxItems) {
      next.removeRange(_maxItems, next.length);
    }
    await _persist(next);
    return item;
  }

  Future<List<NotificationHistoryItem>> list() async {
    final items = await _load();
    return List.unmodifiable(items.where((e) => e.kind == 'content'));
  }

  Future<void> markRead(String id) async {
    final items = await _load();
    final idx = items.indexWhere((e) => e.id == id);
    if (idx < 0) return;
    items[idx] = items[idx].copyWith(read: true);
    await _persist(items);
  }

  Future<void> clear() async {
    await _persist([]);
  }
}
