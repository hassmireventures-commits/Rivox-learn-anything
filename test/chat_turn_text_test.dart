import 'package:ai_quiz_app/features/chat/presentation/chat_turn_text.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('a plain message stays a plain message', () {
    final turn = ChatTurnText.parse('What is a clause?');
    expect(turn.hasAttachment, isFalse);
    expect(turn.displayQuestion, 'What is a clause?');
    expect(turn.compose(), 'What is a clause?');
  });

  test('the bubble shows the question and the file name, not the file', () {
    const body = 'Listening section\n\nThe restaurant opens Friday.';
    final stored = ChatTurnText(
      question: 'What opens on Friday?',
      attachmentLabel: 'notes.pdf',
      attachmentBody: body,
    ).compose();

    final turn = ChatTurnText.parse(stored);
    expect(turn.displayQuestion, 'What opens on Friday?');
    expect(turn.attachmentLabel, 'notes.pdf');
    expect(turn.attachmentBody, body);
    expect(turn.displayQuestion.contains('Listening section'), isFalse);
  });

  test('an attachment with no question uses a short default', () {
    final stored = const ChatTurnText(
      question: '',
      attachmentLabel: 'camera scan',
      attachmentBody: 'Page one',
    ).compose();

    final turn = ChatTurnText.parse(stored);
    expect(turn.displayQuestion, ChatTurnText.defaultQuestion);
    expect(stored.contains('Page one'), isTrue);
  });
}
