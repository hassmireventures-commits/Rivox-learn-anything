import 'dart:convert';

/// A persisted learning goal (primary or secondary).
class SavedGoal {
  const SavedGoal({
    required this.mode,
    required this.context,
    this.topics = const [],
    this.examDate,
    this.examType,
    this.roleSeniority,
  });

  final String mode;
  final String context;
  final List<String> topics;
  final DateTime? examDate;
  final String? examType;
  final String? roleSeniority;

  String get displayLabel {
    if (context.isNotEmpty) return context;
    if (topics.isNotEmpty) return topics.first;
    return mode;
  }

  Map<String, dynamic> toJson() => {
        'mode': mode,
        'context': context,
        'topics': topics,
        if (examDate != null) 'examDate': examDate!.toIso8601String(),
        if (examType != null) 'examType': examType,
        if (roleSeniority != null) 'roleSeniority': roleSeniority,
      };

  factory SavedGoal.fromJson(Map<String, dynamic> json) => SavedGoal(
        mode: json['mode'] as String? ?? 'learning',
        context: json['context'] as String? ?? '',
        topics: (json['topics'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            const [],
        examDate: json['examDate'] != null
            ? DateTime.tryParse(json['examDate'] as String)
            : null,
        examType: json['examType'] as String?,
        roleSeniority: json['roleSeniority'] as String?,
      );

  static List<SavedGoal> listFromJson(String raw) {
    if (raw.isEmpty || raw == '[]') return [];
    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return [];
      return decoded
          .whereType<Map<String, dynamic>>()
          .map(SavedGoal.fromJson)
          .toList();
    } catch (_) {
      return [];
    }
  }

  static String encodeList(List<SavedGoal> goals) =>
      jsonEncode(goals.map((g) => g.toJson()).toList());
}
