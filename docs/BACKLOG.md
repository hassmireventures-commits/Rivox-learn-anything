# Learn Anything — Product backlog

Living list of **not-built, coming-soon, or partial** work. Grounded in shipped logs, explicit Coming soon UI, the 2026-08-23 user-reported batch, and — for B11–B21 — a 2026-08-29 research pass (internal `docs/reviews/*` roadmap docs + external 2026 AI-learning-app market scan) prioritized by MoSCoW. Not a speculative roadmap beyond what's cited per item.

Agents: read this file with `docs/PROJECT_LOG.md` before starting a listed item. When an item ships, move a dated note to the section log and mark status **done** here (do not delete the row).

| ID | Title | Status | Area | MoSCoW |
|----|-------|--------|------|--------|
| B1 | In-app learning chatbot | backlog | chat, learn, ai | Should have |
| B2 | Voice interview agent | partial (STT shipped) | career / interview | Should have |
| B3 | On-device / local LLM | coming soon | ai, llm | Won't have (this cycle) |
| B4 | Persist and translate 2026-08-23 l10n keys | done | l10n | — |
| B5 | Article relevance vs empty resources | done | learn, daily content | — |
| B6 | Leftover Android `study_alarm` channel | done | reminders | — |
| B7 | Daily quiz frequency sequencing | done | quiz, settings | — |
| B8 | Device QA for 2026-08-23 batch | backlog | qa | — |
| B9 | Confirm production ad fill on device | backlog | ads | — |
| B10 | Hosting AdSense display slot IDs | done | hosting | — |
| B11 | Spaced-repetition flashcards from library/mistakes | in progress (2026-08-29) | learn, library, ai | Must have |
| B12 | Automated AI generation quality eval gate | done (2026-08-29) | ai, ci, qa | Must have |
| B13 | Optional encrypted account + cross-device backup/sync | backlog (proposed 2026-08-29) | accounts, infra | Must have |
| B14 | Global AI-generation error-recovery UX contract | done (2026-08-29) | ux, quiz, learn | Must have |
| B15 | Freemium hosted AI tier with budget guardrails | backlog (proposed 2026-08-29) | ai, monetization | Should have |
| B16 | Achievement badges & milestone challenges | done (2026-08-29) | gamification, dashboard | Should have |
| B17 | Mark-for-review / flag questions in mock exams | done (2026-08-29) | exam | Should have |
| B18 | Shared / cohort learning packs | backlog (proposed 2026-08-29) | social, learn | Could have |
| B19 | Home-screen widget (streak / daily quiz) | backlog (proposed 2026-08-29) | platform, retention | Could have |
| B20 | Neurodiversity-aware adaptive pacing | backlog (proposed 2026-08-29) | ai, accessibility | Could have |
| B21 | Marketplace / enterprise SKU / learning-intelligence API | backlog (proposed 2026-08-29) | growth, enterprise | Won't have (this cycle) |

---

## B1 — In-app learning chatbot

- **Status:** backlog
- **Area:** chat, learn, ai
- **Why it exists:** User request #26 (2026-08-23). Feasibility researched and logged; **not built**. Users want follow-up questions on modules, quizzes, and uploaded library files.
- **Suggested next step:** Design a thread UI + persistence. Reuse Built-in/BYOK `LlmManager.completeJson`, RAG from `AiRequestPipeline` + library chunks, and the rolling 24h generation quota (or add a separate chat budget). Gate as premium or quota later. Do not ship in the current release.
- **Risks:** Cost / quota burn per turn; hallucination unless grounded; new persistence model for threads.
- **Source:** [FEATURES_LOG](logs/FEATURES_LOG.md) 2026-08-23 chatbot note.

## B2 — Voice interview agent

- **Status:** partial (2026-08-24) — Whisper STT for spoken answers; no TTS/realtime agent yet
- **Area:** career / interview
- **Why it exists:** User request #21 (2026-08-23) asked for a premium voice interview agent. `drill_create_screen.dart` showed **Voice interview (Coming soon)** only.
- **Shipped:** NVIDIA Whisper Large v3 via `WHISPER_API_KEY` dart-define; mic record → `/v1/audio/transcriptions`; Career **Voice interview** → `/quiz/play/:id?voice=1`; rubric scoring unchanged on transcribed text. Skill: `.cursor/skills/interviewer-voice/SKILL.md`.
- **Suggested next step:** TTS question readout, realtime voice loop, premium entitlement, STT quota if needed.
- **Risks:** Keys must stay in dart-define only; Whisper is batch not streaming; mic permission required on device.
- **Risks:** Mic permissions; cost; quality; must not break resume/JD grounding or LLM-as-judge scoring.
- **Source:** `lib/features/career/presentation/drill_create_screen.dart`; [EXAM_AND_CAREER_MODULES.md](EXAM_AND_CAREER_MODULES.md) non-goals.

## B3 — On-device / local LLM

- **Status:** coming soon (deferred)
- **Area:** ai, llm
- **Decision (2026-08-23):** Continue using **existing LLM API keys** (Built-in / BYOK cloud). Do **not** enable or implement on-device / local LLM. `kLocalLlmEnabled` stays false; `kLocalLlmComingSoon` stays on. No `mlc4j` packaging work in this release.
- **Why it exists:** `kLocalLlmComingSoon` is on. Onboarding and Settings show Local as Coming soon. Host `mlc_llm package` is blocked on `tvm_ffi` ABI; no shippable `mlc4j`.
- **Suggested next step:** Leave deferred. Only revisit after a real runtime exists; then flip `kLocalLlmEnabled` / `kLocalLlmComingSoon`. Until then, Built-in + BYOK remain the only generation path.
- **Risks:** Re-enabling the UI while the stub remains leaves a broken download path; do not ship partially patched host DLLs.
- **Source:** [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) 2026-07-15; 2026-08-23 B3 decision.

## B4 — Persist and translate 2026-08-23 l10n keys

- **Status:** done (2026-08-23)
- **Area:** l10n
- **Why it exists:** First pass of the 27-bug batch compiled only in English. Missing getters (`goalTooVague`, `learnPastPathsTitle`, `settingsDailyQuizFrequency`, `settingsAlarmSound`, `interviewVoiceComingSoon`) were patched later as English stubs in every locale Dart file. Non-en ARBs still omit those keys. `resultsNoAnswer` is now `Not answered` everywhere, still untranslated.
- **Shipped:** Keys plus `resultsNoAnswer` = `Not answered` are in every `lib/l10n/app_*.arb`. English stubs remain for non-en locales.
- **Suggested next step:** Optional real translations later. Regenerating l10n from ARB is now safe for these keys.
- **Risks:** Non-en copy stays English until translated.
- **Source:** [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) 2026-08-23 persist l10n keys.

## B5 — Article relevance vs empty resources

- **Status:** done (2026-08-23)
- **Area:** learn, daily content
- **Why it exists:** User issues #8 / #9 / #25 / #27 — homepage, 404, and off-topic article URLs (e.g. python.org 404 for an AI-agents title). Validator rejected weak token overlap and could leave modules with **empty resources**.
- **Shipped:** Relevance is a sort preference, not a hard drop. HTTPS reachability, homepage reject, python.org homepage/root reject, and 404 reject stay. Summarize-module article fetch unchanged.
- **Suggested next step:** Device QA on technical and non-technical goals.
- **Risks:** Weak-overlap official URLs may be slightly off-topic; site roots and 404s must stay rejected.
- **Source:** [BUGFIX_LOG](logs/BUGFIX_LOG.md) 2026-08-23 article relevance soften.

## B6 — Leftover Android `study_alarm` channel

- **Status:** done (2026-08-23)
- **Area:** reminders
- **Why it exists:** User issue #11 — study alarm sound. Picker uses per-sound channel ids (`study_alarm_$soundId` / `daily_study_$soundId`). The unsuffixed `study_alarm` and `daily_study` channels lingered on existing installs with the old sound.
- **Shipped:** Init and schedule delete obsolete unsuffixed channels via `deleteNotificationChannel`. Suffixed channels are not deleted. Goal-reached notifications use the current suffixed daily channel.
- **Suggested next step:** Device check that existing scheduled alarms still fire after a sound change.
- **Risks:** Changing channel ids again can orphan already-scheduled notifications.
- **Source:** [BUGFIX_LOG](logs/BUGFIX_LOG.md) 2026-08-23 leftover study_alarm channel.

## B7 — Daily quiz frequency sequencing

- **Status:** done (2026-08-23)
- **Area:** quiz, settings
- **Why it exists:** User issue #23 — Settings slider for 1–3 daily quizzes. Extra sessions are created **only after the previous one is completed**, and Home still looked like one-and-done.
- **Shipped:** Up to N quizzes per day. Incomplete daily quiz is reused (no extras). Next slot is generated on Generate tap (or first-of-day auto). Home shows "Daily quiz 2 of 3" when slots remain. Background / Home auto-schedule do not generate slots 2–3 (quota).
- **Suggested next step:** Device QA of frequency 2–3 after completing quiz 1.
- **Risks:** Independent pre-generation would stack unfinished quizzes and burn Built-in quota — still not done.
- **Source:** [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) 2026-08-23 daily quiz frequency UX.

## B8 — Device QA for 2026-08-23 batch

- **Status:** backlog
- **Area:** qa
- **Why it exists:** The 27-bug batch was verified with `flutter analyze` on touched paths only. No emulator or device pass in that session. Highest-value untested paths: path generate + swipe-back, Home → History segment, module quiz of 20, alarm sound, results banner, AI Providers quota + Watch ad, daily pack notify.
- **Suggested next step:** Install a split release APK on a device and walk those paths. File new bugs instead of assuming the batch is production-clean.
- **Risks:** Overlay, ads fill, notification channels, and grading are easy to miss in analyze-only review.
- **Source:** [BUGFIX_LOG](logs/BUGFIX_LOG.md) 2026-08-23 Verified line; [RETRO_2026-08-23.md](logs/RETRO_2026-08-23.md).

## B9 — Confirm production ad fill on device

- **Status:** backlog
- **Area:** ads
- **Why it exists:** Results banner uses production unit `…/5482634804`. Quota unlock loads rewarded interstitial `…/5832808964` then falls back to the production rewarded unit. Fill can fail on some devices. Support/Settings sponsored ads must stay interstitial and must not call `grantAdBonus`.
- **Suggested next step:** Device smoke of results banner + Watch-ad unlock with production units (UMP consent on).
- **Risks:** Rewarded interstitial fill miss; mixing thank-you interstitials with quota grants.
- **Source:** [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) 2026-08-23 production ad units.

## B10 — Hosting AdSense display slot IDs

- **Status:** done (2026-08-23)
- **Area:** hosting
- **Why it exists:** Firebase Hosting has AdSense Auto ads + `ads.txt`. Fixed banner placeholders in `hosting/ads.js` stayed hidden until Display slot IDs were pasted. `app-ads.txt` (AdMob) and `ads.txt` (AdSense) must stay separate.
- **Shipped:** Production Display slot `3346149333` with client `ca-pub-5325876102788151` on `homeTop` and `doc`. Homepage uses one slot per page (duplicate placement removed). Loader `adsbygoogle.js` stays once per page. `hosting/ads.txt` unchanged. App banners stay `ca-app-pub-5325876102788151/5482634804`.
- **Suggested next step:** Confirm AdSense site approval and fill on the live site; create a second Display unit for `homeBottom` if a second homepage banner is needed. Device QA of in-app ads remains B9.
- **Risks:** Do not reuse AdMob (`ca-app-pub`) unit IDs as AdSense slots. Do not replace `ads.txt` with `app-ads.txt`.
- **Source:** [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) 2026-08-23 AdSense Display slot.

---

## 2026-08-29 research pass — MoSCoW feature proposals (B11–B21)

Grounded in two inputs: (1) this repo's own `docs/reviews/*` (billion-dollar-roadmap, scalability-roadmap, product-review, ux-review, executive-summary, risk-register) and `docs/EXAM_AND_CAREER_MODULES.md`, filtered to ideas **not yet in B1–B10**; (2) an external scan of 2026 AI-learning-app trends (Duolingo Max, Khanmigo, Quizlet/Knowt, spaced-repetition research, gamification/retention studies). B1 and B2 above are retro-tagged Should have; B3 is retro-tagged Won't have (reaffirms the existing 2026-08-23 decision, not new).

### B11 — Spaced-repetition flashcards from library/mistakes

- **Status:** backlog (proposed 2026-08-29)
- **Area:** learn, library, ai
- **MoSCoW:** Must have
- **Why it exists:** Confirmed gap — grep of `lib/` found no flashcard or spaced-repetition code (only a dead `multiplayerLeaderboardTitle` l10n string from the removed multiplayer feature). Every major 2026 competitor (Quizlet AI Study Tools, Knowt, Anki-style apps) leads with "turn your notes/mistakes into spaced-repetition cards"; research cited 3.2× retention vs. drill-only apps. This app already has the two building blocks: the Personal Knowledge Base (RAG uploads) and per-question quiz history — a flashcard mode is mostly a new prompt template + a scheduling field on top of existing infra, not a new subsystem.
- **Suggested next step:** Generate flashcards from (a) library chunks the user opted into RAG on, and (b) previously-missed quiz questions. Add a `nextReviewAt`/`easeFactor` pair to the question/answer model (SM-2-style) and a lightweight review queue screen. Reuse `LlmManager` + `AiOutputGate` for generation; reuse Built-in quota accounting.
- **Risks:** Another Isar schema change; scheduling logic needs its own tests (must not silently starve review queues); should not compete with quiz generation for the same daily quota without a clear UX split.
- **Source:** External scan (Quizlet/Knowt/spaced-repetition research, 2026-08-29); internal grep confirming no existing implementation.

### B12 — Automated AI generation quality eval gate

- **Status:** done (2026-08-29)
- **Area:** ai, ci, qa
- **MoSCoW:** Must have
- **Shipped:** `.github/workflows/ai-eval.yml` — daily cron + `workflow_dispatch`, runs `test/model_generation_live_probe_test.dart` against the real Built-in AI backend, keeps the existing 10/10-per-task assertion (stricter than this item's own "alert below 8/10" suggestion, matching the project's established quality bar). Historical tracking relies on browsing past workflow run logs, not a committed log file. ⏳ Requires a `BUILT_IN_AI_API_KEY` GitHub Actions repo secret — not something an agent can add; the workflow skips (not fails) until it's set.
- **Why it exists:** `executive-summary.md`'s 90-day plan calls for an "AI quality eval framework." The repo already has the right primitive — `test/model_generation_live_probe_test.dart`, which scored the live Built-in router chain, primary, and fallback model **10/10 across all 9 generation tasks** on 2026-08-29 — but it's dev-run-only, not wired into CI or tracked over time. Models get silently retired/changed upstream (already happened once — Nemotron EOL, see 2026-08-26 bugfix log), so a regression could ship unnoticed until users hit it.
- **Suggested next step:** Add a scheduled (not per-PR, to avoid burning API quota on every commit) CI job that runs the live probe, stores scores per task/model/date, and alerts (or fails a nightly build) if any task drops below 8/10. Extend probe coverage to BYOK providers (Gemini/Claude/OpenAI-compatible) periodically, not just Built-in.
- **Risks:** Costs real API credits on a schedule; needs a place to store historical scores (even a simple JSON log in the repo would beat nothing); false alerts if a provider has a transient outage need a retry-before-alert step.
- **Source:** `docs/reviews/executive-summary.md` 90-day plan; `test/model_generation_live_probe_test.dart` (exists, unwired); 2026-08-29 live probe run in this session.

### B13 — Optional encrypted account + cross-device backup/sync

- **Status:** backlog (proposed 2026-08-29)
- **Area:** accounts, infra
- **MoSCoW:** Must have
- **Why it exists:** All user data (quiz history, learning paths, library uploads, stats/streaks) lives in local-only Isar today — confirmed by README ("local-first") and `scalability-roadmap.md`. `risk-register.md` R7 flags BYOK-wall activation friction as an "existential" risk, and both `product-review.md` and `executive-summary.md` independently call accounts/sync "retention-critical": an uninstall or device loss currently destroys a user's entire history, streaks included.
- **Suggested next step:** Optional (never forced) account — Firebase Auth already in the stack (`firebase_options.dart`, Firestore rules exist for opt-in analytics). Encrypted backup of Isar collections to Firestore/Storage gated behind explicit opt-in, mirroring the existing `ENABLE_FIRESTORE_ANALYTICS` opt-in pattern. Must not weaken the current "cloud sync is off by default" privacy stance from the README.
- **Risks:** Biggest scope item on this list — touches auth, encryption at rest, conflict resolution on multi-device edits, and Firestore rules/App Check (already flagged as optional/incomplete in `PLAY_STORE_CHECKLIST.md`). Should land behind a feature flag and ship backup before sync.
- **Source:** `docs/reviews/scalability-roadmap.md`, `product-review.md`, `executive-summary.md`, `risk-register.md` R7.

### B14 — Global AI-generation error-recovery UX contract

- **Status:** done (2026-08-29)
- **Area:** ux, quiz, learn
- **MoSCoW:** Must have
- **Shipped:** `GenerationJobService.startPath`/`startDailyContent` now map errors via `AppException.from(...)` like `startQuiz`. New `lib/shared/widgets/generation_job_overlay_binding.dart` extracts the overlay/strip derivation + background-success-auto-nav `ref.listen` shape shared by `create_quiz_screen.dart` and `learn_screen.dart` (path) — no net-new skeleton-loader system was built (nothing like that existed before, and this app's generation flows are full-overlay-shaped, not partial-list-shaped, so it would have been a mismatched addition). `daily_content_detail_screen.dart` kept its own derivation (its success path refreshes in place rather than navigating — a genuinely different shape, not an oversight). Added `onRetry` to `showAppErrorDialog`'s generic dialog, wired from all three screens.
- **Why it exists:** `ux-review.md` flags missing skeleton loaders and an inconsistent error-recovery contract across generation surfaces (quiz, path, daily content) as a cause of perceived freezes. This is cheap relative to its impact — no new backend/schema, just a shared retry/skeleton pattern reused across `generation_job_service.dart` call sites.
- **Suggested next step:** Define one shared "generating → skeleton → success/retry" widget contract and apply it to quiz, path, and daily-content generation screens instead of each screen's own ad hoc loading state.
- **Risks:** Touches several screens at once; regression risk is UI-only (no data-layer changes) if scoped as a pure presentation refactor.
- **Source:** `docs/reviews/ux-review.md`.

### B15 — Freemium hosted AI tier with budget guardrails

- **Status:** backlog (proposed 2026-08-29)
- **Area:** ai, monetization
- **MoSCoW:** Should have
- **Why it exists:** `risk-register.md` R7 (BYOK-wall activation failure) and R12 (AI cost blowout without server-side budgets) are linked risks — `product-review.md` and `executive-summary.md` both propose a freemium hosted tier as the fix, keeping BYOK as the privacy/Pro path. The existing Built-in AI quota system (rolling 24h window, rewarded-ad top-ups) is effectively a prototype of this already; the gap is a **pooled, budgeted** hosted tier beyond the single build-time key, which R12 says must be designed before shipping wider.
- **Suggested next step:** Do not start until R12's server-side budget design exists (a hosted gateway with per-user/day spend caps). Then extend the existing `BuiltInAiQuota`/`BuiltInAiRouter` pattern rather than building a parallel system.
- **Risks:** Real financial exposure if shipped without hard spend caps — this is the one item on this list that can directly cost money if rushed.
- **Source:** `docs/reviews/risk-register.md` R7/R12, `product-review.md`, `executive-summary.md`.

### B16 — Achievement badges & milestone challenges

- **Status:** done (2026-08-29)
- **Area:** gamification, dashboard
- **MoSCoW:** Should have
- **Shipped:** `lib/shared/widgets/dashboard/achievement_badges.dart` — 8 fixed milestones computed live from `DashboardStats` (no new Isar collection, no unlock-history persistence, no first-unlock toast — all deliberately deferred). Streak badges key off `longestStreak` (not `currentStreak`) so an earned badge isn't revoked when today's streak breaks. Wired into `dashboard_screen.dart` below the existing stats section. Covered by `test/achievement_badges_test.dart` (19 tests).
- **Why it exists:** `stats_repository.dart` already computes `currentStreak`/`longestStreak`, so daily-streak retention exists — but 2026 gamification research (Headway, Duolingo) points at badges/milestones and challenges as the next layer on top of streaks, not a replacement. Low novelty risk since it's presentation + a milestone table over data the app already tracks.
- **Suggested next step:** Milestone badges off existing stats (streak length, questions answered, topics mastered) shown on the dashboard; no new AI generation involved, so no quota/cost impact.
- **Risks:** Low — mainly scope creep if badge criteria multiply; keep the first version to 5–10 fixed milestones.
- **Source:** External scan (2026 gamification/retention research, 2026-08-29); `lib/data/local/repositories/stats_repository.dart` (existing streak data confirmed via grep).

### B17 — Mark-for-review / flag questions in mock exams

- **Status:** done (2026-08-29)
- **Area:** exam
- **MoSCoW:** Should have
- **Shipped:** In-memory `_flaggedIndices` on `quiz_play_screen.dart` (shared by mock exams and regular quizzes), gated to `quizKind == mock` only. AppBar flag toggle + a scrollable row of jump-to chips for flagged questions, using the existing `_goTo(index)`. No `Question` schema change — flags only need to survive the current attempt, not persist across sessions.
- **Why it exists:** `docs/EXAM_AND_CAREER_MODULES.md` already lists this as a "nice-to-have v1.1" item for the mock-exam module; it just hasn't been promoted into this backlog file yet.
- **Suggested next step:** Add a flag toggle per question in the mock-exam play screen and a review-flagged-only filter before final submit — UI-only against the existing exam session model.
- **Risks:** Low — self-contained to the exam play screen.
- **Source:** `docs/EXAM_AND_CAREER_MODULES.md`.

### B18 — Shared / cohort learning packs

- **Status:** backlog (proposed 2026-08-29)
- **Area:** social, learn
- **MoSCoW:** Could have
- **Why it exists:** `billion-dollar-roadmap.md` names cohort/shared-pack network effects as a growth-loop step (habit → investment → social). Genuinely useful but needs moderation and identity work this app doesn't have yet (no accounts — see B13).
- **Suggested next step:** Do not start before B13 (accounts) lands. Scope v1 as read-only shared packs (export/import a learning path), not live social features, to avoid a moderation system on day one.
- **Risks:** Content moderation, abuse, and spam surface area — the reason this is Could have, not Should have, until accounts exist.
- **Source:** `docs/reviews/billion-dollar-roadmap.md`.

### B19 — Home-screen widget (streak / daily quiz)

- **Status:** backlog (proposed 2026-08-29)
- **Area:** platform, retention
- **MoSCoW:** Could have
- **Why it exists:** Not in any existing review doc, but a direct, low-risk retention lever supported by the external 2026 scan (habit-forming apps lean on OS-level surfaces, not just in-app streaks) and by data the app already has (`stats_repository.dart` streak, daily quiz state).
- **Suggested next step:** Android home-screen widget showing current streak + a "Start today's quiz" deep link (existing `deepLinkScheme`). iOS WidgetKit as a follow-up, not v1.
- **Risks:** Platform-specific native code (Android App Widget / Glance), separate from the Flutter codebase's usual surface area; low functional risk to the rest of the app since it's read-only + a deep link.
- **Source:** External scan (2026-08-29); existing streak/deep-link infra.

### B20 — Neurodiversity-aware adaptive pacing

- **Status:** backlog (proposed 2026-08-29)
- **Area:** ai, accessibility
- **MoSCoW:** Could have
- **Why it exists:** External 2026 scan flags neurodiversity-aware pacing (ADHD/dyslexia-adjusted difficulty and break cadence) as an emerging differentiator in AI tutoring. Interesting and aligned with `ux-review.md`'s existing accessibility gap callout, but the detection/adaptation logic is research-grade and unproven — appropriately Could have, not a near-term commitment.
- **Suggested next step:** Do not build affective/behavioral detection speculatively. If pursued, start narrow: a manual "shorter sessions / more breaks" pacing preference in Settings (no inference), then evaluate real signal-based adaptation later.
- **Risks:** Easy to over-promise here; inferred neurodiversity signals are sensitive and error-prone — a manual preference is the safer v1 than any automatic detection.
- **Source:** External scan (2026-08-29); `docs/reviews/ux-review.md` accessibility gap.

### B21 — Marketplace / enterprise SKU / learning-intelligence API

- **Status:** backlog (proposed 2026-08-29)
- **Area:** growth, enterprise
- **MoSCoW:** Won't have (this cycle)
- **Why it exists:** `billion-dollar-roadmap.md` names three long-horizon (12–24 month) directions: a creator/content marketplace, an enterprise/education SKU, and a third-party learning-intelligence API. All three require infrastructure this app doesn't have yet and that nothing else on this list depends on: payments/entitlements, server-side content moderation, and — for enterprise/education specifically — the age-gating and school-use policy work `risk-register.md` R14 flags as currently entirely missing.
- **Suggested next step:** Explicitly deferred. Do not start scaffolding for any of the three until B13 (accounts), a real payments/entitlements layer, and R14's policy work exist. Revisit only after B11–B17 ship and prove retention.
- **Risks:** The main risk is scope sprawl (`risk-register.md` R13) — starting any of these now would pull effort from the Must/Should items above before product-market fit on the core app is proven.
- **Source:** `docs/reviews/billion-dollar-roadmap.md`, `risk-register.md` R13/R14.
