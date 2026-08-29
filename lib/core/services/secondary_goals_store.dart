import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../models/saved_goal.dart';

class SecondaryGoalsStore {
  SecondaryGoalsStore._();
  static final instance = SecondaryGoalsStore._();

  List<SavedGoal> _cached = [];

  List<SavedGoal> get current => List.unmodifiable(_cached);

  Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/secondary_goals.json');
  }

  Future<List<SavedGoal>> load() async {
    try {
      final file = await _file();
      if (!file.existsSync()) return _cached;
      final json = jsonDecode(await file.readAsString());
      if (json is List) {
        _cached = json
            .whereType<Map<String, dynamic>>()
            .map(SavedGoal.fromJson)
            .toList();
      }
    } catch (_) {}
    return _cached;
  }

  Future<void> save(List<SavedGoal> goals) async {
    _cached = List.of(goals);
    final file = await _file();
    await file.writeAsString(
      jsonEncode(goals.map((g) => g.toJson()).toList()),
    );
  }
}
