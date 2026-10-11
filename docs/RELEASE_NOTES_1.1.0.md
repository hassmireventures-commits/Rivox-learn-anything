# Rivox 1.1.0 (build 18)

**Release date:** 2026-10-11
**Version:** 1.1.0
**Version code:** 18
**Package:** `com.aiquiz.ai_quiz_app`

Upload this AAB to Play. It contains everything in build 17 below plus the R8 optimisation. If build 17 was never uploaded, skip it and upload this one; version codes only need to increase.

Build command: `flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json` (upload keystore via `android/key.properties`).

**AAB:** `build/app/outputs/bundle/release/app-release.aab`, 103.8 MB (build 17: 104.7 MB), built 2026-10-11 from branch `build/r8-optimized-shrinking`. Verified: package `com.aiquiz.ai_quiz_app`, versionCode 18, versionName 1.1.0, signed with the upload key (SHA-1 `F9:E4:96:62:50:49:88:1E:63:CC:5B:94:04:9D:A1:D5:4D:5E:93:A0`). Android resources 1.55 MB (1,114 files) to 0.50 MB (245 files); dex 11.07 to 10.89 MB; native libraries unchanged (108.9 MB uncompressed). Launch-test on a phone before rollout: a resource removed by mistake only shows at runtime.

## What's new in build 18 (since build 17)

- Play Console recommendation "Improve your app's memory and performance with R8 optimisation" (backlog B45, part 1): Android Gradle Plugin 8.11.1 to 8.13.2, and `android.r8.optimizedResourceShrinking=true` so R8 shrinks code and resources together. No app code changed.

Play Console "What's new" text (use this whether or not build 17 was uploaded; 450 characters):

```
Rivox is now your AI tutor.
- Ask about a photo, speak your question, or have replies read aloud
- Quizzes right inside the chat, and the tutor fixes your plan when something is off
- Answer a daily quick question straight from the notification
- Streak freezes, XP and levels
- Lessons adapt to any skill: exams, coding, fitness, art, DIY and more
- Videos play inside the app
- Faster and lighter
- Google sign-in fixed
```

---

# Rivox 1.1.0 (build 17)

**Version code:** 17

Builds 14, 15, and 16 are already assigned; do not upload them again.

Build command: `flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json` (upload keystore via `android/key.properties`).

**AAB:** `build/app/outputs/bundle/release/app-release.aab`, 104.7 MB, built 2026-10-11 from branch `feat/ai-tutor-build-17`. Verified: package `com.aiquiz.ai_quiz_app`, versionCode 17, versionName 1.1.0, signed with the upload key (SHA-1 `F9:E4:96:62:50:49:88:1E:63:CC:5B:94:04:9D:A1:D5:4D:5E:93:A0`).

## What's new in build 17 (since build 16)

Play Console "What's new" text (under 500 characters):

```
Rivox is now your AI tutor.
- Ask about a photo, speak your question, or have replies read aloud
- Quizzes right inside the chat, and the tutor fixes your plan when something is off
- Answer a daily quick question straight from the notification
- Streak freezes, XP and levels
- Lessons adapt to any skill: exams, coding, fitness, art, DIY and more
- Videos play inside the app
- Google sign-in fixed
```

### Fixes
- Google sign-in on Play Store installs (Play app signing key registered in Firebase)
- Opening History, Home, or Learn from chat no longer shows a blank screen
- Module quizzes stay on the goal (an IELTS "Advanced English" module no longer produces a quiz about a car)
- Built-in AI backup model replaced (the old one was retired by NVIDIA)
- Notification buttons that do not open the app now work (also fixes reminder Snooze and Dismiss)

### Tutor and chat
- In-chat quiz forms with instant feedback, quick-reply suggestions, Markdown replies, Copy and Listen
- The tutor can add, remove, rename, or reorder path modules (with Undo) and replace a broken quiz
- "+" menu: ask about a photo (camera or gallery), scan pages, or upload a file; mic button for voice questions
- Chat messages pass an extra safety check

### Learning
- Library search matches by meaning, not only shared words
- Camera scans fall back to AI OCR when the on-device read is unclear
- Daily quick question, streak freezes, XP and levels, evening streak reminder when at risk
- Practice style adapts to the learner's field

### Privacy
- Privacy policy updated (2026-10-11): NVIDIA processes chat safety checks, library search, photos, and voice. Update the Play Data safety form to match before publishing.

---

# Rivox 1.1.0 (build 16)

**Release date:** 2026-10-02
**Version code:** 16

## What's new (since build 15)

### Chat
- Attach a text file or a PDF, or scan a page with the camera, and ask about it in the same message
- Edit the latest message, stop a reply that is still coming in, or send that message again
- A file shows as its name on the message. The question stays readable

### Accounts
- Google sign-in opens one account sheet. If sign-in does not finish, the welcome screen says to try again or continue with email

### Still in this version from build 15
- IELTS, NEET, JEE Main, UPSC, SSC, and bank practice uses a real task: a passage, chart, table, or conversation
- Answer keys are checked against that material

## Play Store release notes (paste)

```
Chat can take a text file, a PDF, or a camera scan. You can edit a message, stop a reply, or send it again.

Google sign-in uses one account sheet. If it does not finish, try again or continue with email.

Practice for IELTS, NEET, JEE Main, UPSC, SSC, and bank tests uses a real task: a passage, chart, table, or conversation. The answer is checked against that material.
```

## Build artifacts

| Artifact | Path |
|----------|------|
| App Bundle (AAB) | `build/app/outputs/bundle/release/app-release.aab` (101.6MB — upload this file to Play Console) |

## Build command

```powershell
cd "d:\Documents\App projects\learn-anything\learn-anything"
flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json
```

---

# Rivox 1.1.0 (build 15)

**Release date:** 2026-09-27
**Version:** 1.1.0
**Version code:** 15
**Package:** `com.aiquiz.ai_quiz_app`

Upload this AAB to Play. Build 14 is already assigned; do not upload it again.

## What's new (since build 14)

### Competitive exams
- IELTS, NEET, JEE Main, UPSC, SSC, banking, and other named exams or certifications get paper-style practice: a task from the syllabus, not a quiz about the exam name, fees, or dates
- A question that needs a passage, chart, table, or conversation shows that material on the question and on the results
- Listening practice reads the transcript aloud on the device
- Multiple choice, true/false, and fill-in-the-blank can appear in one quiz when mixed is selected
- The marked answer has to follow the chart or the text. A key that the material does not support is corrected or that item is not scored against you

### Accounts
- Google sign-in is restored on the same install, without the account picker every launch

## Play Store release notes (paste)

```
Practice for competitive exams the way the paper is written. IELTS, NEET, JEE Main, UPSC, SSC, and bank tests now use a real task: a passage, chart, table, or conversation, then a question about that material.

Answer keys are checked against the chart or the text. Mixed quizzes can include multiple choice, true or false, and fill-in-the-blank.
```

## Build artifacts

| Artifact | Path |
|----------|------|
| App Bundle (AAB) | `build/app/outputs/bundle/release/app-release.aab` (101.6MB — upload this file to Play Console) |

## Build command

```powershell
cd "d:\Documents\App projects\learn-anything\learn-anything"
flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json
```

---

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
