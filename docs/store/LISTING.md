# Play Store listing drafts

Copy into Play Console. Hosted legal URLs must match live pages before production.

**2026-08-29 ASO revision:** the 2026-08-29 SEO audit found "Rivox" and "Learn
Anything" both collide with unrelated existing products in search (see
`docs/logs/FEATURES_LOG.md`). Retitled/re-described below to lead with
differentiator keywords instead of the collision-prone generic phrase.
Character counts verified programmatically against Google's real current
limits (title 30, short description 80, full description 4000 — confirmed via
Google's own Play Console help docs; an externally-sourced "ASO report" this
session claimed the title limit was 50, which is wrong).

## Short description (max 80 characters)

Generate personalized AI study plans, quizzes, and voice interview drills. (74 chars)

## Play Store title (max 30 characters)

Rivox: AI Study Plan & Quiz (27 chars)

## Full description

Rivox — The AI App for Learning Anything

Turn any goal into a personal study plan. Rivox uses AI to build quizzes, structured learning paths, daily article-and-video picks, and career interview practice — while keeping your progress on your device.

Whether you are preparing for exams, leveling up at work, or exploring a new subject, Rivox adapts to your goals and shows you what to study next.

━━━━━━━━━━━━━━━━━━━━
WHAT YOU CAN DO
━━━━━━━━━━━━━━━━━━━━

📚 LEARN WITH AI PATHS
• Generate multi-module learning paths tailored to your goals
• Each module includes summaries, trusted articles, in-app YouTube lessons, and practice quizzes
• Track progress module by module and pick up where you left off
• Build paths from your own library content for grounded, relevant study

🎯 QUIZZES ON ANY TOPIC
• Create quick quizzes (MCQ, true/false, fill-in-the-blank, mixed)
• Set difficulty, question count, timers, and explanations
• Daily Quiz of the Day and weak-topic practice on your Home dashboard
• Full results, review, and history — all stored locally

📰 DAILY LEARNING PACK
• Every day: one validated article and one video matched to your goals
• Read articles in-app; watch videos without leaving Rivox
• Get a notification when today’s pack is ready

🎤 VOICE INTERVIEW PRACTICE
• Practice open-ended HR and technical interview questions out loud
• Speak your answer; Rivox transcribes and scores it with an AI rubric
• High-contrast voice mode designed for real interview rehearsal

💼 CAREER & EXAM MODES
• Career: skill matrix, interview drills, and role-focused practice
• Exam prep: syllabus tracking, mock exams, and study-plan support
• Goal-aware prompts so content stays relevant to what you are studying for

📁 YOUR LIBRARY
• Upload notes, resumes, job descriptions, and study materials
• Generate grounded quizzes and paths from your own content
• Your files stay on your device unless you choose to send chunks to an AI provider

━━━━━━━━━━━━━━━━━━━━
AI THAT YOU CONTROL
━━━━━━━━━━━━━━━━━━━━

• Built-in AI — start learning immediately with a free daily quota; watch a rewarded ad to unlock more generations
• Bring Your Own Key — connect OpenAI-compatible providers and use your own API keys
• Economy mode and smart sizing to keep generation fast on mobile
• Continue generation in the background while you use other parts of the app

━━━━━━━━━━━━━━━━━━━━
DESIGNED FOR REAL LIFE
━━━━━━━━━━━━━━━━━━━━

• Local-first: quizzes, paths, keys, and progress stored on your phone
• Study reminders with alarm-style notifications you can customize
• Insights dashboard: streaks, weak topics, syllabus coverage, and AI usage
• Multi-language app UI and quiz generation support
• In-app help, privacy policy, and terms — no account required to start

━━━━━━━━━━━━━━━━━━━━
PRIVACY & TRANSPARENCY
━━━━━━━━━━━━━━━━━━━━

Your learning data stays on your device. API keys are stored in secure storage and sent only to the provider you select. Optional anonymized analytics are opt-in. Ads (Google AdMob) may appear; consent is handled where required by law.

━━━━━━━━━━━━━━━━━━━━

Rivox is built for learners who want AI-powered study without giving up control of their data or their keys.

Publisher: Hassmire Ventures
Support: hassmireventures@gmail.com
Website: https://learn-anything-43970.web.app
Privacy: https://learn-anything-43970.web.app/privacy
Terms: https://learn-anything-43970.web.app/terms

## App category

Education

## Contact

- Website: https://learn-anything-43970.web.app
- Google Play: https://play.google.com/store/apps/details?id=com.aiquiz.ai_quiz_app
- Email: hassmireventures@gmail.com
- Custom domain (later): https://learnanything.app

## Content rating notes (for questionnaire)

- Educational / utility app
- No user-generated social feed or chat rooms
- Ads may be shown (AdMob); rewarded ads unlock Built-in AI quota
- Users may enter their own AI provider API keys (stored on device)

## Data safety (draft answers)

| Data type | Collected? | Shared? | Notes |
|-----------|------------|---------|-------|
| Name / profile prefs | On device only | No | Local Isar storage |
| API keys | On device only | No | Secure storage; sent only to the provider the user chose |
| Quiz / learning content | On device | No | May be sent to the user's chosen AI provider when generating |
| Device / advertising IDs | Via AdMob if ads shown | Yes (ad network) | UMP consent gated |
| Crash logs | Yes (Crashlytics) | With Google Firebase | Scrubbed; no API keys |
| Optional analytics | Only if opted in | Firebase Firestore | Hashed anon id; no quiz text |

## Graphics still needed (you)

- Feature graphic 1024×500 — see `docs/store/featureGraphic.png` (generated from Rivox marketing asset)
- Phone screenshots (min 2)
- Optional tablet / TV assets

## In-app legal assets (verified in repo)

- `assets/legal/privacy_v1_en.md`
- `assets/legal/terms_v1_en.md`
- `assets/legal/legal_manifest.json`
- Hosted URLs in `AppConstants`: `https://learn-anything-43970.web.app/privacy` and `/terms` (switch to learnanything.app after custom domain)

## ASO / Play Console action items (2026-08-29, fact-checked)

An externally-sourced "ASO strategy report" was reviewed this session. Most of
it was real Google documentation; a couple of claims were fabricated or
outdated. Verified against Google's own current docs before acting on any of
it — see `docs/logs/FEATURES_LOG.md` for the full fact-check.

**Real, worth doing (manual Play Console steps — not code):**
- **Custom Store Listings**: Play Console supports up to 50 CSLs, and one real
  targeting option is "Organic Search: users who discover your app on Play
  using specific search terms" (confirmed on Google's own CSL help page).
  Worth creating one CSL targeted at a term like "voice interview
  preparation" with creative emphasizing that feature — this is a
  post-search-click conversion lever (which listing/screenshots a searcher
  sees), **not** a keyword-ranking mechanism. Manual step in Play Console →
  Grow → Store presence → Custom store listings.
- **Android Vitals thresholds** (confirmed real, current): bad-behavior
  thresholds are user-perceived crash rate **< 1.09%** and ANR rate **<
  0.47%**, evaluated over a rolling 28-day window. Worth a periodic manual
  check in Play Console → Quality → Android vitals — not something to
  automate from this repo.
- **Target SDK 36 (Android 16)**: confirmed real requirement, deadline
  **2026-08-31** for new app updates. Already satisfied — `android/app/build.gradle.kts`
  uses Flutter's dynamic `flutter.targetSdkVersion`/`flutter.compileSdkVersion`
  (not a hardcoded old value), and the installed Flutter 3.47.1 defaults both
  to **36**. No action needed unless a future Flutter downgrade changes that.

**Fabricated/outdated — do not implement:**
- **"Firebase App Indexing"** (the report's suggested `Indexables.noteDigitalDocumentBuilder()`
  / `FirebaseAppIndex.getInstance().update()` code): this library is
  discontinued — Firebase's own docs state it's "no longer the recommended
  way of indexing content" and the Google Search app no longer uses it. The
  real 2026 equivalent is **Android App Links** (`autoVerify="true"` intent
  filter + a `.well-known/assetlinks.json` Digital Asset Links file on the
  website). **Deliberately not implemented this session** — the website's
  actual pages (`/privacy`, `/terms`, `/games`, `/games/dino`, `/`) don't
  correspond to any real in-app route, so enabling site-wide App Links right
  now would hijack real visitors' taps (from Search results or shared links)
  into a broken in-app screen instead of showing the actual page. Revisit
  only once there's a genuine shareable in-app destination (e.g. a public
  quiz-share landing page) that both the site and app agree on — likely a new
  reserved path prefix (e.g. `/open/*`) with a real web fallback, not the
  whole domain.
- The report's claimed **50-character title limit** — the real limit is
  **30 characters** (Google's own listing-requirements page), matching what
  this doc already had before the report's claim.
