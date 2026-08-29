import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

class PathStepsStorage {
  PathStepsStorage._();
  static final instance = PathStepsStorage._();

  Future<File> _file(String pathUuid) async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/path_steps');
    if (!folder.existsSync()) {
      folder.createSync(recursive: true);
    }
    return File('${folder.path}/$pathUuid.json');
  }

  Future<void> saveSteps(String pathUuid, List<Map<String, dynamic>> steps) async {
    final file = await _file(pathUuid);
    await file.writeAsString(jsonEncode(steps));
  }

  Future<List<Map<String, dynamic>>> loadSteps(String pathUuid) async {
    final file = await _file(pathUuid);
    if (!file.existsSync()) return [];
    try {
      final decoded = jsonDecode(await file.readAsString());
      if (decoded is! List) return [];
      return decoded.map((e) => Map<String, dynamic>.from(e as Map)).toList();
    } catch (_) {
      return [];
    }
  }

  Future<void> deleteSteps(String pathUuid) async {
    final file = await _file(pathUuid);
    if (file.existsSync()) {
      await file.delete();
    }
  }

  Future<void> clearAll() async {
    final dir = await getApplicationDocumentsDirectory();
    final folder = Directory('${dir.path}/path_steps');
    if (folder.existsSync()) {
      await folder.delete(recursive: true);
    }
  }
}
