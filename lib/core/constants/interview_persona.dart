/// Interviewer persona for voice interview sessions.
enum InterviewPersona {
  hr,
  tech;

  String get id => name;

  static InterviewPersona? fromId(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    return switch (raw.toLowerCase()) {
      'hr' => InterviewPersona.hr,
      'tech' => InterviewPersona.tech,
      _ => null,
    };
  }
}
