import 'dart:io';

import 'package:path_provider/path_provider.dart';

import '../../data/local/repositories/goal_progress_repository.dart';

/// One-time reset of inflated career/exam progress to 0%.
class ReadinessZeroMigration {
  ReadinessZeroMigration._();

  static const _flagName = 'readiness_zero_v1.done';

  static Future<File> _flagFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_flagName');
  }

  /// Runs at most once. Zeros career skill levels and syllabus unit mastery.
  static Future<void> runIfNeeded(GoalProgressRepository repo) async {
    try {
      final flag = await _flagFile();
      if (await flag.exists()) return;
      await repo.resetAllProgressLevelsToZero();
      await flag.writeAsString(DateTime.now().toUtc().toIso8601String());
    } catch (_) {
      // Soft-fail: app must still launch if migration cannot complete.
    }
  }
}
