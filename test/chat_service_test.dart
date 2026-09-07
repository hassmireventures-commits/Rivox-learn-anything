import 'package:ai_quiz_app/data/remote/ai/chat_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ChatService.parseReply', () {
    test('extracts reply from clean {"reply": "..."} JSON', () {
      const raw = '{"reply": "Photosynthesis converts light into chemical energy."}';
      expect(
        ChatService.parseReply(raw),
        'Photosynthesis converts light into chemical energy.',
      );
    });

    test('extracts reply when JSON is wrapped in a markdown code fence', () {
      const raw = '```json\n{"reply": "Mitochondria are the powerhouse of the cell."}\n```';
      expect(ChatService.parseReply(raw), 'Mitochondria are the powerhouse of the cell.');
    });

    test('trims whitespace around the reply text', () {
      const raw = '{"reply": "  Extra spaces should be trimmed.  "}';
      expect(ChatService.parseReply(raw), 'Extra spaces should be trimmed.');
    });

    test('falls back to raw trimmed text when the model ignores the JSON contract', () {
      const raw = '  Just a plain sentence, no JSON at all.  ';
      expect(ChatService.parseReply(raw), 'Just a plain sentence, no JSON at all.');
    });

    test('throws InvalidJsonException when the model returns nothing usable', () {
      expect(() => ChatService.parseReply('   '), throwsA(isA<Exception>()));
    });

    test('ignores unrelated JSON without a reply key and falls back to raw text', () {
      const raw = '{"notReply": "unexpected shape"}';
      // No usable `reply` field -> falls back to the raw (non-empty) text.
      expect(ChatService.parseReply(raw), raw);
    });
  });
}
