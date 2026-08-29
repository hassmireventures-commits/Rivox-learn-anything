import 'package:ai_quiz_app/core/services/topic_grounding_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('TopicGroundingService.normalizeDomainUrl', () {
    test('normalizes bare domains', () {
      expect(
        TopicGroundingService.normalizeDomainUrl('elsai.ai'),
        'https://elsai.ai',
      );
      expect(
        TopicGroundingService.normalizeDomainUrl('https://www.elsai.ai/about'),
        'https://elsai.ai',
      );
    });

    test('returns null for non-domains', () {
      expect(TopicGroundingService.normalizeDomainUrl('Python'), isNull);
      expect(TopicGroundingService.normalizeDomainUrl('Islamic history'), isNull);
    });
  });

  group('TopicGroundingService.wikipediaSearchTerm', () {
    test('uses brand label from domain', () {
      expect(TopicGroundingService.wikipediaSearchTerm('elsai.ai'), 'elsai');
      expect(TopicGroundingService.wikipediaSearchTerm('https://openai.com'), 'openai');
    });
  });

  group('TopicGroundingService.parseHomepageMeta', () {
    test('extracts title and og:description', () {
      const html = '''
<html><head>
<title>Elsai — AI Platform</title>
<meta property="og:description" content="Elsai builds enterprise AI tools for teams." />
</head><body></body></html>
''';
      final parsed = TopicGroundingService.parseHomepageMeta(html);
      expect(parsed.title, contains('Elsai'));
      expect(parsed.description, contains('enterprise AI'));
    });
  });

  group('TopicGroundingFacts.isUsable', () {
    test('accepts site description with title', () {
      const facts = TopicGroundingFacts(
        siteTitle: 'Elsai',
        siteDescription: 'Elsai builds enterprise AI automation for business teams worldwide.',
      );
      expect(facts.isUsable, isTrue);
    });

    test('rejects empty facts', () {
      expect(const TopicGroundingFacts().isUsable, isFalse);
    });
  });

  group('TopicGroundingService.buildLearningScope', () {
    test('combines site and wiki text', () {
      const facts = TopicGroundingFacts(
        siteTitle: 'Elsai AI',
        siteDescription: 'Elsai provides AI workflow automation.',
        wikipediaTitle: 'Example Corp',
        wikipediaExtract: 'Example Corp is a technology company.',
      );
      final scope = TopicGroundingService.buildLearningScope(facts, 'elsai.ai');
      expect(scope, contains('elsai.ai'));
      expect(scope, contains('AI workflow'));
      expect(scope, contains('technology company'));
    });
  });
}
