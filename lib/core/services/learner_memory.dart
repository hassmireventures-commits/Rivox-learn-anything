/// A single title+type pair from the learner's library, kept lightweight
/// (not the full [KnowledgeSource]) since this only needs to be readable by
/// chat as reference context.
class LibrarySourceRef {
  const LibrarySourceRef({required this.title, required this.type});

  final String title;
  final String type;

  Map<String, dynamic> toJson() => {'title': title, 'type': type};

  static LibrarySourceRef fromJson(Map<String, dynamic> json) => LibrarySourceRef(
        title: json['title']?.toString() ?? '',
        type: json['type']?.toString() ?? '',
      );
}

/// Consolidated, once-a-day-refreshed picture of the learner: goals, library
/// content, quiz performance pattern, and recent daily content — the
/// primary reference chat draws on instead of assembling this fresh on
/// every message. Computed by [LearnerMemoryService], scheduled by
/// [LearnerMemoryScheduler]. Purely a local statistical rollup — no AI call
/// went into producing this.
class LearnerMemorySnapshot {
  const LearnerMemorySnapshot({
    required this.goalMode,
    required this.goalContextLabel,
    required this.primaryTopics,
    required this.librarySources,
    required this.topicAccuracy,
    required this.frequentlyMissed,
    required this.currentStreak,
    required this.longestStreak,
    required this.recentDailyTopics,
    required this.computedAt,
  });

  final String goalMode;
  final String goalContextLabel;
  final List<String> primaryTopics;
  final List<LibrarySourceRef> librarySources;

  /// Topic -> rounded accuracy percent, most-recently-active topics first.
  final Map<String, int> topicAccuracy;

  /// Topics behind the most wrong answers, most-missed first.
  final List<String> frequentlyMissed;

  final int currentStreak;
  final int longestStreak;

  /// Most recent daily-content topics/titles, most recent first.
  final List<String> recentDailyTopics;

  final DateTime computedAt;

  Map<String, dynamic> toJson() => {
        'goalMode': goalMode,
        'goalContextLabel': goalContextLabel,
        'primaryTopics': primaryTopics,
        'librarySources': librarySources.map((s) => s.toJson()).toList(),
        'topicAccuracy': topicAccuracy,
        'frequentlyMissed': frequentlyMissed,
        'currentStreak': currentStreak,
        'longestStreak': longestStreak,
        'recentDailyTopics': recentDailyTopics,
        'computedAt': computedAt.toIso8601String(),
      };

  static LearnerMemorySnapshot fromJson(Map<String, dynamic> json) {
    return LearnerMemorySnapshot(
      goalMode: json['goalMode']?.toString() ?? 'learning',
      goalContextLabel: json['goalContextLabel']?.toString() ?? '',
      primaryTopics: (json['primaryTopics'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      librarySources: (json['librarySources'] as List?)
              ?.map((e) => LibrarySourceRef.fromJson(Map<String, dynamic>.from(e as Map)))
              .toList() ??
          const [],
      topicAccuracy: (json['topicAccuracy'] as Map?)?.map(
            (k, v) => MapEntry(k.toString(), (v as num).toInt()),
          ) ??
          const {},
      frequentlyMissed:
          (json['frequentlyMissed'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      currentStreak: (json['currentStreak'] as num?)?.toInt() ?? 0,
      longestStreak: (json['longestStreak'] as num?)?.toInt() ?? 0,
      recentDailyTopics:
          (json['recentDailyTopics'] as List?)?.map((e) => e.toString()).toList() ?? const [],
      computedAt: DateTime.tryParse(json['computedAt']?.toString() ?? '') ?? DateTime.now(),
    );
  }

  /// Compact, prompt-ready summary. Null when there's nothing worth telling
  /// the model beyond what it already gets elsewhere.
  String? toPromptSection() {
    final buffer = StringBuffer();
    var wroteAnything = false;

    if (goalContextLabel.trim().isNotEmpty) {
      buffer.writeln('Learner memory (goals, library, study pattern):');
      buffer.writeln('- Goal: $goalContextLabel ($goalMode)');
      wroteAnything = true;
    }
    if (librarySources.isNotEmpty) {
      final names = librarySources.take(8).map((s) => s.title).join(', ');
      buffer.writeln('- Library sources: $names');
      wroteAnything = true;
    }
    if (topicAccuracy.isNotEmpty) {
      final lines = topicAccuracy.entries.take(6).map((e) => '${e.key}: ${e.value}%').join(', ');
      buffer.writeln('- Topic accuracy: $lines');
      wroteAnything = true;
    }
    if (frequentlyMissed.isNotEmpty) {
      buffer.writeln('- Frequently missed topics: ${frequentlyMissed.take(5).join(', ')}');
      wroteAnything = true;
    }
    if (currentStreak > 0 || longestStreak > 0) {
      buffer.writeln('- Study streak: $currentStreak days (longest $longestStreak)');
      wroteAnything = true;
    }
    if (recentDailyTopics.isNotEmpty) {
      buffer.writeln('- Recent daily content: ${recentDailyTopics.take(5).join(', ')}');
      wroteAnything = true;
    }

    return wroteAnything ? buffer.toString().trimRight() : null;
  }
}
