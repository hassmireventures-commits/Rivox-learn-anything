# Rivox 1.1.0 (build 14)

**Release date:** 2026-09-19
**Version:** 1.1.0
**Version code:** 14
**Package:** `com.aiquiz.ai_quiz_app`

Upload this AAB to Play. Do not upload builds 7–13 if 14 is the next store version.

## What's new (since build 13)

### Accounts
- Official Google "Sign in with Google" icon (from Google's own branding kit) on the onboarding and Cloud Backup sign-in buttons, replacing an earlier hand-drawn version

### Sharing & export
- **Share quiz results and learning-path progress as an image** — a branded card (score/topic/date, or path completion %) rendered to PNG and shared via the system share sheet
- **Local encrypted `.rivox` file sharing** — export a learning path as an encrypted file protected by a 6-digit PIN (shared separately from the file), for sharing with classmates/students without any cloud account; import prompts for the PIN and offers to replace your current path

### Learning path
- **Alternate "Map view"** — a visual, connected-node sequence of a path's modules (locked/current/completed), next to the existing list view
- **Video chapters** — Daily Pack videos with captions now get 3-5 AI-derived chapter markers; tap a chapter chip to jump to that point in the video

### Camera-to-Quiz
- **Scan pages into your Library** — point the camera at printed or handwritten pages, capture one or more, review and edit the extracted text, then add it to your Library like any other upload. Fully on-device text recognition, no cloud OCR call

### Voice interview
- **Speech-delivery feedback** — words-per-minute and filler-word count shown on interview results
- **Feedback tone** — choose Strict or Friendly scoring tone, independent of the HR/Tech question persona
- **Questions read aloud** — interview questions are now spoken via on-device text-to-speech, with a mute toggle

### Home screen
- **Streak widget** (Android) — shows your current streak on the home screen, tapping through to the app

### Pacing
- New Settings toggle: "Prefer shorter sessions" — shows a one-time gentle break reminder at the halfway point of quizzes with 10+ questions

### Website
- Second batch of study-technique blog posts (active recall, short study sessions, JD-to-study-list, mock-exam mistakes)
- Ad placement rework and a mobile layout fix on the 2048 mini-game

## Known/accepted trade-offs in this build
- Home-screen widget is Android only (iOS WidgetKit not built); its static labels are English-only
- Voice interview pause-time detection was not built (kept to words-per-minute + filler words, which don't depend on unverified Whisper API timing support)
- APK size grew ~10-15MB per ABI from new native dependencies (camera, on-device text recognition, text-to-speech, home-screen widget support) — worth a Play Console size/App Bundle check after this upload

## Build artifacts

| Artifact | Path |
|----------|------|
| arm64-v8a APK | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` (47.5MB) |
| armeabi-v7a APK | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` (41.9MB) |
| x86_64 APK | `build/app/outputs/flutter-apk/app-x86_64-release.apk` (49.8MB) |
| App Bundle (AAB) | `build/app/outputs/bundle/release/app-release.aab` (101.3MB — this is the file to upload to Play Console; end-user download size per device is much smaller since Play delivers only the matching ABI/resources from the bundle) |

## Build command

```powershell
cd "d:\Documents\App projects\learn-anything\learn-anything"
flutter test
flutter build apk --release --split-per-abi --dart-define-from-file=tool/.local_dart_defines.json
flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json
```

## Play Store release notes (paste)

```
Rivox 1.1.0

• New: scan physical pages into your Library with the camera (on-device text recognition)
• New: share quiz results and learning path progress as an image
• New: share a learning path as an encrypted file, no cloud account needed
• New: learning path map view, and AI-generated video chapters in Daily Pack
• New: voice interview — speech pace/filler-word feedback, strict/friendly tone, questions read aloud
• New: home-screen streak widget
• New: "Prefer shorter sessions" option with a gentle break reminder
• Improved: official Google sign-in icon
```
