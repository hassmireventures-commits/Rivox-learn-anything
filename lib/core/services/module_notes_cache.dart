import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class ModuleNotesCacheEntry {
  const ModuleNotesCacheEntry({
    required this.notes,
    required this.usedTranscript,
  });

  final String notes;
  final bool usedTranscript;

  Map<String, dynamic> toJson() => {
        'notes': notes,
        'usedTranscript': usedTranscript,
      };

  factory ModuleNotesCacheEntry.fromJson(Map<String, dynamic> json) =>
      ModuleNotesCacheEntry(
        notes: json['notes']?.toString() ?? '',
        usedTranscript: json['usedTranscript'] == true,
      );
}

/// Persists module notes per pathId + moduleIndex on disk.
class ModuleNotesCache {
  ModuleNotesCache._();

  static Future<File> _file(String pathId, int moduleIndex) async {
    final dir = await getApplicationDocumentsDirectory();
    final safe = pathId.replaceAll(RegExp(r'[^a-zA-Z0-9_-]'), '_');
    return File('${dir.path}/module_notes_v2_${safe}_$moduleIndex.json');
  }

  static Future<ModuleNotesCacheEntry?> load(String pathId, int moduleIndex) async {
    try {
      final file = await _file(pathId, moduleIndex);
      if (!await file.exists()) return null;
      final map = jsonDecode(await file.readAsString());
      if (map is! Map) return null;
      final entry = ModuleNotesCacheEntry.fromJson(Map<String, dynamic>.from(map));
      if (entry.notes.trim().isEmpty) return null;
      return entry;
    } catch (_) {
      return null;
    }
  }

  static Future<void> save(
    String pathId,
    int moduleIndex,
    ModuleNotesCacheEntry entry,
  ) async {
    try {
      final file = await _file(pathId, moduleIndex);
      await file.writeAsString(jsonEncode(entry.toJson()));
    } catch (_) {}
  }

  static Future<void> clear(String pathId, int moduleIndex) async {
    try {
      final file = await _file(pathId, moduleIndex);
      if (await file.exists()) await file.delete();
    } catch (_) {}
  }
}
