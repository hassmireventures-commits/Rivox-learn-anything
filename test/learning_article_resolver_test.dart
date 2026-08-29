import 'package:ai_quiz_app/core/services/learning_article_resolver.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('LearningArticleResolver.condenseLearningTitle', () {
    test('strips introduction filler from module titles', () {
      expect(
        LearningArticleResolver.condenseLearningTitle(
          'Introduction to clinical practice',
        ),
        'clinical practice',
      );
    });

    test('strips module prefix', () {
      expect(
        LearningArticleResolver.condenseLearningTitle('Module 3: Dental anatomy'),
        'Dental anatomy',
      );
    });
  });

  group('LearningArticleResolver.buildSearchQueries', () {
    test('combines module title with path goal for any subject', () {
      final queries = LearningArticleResolver.buildSearchQueries(
        topic: 'Introduction to clinical practice',
        goalContext: 'dental',
      );
      expect(queries, contains('Introduction to clinical practice'));
      expect(queries, contains('clinical practice'));
      expect(queries, contains('dental'));
      expect(queries, contains('dental clinical practice'));
    });

    test('includes org brand queries for domain goals', () {
      final queries = LearningArticleResolver.buildSearchQueries(
        topic: 'Product overview',
        goalContext: 'elsai.ai',
      );
      expect(queries.any((q) => q.toLowerCase().contains('elsai')), isTrue);
    });

    test('dedupes case-insensitive queries', () {
      final queries = LearningArticleResolver.buildSearchQueries(
        topic: 'Python',
        goalContext: 'python',
      );
      expect(
        queries.where((q) => q.toLowerCase() == 'python').length,
        1,
      );
    });
  });

  group('LearningArticleResolver.scoreCandidate', () {
    test('prefers coding tutorials over Wikipedia for Python', () {
      final tutorial = ArticleCandidate(
        title: 'Python Tutorial — W3Schools',
        url: 'https://www.w3schools.com/python/default.asp',
        summary: 'Hands-on Python basics and syntax.',
        source: 'w3schools',
      );
      final wiki = ArticleCandidate(
        title: 'Python (programming language)',
        url: 'https://en.wikipedia.org/wiki/Python_(programming_language)',
        summary: 'General-purpose programming language.',
        source: 'wikipedia',
      );

      final tutorialScore = LearningArticleResolver.scoreCandidate(
        candidate: tutorial,
        topic: 'Python basics',
        goalContext: 'Python',
        condensedTopic: 'Python basics',
      );
      final wikiScore = LearningArticleResolver.scoreCandidate(
        candidate: wiki,
        topic: 'Python basics',
        goalContext: 'Python',
        condensedTopic: 'Python basics',
      );

      expect(tutorialScore, greaterThan(wikiScore));
    });

    test('prefers medical source bonus for dental goals', () {
      final khan = ArticleCandidate(
        title: 'Health and medicine',
        url: 'https://www.khanacademy.org/science/health-and-medicine',
        summary: 'Clinical foundations.',
        source: 'khanacademy',
      );
      final genericWiki = ArticleCandidate(
        title: 'Learning',
        url: 'https://en.wikipedia.org/wiki/Learning',
        summary: 'How people acquire knowledge.',
        source: 'wikipedia',
      );

      final khanScore = LearningArticleResolver.scoreCandidate(
        candidate: khan,
        topic: 'Introduction to clinical practice',
        goalContext: 'dental',
        condensedTopic: 'clinical practice',
      );
      final wikiScore = LearningArticleResolver.scoreCandidate(
        candidate: genericWiki,
        topic: 'Introduction to clinical practice',
        goalContext: 'dental',
        condensedTopic: 'clinical practice',
      );

      expect(khanScore, greaterThan(wikiScore));
    });

    test('ranks stronger title overlap higher within same source', () {
      final strong = ArticleCandidate(
        title: 'Dental anatomy',
        url: 'https://en.wikipedia.org/wiki/Dental_anatomy',
        summary: 'Structure of teeth and jaw.',
        source: 'wikipedia',
        queryRank: 0,
        resultRank: 0,
      );
      final weak = ArticleCandidate(
        title: 'Learning',
        url: 'https://en.wikipedia.org/wiki/Learning',
        summary: 'Generic learning article.',
        source: 'wikipedia',
        queryRank: 3,
        resultRank: 2,
      );

      final strongScore = LearningArticleResolver.scoreCandidate(
        candidate: strong,
        topic: 'Dental anatomy basics',
        goalContext: 'dental',
        condensedTopic: 'Dental anatomy basics',
      );
      final weakScore = LearningArticleResolver.scoreCandidate(
        candidate: weak,
        topic: 'Dental anatomy basics',
        goalContext: 'dental',
        condensedTopic: 'Dental anatomy basics',
      );

      expect(strongScore, greaterThan(weakScore));
    });
  });
}
