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
    int moduleCount = 6,
    String ragContextBlock = '',
    String topicResolutionBlock = '',
  }) {
    final allowedDocs = OfficialLearningDomains.docDomains.take(28).join(', ');
    // Keep path JSON lean (classic app used 4-6 modules) so generation stays fast.
    final count = moduleCount.clamp(4, 6);
    final rag = ragContextBlock.isNotEmpty ? '$ragContextBlock\n\n' : '';
    final resolution = topicResolutionBlock.isNotEmpty ? '$topicResolutionBlock\n\n' : '';
    final libraryNote = ragContextBlock.isNotEmpty
        ? '- Library excerpts (resume, job description, notes) are highest priority; lightly normalize messy formatting but do not invent facts.\n'
        : '';
    return '''
${rag}${resolution}Create a personalized learning path as a single JSON object (no markdown).

User goals: ${goals.isEmpty ? 'general learning' : goals.join(', ')}
Weak topics: ${weakTopics.isEmpty ? 'none yet' : weakTopics.join(', ')}
Skill level: ${(skillLevel * 100).round()}%
Daily study time: $dailyMinutes minutes
Focus area: ${focus ?? 'based on goals and weak topics'}
Output language: Write all module titles and summaries in $language.

Requirements:
$libraryNote- PRIMARY GOAL drives every module — weak topics are hints only when they directly support that goal; never substitute unrelated domains (e.g. Islamic history or biomedical when the goal is a company domain)
- Assume ZERO prior knowledge — module 1 must be the most basic foundations of the primary goal only
- Exactly $count ordered modules from foundations to practice
- Each module needs: title, summary, difficulty (easy|medium|hard), estimatedMinutes
- Each module MUST include at least one "resources" entry with type "doc" and a REAL article URL (not a homepage) from ONLY these domains: $allowedDocs (or other .gov/.edu docs)
- The article URL path MUST match the module topic (e.g. a page about that concept). Never use site roots like https://python.org/ or https://www.w3schools.com/
- For non-technical goals (history, business, languages, civics), prefer Khan Academy, Britannica, Wikipedia, wikiHow, How-To Geek, Investopedia, OpenStax, or .edu — never a programming homepage
- For computer science, coding, and programming goals prefer GeeksforGeeks, W3Schools, MDN, freeCodeCamp, TutorialsPoint, Real Python, or official docs (docs.python.org, react.dev, docs.flutter.dev) — real tutorial paths, never site roots
- If the user goal is too vague to pick a real article, still write specific module titles from first principles of that subject
- Treat every word in user goals as mandatory scope (e.g. "Islamic history" = historical periods/events, NOT generic religious practice trivia; "Biomedical" = clinical/bioengineering, NOT general high-school biology). For any subject, pick Wikipedia articles whose title/path matches the module topic — search the exact module concept when unsure
- Every module MUST include "youtubeUrl" with a real educational YouTube tutorial matching the module title (https://www.youtube.com/watch?v=VIDEO_ID). Both article and video are required per module.
- Prefer well-known educational channels (freeCodeCamp, Traversy Media, Corey Schafer, CS Dojo, Khan Academy, official docs channels)
- NEVER use music videos, memes, movie clips, or entertainment (e.g. never Rick Astley / Never Gonna Give You Up)
- If you are not sure of a real educational video ID, omit youtubeUrl or set it to null — do NOT invent random IDs
- The YouTube video ID must be exactly 11 characters when present
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
