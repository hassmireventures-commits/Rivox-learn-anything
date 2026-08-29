# Rivox 1.0.1 (build 2)

**Release date:** 2026-08-24  
**Version:** 1.0.1  
**Version code:** 2  
**Package:** `com.aiquiz.ai_quiz_app`

## Short description (Play Store — 80 chars max)

Rivox — AI learning with quizzes, paths, voice interviews, and daily study picks.

## What's new

### Rivox rebrand
- New **Rivox** name, logo, and launcher icon across the app, splash screen, and install label
- Updated share text, settings, and support copy to Rivox branding
- Refreshed Firebase Hosting site with new hero image and cache-safe assets

### Voice interview
- **Stop** label now visible on the red recording button
- Recording timer shows elapsed time with a **3-minute maximum** (auto-stops)
- Fixed transcription **404** error — Whisper now uses the correct NVIDIA cloud endpoint
- High-contrast question text and speech-only open questions in voice mode

### Learn & paths
- **Learn tab no longer freezes** after returning from a learning path
- Background path generation and “Continue in background” behave reliably
- Learning paths require both article and video in daily packs

### Quizzes & notifications
- Quiz notifications open **Results** when the quiz is already completed
- Fixed MCQ generation with only one answer option
- AI usage empty state no longer appears alongside token counts after first generation

### Reminders & alarms
- Reminder sounds limited to **Alarm** and **Urgent** (removed broken Default/Chime previews)

### Other fixes
- Dashboard live API limit countdown
- Auto-generation exempt from Built-in AI daily quota where intended
- Competitive exam logical-reasoning quiz quality improvements
- Split APK / launcher icon build fixes

## Build artifacts

| Artifact | Path |
|----------|------|
| arm64-v8a APK | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` |
| armeabi-v7a APK | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` |
| x86_64 APK | `build/app/outputs/flutter-apk/app-x86_64-release.apk` |
| App Bundle (AAB) | `build/app/outputs/bundle/release/app-release.aab` |

## Build command

```powershell
flutter test
flutter build apk --release --split-per-abi --dart-define-from-file=tool/.local_dart_defines.json
flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json
```

## Play Store release notes (paste)

```
Rivox 1.0.1

• Rebrand to Rivox — new logo, icon, and splash
• Voice interview: visible Stop button, 3-min timer, transcription fix
• Learn tab no longer stuck after viewing a learning path
• Quiz notifications open results when already completed
• Reminder sounds: Alarm and Urgent only
• Bug fixes for AI usage display, daily packs, and quiz quality
```
