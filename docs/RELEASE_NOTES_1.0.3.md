# Rivox 1.0.3 (build 4)

**Release date:** 2026-08-26  
**Version:** 1.0.3  
**Version code:** 4  
**Package:** `com.aiquiz.ai_quiz_app`

## What's new

### Built-in AI fix
- **Built-in AI key** now resolves from the embedded release build even when secure storage is empty or was cleared after an upgrade
- Ensures quiz, path, and daily pack generation work on fresh installs and after Android secure-storage resets

### Ads
- Native ads scroll with content (History, saved articles, library, results, insights) with a **dismiss (×)** button
- **No ads** in the in-app article reader

### Dashboard & reminders
- Study goal ring updates in real time; duplicate title removed
- Insights: weekday labels on weekly chart, 14-day activity trend, refresh button
- Alarm notifications include **Dismiss** (no need to swipe away)

### Other
- Daily quiz rolls forward at midnight; pull-to-refresh reloads ads and stats
- AdMob native/banner integration fixes for release builds

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
Rivox 1.0.3

• Fix: Built-in AI works reliably on release installs
• Native ads scroll with content; tap × to dismiss
• Ad-free article reader
• Study goal chart live updates; alarm Dismiss button
• Daily quiz and insights chart improvements
```
