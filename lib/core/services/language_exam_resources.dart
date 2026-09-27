/// English-proficiency exams (IELTS and close cousins) and curated skill
/// articles, ordered from basics to later tasks. Not Wikipedia.
class LanguageExamResources {
  LanguageExamResources._();

  static final _exam = RegExp(
    r'\b(ielts|toefl|toeic|celpip|oet|pte|duolingo english|cambridge english)\b',
    caseSensitive: false,
  );

  static bool matches(String text) {
    final t = text.trim();
    if (t.isEmpty) return false;
    return _exam.hasMatch(t);
  }

  static bool matchesAny(Iterable<String> parts) =>
      parts.any((p) => matches(p));

  /// Basics first: reading techniques, then listening, writing, speaking.
  static const ieltsArticles = <({String url, String title, String summary})>[
    (
      url: 'https://ieltsliz.com/ielts-reading-lessons-information-and-tips/',
      title: 'IELTS Reading: practice, tips, and question types',
      summary:
          'Start here: skimming, scanning, and the real reading question types (True/False/Not Given, headings, multiple choice).',
    ),
    (
      url: 'https://ieltsliz.com/ielts-listening/',
      title: 'IELTS Listening: practice and techniques',
      summary:
          'How the four listening sections work, and practice for form, map, and multiple-choice questions.',
    ),
    (
      url: 'https://ieltsliz.com/ielts-writing-task-2/',
      title: 'IELTS Writing Task 2: essays from the basics',
      summary:
          'Essay types, planning, and model answers for the 250-word task.',
    ),
    (
      url: 'https://ieltsliz.com/ielts-writing-task-1-lessons-and-tips/',
      title: 'IELTS Writing Task 1: charts, diagrams, and GT letters',
      summary:
          'How to describe data or write a General Training letter, with model answers.',
    ),
    (
      url: 'https://ieltsliz.com/ielts-speaking-free-lessons-essential-tips/',
      title: 'IELTS Speaking: parts 1 to 3',
      summary:
          'Cue cards, how long to speak, and model answers for the three speaking parts.',
    ),
  ];

  static List<({String url, String title, String summary})> articlesFor(String topic) =>
      ieltsArticles;

  /// Next unseen article. Wraps to the basics page when every URL was recent.
  static ({String url, String title, String summary}) nextArticle(
    String topic, {
    Set<String> excludeUrls = const {},
  }) {
    final all = articlesFor(topic);
    for (final article in all) {
      if (!excludeUrls.contains(article.url)) return article;
    }
    return all.first;
  }
}
