import '../../../core/constants/official_learning_domains.dart';

class PathPromptBuilder {
  const PathPromptBuilder._();

  static String build({
    required List<String> goals,
    required List<String> weakTopics,
    required double skillLevel,
    required int dailyMinutes,
    String? focus,
    required String language,
  }) {
    final allowedDocs = OfficialLearningDomains.docDomains.take(12).join(', ');
    return '''
Create a personalized learning path as a single JSON object (no markdown).

User goals: ${goals.isEmpty ? 'general learning' : goals.join(', ')}
Weak topics: ${weakTopics.isEmpty ? 'none yet' : weakTopics.join(', ')}
Skill level: ${(skillLevel * 100).round()}%
Daily study time: $dailyMinutes minutes
Focus area: ${focus ?? 'based on goals and weak topics'}
Output language: Write all module titles and summaries in $language.

Requirements:
- 4 to 6 ordered modules from foundations to practice
- Each module needs: title, summary, difficulty (easy|medium|hard), estimatedMinutes
- Each module needs 2-4 "resources" with type "doc", title, and full https URL from ONLY these official domains: $allowedDocs (or other .gov/.edu docs)
- Each module needs one educational YouTube watch URL as "youtubeUrl" (https://www.youtube-nocookie.com/watch?v=...) from reputable channels with embedding enabled
- Use only well-known, embed-friendly YouTube videos from major educational channels (e.g. freeCodeCamp, Khan Academy, Google Developers). Do NOT invent video IDs.
- URLs must be real, well-known documentation pages when possible

JSON schema:
{
  "title": "string",
  "steps": [
    {
      "title": "string",
      "summary": "string",
      "difficulty": "easy|medium|hard",
      "estimatedMinutes": 15,
      "youtubeUrl": "https://www.youtube.com/watch?v=...",
      "resources": [
        {"type":"doc","title":"string","url":"https://..."}
      ]
    }
  ]
}
''';
  }
}
