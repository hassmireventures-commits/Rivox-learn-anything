import 'package:ai_quiz_app/core/error/app_exception.dart';
import 'package:ai_quiz_app/data/remote/ai/ai_output_gate.dart';
import 'package:ai_quiz_app/data/remote/ai/quiz_json_parser.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AiOutputGate', () {
    test('accepts valid JSON object', () {
      expect(AiOutputGate.acceptsJsonObject('{"brief":"Keep going today."}'), isTrue);
    });

    test('accepts embedded JSON even when reasoning prefix present', () {
      const raw = 'JSON only. The user wants a brief. {"brief":"Keep going with Python today."}';
      expect(AiOutputGate.acceptsJsonObject(raw), isTrue);
    });

    test('disables json_object mode for Nemotron', () {
      expect(
        AiOutputGate.useJsonObjectResponseFormat('nvidia/nemotron-3-nano-30b-a3b'),
        isFalse,
      );
      expect(
        AiOutputGate.useJsonObjectResponseFormat('meta/llama-3.2-11b-vision-instruct'),
        isTrue,
      );
    });

    test('disables thinking for Nemotron requests', () {
      expect(
        AiOutputGate.requestExtrasForModel('nvidia/nemotron-3-nano-30b-a3b'),
        {'chat_template_kwargs': {'enable_thinking': false}},
      );
      expect(AiOutputGate.requestExtrasForModel('gpt-4o-mini'), isEmpty);
    });

    test('rejects empty Nemotron content stub', () {
      expect(AiOutputGate.acceptsJsonObject('{"questions":[]}'), isFalse);
    });

    test('extracts JSON from Nemotron reasoning channel', () {
      const reasoning = '''
Thinking about variables...
{
  "questions": [
    {"text":"What is x?","options":["1","2","3","4"],"correctIndex":0,"type":"mcq","explanation":"Basic."}
  ]
}
''';
      const stub = '{"questions":[]}';
      final normalized = AiOutputGate.normalizeFromOpenAiMessage(
        {'content': stub, 'reasoning_content': reasoning},
        modelId: 'nvidia/nemotron-3-nano-30b-a3b',
      );
      expect(normalized, contains('"questions"'));
      expect(QuizJsonParser.parse(normalized!, expectedCount: 1).questions, isNotEmpty);
    });

    test('extracts embedded JSON', () {
      const raw = 'Here is output {"steps":[{"title":"Intro"}]} end';
      final extracted = AiOutputGate.extractJsonObject(raw);
      expect(extracted.startsWith('{'), isTrue);
    });

    test('repairs Nemotron single-quoted brief JSON', () {
      const broken =
          '''{"brief':'You have got this! Keep practicing Python variables today.'} extra''';
      final repaired = AiOutputGate.normalizeFromOpenAiMessage(
        {'content': broken},
        modelId: 'nvidia/nemotron-3-nano-30b-a3b',
      );
      expect(repaired, isNotNull);
      expect(repaired, contains('brief'));
    });

    test('requireJsonOutput extracts and rejects stubs', () {
      expect(
        AiOutputGate.requireJsonOutput('prefix {"brief":"Keep studying Python today."}'),
        contains('"brief"'),
      );
      expect(
        () => AiOutputGate.requireJsonOutput('{"questions":[]}'),
        throwsA(isA<InvalidJsonException>()),
      );
    });

    test('needsStrictRetry is true for placeholders and false for valid JSON', () {
      expect(AiOutputGate.needsStrictRetry('{"title":"..."}'), isTrue);
      expect(
        AiOutputGate.needsStrictRetry('{"brief":"Keep practicing Python variables."}'),
        isFalse,
      );
    });

    test('accepts pulse brief with enough substance', () {
      expect(
        AiOutputGate.acceptsPulseBrief(
          'You are making steady progress on Python. Keep practicing variables today.',
        ),
        isTrue,
      );
      expect(AiOutputGate.acceptsPulseBrief('---'), isFalse);
    });
  });
}
