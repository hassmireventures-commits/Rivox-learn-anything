// File generated for Firebase project learn-anything-43970.
// Regenerate with: scripts/configure_firebase.ps1 (requires `firebase login`)

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB4T5XCQAQwhp9qgiv4ZeKMwG10kIfcOH8',
    appId: '1:943316506839:android:a365921c8f147433d4b892',
    messagingSenderId: '943316506839',
    projectId: 'learn-anything-43970',
    storageBucket: 'learn-anything-43970.firebasestorage.app',
  );
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDyOBCJQv-wJR4rZgbVJESVtTd9bhoCeKA',
    appId: '1:943316506839:ios:20d594668fd2b26dd4b892',
    messagingSenderId: '943316506839',
    projectId: 'learn-anything-43970',
    storageBucket: 'learn-anything-43970.firebasestorage.app',
    iosBundleId: 'com.aiquiz.aiQuizApp',
  );
  static bool optionsAreConfigured(FirebaseOptions options) {
    return !options.apiKey.contains('REPLACE_WITH') &&
        !options.appId.contains('REPLACE_WITH') &&
        !options.messagingSenderId.contains('REPLACE_WITH') &&
        options.apiKey.isNotEmpty &&
        options.appId.isNotEmpty &&
        options.messagingSenderId.isNotEmpty;
  }

  static bool get isConfigured {
    if (kIsWeb) return false;
    try {
      return optionsAreConfigured(currentPlatform);
    } catch (_) {
      return false;
    }
  }
}
