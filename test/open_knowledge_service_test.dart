import 'package:ai_quiz_app/core/services/open_knowledge/arxiv_source.dart';
import 'package:ai_quiz_app/core/services/open_knowledge/open_knowledge_models.dart';
import 'package:ai_quiz_app/core/services/open_knowledge/open_knowledge_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ArxivSource', () {
    test('parses atom entry fields', () {
      const xml = '''
<feed>
  <entry>
    <title>Deep Learning Basics</title>
    <summary>A survey of neural networks.</summary>
    <id>http://arxiv.org/abs/1234.5678</id>
  </entry>
</feed>
''';
      expect(ArxivSource.parseTagTextForTest(xml, 'title'), 'Deep Learning Basics');
      expect(
        ArxivSource.parseTagTextForTest(xml, 'summary'),
        contains('neural networks'),
      );
      expect(
        ArxivSource.parseTagTextForTest(xml, 'id'),
        contains('arxiv.org'),
      );
    });
  });

  group('OpenKnowledgeHit', () {
    test('formats prompt line with url', () {
      const hit = OpenKnowledgeHit(
        source: 'Wikipedia',
        title: 'Artificial intelligence',
        summary: 'AI overview.',
        url: 'https://en.wikipedia.org/wiki/Artificial_intelligence',
      );
      expect(hit.promptLine, contains('Wikipedia'));
      expect(hit.promptLine, contains('wikipedia.org'));
    });
  });

  group('OpenKnowledgeService topic routing', () {
    test('detects biomedical topics', () {
      expect(
        OpenKnowledgeService.topicIsBiomedical('biomedical engineering'),
        isTrue,
      );
      expect(OpenKnowledgeService.topicIsBiomedical('python'), isFalse);
    });

    test('detects STEM topics', () {
      expect(OpenKnowledgeService.topicIsStem('machine learning'), isTrue);
      expect(OpenKnowledgeService.topicIsStem('marketing'), isFalse);
    });

    test('detects literature topics', () {
      expect(OpenKnowledgeService.topicIsLiterature('classic literature'), isTrue);
    });
  });
}
