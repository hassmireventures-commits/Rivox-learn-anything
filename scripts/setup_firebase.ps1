# Completes Firebase wiring for AI Quiz (project: ai-quiz-5c2ff).
# Prerequisites: Node.js (for firebase-tools), Flutter/Dart on PATH.
# Run from the project root:
#   powershell -ExecutionPolicy Bypass -File scripts/setup_firebase.ps1

$ErrorActionPreference = "Stop"
$projectRoot = Split-Path -Parent $PSScriptRoot
Set-Location $projectRoot

$pubBin = Join-Path $env:LOCALAPPDATA "Pub\Cache\bin"
if (Test-Path $pubBin) {
  $env:Path = "$pubBin;$env:Path"
}

Write-Host "==> Installing FlutterFire CLI..."
dart pub global activate flutterfire_cli

Write-Host "==> Installing Firebase CLI (npm)..."
npm install -g firebase-tools

Write-Host "==> Checking Firebase login..."
firebase login:list
if ($LASTEXITCODE -ne 0) {
  Write-Host "Log in to Firebase (browser will open)..."
  firebase login
}

Write-Host "==> Running flutterfire configure for ai-quiz-5c2ff..."
flutterfire configure `
  --project=ai-quiz-5c2ff `
  --platforms=android `
  --android-package-name=com.aiquiz.ai_quiz_app `
  --yes

Write-Host ""
Write-Host "Done. Next:"
Write-Host "  1. Enable Cloud Firestore in Firebase Console (if not already)."
Write-Host "  2. Publish the Firestore rules from README.md"
Write-Host "  3. flutter run"
Write-Host "  4. Multiplayer -> Host a Quiz and confirm a rooms/ doc appears in Firestore."
