/// Feedback tone for interview rubric scoring (B37) — orthogonal to
/// [InterviewPersona], which controls the *questions* asked, not how the
/// feedback on answers reads. Kept as a separate enum rather than folding
/// into persona since a candidate might want tech questions with friendly
/// feedback, or HR questions scored strictly, independently.
enum ScoringTone {
  strict,
  friendly;

  String get id => name;

  static ScoringTone fromId(String? raw) => switch (raw?.toLowerCase()) {
        'strict' => ScoringTone.strict,
        _ => ScoringTone.friendly,
      };
}
