# Run after `firebase login` to generate platform Firebase config files.
# Prerequisites:
#   1. npm / npx available
#   2. `npx firebase-tools login` completed in an interactive terminal
#   3. Access to Firebase project learn-anything-43970
#
# Usage (from repo root):
#   powershell -ExecutionPolicy Bypass -File scripts/configure_firebase.ps1

$ErrorActionPreference = 'Stop'
$env:Path = "$env:LOCALAPPDATA\Programs\Git\bin;$env:LOCALAPPDATA\Pub\Cache\bin;$env:APPDATA\npm;" + $env:Path

Write-Host 'Activating flutterfire_cli...'
dart pub global activate flutterfire_cli

Write-Host 'Configuring Firebase project learn-anything-43970 (android + ios)...'
dart pub global run flutterfire_cli:flutterfire configure `
  --project=learn-anything-43970 `
  --platforms=android,ios `
  --android-package-name=com.aiquiz.ai_quiz_app `
  --ios-bundle-id=com.aiquiz.aiQuizApp `
  --out=lib/firebase_options.dart `
  --yes

# FlutterFire may overwrite firebase_options.dart; restore app helpers used by bootstrap.
$optionsPath = Join-Path $PSScriptRoot '..\lib\firebase_options.dart' | Resolve-Path
$contents = Get-Content -Raw $optionsPath
if ($contents -notmatch 'optionsAreConfigured') {
  Write-Host 'Appending isConfigured helpers to firebase_options.dart...'
  $helpers = @'

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
'@
  $trimmed = $contents.TrimEnd()
  if ($trimmed.EndsWith('}')) {
    $withoutLast = $trimmed.Substring(0, $trimmed.LastIndexOf('}'))
    Set-Content -Path $optionsPath -Value ($withoutLast.TrimEnd() + "`r`n" + $helpers.TrimStart()) -NoNewline
    Add-Content -Path $optionsPath -Value ''
  }
}

Write-Host 'Done. Verify DefaultFirebaseOptions.isConfigured == true and google-services.json has no REPLACE_WITH_* placeholders.'
Write-Host 'Firestore cloud writes stay off unless ENABLE_FIRESTORE_ANALYTICS=true.'
