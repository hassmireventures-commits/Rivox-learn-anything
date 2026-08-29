import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/quiz_session.dart';
import '../../data/local/models/telemetry_event.dart';
import '../../data/local/repositories/learner_repository.dart';

class LearnerFeatures {
  const LearnerFeatures({
    required this.avgAccuracy,
    required this.sessionCount7d,
    required this.dropOffRate,
    required this.avgSessionHour,
    required this.weakTopicCount,
    required this.streakRisk,
    required this.engagementScore,
  });

  final double avgAccuracy;
  final int sessionCount7d;
  final double dropOffRate;
  final double avgSessionHour;
  final int weakTopicCount;
  final double streakRisk;
  final double engagementScore;
}

class FeatureEngineeringService {
  FeatureEngineeringService(this._isarService, this._learnerRepository);

  final IsarService _isarService;
  final LearnerRepository _learnerRepository;

  Isar get _db => _isarService.db;

  Future<LearnerFeatures> compute() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final sessions = await _db.quizSessions
        .filter()
        .completedAtIsNotNull()
        .sortByCompletedAtDesc()
        .findAll();

    final recent = sessions.where((s) => s.completedAt!.isAfter(weekAgo)).toList();
    final avgAccuracy = sessions.isEmpty
        ? 0.0
        : sessions.fold<double>(0, (a, s) => a + (s.accuracy ?? 0)) / sessions.length;

    final events = await _db.telemetryEvents.where().sortByTimestampDesc().limit(300).findAll();
    final starts = events.where((e) => e.type == 'quiz_started').length;
    final completes = events.where((e) => e.type == 'quiz_completed').length;
    final dropOffRate = starts == 0 ? 0.0 : (starts - completes).clamp(0, starts) / starts;

    final hours = events.map((e) => e.timestamp.hour.toDouble()).toList();
    final avgHour = hours.isEmpty ? 12.0 : hours.reduce((a, b) => a + b) / hours.length;

    final weak = await _learnerRepository.weakTopics();
    final lastDay = sessions.isEmpty
        ? null
        : DateTime(
            sessions.first.completedAt!.year,
            sessions.first.completedAt!.month,
            sessions.first.completedAt!.day,
          );
    final today = DateTime(now.year, now.month, now.day);
    final streakRisk = lastDay == null
        ? 1.0
        : today.difference(lastDay).inDays >= 1
            ? 0.8
            : 0.1;

    final engagement = (recent.length / 7.0).clamp(0.0, 1.0) * (1 - dropOffRate) * (avgAccuracy / 100);

    return LearnerFeatures(
      avgAccuracy: avgAccuracy,
      sessionCount7d: recent.length,
      dropOffRate: dropOffRate,
      avgSessionHour: avgHour,
      weakTopicCount: weak.length,
      streakRisk: streakRisk,
      engagementScore: engagement.clamp(0.0, 1.0),
    );
  }

  Future<Map<String, int>> navTapCounts() async {
    final events = await _db.telemetryEvents.filter().typeEqualTo('nav_tap').findAll();
    final counts = <String, int>{};
    for (final e in events) {
      final payload = jsonDecode(e.payloadJson);
      if (payload is Map && payload['destination'] != null) {
        final key = payload['destination'].toString();
        counts[key] = (counts[key] ?? 0) + 1;
      }
    }
    return counts;
  }
}
