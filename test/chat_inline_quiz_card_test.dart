import 'package:ai_quiz_app/data/remote/ai/chat_reply_result.dart';
import 'package:ai_quiz_app/features/chat/presentation/chat_inline_quiz_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  final quiz = ChatInlineQuiz.fromJson({
    'topic': 'Git',
    'questions': [
      {
        'question': 'Which command records a snapshot?',
        'options': ['git commit', 'git push', 'git fetch'],
        'answerIndex': 0,
        'explanation': 'Commit writes to the local history.',
      },
    ],
  })!;

  Widget host(ChatInlineQuiz q, {void Function(int, int)? onAnswer, VoidCallback? onExplain}) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: ChatInlineQuizCard(
            quiz: q,
            onAnswer: onAnswer ?? (_, _) {},
            onExplainMistakes: onExplain,
            onAnotherRound: () {},
          ),
        ),
      ),
    );
  }

  testWidgets('tapping an option reports the pick', (tester) async {
    (int, int)? picked;
    await tester.pumpWidget(host(quiz, onAnswer: (q, o) => picked = (q, o)));
    expect(find.text('Quick check: Git'), findsOneWidget);
    await tester.tap(find.text('git push'));
    expect(picked, (0, 1));
  });

  testWidgets('answered card shows feedback, score, and locks options', (tester) async {
    var taps = 0;
    var explained = false;
    await tester.pumpWidget(host(
      quiz.withAnswer(0, 1),
      onAnswer: (_, _) => taps++,
      onExplain: () => explained = true,
    ));
    expect(find.textContaining('Not quite.'), findsOneWidget);
    expect(find.textContaining('Commit writes to the local history.'), findsOneWidget);
    expect(find.text('0 of 1 correct'), findsOneWidget);

    await tester.tap(find.text('git fetch'));
    expect(taps, 0);

    await tester.tap(find.text('Explain my mistakes'));
    expect(explained, isTrue);
  });

  testWidgets('a perfect score hides "Explain my mistakes"', (tester) async {
    await tester.pumpWidget(host(quiz.withAnswer(0, 0), onExplain: () {}));
    expect(find.text('All 1 correct. Nice work.'), findsOneWidget);
    expect(find.text('Explain my mistakes'), findsNothing);
    expect(find.text('Harder questions'), findsOneWidget);
  });
}
