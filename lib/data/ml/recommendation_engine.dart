import 'dart:convert';

import 'package:isar_community/isar.dart';

import '../../data/local/isar_service.dart';
import '../../data/local/models/model_weights.dart';
import '../../data/local/repositories/learner_repository.dart';
import 'feature_engineering_service.dart';

class RecommendationEngine {
  RecommendationEngine(this._isarService, this._learnerRepository, this._features);

  final IsarService _isarService;
  final LearnerRepository _learnerRepository;
  final FeatureEngineeringService _features;

  Isar get _db => _isarService.db;

  Future<Map<String, double>> _weights(String modelId) async {
    final row = await _db.modelWeights.filter().modelIdEqualTo(modelId).findFirst();
    if (row == null) {
      return {
        'weakness': 0.45,
        'recency': 0.2,
        'goal': 0.25,
        'streak': 0.1,
      };
    }
    final map = jsonDecode(row.weightsJson);
    if (map is! Map) return {};
    return map.map((k, v) => MapEntry(k.toString(), (v as num).toDouble()));
  }

  Future<void> _saveWeights(String modelId, Map<String, double> weights) async {
    var row = await _db.modelWeights.filter().modelIdEqualTo(modelId).findFirst();
    row ??= ModelWeights()..modelId = modelId;
    row
      ..weightsJson = jsonEncode(weights)
      ..updatedAt = DateTime.now();
    await _db.writeTxn(() async {
      await _db.modelWeights.put(row!);
    });
  }

  Future<void> refreshRecommendations() async {
    await _learnerRepository.clearOldRecommendations();
    final features = await _features.compute();
    final profile = await _learnerRepository.getOrCreateProfile();
    final goals = _learnerRepository.goalsOf(profile);

    // Per-mode weight overrides (applied on top of stored weights)
    String goalMode = 'learning';
    try { goalMode = profile.goalMode; } catch (_) {}
    final weights = _weightsForMode(goalMode, await _weights('next_topic'));

    final topics = await _learnerRepository.allTopics();

    if (features.dropOffRate > 0.4 || features.engagementScore < 0.25) {
      await _learnerRepository.addRecommendation(
        kind: 'nudge',
        title: 'A short win keeps your streak alive',
        reason: 'Engagement dipped recently - a 5-question quiz helps.',
        score: 0.9,
        actionPayload: {'questionCount': 5},
      );
    }

    if (features.streakRisk > 0.5) {
      await _learnerRepository.addRecommendation(
        kind: 'break',
        title: 'Take a mindful pause or a tiny quiz',
        reason: 'You may be overdue for a session.',
        score: 0.7,
      );
    }

    // Exam mode: prefer full-length timed mocks as urgency rises.
    if (goalMode == 'exam_prep') {
      final daysLeft = profile.examDate?.difference(DateTime.now()).inDays;
      final mockScore = daysLeft == null
          ? 0.65
          : daysLeft <= 14
              ? 0.95
              : daysLeft <= 30
                  ? 0.8
                  : 0.55;
      await _learnerRepository.addRecommendation(
        kind: 'mock',
        title: 'Sit a timed mock',
        reason: daysLeft != null && daysLeft <= 14
            ? 'Exam soon - build stamina with a full timed paper.'
            : 'Full-length practice surfaces syllabus gaps early.',
        score: mockScore,
        actionPayload: {
          'route': '/exam/mock/create',
          if (daysLeft != null) 'daysLeft': daysLeft,
        },
      );
    }

    // Career mode: weekly-style interview drill nudge.
    if (goalMode == 'career') {
      final role = () {
        try {
          return profile.goalContext.trim();
        } catch (_) {
          return '';
        }
      }();
      await _learnerRepository.addRecommendation(
        kind: 'interview',
        title: 'Practice an interview drill',
        reason: role.isEmpty
            ? 'Short mixed drills (MCQ + open answers) close skill gaps.'
            : 'Interview practice for $role builds readiness beyond quizzes.',
        score: 0.78,
        actionPayload: {'route': '/career/drill/create'},
      );
    }

    final scored = <({String topic, double score, String reason})>[];
    for (final topic in topics) {
      final weakness = 1 - topic.strength;
      final recency = topic.lastSeenAt == null
          ? 1.0
          : (DateTime.now().difference(topic.lastSeenAt!).inHours / 72).clamp(0.0, 1.0);
      final goal = goals.any((g) => topic.topic.toLowerCase().contains(g.toLowerCase()))
          ? 1.0
          : 0.0;
      final score = weakness * (weights['weakness'] ?? 0.45) +
          recency * (weights['recency'] ?? 0.2) +
          goal * (weights['goal'] ?? 0.25) +
          features.streakRisk * (weights['streak'] ?? 0.1);
      scored.add((
        topic: topic.topic,
        score: score,
        reason: weakness > 0.5
            ? 'Low mastery on ${topic.topic}'
            : 'Good time to revisit ${topic.topic}',
      ));
    }

    for (final goal in goals) {
      if (!scored.any((s) => s.topic.toLowerCase() == goal.toLowerCase())) {
        scored.add((
          topic: goal,
          score: 0.8,
          reason: 'Aligned with your learning goal',
        ));
      }
    }

    scored.sort((a, b) => b.score.compareTo(a.score));
    for (final item in scored.take(3)) {
      await _learnerRepository.addRecommendation(
        kind: item.score > 0.6 && topics.any((t) => t.topic == item.topic && t.strength < 0.45)
            ? 'remedial'
            : 'next_topic',
        title: 'Practice ${item.topic}',
        reason: item.reason,
        score: item.score,
        topic: item.topic,
        actionPayload: {'topic': item.topic},
      );
    }

    // Layout suggestion (applied cautiously elsewhere).
    final suggestedLayout = _classifyLayout(features);
    if (profile.layoutModeOverride == 'auto' && profile.layoutMode != suggestedLayout) {
      final canChange = profile.lastLayoutChangeAt == null ||
          DateTime.now().difference(profile.lastLayoutChangeAt!).inHours >= 24;
      if (canChange) {
        await _learnerRepository.addRecommendation(
          kind: 'layout',
          title: 'Switch to $suggestedLayout layout',
          reason: 'Based on your recent progress and engagement.',
          score: 0.55,
          actionPayload: {'layoutMode': suggestedLayout},
        );
      }
    }

    await _updateNavAffinity();
  }

  /// Returns weight map adjusted for the user's goal mode.
  /// Stored/trained weights are used as a base and overridden per mode so that
  /// the per-mode priorities take effect immediately without erasing learned weights.
  Map<String, double> _weightsForMode(String mode, Map<String, double> base) {
    return switch (mode) {
      'exam_prep' => {
          'weakness': 0.50,
          'recency': 0.15,
          'goal': 0.30,
          'streak': 0.05,
        },
      'career' => {
          'weakness': 0.35,
          'recency': 0.10,
          'goal': 0.45,
          'streak': 0.10,
        },
      _ => base, // 'learning' - use stored/default weights unchanged
    };
  }

  String _classifyLayout(LearnerFeatures f) {
    if (f.avgAccuracy < 55 || f.sessionCount7d < 2) return 'beginner';
    if (f.avgAccuracy > 80 && f.sessionCount7d >= 5) return 'advanced';
    return 'intermediate';
  }

  Future<void> _updateNavAffinity() async {
    final counts = await _features.navTapCounts();
    if (counts.isEmpty) return;
    final max = counts.values.fold<int>(0, (a, b) => a > b ? a : b).toDouble();
    final affinity = counts.map((k, v) => MapEntry(k, v / max));
    final profile = await _learnerRepository.getOrCreateProfile();
    final order = [..._learnerRepository.navOrderOf(profile)]
      ..sort((a, b) => (affinity[b] ?? 0).compareTo(affinity[a] ?? 0));
    // Keep home first for stability.
    order.remove('home');
    order.insert(0, 'home');
    if (!order.contains('settings')) order.add('settings');
    await _learnerRepository.updateProfile(navOrder: order, navAffinity: affinity);
  }

  Future<void> learnFromOutcome({required bool positive}) async {
    final weights = await _weights('next_topic');
    final delta = positive ? 0.02 : -0.02;
    weights.updateAll((key, value) => (value + delta).clamp(0.05, 0.8));
    await _saveWeights('next_topic', weights);
  }
}
