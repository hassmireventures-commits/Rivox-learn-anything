import 'package:ai_quiz_app/core/constants/app_constants.dart';
import 'package:ai_quiz_app/core/constants/quiz_kind.dart';
import 'package:ai_quiz_app/core/services/firebase_availability.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('legal urls are hosted (not example.com)', () {
    expect(AppConstants.privacyPolicyUrl.contains('example.com'), isFalse);
    expect(AppConstants.termsUrl.contains('example.com'), isFalse);
  });

    test('question count options are 5, 10, 15, 20', () {
      expect(AppConstants.questionCounts, [5, 10, 15, 20]);
    });

    test('app constants are defined', () {
    expect(AppConstants.appName, 'Rivox');
    expect(AppConstants.appVersion, '1.0.5');
    expect(AppConstants.questionCounts, contains(10));
  });

  test('quiz kinds include daily and demo', () {
    expect(QuizKind.daily, 'daily');
    expect(QuizKind.demo, 'demo');
  });

  test('firebase client config is present for learn-anything-43970', () {
    expect(isFirebaseConfigured, isTrue);
  });
}

