import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

/// Remembers YouTube IDs rejected as irrelevant or known-bad so paths never reuse them.
class YoutubeRejectStore {
  YoutubeRejectStore._();

  static const _fileName = 'youtube_rejected_ids_v1.json';

  /// Notorious non-educational IDs (Rickroll, etc.).
  static const seededRejects = <String>{
    'dQw4w9WgXcQ', // Never Gonna Give You Up
    'jNQXAC9IVRw', // Me at the zoo (often wrong placeholder)
    '9bZkp7q19f0', // Gangnam Style
    'kJQP7kiw5Fk', // Despacito
    'fJ9rUzIMcZQ', // Bohemian Rhapsody
  };

  static Set<String>? _cache;

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<Set<String>> load() async {
    if (_cache != null) return _cache!;
    final ids = <String>{...seededRejects};
    try {
      final file = await _file();
      if (await file.exists()) {
        final list = jsonDecode(await file.readAsString());
        if (list is List) {
          for (final e in list) {
            final id = e.toString().trim();
            if (id.length == 11) ids.add(id);
          }
        }
      }
    } catch (_) {}
    _cache = ids;
    return ids;
  }

  static Future<bool> isRejected(String videoId) async {
    final ids = await load();
    return ids.contains(videoId.trim());
  }

  static Future<void> reject(String videoId, {String reason = 'irrelevant'}) async {
    final id = videoId.trim();
    if (id.length != 11) return;
    final ids = await load();
    if (ids.contains(id)) return;
    ids.add(id);
    _cache = ids;
    try {
      final file = await _file();
      await file.writeAsString(jsonEncode(ids.toList()));
    } catch (_) {}
  }
}
