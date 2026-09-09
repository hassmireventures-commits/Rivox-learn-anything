# Rivox 1.1.0 (build 8)

**Release date:** 2026-09-08  
**Version:** 1.1.0  
**Version code:** 8 (supersedes build 7 — same feature set; build 7 flagged by Play Console for
low obfuscation (24%, then 19%, both below the 25% minimum), traced to overly broad
`-keep class com.google.firebase.** { *; }` / `-keep class com.google.android.gms.** { *; }`
rules in `android/app/proguard-rules.pro` keeping those entire (large) packages fully
unobfuscated. Removed — Firebase/Play Services/AdMob all ship their own consumer ProGuard
rules bundled in their AARs, so nothing actually needed was lost. Do not upload build 7.)  
**Package:** `com.aiquiz.ai_quiz_app`

## What's new

### AI Chat
- New **Chat** tab: a single continuous, RAG-grounded conversation that can answer questions about your library content, quiz history, and mistakes
- Chat can **propose** — but never perform on its own — generating a quiz or learning path on a topic; tapping the suggestion runs the same quota/firewall checks as Create Quiz/Learn
- New **Learner Memory**: a daily-refreshed picture of your goals, library, quiz-pattern (per-topic accuracy, streaks, frequently-missed topics), and recent daily content, so chat can answer "how am I doing" style questions without re-deriving everything from scratch every message
- Fixed: chat could describe having performed an action (adding content, enabling something) that it never actually did
- Fixed: a chat-generated quiz/path could finish without any visible way to open it
- The floating chat button is now draggable to either edge of the screen, and no longer appears on quiz-play or learning-path screens

### Generation & quota
- New global "ready" indicator: any quiz, learning path, or daily-content job that finishes while you're away from where it started now shows a tap-to-open banner, everywhere in the app
- Fixed a real concurrency bug where watching a rewarded ad to unlock more generations didn't always take effect afterward
- Removed the daily cap on watching rewarded ads to unlock more generations — watch as many as you like, one ad now unlocks exactly one more generation
- Starting a new quiz while a previous one is sitting ready-but-unopened now takes you to that one instead of discarding it

### Flashcards
- Flashcard answers now include a separate "why" explanation, not just the bare answer
- Fixed cramped rating-button alignment on the review screen; made the flashcard itself tappable to reveal the answer

### Dashboard
- Fixed an overlapping/unreadable y-axis on the weekly-activity and difficulty-mix charts
- "Today's AI brief" now refreshes in about half the time
- Clearer wording ("Continue quiz") for a not-yet-completed Quiz of the Day

### Performance
- Timed quizzes and mock exams no longer redraw the entire question screen every second just to update the countdown — only the small timer widget updates now

### Analytics & privacy
- Real Firebase Analytics (GA4) added, gated behind the existing "Help improve Rivox" opt-in (off by default, same as the existing anonymized telemetry)

### Behind the scenes
- Groundwork for optional, end-to-end encrypted cloud backup/restore (Google Sign-In based) — built and tested, not yet enabled for users
- Full test suite: 195 automated tests (up from 140), all passing
- Removed redundant blanket ProGuard/R8 keep rules for Firebase/Play Services/AdMob, fixing a Play Console app-optimization warning (build 8 only — see version-code note above)

## Build artifacts

| Artifact | Path |
|----------|------|
| arm64-v8a APK | `build/app/outputs/flutter-apk/app-arm64-v8a-release.apk` |
| armeabi-v7a APK | `build/app/outputs/flutter-apk/app-armeabi-v7a-release.apk` |
| x86_64 APK | `build/app/outputs/flutter-apk/app-x86_64-release.apk` |
| App Bundle (AAB) | `build/app/outputs/bundle/release/app-release.aab` |

*Split APKs above are from the prior build at this same code revision; rebuild with the command below if you need them re-stamped at 1.1.0+7 specifically (e.g. for sideloading).*

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

• New: AI Chat — ask questions about your library, quiz history, and mistakes; can suggest (never auto-start) a quiz or learning path
• New: Learner Memory gives chat an up-to-date picture of your goals and study pattern
• New: Flashcard answers now include a "why" explanation
• Improved: rewarded ads to unlock more generations have no daily cap — one ad, one more generation
• Improved: a global "ready" banner shows whenever a quiz/path/daily content finishes in the background
• Fixed: overlapping chart labels on the dashboard; slow AI brief refresh; cramped flashcard buttons
• Faster: timed quizzes no longer redraw the whole screen every second
```
