import 'package:ai_quiz_app/core/services/daily_content_service.dart';
import 'package:ai_quiz_app/core/services/open_knowledge/open_knowledge_models.dart';
import 'package:ai_quiz_app/core/services/open_knowledge/wikipedia_source.dart';
import 'package:ai_quiz_app/core/services/topic_grounding_service.dart';
import 'package:flutter_test/flutter_test.dart';

/// Fakes [WikipediaSource.searchArticles] so tests never hit the real
/// network — matches this repo's existing dependency-injection seam
/// (`TopicGroundingService({Dio? dio, WikipediaSource? wikipedia})`).
class _FakeWikipediaSource extends WikipediaSource {
  _FakeWikipediaSource(this._hits);

  final List<OpenKnowledgeHit> _hits;

  @override
  Future<List<OpenKnowledgeHit>> searchArticles(
    String searchTerm, {
    int limit = 5,
  }) async {
    return _hits;
  }
}

void main() {
  group('TopicGroundingService.findWikipediaArticle excludeUrls', () {
    // Regression test for "Daily study shows the same Wikipedia article
    // every day": for a fixed topic string, WikipediaSource.searchArticles
    // is fully deterministic, so without an exclusion list the resolver
    // always returned the same first hit. This asserts the fix: a URL in
    // excludeUrls is skipped in favor of the next candidate.
    test('skips an excluded URL and returns the next candidate', () async {
      final fake = _FakeWikipediaSource(const [
        OpenKnowledgeHit(
          source: 'Wikipedia',
          title: 'Dart (programming language)',
          summary: 'A client-optimized language for fast apps.',
          url: 'https://en.wikipedia.org/wiki/Dart_(programming_language)',
        ),
        OpenKnowledgeHit(
          source: 'Wikipedia',
          title: 'Flutter (software)',
          summary: 'An open-source UI toolkit.',
          url: 'https://en.wikipedia.org/wiki/Flutter_(software)',
        ),
      ]);
      final service = TopicGroundingService(wikipedia: fake);

      final result = await service.findWikipediaArticle(
        'Dart',
        excludeUrls: const {
          'https://en.wikipedia.org/wiki/Dart_(programming_language)',
        },
      );

      expect(result, isNotNull);
      expect(result!.url, 'https://en.wikipedia.org/wiki/Flutter_(software)');
    });

    test('returns null when every candidate is excluded', () async {
      final fake = _FakeWikipediaSource(const [
        OpenKnowledgeHit(
          source: 'Wikipedia',
          title: 'Dart (programming language)',
          summary: 'A client-optimized language for fast apps.',
          url: 'https://en.wikipedia.org/wiki/Dart_(programming_language)',
        ),
      ]);
      final service = TopicGroundingService(wikipedia: fake);

      final result = await service.findWikipediaArticle(
        'Dart',
        excludeUrls: const {
          'https://en.wikipedia.org/wiki/Dart_(programming_language)',
        },
      );

      expect(result, isNull);
    });

    test('with no excludeUrls returns the first candidate as before', () async {
      final fake = _FakeWikipediaSource(const [
        OpenKnowledgeHit(
          source: 'Wikipedia',
          title: 'Dart (programming language)',
          summary: 'A client-optimized language for fast apps.',
          url: 'https://en.wikipedia.org/wiki/Dart_(programming_language)',
        ),
      ]);
      final service = TopicGroundingService(wikipedia: fake);

      final result = await service.findWikipediaArticle('Dart');

      expect(result, isNotNull);
      expect(
        result!.url,
        'https://en.wikipedia.org/wiki/Dart_(programming_language)',
      );
    });
  });

  group('DailyContentPack recentArticleUrls persistence', () {
    // The daily-pack JSON cache now also remembers recently shown article
    // URLs so the exclusion list survives across days/process restarts.
    test('round-trips through toJson/fromJson', () {
      const pack = DailyContentPack(
        dateKey: '2026-9-7',
        topic: 'Python',
        recentArticleUrls: [
          'https://en.wikipedia.org/wiki/Python_(programming_language)',
          'https://docs.python.org/3/tutorial/',
        ],
      );

      final restored = DailyContentPack.fromJson(pack.toJson());

      expect(restored.recentArticleUrls, pack.recentArticleUrls);
    });

    test('defaults to an empty list for older persisted files without the field', () {
      final restored = DailyContentPack.fromJson(const {
        'date': '2026-9-7',
        'topic': 'Python',
        'article': null,
        'video': null,
      });

      expect(restored.recentArticleUrls, isEmpty);
    });
  });
}
