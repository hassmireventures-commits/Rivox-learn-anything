import 'coding_tutorial_sources.dart';
import 'exam_cert_resources.dart';
import 'language_exam_resources.dart';

/// Picks a basics-first lesson for language exams, coding, and other exams.
/// General topics are not handled here.
class SkillArticles {
  SkillArticles._();

  static bool isPracticeTopic(String text) {
    return LanguageExamResources.matches(text) ||
        CodingTutorialSources.isCodingTopic(text) ||
        ExamCertResources.matches(text);
  }

  /// Topic string to use for today's pack when the goal is a practice subject.
  /// Keeps a specific topic such as "Python" and only falls back to the goal
  /// when the picked string is a subskill like "loops".
  static String? preferredTopic({
    required String resolved,
    required String picked,
    required String goalContext,
    required List<String> goals,
  }) {
    if (isPracticeTopic(resolved)) return resolved.trim();
    for (final part in [picked, goalContext, ...goals]) {
      if (isPracticeTopic(part)) return part.trim();
    }
    return null;
  }

  static List<({String url, String title, String summary})> allCurated(String topic) {
    if (LanguageExamResources.matches(topic)) {
      return LanguageExamResources.articlesFor(topic);
    }
    if (CodingTutorialSources.isCodingTopic(topic)) {
      return CodingTutorialSources.articleCandidates(topic);
    }
    return ExamCertResources.articlesFor(topic);
  }

  static ({String url, String title, String summary})? curated(
    String topic, {
    Set<String> excludeUrls = const {},
  }) {
    if (LanguageExamResources.matches(topic)) {
      return LanguageExamResources.nextArticle(topic, excludeUrls: excludeUrls);
    }
    final coding = CodingTutorialSources.nextArticle(
      topic,
      excludeUrls: excludeUrls,
    );
    if (coding != null) return coding;
    return ExamCertResources.nextArticle(topic, excludeUrls: excludeUrls);
  }
}
