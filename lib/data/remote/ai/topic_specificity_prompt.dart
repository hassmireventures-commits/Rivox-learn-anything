import 'models/quiz_generation_request.dart';

/// Keeps quiz questions scoped to the exact subfield named in the topic
/// (e.g. "Islamic history" → history, not Islam 101; "Biomedical" → applied
/// medicine/engineering, not general cell biology).
class TopicSpecificityPrompt {
  TopicSpecificityPrompt._();

  static bool applies(QuizGenerationRequest request) => block(request).isNotEmpty;

  static bool suppressBeginnerTrack(QuizGenerationRequest request) {
    final topic = request.topic.trim();
    if (topic.isEmpty) return false;
    final lower = topic.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');
    return _isIslamicHistory(lower) ||
        _isBiomedical(lower) ||
        _hasHistoryModifier(lower) ||
        _hasMedicalModifier(lower);
  }

  static String block(QuizGenerationRequest request) {
    final topic = request.topic.trim();
    if (topic.isEmpty) return '';

    final lower = topic.toLowerCase().replaceAll(RegExp(r'\s+'), ' ');

    if (_isIslamicHistory(lower)) return _islamicHistoryBlock(topic);
    if (_isBiomedical(lower)) return _biomedicalBlock(topic);
    if (_hasHistoryModifier(lower)) return _historyBlock(topic);
    if (_hasMedicalModifier(lower)) return _medicalBlock(topic);

    return _generalScopeBlock(topic);
  }

  static bool _isIslamicHistory(String lower) =>
      lower.contains('islamic history') ||
      lower.contains('history of islam') ||
      (lower.contains('islam') && lower.contains('history'));

  static bool _isBiomedical(String lower) =>
      lower.contains('biomedical') ||
      lower.contains('bio medical') ||
      lower.contains('bio-medical') ||
      (lower.contains('bio') && lower.contains('medical'));

  static bool _hasHistoryModifier(String lower) {
    if (_isIslamicHistory(lower)) return false;
    return RegExp(r'\bhistory\b').hasMatch(lower) ||
        lower.contains('historical') ||
        lower.endsWith(' history');
  }

  static bool _hasMedicalModifier(String lower) {
    if (_isBiomedical(lower)) return false;
    const keys = [
      'clinical', 'diagnostic', 'pharmacology', 'anatomy', 'physiology',
      'nursing', 'healthcare', 'medical device',
    ];
    return keys.any(lower.contains);
  }

  static String _islamicHistoryBlock(String topic) => '''
TOPIC SCOPE — ISLAMIC HISTORY ("$topic"):
Every question MUST focus on historical periods, empires, events, figures, trade routes, cultural developments, and political changes in Islamic civilization.
FORBIDDEN unless tied to a specific historical context: Ramadan/fasting month trivia, naming the Quran/holy book, generic five pillars, daily worship rituals, or introductory "what is Islam" facts.
Even at easy difficulty, ask history questions (e.g. Umayyad/Abbasid caliphates, Golden Age scholars, key battles, spread of Islam, Ottoman/Safavid/Mughal eras) — NOT religious practice basics.
''';

  static String _biomedicalBlock(String topic) => '''
TOPIC SCOPE — BIOMEDICAL ("$topic"):
Every question MUST focus on biomedical science, clinical applications, medical devices, diagnostics, bioengineering, health technology, or medicine-adjacent engineering.
Treat "bio" here as biomedical — NOT general high-school biology (cells, photosynthesis, ecosystems, taxonomy) unless directly applied to a medical or clinical context.
Prefer questions on imaging, prosthetics, biomaterials, lab diagnostics, regulatory/clinical workflows, and human physiology in a healthcare setting.
''';

  static String _historyBlock(String topic) => '''
TOPIC SCOPE — HISTORY ("$topic"):
Every question MUST stay within the historical subfield named in the topic — timelines, causes/effects, key figures, primary sources, and historiography.
Do NOT default to the broader parent subject's introductory or religious/cultural trivia unless the question is explicitly historical.
Modifiers like "history", "historical", or "era" define the domain — honor them strictly.
''';

  static String _medicalBlock(String topic) => '''
TOPIC SCOPE — MEDICAL / HEALTH ("$topic"):
Questions must stay within the clinical or applied health sciences named in the topic — not generic biology or unrelated wellness trivia.
''';

  static String _generalScopeBlock(String topic) => '''
TOPIC SCOPE:
Treat every word in "$topic" as mandatory scope. Modifiers (history, medical, engineering, law, etc.) define the question domain — do NOT collapse to the parent subject's intro-level facts.
At easy difficulty, stay foundational WITHIN the exact subfield named — not the broader category.
''';
}
