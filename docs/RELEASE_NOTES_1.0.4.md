# Rivox 1.0.4 (build 5)

**Release date:** 2026-08-26  
**Version:** 1.0.4  
**Version code:** 5  
**Package:** `com.aiquiz.ai_quiz_app`

## What's new

### Built-in AI fix (critical)
- NVIDIA retired `meta/llama-3.1-8b-instruct` on 2026-08-26 (HTTP 410 Gone), which caused **AI Offline** and blocked quiz/path generation
- Built-in AI now uses **`nvidia/nemotron-3-nano-30b-a3b`** — verified live chat + JSON completions
- Existing installs auto-update the stored model on next app launch (no reinstall required)

### Also in this release chain (1.0.3)
- Built-in API key fallback when secure storage is empty
- Scrollable/dismissible native ads; ad-free article reader
- Study goal live updates; alarm Dismiss button

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
$env:GRADLE_USER_HOME = "$env:USERPROFILE\.gradle"
flutter test
flutter build apk --release --split-per-abi --dart-define-from-file=tool/.local_dart_defines.json
flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json
```

## Play Store release notes (paste)

```
Rivox 1.0.4

• Fix: Built-in AI restored after NVIDIA model retirement (AI Offline resolved)
• Quiz, daily pack, and study brief generation working again
• Includes prior fixes: ad placement, study goal, alarm dismiss
```
