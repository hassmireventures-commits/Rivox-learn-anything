import 'dart:convert';

import 'package:ai_quiz_app/data/remote/ai/models/generated_quiz.dart';
import 'package:ai_quiz_app/data/remote/ai/models/question_stimulus.dart';
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
