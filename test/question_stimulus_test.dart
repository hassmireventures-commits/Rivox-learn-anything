import 'dart:convert';

import 'package:ai_quiz_app/data/remote/ai/models/generated_quiz.dart';
import 'package:ai_quiz_app/data/remote/ai/models/question_stimulus.dart';
import 'package:ai_quiz_app/data/remote/ai/quiz_json_parser.dart';
import 'package:ai_quiz_app/data/remote/ai/stimulus_answer_check.dart';
import 'package:ai_quiz_app/features/quiz/presentation/question_stimulus_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('chart and transcript parse, and a bare question has no stimulus', () {
    final chart = QuestionStimulus.fromMap({
      'kind': 'chart',
      'title': 'Average temperature',
      'unit': '°C',
      'points': [
        {'label': 'London', 'value': 8},
        {'label': 'Cairo', 'value': 22},
      ],
    });
    expect(chart, isNotNull);
    expect(chart!.isChart, isTrue);
    expect(chart.points, hasLength(2));

    final spoken = QuestionStimulus.tryParse(
      '{"kind":"transcript","title":"Conversation","body":"Anna: Hi\\nBen: Hello"}',
    );
    expect(spoken!.isTranscript, isTrue);
    expect(spoken.body, contains('Anna'));

    expect(QuestionStimulus.fromMap({'kind': 'passage', 'body': ''}), isNull);
    expect(QuestionStimulus.fromMap({'kind': 'video'}), isNull);
  });

  test('generated quiz keeps stimulus only when the object is usable', () {
    final quiz = GeneratedQuiz.fromJson({
      'questions': [
        {
          'text': 'Which city is warmer?',
          'options': ['London', 'Cairo', 'Oslo', 'Paris'],
          'correctIndex': 1,
          'type': 'mcq',
          'stimulus': {
            'kind': 'chart',
            'title': 'Average temperature',
            'points': [
              {'label': 'London', 'value': 8},
              {'label': 'Cairo', 'value': 22},
            ],
          },
        },
        {
          'text': 'What is 2+2?',
          'options': ['3', '4', '5', '6'],
          'correctIndex': 1,
          'type': 'mcq',
        },
      ],
    });
    expect(quiz.questions.first.stimulusJson, contains('chart'));
    expect(quiz.questions.last.stimulusJson, isNull);
  });

  test('a chart caption is rewritten and the key follows the highest value', () {
    final aligned = StimulusAnswerCheck.align(
      text: 'The graph shows the average temperature in London and Cairo over the past week.',
      options: const ['8°C', '22°C', '15°C', '30°C'],
      correctIndex: 0,
      type: 'mcq',
      stimulusJson:
          '{"kind":"chart","title":"Average temperature","unit":"°C","points":[{"label":"London","value":8},{"label":"Cairo","value":22}]}',
    );
    expect(aligned.changed, isTrue);
    expect(aligned.text, 'What is the highest average temperature?');
    expect(aligned.correctIndex, 1);
  });

  test('a named chart question keeps that label, not the other bar', () {
    final aligned = StimulusAnswerCheck.align(
      text: 'What is the average temperature in London?',
      options: const ['8°C', '22°C', '15°C', '30°C'],
      correctIndex: 1,
      type: 'mcq',
      stimulusJson:
          '{"kind":"chart","title":"Average temperature","points":[{"label":"London","value":8},{"label":"Cairo","value":22}]}',
    );
    expect(aligned.correctIndex, 0);
    expect(aligned.text, contains('London'));
  });

  test('a transcript key that the speakers never mention is replaced', () {
    const body =
        'A: Did you hear about the new restaurant in town? B: Yes, I went there last weekend. A: How was it? B: It was great, I highly recommend it.';
    final quiz = QuizJsonParser.parse(
      '''
{"questions":[
  {"text":"What is the main topic of the conversation?","options":["The upcoming event","The new restaurant","A train delay","A school exam"],"correctIndex":0,"type":"mcq","explanation":"They discuss an event.","stimulus":{"kind":"transcript","title":"Conversation","body":"$body"}},
  {"text":"What is 2+2?","options":["3","4","5","6"],"correctIndex":1,"type":"mcq"}
]}
''',
      expectedCount: 2,
    );
    final topic = quiz.questions.first;
    expect(topic.correctIndex, 1);
    expect(topic.options[topic.correctIndex], 'The new restaurant');
    expect(topic.explanation, isNot(contains('event')));
    expect(quiz.questions.last.correctIndex, 1);
  });

  test('true/false, fill-blank, and cue keys follow the material', () {
    const chart =
        '{"kind":"chart","title":"Average temperature","points":[{"label":"London","value":8},{"label":"Cairo","value":22}]}';
    final warmer = StimulusAnswerCheck.align(
      text: 'Cairo is warmer than London.',
      options: const ['True', 'False'],
      correctIndex: 1,
      type: 'true_false',
      stimulusJson: chart,
    );
    expect(warmer.correctIndex, 0);

    final london = StimulusAnswerCheck.align(
      text: 'The temperature in London is 22.',
      options: const ['True', 'False'],
      correctIndex: 0,
      type: 'true_false',
      stimulusJson: chart,
    );
    expect(london.correctIndex, 1);

    final blank = StimulusAnswerCheck.align(
      text: 'The temperature in London is _____.',
      options: const ['22', '8', '15', '30'],
      correctIndex: 0,
      type: 'fill_blank',
      stimulusJson: chart,
    );
    expect(blank.correctIndex, 1);
    expect(blank.text, contains('_____'));

    final cue = StimulusAnswerCheck.align(
      text: 'Which thesis matches the task?',
      options: const ['An upcoming event', 'A new restaurant', 'A train delay', 'A school exam'],
      correctIndex: 0,
      type: 'mcq',
      stimulusJson:
          '{"kind":"cue","title":"Task","body":"Write about a new restaurant you enjoyed."}',
    );
    expect(cue.correctIndex, 1);

    final unproven = StimulusAnswerCheck.align(
      text: 'What does this figure mean for next year?',
      options: const ['8°C', '22°C', '15°C', '30°C'],
      correctIndex: 0,
      type: 'mcq',
      stimulusJson: chart,
    );
    expect(unproven.drop, isTrue);
  });

  testWidgets('only a question that needs extra material shows it', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: ListView(
            children: [
              QuestionStimulusView(
                raw: jsonEncode({
                  'kind': 'chart',
                  'title': 'Average temperature',
                  'unit': '°C',
                  'points': [
                    {'label': 'London', 'value': 8},
                    {'label': 'Cairo', 'value': 22},
                  ],
                }),
              ),
              QuestionStimulusView(
                raw: jsonEncode({
                  'kind': 'table',
                  'title': 'Visitors',
                  'columns': ['Place', 'Saturday'],
                  'rows': [
                    ['Museum', '120'],
                  ],
                }),
              ),
              QuestionStimulusView(
                raw: jsonEncode({
                  'kind': 'transcript',
                  'title': 'Conversation',
                  'body': 'Anna: The booking is at six.',
                }),
              ),
              QuestionStimulusView(
                raw: jsonEncode({
                  'kind': 'passage',
                  'title': 'Reading',
                  'body': 'Cities near the coast stay milder in winter.',
                }),
              ),
              const QuestionStimulusView(raw: null),
            ],
          ),
        ),
      ),
    );

    expect(find.text('Average temperature'), findsOneWidget);
    expect(find.text('London'), findsOneWidget);
    expect(find.text('Museum'), findsOneWidget);
    expect(find.text('Anna: The booking is at six.'), findsOneWidget);
    expect(find.byTooltip('Listen'), findsOneWidget);
    expect(find.text('Cities near the coast stay milder in winter.'), findsOneWidget);
  });
}
