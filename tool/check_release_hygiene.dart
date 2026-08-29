// Release hygiene gate for CI (ARB Must Q6).
//
// Fails the build if known placeholder / insecure patterns remain in source.
// Usage: `dart run tool/check_release_hygiene.dart`

import 'dart:io';

void main() {
  final root = Directory.current;
  final failures = <String>[];

  void fail(String msg) => failures.add(msg);

  final appConstants = File('lib/core/constants/app_constants.dart');
  if (appConstants.existsSync()) {
    final text = appConstants.readAsStringSync();
    final hasPlaceholderLegal = text.contains("'https://example.com") ||
        text.contains('"https://example.com') ||
        text.contains("'http://example.com") ||
        text.contains('"http://example.com');
    if (hasPlaceholderLegal) {
      fail('app_constants.dart still references example.com legal URLs');
    }
  } else {
    fail('Missing lib/core/constants/app_constants.dart');
  }

  final manifest = File('android/app/src/main/AndroidManifest.xml');
  if (manifest.existsSync()) {
    final text = manifest.readAsStringSync();
    if (RegExp(r'usesCleartextTraffic\s*=\s*"true"').hasMatch(text)) {
      fail('AndroidManifest enables usesCleartextTraffic=true');
    }
  }

  final firebaseOptions = File('lib/firebase_options.dart');
  if (firebaseOptions.existsSync()) {
    final text = firebaseOptions.readAsStringSync();
    // Placeholders are OK while Firebase is optional; warn only if analytics
    // cloud writes are enabled by default (they must stay off).
    if (text.contains('REPLACE_WITH_') &&
        File('lib/data/remote/analytics/anon_analytics_sync.dart')
            .readAsStringSync()
            .contains('defaultValue: true')) {
      fail('Firestore analytics enabled by default with placeholder Firebase options');
    }
  }

  final analytics = File('lib/data/remote/analytics/anon_analytics_sync.dart');
  if (analytics.existsSync()) {
    final text = analytics.readAsStringSync();
    if (!text.contains('ENABLE_FIRESTORE_ANALYTICS')) {
      fail('AnonAnalyticsSync must gate writes with ENABLE_FIRESTORE_ANALYTICS');
    }
  }

  final rules = File('firestore.rules');
  if (!rules.existsSync()) {
    fail('Missing firestore.rules (required when analytics cloud writes may be on)');
  } else {
    final rulesText = rules.readAsStringSync();
    if (RegExp(r'allow\s+read,\s*write:\s*if\s+true').hasMatch(rulesText) ||
        RegExp(r'allow\s+write:\s*if\s+true').hasMatch(rulesText)) {
      fail('firestore.rules must not allow unrestricted writes');
    }
  }

  final consent = File('lib/core/ai_platform/ai_consent_gate.dart');
  if (consent.existsSync()) {
    final text = consent.readAsStringSync();
    if (RegExp(r'sendChunksToProvider\s*=\s*true').hasMatch(text) ||
        text.contains("sendChunksToProvider: json['sendChunksToProvider'] as bool? ?? true")) {
      fail('sendChunksToProvider must default to false (opt-in)');
    }
  }

  if (failures.isNotEmpty) {
    stderr.writeln('Release hygiene check FAILED:');
    for (final f in failures) {
      stderr.writeln('  - $f');
    }
    exit(1);
  }

  stdout.writeln('Release hygiene check passed (${root.path}).');
}
