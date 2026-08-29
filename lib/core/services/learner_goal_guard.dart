import '../../data/local/models/learner_profile.dart';
import '../../data/local/repositories/learner_repository.dart';

/// Parses and validates learner goal topics / syllabus / skills.
class LearnerGoalGuard {
  LearnerGoalGuard._();

  /// Split on commas, trim, drop empties. `"Python,"` → `[]` after filter of empties
  /// from trailing comma → actually `"Python,"`.split → ["Python", ""] → ["Python"].
  /// Consecutive commas `"Python,,Django"` → ["Python", "Django"].
  static List<String> parseCommaTopics(String raw) {
    if (raw.trim().isEmpty) return const [];
    return raw
        .split(',')
        .map((e) => e.trim())
        .where((e) => e.isNotEmpty)
        .toList(growable: false);
  }

  static bool hasUsableGoal(
    LearnerProfile profile, {
    required LearnerRepository learnerRepository,
  }) {
    final topics = learnerRepository.goalsOf(profile);
    final mode = profile.goalMode;
    switch (mode) {
      case 'exam_prep':
        return profile.goalContext.trim().isNotEmpty &&
            profile.examDate != null &&
            topics.isNotEmpty;
      case 'career':
        return profile.goalContext.trim().isNotEmpty && topics.isNotEmpty;
      default:
        return topics.isNotEmpty && !topics.every(_isTooVague);
    }
  }

  /// Validation error key for UI (caller maps to l10n).
  static String? validateDraft({
    required String goalMode,
    required String goalContext,
    required String topicsRaw,
    DateTime? examDate,
  }) {
    final topics = parseCommaTopics(topicsRaw);
    if (topics.isEmpty) {
      return switch (goalMode) {
        'exam_prep' => 'syllabus',
        'career' => 'skills',
        _ => 'topics',
      };
    }
    if (topics.every(_isTooVague)) {
      return 'tooVague';
    }
    switch (goalMode) {
      case 'exam_prep':
        if (goalContext.trim().isEmpty) return 'examName';
        if (examDate == null) return 'examDate';
      case 'career':
        if (goalContext.trim().isEmpty) return 'role';
    }
    return null;
  }

  static const _vagueGoals = {
    'learning',
    'learn',
    'study',
    'studying',
    'general',
    'anything',
    'stuff',
    'things',
    'knowledge',
    'education',
    'skill',
    'skills',
  };

  static bool _isTooVague(String topic) {
    final t = topic.toLowerCase().replaceAll(RegExp(r'[^a-z0-9\s]'), '').trim();
    if (t.isEmpty) return true;
    if (t.length < 4) return true;
    return _vagueGoals.contains(t);
  }

  static bool isTopicTooVague(String topic) => _isTooVague(topic);
}
