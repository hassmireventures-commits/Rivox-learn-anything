# Rivox 1.0.5 (build 6)

**Release date:** 2026-08-29  
**Version:** 1.0.5  
**Version code:** 6  
**Package:** `com.aiquiz.ai_quiz_app`

## What's new

### Spaced-repetition flashcards
- New **Flashcards** feature (SM-2 spaced repetition) — review due cards from the Learn tab
- Two ways to build a deck: free, instant cards from your **quiz mistakes** (Results screen), or AI-generated cards from your **Personal Knowledge Base** (Library screen)
- Fixed a bug where the "N due for review" count didn't refresh after reviewing or adding cards

### Achievements
- Achievements are now a swipeable slide carousel instead of a static grid
- Sorted so your closest-to-unlocking badge always leads

### Mock exams
- Added mark-for-review: flag questions during a mock exam and jump back to them before submitting

### Voice interview
- Live captions now update as you speak (previously only appeared after you stopped recording)
- Added an option to use your own speech-to-text API key instead of the built-in one (Voice Interview → key icon)

### Reliability
- Fixed a bug where every quiz/path/content generation silently ate up to ~1.6s of wasted latency from leftover debug instrumentation
- More consistent error messages and a "Try again" option across quiz, learning-path, and daily-content generation failures
- Upgraded the file picker library — fixes a Google Play Console flag on image memory handling, and keeps import/export (library uploads, settings backup) working

### Behind the scenes
- Automated CI now runs on every change: static analysis, full test suite, and a scheduled live-quality check against the AI backend
- Full test suite: 140 automated tests, all passing

## Build artifacts

| Artifact | Path |
|----------|------|
| arm64-v8a APK | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` |
| armeabi-v7a APK | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` |
| x86_64 APK | `build/app/outputs/flutter-apk/app-x86_64-release.apk` |
| App Bundle (AAB) | `build/app/outputs/bundle/release/app-release.aab` |

## Build command

```powershell
cd "d:\Documents\App projects\learn-anything\learn-anything"
flutter test
flutter build apk --release --split-per-abi --dart-define-from-file=tool/.local_dart_defines.json
flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json
```

## Play Store release notes (paste)

```
Rivox 1.0.5

• New: Spaced-repetition flashcards — build a deck from quiz mistakes (free) or your library (AI-generated), review on your own schedule
• New: Achievements are now a swipeable carousel, closest-to-unlocking first
• New: Mark questions for review during mock exams
• Improved: Voice interview live captions update as you speak; option to use your own speech-to-text key
• Fixed: Faster, more reliable quiz/path/content generation with clearer error messages and a retry option
```
