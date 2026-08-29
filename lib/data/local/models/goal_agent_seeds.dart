/// Parsed GoalAgent v2 payloads (exam_prep / career).
class AgentSyllabusUnitSeed {
  const AgentSyllabusUnitSeed({
    required this.title,
    required this.weight,
    required this.topics,
    this.targetMastery = 0.7,
  });

  final String title;
  final double weight;
  final List<String> topics;
  final double targetMastery;

  factory AgentSyllabusUnitSeed.fromJson(Map<String, dynamic> json) {
    final topicsRaw = json['topics'];
    final topics = topicsRaw is List
        ? topicsRaw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    return AgentSyllabusUnitSeed(
      title: (json['title']?.toString() ?? '').trim(),
      weight: ((json['weight'] as num?)?.toDouble() ?? 1.0).clamp(0.05, 1.0),
      topics: topics,
      targetMastery: ((json['targetMastery'] as num?)?.toDouble() ?? 0.7).clamp(0.1, 1.0),
    );
  }
}

class AgentCareerSkillSeed {
  const AgentCareerSkillSeed({
    required this.title,
    required this.category,
    required this.targetLevel,
    required this.seedLevel,
    required this.topics,
  });

  final String title;
  final String category;
  final double targetLevel;
  final double seedLevel;
  final List<String> topics;

  factory AgentCareerSkillSeed.fromJson(Map<String, dynamic> json) {
    final topicsRaw = json['topics'];
    final topics = topicsRaw is List
        ? topicsRaw.map((e) => e.toString().trim()).where((e) => e.isNotEmpty).toList()
        : <String>[];
    final category = (json['category']?.toString() ?? 'technical').toLowerCase();
    return AgentCareerSkillSeed(
      title: (json['title']?.toString() ?? '').trim(),
      category: switch (category) {
        'behavioral' || 'tool' || 'domain' => category,
        _ => 'technical',
      },
      targetLevel: ((json['targetLevel'] as num?)?.toDouble() ?? 0.8).clamp(0.1, 1.0),
      seedLevel: ((json['seedLevel'] as num?)?.toDouble() ?? 0.2).clamp(0.0, 1.0),
      topics: topics,
    );
  }
}

List<AgentSyllabusUnitSeed> parseSyllabusUnits(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map>()
      .map((e) => AgentSyllabusUnitSeed.fromJson(Map<String, dynamic>.from(e)))
      .where((u) => u.title.isNotEmpty)
      .toList();
}

List<AgentCareerSkillSeed> parseCareerSkills(dynamic raw) {
  if (raw is! List) return [];
  return raw
      .whereType<Map>()
      .map((e) => AgentCareerSkillSeed.fromJson(Map<String, dynamic>.from(e)))
      .where((s) => s.title.isNotEmpty)
      .toList();
}
