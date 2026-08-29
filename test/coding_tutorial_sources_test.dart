import 'package:ai_quiz_app/core/services/coding_tutorial_sources.dart';
import 'package:ai_quiz_app/core/services/learning_article_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CodingTutorialSources.isCodingTopic', () {
    test('detects programming topics', () {
      expect(CodingTutorialSources.isCodingTopic('Python'), isTrue);
      expect(CodingTutorialSources.isCodingTopic('Computer science'), isTrue);
      expect(CodingTutorialSources.isCodingTopic('JavaScript basics'), isTrue);
    });

    test('skips non-coding topics', () {
      expect(CodingTutorialSources.isCodingTopic('Islamic history'), isFalse);
      expect(CodingTutorialSources.isCodingTopic('Marketing'), isFalse);
      expect(CodingTutorialSources.isCodingTopic('Azure DevOps'), isFalse);
      expect(CodingTutorialSources.isCodingTopic('Product management'), isFalse);
    });
  });

  group('CodingTutorialSources.articleCandidates', () {
    test('returns W3Schools and GeeksforGeeks for Python', () {
      final urls = CodingTutorialSources.articleCandidates('Python')
          .map((e) => e.url)
          .join(' ');
      expect(urls, contains('w3schools.com'));
      expect(urls, contains('geeksforgeeks.org'));
    });

    test('returns DSA tutorials for computer science', () {
      final urls = CodingTutorialSources.articleCandidates('Computer science')
          .map((e) => e.url)
          .join(' ');
      expect(urls, contains('geeksforgeeks.org'));
    });

    test('does not return generic DSA for unrelated goals', () {
      final urls = CodingTutorialSources.articleCandidates('Azure DevOps')
          .map((e) => e.url)
          .join(' ');
      expect(urls, isEmpty);
    });
  });

  group('LearningArticleResolver.buildSearchQueries', () {
    test('expands multi-word product goals for Wikipedia', () {
      final queries = LearningArticleResolver.buildSearchQueries(
        topic: 'Azure DevOps',
      );
      expect(queries, contains('Azure DevOps'));
      expect(queries, contains('Azure DevOps overview'));
    });
  });
}
