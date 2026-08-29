import 'package:ai_quiz_app/core/services/firebase_availability.dart';
import 'package:ai_quiz_app/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('isFirebaseConfigured is true for learn-anything-43970 client config', () {
    expect(DefaultFirebaseOptions.isConfigured, isTrue);
    expect(isFirebaseConfigured, isTrue);
    expect(DefaultFirebaseOptions.android.projectId, 'learn-anything-43970');
  });

  test('optionsAreConfigured rejects placeholder-shaped keys', () {
    expect(
      DefaultFirebaseOptions.optionsAreConfigured(
        const FirebaseOptions(
          apiKey: 'REPLACE_WITH_ANDROID_API_KEY',
          appId: 'REPLACE_WITH_ANDROID_APP_ID',
          messagingSenderId: 'REPLACE_WITH_PROJECT_NUMBER',
          projectId: 'learn-anything-43970',
        ),
      ),
      isFalse,
    );
  });

  test('optionsAreConfigured accepts generated Android options', () {
    expect(
      DefaultFirebaseOptions.optionsAreConfigured(DefaultFirebaseOptions.android),
      isTrue,
    );
  });
}
