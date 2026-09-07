# Learn Anything — Product backlog

Living list of **not-built, coming-soon, or partial** work. Grounded in shipped logs, explicit Coming soon UI, the 2026-08-23 user-reported batch, and — for B11–B26 — 2026-08-29 research passes (internal `docs/reviews/*` roadmap docs + external 2026 AI-learning-app market scan for B11–B21; the site's own SEO audit + a fact-checked external ASO report for B22–B26) prioritized by MoSCoW. B27–B39 come from a 2026-09-07 early-beta user feedback report, with every item verified against the app's actual current code before being scoped (several beta asks turned out to already be shipped or redundant with an existing algorithm — documented as such rather than re-implemented). B40–B44 come from a 2026-09-07 "how would Google build this" hypothetical feedback pass — fact-checked the same way (one claimed capability, a per-app screen-time hook via "Google Fit," doesn't actually exist as described; one, a lock-screen unlock gate, isn't achievable through public Android APIs available to a third-party app; both corrected to their real, buildable equivalent rather than scoped as pitched). Not a speculative roadmap beyond what's cited per item.

Agents: read this file with `docs/PROJECT_LOG.md` before starting a listed item. When an item ships, move a dated note to the section log and mark status **done** here (do not delete the row).

| ID | Title | Status | Area | MoSCoW |
|----|-------|--------|------|--------|
| B1 | In-app learning chatbot | done (2026-09-07) | chat, learn, ai | Should have |
| B2 | Voice interview agent | partial (STT shipped) | career / interview | Should have |
| B3 | On-device / local LLM | coming soon | ai, llm | Won't have (this cycle) |
| B4 | Persist and translate 2026-08-23 l10n keys | done | l10n | — |
| B5 | Article relevance vs empty resources | done | learn, daily content | — |
| B6 | Leftover Android `study_alarm` channel | done | reminders | — |
| B7 | Daily quiz frequency sequencing | done | quiz, settings | — |
| B8 | Device QA for 2026-08-23 batch | backlog | qa | — |
| B9 | Confirm production ad fill on device | backlog | ads | — |
| B10 | Hosting AdSense display slot IDs | done | hosting | — |
| B11 | Spaced-repetition flashcards from library/mistakes | done (2026-08-29) | learn, library, ai | Must have |
| B12 | Automated AI generation quality eval gate | done (2026-08-29) | ai, ci, qa | Must have |
| B13 | Optional encrypted account + cross-device backup/sync | done (2026-09-07) | accounts, infra | Must have |
| B14 | Global AI-generation error-recovery UX contract | done (2026-08-29) | ux, quiz, learn | Must have |
| B15 | Freemium hosted AI tier with budget guardrails | backlog (proposed 2026-08-29) | ai, monetization | Should have |
| B16 | Achievement badges & milestone challenges | done (2026-08-29) | gamification, dashboard | Should have |
| B17 | Mark-for-review / flag questions in mock exams | done (2026-08-29) | exam | Should have |
| B18 | Shared / cohort learning packs | backlog (proposed 2026-08-29) | social, learn | Could have |
| B19 | Home-screen widget (streak / daily quiz) | backlog (proposed 2026-08-29) | platform, retention | Could have |
| B20 | Neurodiversity-aware adaptive pacing | backlog (proposed 2026-08-29) | ai, accessibility | Could have |
| B21 | Marketplace / enterprise SKU / learning-intelligence API | backlog (proposed 2026-08-29) | growth, enterprise | Won't have (this cycle) |
| B22 | Google Search Console verification + sitemap submission | backlog (proposed 2026-08-29) | seo, hosting | Must have |
| B23 | Attach `learnanything.app` custom domain | backlog (proposed 2026-08-29) | hosting, branding | Should have |
| B24 | Custom Store Listing targeted at "voice interview preparation" | backlog (proposed 2026-08-29) | aso, marketing | Should have |
| B25 | Content build-out for long-tail SEO keywords (blog / comparison pages) | partial (2026-09-07, first batch shipped) | hosting, content, seo | Could have |
| B26 | Scoped Android App Links (reserved app-deep-link path) | backlog (proposed 2026-08-29) | mobile, hosting, deep-linking | Could have |
| B27 | Onboarding is already API-key-free; remove dead BYOK onboarding step | backlog (proposed 2026-09-07) | onboarding, ux | Won't have (already satisfied) |
| B28 | Export quiz results / learning path as a shareable image | backlog (proposed 2026-09-07) | quiz, learn, sharing | Should have |
| B29 | Achievement unlock celebration + persisted unlock history | backlog (proposed 2026-09-07) | gamification, dashboard | Could have |
| B30 | Ad-free premium subscription (IAP) for unlimited Built-in AI | backlog (proposed 2026-09-07) | monetization | Should have |
| B31 | Classroom quiz-code sharing for teacher-led groups | backlog (proposed 2026-09-07) | social, career, accounts | Could have |
| B32 | ASO: beta-suggested title change is invalid/redundant — no action | backlog (proposed 2026-09-07) | aso, marketing | Won't have |
| B33 | Launch Loop: demo video + community feedback posts | backlog (proposed 2026-09-07) | marketing, growth | Could have |
| B34 | Camera-to-Quiz (OCR ingestion into Library) | backlog (proposed 2026-09-07) | library, ai, ocr | Should have |
| B35 | Daily Pack: timestamped video chapters/summary | backlog (proposed 2026-09-07) | learn, daily content | Could have |
| B36 | Local `.rivox` encrypted export/import (no-cloud sharing) | backlog (proposed 2026-09-07) | learn, sharing, privacy | Should have |
| B37 | Voice interview: speech-delivery feedback + persona-aware scoring | backlog (proposed 2026-09-07) | career, ai, voice | Should have |
| B38 | Flashcards already use SM-2 (superset of Leitner) — no algorithm change | backlog (proposed 2026-09-07) | learn, flashcards | Won't have (algorithm) |
| B39 | Learning path visual mind-map view | backlog (proposed 2026-09-07) | learn, ux | Could have |
| B40 | On-device AI via ML Kit GenAI APIs (Gemini Nano / AICore) | backlog (proposed 2026-09-07) | ai, llm, platform | Could have |
| B41 | Google Drive/Workspace folder sync for auto-flashcard generation | backlog (proposed 2026-09-07) | learn, library, integrations | Could have |
| B42 | Realtime conversational voice interview (Gemini Live-style) | backlog (proposed 2026-09-07) | career, ai, voice | Won't have (this cycle) |
| B43 | Lock-screen "answer to unlock" gamification | backlog (proposed 2026-09-07) | gamification, platform | Won't have (not feasible) |
| B44 | Screen-time-aware streak nudge via Android UsageStatsManager | backlog (proposed 2026-09-07) | gamification, platform, retention | Could have |

---

## B1 — In-app learning chatbot

- **Status:** done (2026-09-07)
- **Area:** chat, learn, ai
- **Why it exists:** User request #26 (2026-08-23). Feasibility researched and logged; **not built**. Users want follow-up questions on modules, quizzes, and uploaded library files.
- **Shipped:** Single continuous RAG chat thread (`ChatMessage` Isar collection, `ChatRepository`, `ChatScreen` at `/chat`). Reuses `LlmManager.completeJson` (model replies `{"reply": "..."}`, parsed back out — no new plain-text completion path added to hardened provider code) and the existing `AiRequestPipeline`/`RagContextBuilder` for consent gating, RAG retrieval, and audit logging. Gated by a new, fully independent `BuiltInChatQuota` (8 free messages/24h + rewarded-ad bonus) — never reads/writes the generation quota (`BuiltInAiQuota`). Global entry point: a floating action button wired once in `lib/app.dart`, hidden on onboarding/quiz-play/the chat screen itself/the providers screen (which has its own FAB).
- **Risks:** Cost / quota burn per turn (mitigated by the new independent quota); hallucination unless grounded (mitigated by reusing the existing RAG pipeline, not a new one); live chat replies not tested end-to-end (would burn real API quota) — unverified by a live probe, consistent with how other new AI features ship without one unless asked.
- **Source:** [FEATURES_LOG](logs/FEATURES_LOG.md) 2026-09-07 RAG chat entry.

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
- **2026-09-07 update:** A different, unblocked on-device path exists independent of the MLC `tvm_ffi` issue above — see new **B40** (ML Kit GenAI APIs / Gemini Nano via Android AICore). It is scope-limited (fixed task APIs, not a general instruct/JSON model) so it cannot fully replace Built-in/BYOK the way a working `mlc4j` package eventually could, but it's worth evaluating separately rather than waiting on this item's blocked path.
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

- **Status:** done (2026-08-29)
- **Area:** learn, library, ai
- **MoSCoW:** Must have
- **Shipped:** New `Flashcard` Isar collection with a tested, pure SM-2 implementation (`SpacedRepetition.review`); free/instant cards from quiz mistakes (`QuizRepository.getWrongQuestions` + `FlashcardRepository.fromWrongQuestion`, no AI call) and AI-generated cards from the library (`FlashcardGenerationService`, quota-gated like other generation); review screen at `/flashcards`; entry points on Learn, Library, and Results screens. Covered by `test/flashcard_repository_test.dart` (7 tests). A follow-up bugfix (2026-08-29, see `docs/logs/BUGFIX_LOG.md`) fixed the due-count display never refreshing after a review.
- **Why it exists:** Confirmed gap — grep of `lib/` found no flashcard or spaced-repetition code (only a dead `multiplayerLeaderboardTitle` l10n string from the removed multiplayer feature). Every major 2026 competitor (Quizlet AI Study Tools, Knowt, Anki-style apps) leads with "turn your notes/mistakes into spaced-repetition cards"; research cited 3.2× retention vs. drill-only apps. This app already has the two building blocks: the Personal Knowledge Base (RAG uploads) and per-question quiz history — a flashcard mode is mostly a new prompt template + a scheduling field on top of existing infra, not a new subsystem.
- **Suggested next step:** Generate flashcards from (a) library chunks the user opted into RAG on, and (b) previously-missed quiz questions. Add a `nextReviewAt`/`easeFactor` pair to the question/answer model (SM-2-style) and a lightweight review queue screen. Reuse `LlmManager` + `AiOutputGate` for generation; reuse Built-in quota accounting.
- **Risks:** Another Isar schema change; scheduling logic needs its own tests (must not silently starve review queues); should not compete with quiz generation for the same daily quota without a clear UX split.
- **Source:** External scan (Quizlet/Knowt/spaced-repetition research, 2026-08-29); internal grep confirming no existing implementation.

### B12 — Automated AI generation quality eval gate

- **Status:** done (2026-08-29)
- **Area:** ai, ci, qa
- **MoSCoW:** Must have
- **Shipped:** `.github/workflows/ai-eval.yml` — daily cron + `workflow_dispatch`, runs `test/model_generation_live_probe_test.dart` against the real Built-in AI backend, keeps the existing 10/10-per-task assertion (stricter than this item's own "alert below 8/10" suggestion, matching the project's established quality bar). Historical tracking relies on browsing past workflow run logs, not a committed log file.
- **Gate scope (2026-08-29, after first live run):** first `workflow_dispatch` run caught a real case — "primary model alone" scored 0/10 on `quiz` (one slow ~24s call came back unparseable, likely `max_tokens` truncation) while "router chain" (the actual user-facing path, which retries via `BuiltInAiRouter.withModelFallback`) and "fallback model alone" both scored 10/10 clean. Split the workflow into 3 steps so only **router chain** fails the job; primary-alone/fallback-alone still run every time (`continue-on-error: true`) for visibility but don't block on ordinary single-model output variance that never reaches real users.
- **Secret added (2026-08-29):** `BUILT_IN_AI_API_KEY` is set as a repo secret; the workflow runs its checks instead of skipping.
- **Why it exists:** `executive-summary.md`'s 90-day plan calls for an "AI quality eval framework." The repo already has the right primitive — `test/model_generation_live_probe_test.dart`, which scored the live Built-in router chain, primary, and fallback model **10/10 across all 9 generation tasks** on 2026-08-29 — but it's dev-run-only, not wired into CI or tracked over time. Models get silently retired/changed upstream (already happened once — Nemotron EOL, see 2026-08-26 bugfix log), so a regression could ship unnoticed until users hit it.
- **Suggested next step:** Add a scheduled (not per-PR, to avoid burning API quota on every commit) CI job that runs the live probe, stores scores per task/model/date, and alerts (or fails a nightly build) if any task drops below 8/10. Extend probe coverage to BYOK providers (Gemini/Claude/OpenAI-compatible) periodically, not just Built-in.
- **Risks:** Costs real API credits on a schedule; needs a place to store historical scores (even a simple JSON log in the repo would beat nothing); false alerts if a provider has a transient outage need a retry-before-alert step.
- **Source:** `docs/reviews/executive-summary.md` 90-day plan; `test/model_generation_live_probe_test.dart` (exists, unwired); 2026-08-29 live probe run in this session.

### B13 — Optional encrypted account + cross-device backup/sync

- **Status:** done (2026-09-07)
- **Area:** accounts, infra
- **MoSCoW:** Must have
- **Why it exists:** All user data (quiz history, learning paths, library uploads, stats/streaks) lives in local-only Isar today — confirmed by README ("local-first") and `scalability-roadmap.md`. `risk-register.md` R7 flags BYOK-wall activation friction as an "existential" risk, and both `product-review.md` and `executive-summary.md` independently call accounts/sync "retention-critical": an uninstall or device loss currently destroys a user's entire history, streaks included.
- **Shipped:** Ships behind `kCloudBackupEnabled` (`lib/core/services/backup_flags.dart`, currently `false` — dark until deliberately flipped on, pending the Firebase-console prerequisite below). Google Sign-In only (`lib/data/remote/auth/auth_service.dart`, targets the current async `google_sign_in` 7.x API). Client-side end-to-end AES-256-GCM encryption with a user-chosen passphrase (`lib/data/remote/backup/backup_crypto.dart`, PBKDF2-HMAC-SHA256 key derivation) — Rivox/Firebase can never read backup contents. Covers quiz history, learning paths (+ step files), daily stats, learner profile, flashcards, chat history, syllabus/study-plan/career-skill data, and library uploads; excludes BYOK provider configs, internal AI-tuning data, and operational logs by design. Manual "Create backup now" / "Restore from backup" only (`lib/features/settings/presentation/backup_settings_screen.dart`) — no continuous sync, no conflict resolution, matching this entry's own "ship backup before sync" guidance. Encrypted blob in Firebase Storage (`users/{uid}/backups/latest.enc`); small cleartext KDF-params metadata doc in Firestore (`users/{uid}/backup_metadata/current`) — new `firestore.rules`/`storage.rules` scope both to `request.auth.uid == uid`.
- **Corrected from this entry's original assumptions (verified against real code before building):** Firebase Auth was **not** actually in the stack (only `firebase_core`/`cloud_firestore`/`firebase_crashlytics` were) — added fresh. No `request.auth.uid`-scoped Firestore rule pattern existed anywhere — designed from scratch, not "mirrored."
- **Known follow-ups, not blocking:** Firebase console setup (enable Google provider, register SHA-1/SHA-256, regenerate config files) is a manual prerequisite before sign-in works on a device — required before flipping the feature flag on. PBKDF2 at the shipped 600k-iteration default measured ~3.4s per derivation on the dev machine (real low-end Android devices will likely be slower) — acceptable for an infrequent, explicit action behind a progress dialog, but worth reducing (plan's documented fallback: 210k iterations) if user feedback says otherwise. App Check, backup version history/rollback, and an account-deletion/"delete my cloud data" flow remain deferred, as originally scoped.
- **Risks:** Encryption is genuinely zero-knowledge — a forgotten passphrase with no other signed-in device means that backup is permanently unreadable, by design (documented prominently in the passphrase-entry UI, not buried).
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

### B22 — Google Search Console verification + sitemap submission

- **Status:** backlog (proposed 2026-08-29)
- **Area:** seo, hosting
- **MoSCoW:** Must have
- **Why it exists:** The 2026-08-29 SEO audit confirmed via `site:learn-anything-43970.web.app` that the website is **not indexed by Google at all** — the single highest-leverage SEO fix available, ahead of any on-page work. `robots.txt`/`sitemap.xml` now exist and are deployed live, but nothing has told Google to actually crawl them; there is also currently no way to monitor indexing status, crawl errors, or search performance at all (confirmed: no Search Console verification, no Analytics, anywhere in the repo).
- **Suggested next step:** Verify the domain in Google Search Console (HTML meta tag or DNS TXT record — either works with the current `learn-anything-43970.web.app` domain), then submit `https://learn-anything-43970.web.app/sitemap.xml`. Requires the site owner's Google account — not something an agent can do.
- **Risks:** None — purely additive, no downside to doing this immediately.
- **Source:** `docs/logs/FEATURES_LOG.md` 2026-08-29 SEO audit.

### B23 — Attach `learnanything.app` custom domain

- **Status:** backlog (proposed 2026-08-29)
- **Area:** hosting, branding
- **MoSCoW:** Should have
- **Why it exists:** The site currently lives on the generic Firebase subdomain `learn-anything-43970.web.app`; `learnanything.app` is already the documented intended domain (`lib/core/constants/app_constants.dart`'s own comment: "Switch back to https://learnanything.app/... after custom domain DNS is live") but DNS was never attached. Every day on the throwaway subdomain delays building real domain authority, and canonical tags / Search Console verification / all backlinks accumulated before the switch would need to be redirected (301) to preserve any SEO value already built.
- **Suggested next step:** Attach the domain in Firebase Hosting (Console → Hosting → Add custom domain), configure DNS, then update canonical/OG URLs across `hosting/*.html`, `hosting/sitemap.xml`, `hosting/robots.txt`, `AppConstants`'s privacy/terms URLs, and the Play Store listing URLs in `docs/store/LISTING.md` — all in one pass, with 301 redirects from the old domain, not a partial switch.
- **Risks:** A domain migration is itself a real SEO event — must be done as a clean cutover with redirects, not left half-migrated (some canonicals pointing one way, live traffic serving another).
- **Source:** `lib/core/constants/app_constants.dart` comment; `docs/PLAY_STORE_CHECKLIST.md` item 3; 2026-08-29 SEO audit.

### B24 — Custom Store Listing targeted at "voice interview preparation"

- **Status:** backlog (proposed 2026-08-29)
- **Area:** aso, marketing
- **MoSCoW:** Should have
- **Why it exists:** Confirmed real (fact-checked against Google's own Custom Store Listings help page, not assumed) during the 2026-08-29 ASO report review: Play Console supports up to 50 Custom Store Listings, including one genuinely targetable at "Organic Search: users who discover your app on Play using specific search terms." Voice interview practice with live captions was independently identified by the earlier keyword research as one of the most winnable long-tail terms for this app (open niche, no dominant incumbent).
- **Suggested next step:** Create a CSL in Play Console (Grow → Store presence → Custom store listings) targeted at organic search term "voice interview preparation" (or similar), with creative/screenshots emphasizing that feature specifically rather than the general app pitch. Manual Play Console step, not code.
- **Risks:** Low — this only changes which listing/creative a searcher sees after they already searched that term (a conversion lever), not search rankings themselves; don't oversell it internally as an SEO ranking mechanism.
- **Source:** `docs/store/LISTING.md` 2026-08-29 ASO revision; Google Play Console Custom Store Listings help docs.

### B25 — Content build-out for long-tail SEO keywords (blog / comparison pages)

- **Status:** partial (2026-09-07) — first batch of 3 shipped
- **Area:** hosting, content, seo
- **MoSCoW:** Could have
- **Why it exists:** The 2026-08-29 keyword research found that real top-ranking competitors in this space win via scale — e.g. PracticeMock-style programmatic SEO (one indexed page per exam/topic, ~500+ pages) and RemNote-style long-form comparison posts ("Best Anki Alternatives" with tables, named competitors, FAQ sections). A handful of static marketing pages cannot compete head-on with that; winnable long-tail phrases (BYOK AI quiz generation, local-first flashcards, AI quiz for competitive exams) need actual content to rank for, not just better meta tags on the homepage.
- **Shipped:** Exactly the first batch this entry's own "suggested next step" called for — 3 real, substantive posts (`/blog/byok-ai-quiz-generation`, `/blog/local-first-flashcards-spaced-repetition`, `/blog/ai-quiz-competitive-exam-prep`), one per identified winnable phrase, each explaining the underlying concept genuinely (not just restating app marketing copy) plus an FAQ section, and a `/blog` hub page. See `docs/logs/FEATURES_LOG.md` 2026-09-07 entry.
- **Suggested next step:** Decide whether to invest further (comparison-style posts, e.g. "Rivox vs [named competitor]", or the larger programmatic-SEO approach) only after seeing whether this first batch gets any real traffic/indexing — per this entry's own original caution against building more speculatively.
- **Risks:** Thin/low-quality pages built purely for SEO can actively hurt rankings (Google's stated policy against "scaled content abuse") — the shipped batch was written to be genuinely useful on its own merits, not filler; any further batch must hold the same bar.
- **Source:** `docs/logs/FEATURES_LOG.md` 2026-08-29 SEO audit keyword research; 2026-09-07 shipped batch.

### B26 — Scoped Android App Links (reserved app-deep-link path)

- **Status:** backlog (proposed 2026-08-29)
- **Area:** mobile, hosting, deep-linking
- **MoSCoW:** Could have
- **Why it exists:** An externally-sourced ASO report's "Firebase App Indexing" section was confirmed fake/outdated (that library was discontinued years ago); the real 2026 equivalent is Android App Links (`autoVerify="true"` + `.well-known/assetlinks.json`). Investigated implementing it directly this session and found the app's actual `DeepLinkHandler`/router has no route matching any of the website's real pages (`/privacy`, `/terms`, `/games`, `/games/dino`, `/`) — enabling it site-wide as the report described would hijack real visitors' Search-result taps into a broken in-app screen instead of the actual page. Deliberately not implemented; the SHA-256 fingerprint needed for `assetlinks.json` was already extracted from `android/upload-keystore.jks` this session if/when this is picked up (note: if Play App Signing is enabled, the real fingerprint needed is the **app signing key** from Play Console → Setup → App integrity, not the upload key — confirm which before shipping).
- **Suggested next step:** Design a reserved path prefix (e.g. `/open/*`) that's exclusively for app deep links, with a real web fallback page for users without the app installed, before touching `AndroidManifest.xml`'s `autoVerify` intent filter. Do not scope App Links to the whole domain.
- **Risks:** Doing this wrong (site-wide, without matching app routes) actively breaks the live site's UX for real visitors — this is the one item on this list where the risk of a rushed implementation is worse than not doing it at all.
- **Source:** `docs/store/LISTING.md` 2026-08-29 ASO fact-check section; `lib/core/services/deep_link_handler.dart` investigation this session.

### B27 — Onboarding is already API-key-free; remove dead BYOK onboarding step

- **Status:** backlog (proposed 2026-09-07)
- **Area:** onboarding, ux
- **MoSCoW:** Won't have (already satisfied)
- **Why it exists:** Beta feedback: "Don't push API keys right away. Give us a flawless, simple free tier first." Verified against the actual live flow (`app_router.dart:66-67` → `splash_screen.dart` → `welcome_screen.dart`): the real onboarding is a 4-page flow (identity → goal mode → daily-minutes habit → legal consent) that never asks for an API key. The "Continue" action on the legal page calls `ref.read(providerRepositoryProvider).ensureBuiltInSeeded()` (`welcome_screen.dart:468-471`) and routes straight to `/dashboard` — Built-in AI is silently seeded with zero user input. **This beta ask is already true today.**
- **The one real gap found:** `lib/features/onboarding/presentation/onboarding_provider_step.dart` — a "Cloud AI vs. skip (use Built-in)" + BYOK-key-entry widget — exists in the codebase but is **not referenced anywhere** (confirmed: the only repo-wide match for `OnboardingProviderStep` is its own definition). It's dead code, disconnected from `app_router.dart`/`welcome_screen.dart`, and could confuse a future maintainer into thinking onboarding still gates on it.
- **Suggested next step:** No product/UX change needed. Either (a) delete `onboarding_provider_step.dart` outright (confirmed zero call sites), or (b) repurpose it as an optional "Add your own API key" entry point surfaced later — e.g. a one-time dismissible card on the dashboard's first visit, or just left as the existing `/settings/providers` (`providers_screen.dart`) entry point, which already covers this need for the small minority of users who want BYOK. Recommend (a): delete the dead file; BYOK already has a real, working entry point at `/settings/providers`.
- **Risks:** None — this is a documentation/cleanup item, not a behavior change. Deleting dead code cannot regress the live flow since nothing calls it.
- **Source:** `lib/core/router/app_router.dart:66-67`, `lib/features/onboarding/presentation/welcome_screen.dart:172,468-471`, `lib/features/onboarding/presentation/onboarding_provider_step.dart` (verified dead via repo-wide grep), 2026-09-07 beta feedback report.

### B28 — Export quiz results / learning path as a shareable image

- **Status:** backlog (proposed 2026-09-07)
- **Area:** quiz, learn, sharing
- **MoSCoW:** Should have
- **Why it exists:** Beta feedback: "Let us export custom quizzes or learning paths as clean images/PDFs so we can show them off on social media." Verified: `pubspec.yaml:24` already has `share_plus: ^13.2.0`, but the only existing usage is plain-text sharing (`results_screen.dart:115-131`, a score string + deep link, no rendered artifact). No `screenshot`, `pdf`, or `printing` package exists; no export button exists on `path_detail_screen.dart` or `achievement_badges.dart`. This is a real, unaddressed gap and the single highest-leverage low-cost virality lever in the whole feedback report — every other social-media share today is a plain link.
- **Suggested next step (start here — easiest high-impact item on this list):**
  - Add the `screenshot: ^3.0.0` package (renders any widget subtree to a `Uint8List` PNG without a native platform channel — pairs directly with the already-present `share_plus`).
  - New shared widget `lib/shared/widgets/share_card.dart` — a fixed-size, brand-styled `RepaintBoundary`-wrapped card (app logo, gradient background matching `AppTheme.purpleStart`/`purpleEnd`, score/topic/date for quiz results, or module list + completion % for a path) rendered off-screen, captured via `ScreenshotController().captureFromWidget(...)`, then shared with `SharePlus.instance.share(ShareParams(files: [XFile(pngPath)]))`.
  - Two call sites: a "Share as image" button next to the existing text-share button on `results_screen.dart` (reuse the same score/topic data already in scope there), and a new one on `path_detail_screen.dart`'s app bar (module list + `steps` completion state already available at `path_detail_screen.dart:374-618`).
  - No new Isar schema needed — the card is rendered from data already loaded on-screen (`QuizSession`, `LearningPath`/steps), not a new persisted concept.
  - PDF export explicitly deferred to a v2 if users ask for it specifically — image share alone satisfies the stated "show off on social media" use case with far less effort (no `pdf`/`printing` package, no multi-page layout logic).
- **Risks:** Low — additive UI + one new lightweight package; no existing schema or provider touched. Widget-to-image rendering must run off the visible tree (or briefly overlay) to capture a fixed layout regardless of the user's current scroll position — a known `screenshot` package pattern, not a novel risk.
- **Source:** 2026-09-07 beta feedback report; `pubspec.yaml:24` (`share_plus` already present); `results_screen.dart:115-131` (current text-only share, confirmed via grep no image/PDF path exists anywhere in `lib/`).

### B29 — Achievement unlock celebration + persisted unlock history

- **Status:** backlog (proposed 2026-09-07)
- **Area:** gamification, dashboard
- **MoSCoW:** Could have
- **Why it exists:** Beta feedback: "Gamify the dashboard: build visual streaks and milestone badges." Verified this is **substantially already shipped**: `dashboard_screen.dart:594-599` shows a streak stat tile with a flame icon and `currentStreak`; `lib/shared/widgets/dashboard/achievement_badges.dart` renders 8 live-computed milestone badges (B16, done 2026-08-29), keyed on `longestStreak` so an earned badge isn't revoked. The real gap versus the feedback is narrow: B16's own backlog entry explicitly deferred unlock-history persistence and a first-unlock celebration moment — badges are recomputed live every time, so a user gets no distinct "you just unlocked X!" moment, only a static grid that happens to include a new badge next time they open the dashboard.
- **Suggested next step:** Add a small `UnlockedAchievement` Isar collection (`id`, `achievementKey` (String, matches `AchievementDef.id`), `unlockedAt` (DateTime)) written once, the first time `AchievementBadgesSection`'s live computation detects a badge crossing from not-unlocked to unlocked (compare against the persisted set on each dashboard load — no polling needed). On a newly-detected unlock, show a one-time celebration (a `showDialog`/`showModalBottomSheet` with confetti-style animation or a simple scale-in badge reveal) instead of silently updating the grid. Optionally fire a local notification (reusing `NotificationService`'s existing channel pattern) for milestone unlocks that happen while the app is backgrounded (e.g. a streak threshold crossed via `background_daily_tasks.dart`).
- **Risks:** Low — additive Isar collection, no existing schema modified; must guard against re-showing the celebration on every app open (read-before-write against the persisted set solves this).
- **Source:** 2026-09-07 beta feedback report; `docs/BACKLOG.md` B16 (already shipped, explicitly deferred this exact gap); `lib/shared/widgets/dashboard/achievement_badges.dart`, `lib/features/dashboard/presentation/dashboard_screen.dart:594-599`.

### B30 — Ad-free premium subscription (IAP) for unlimited Built-in AI

- **Status:** backlog (proposed 2026-09-07)
- **Area:** monetization
- **MoSCoW:** Should have
- **Why it exists:** Beta feedback: "A low-cost, ad-free subscription for unlimited built-in AI generations would be worth paying for." Verified there is **zero subscription/IAP infrastructure today** — `pubspec.yaml` has `google_mobile_ads: ^9.0.0` but no `in_app_purchase`/`purchases_flutter`/equivalent anywhere in `lib/`; monetization is currently 100% ads (native slots) + BYOK. This is the same underlying need as the already-proposed **B15 — Freemium hosted AI tier with budget guardrails**, which explicitly names the current `BuiltInAiQuota` rolling-24h-window system "a prototype of this already" and gates any wider hosted tier on a not-yet-designed server-side spend-cap system (`risk-register.md` R12) — because removing the quota for paying users means Rivox, not the user, pays NVIDIA per generation, and that exposure must be capped before it ships.
- **Suggested next step:** Do not build this as a separate system from B15 — B30 is the shippable product wrapping B15's prerequisite spend-safety design. Once R12's server-side budget/spend-cap gateway exists: add `in_app_purchase` (official Flutter Foundation package, Play Billing on Android), a `PremiumEntitlement` local cache (Isar or a simple signed local flag re-verified against Play's purchase-token API periodically — do not trust an unverified local flag alone for a paid feature), gate `ScrollableNativeAdSlot` rendering and `BuiltInAiQuota.freeGenerationsPerDay`'s cap behind `isPremium`, and add a Settings entry point (`settings_screen.dart`, alongside the existing Support section) to purchase/restore.
- **Risks:** Real financial exposure if the Built-in AI side ships without B15/R12's spend caps first (same risk B15 already documents) — this is a strict superset of B15's risk, not a new one. Also: any local-only entitlement flag is trivially spoofable; server-side (or at minimum Play purchase-token) verification is required before gating a paid feature on it.
- **Source:** 2026-09-07 beta feedback report; `docs/BACKLOG.md` B15 (extends, does not duplicate); `lib/core/services/built_in_ai_config.dart:63-70`, `built_in_ai_quota.dart` (existing quota prototype); `docs/reviews/risk-register.md` R12.

### B31 — Classroom quiz-code sharing for teacher-led groups

- **Status:** backlog (proposed 2026-09-07)
- **Area:** social, career, accounts
- **MoSCoW:** Could have
- **Why it exists:** Beta feedback: "Let teachers build a quiz on Rivox and export a quick code or file for an entire group of students." Verified there is **no accounts, backend identity, or group concept anywhere today** — all data is local-only Isar (per B13); the only existing cross-device mechanism is `DeepLinkHandler` pre-filling a quiz-create screen with a topic (`results_screen.dart`'s text share), not a shared quiz/session, invite code, or join code. This is functionally the same ask as the already-proposed **B18 — Shared / cohort learning packs**, which explicitly says "do not start before B13 (accounts) lands."
- **Suggested next step:** Do not start before B13 (optional accounts) ships — same dependency B18 already documents. When picked up, scope narrowly as B18's own suggested v1: a read-only exported/imported quiz pack (not a live classroom session, no real-time student tracking, no moderation system) — a teacher exports a quiz pack (could reuse **B36**'s `.rivox` file format below, or a lightweight numeric/word join code resolved through the B13 accounts backend once it exists) and students import it. Do not build any live/real-time group feature in v1.
- **Risks:** Same as B18 — content moderation, spam, and abuse surface area once any code/link is shareable beyond a single device; the reason this stays Could have, not Should have, until B13 exists.
- **Source:** 2026-09-07 beta feedback report; `docs/BACKLOG.md` B18 (extends, same dependency), B13 (blocking prerequisite).

### B32 — ASO: beta-suggested title change is invalid/redundant — no action

- **Status:** backlog (proposed 2026-09-07)
- **Area:** aso, marketing
- **MoSCoW:** Won't have
- **Why it exists:** Beta feedback: "Change the store title to something like 'Rivox: AI Quiz Maker & Study Planner' to capture real search traffic." Fact-checked against the current live listing (`docs/store/LISTING.md:20`, already revised 2026-08-29 per the earlier ASO fact-check pass): the current title is `Rivox: AI Study Plan & Quiz` at **27 characters** (Play Store's real limit is 30). The beta-suggested alternative, `Rivox: AI Quiz Maker & Study Planner`, is **36 characters** — it **exceeds the 30-character limit** and would be truncated or rejected in Play Console, not simply "different." Content-wise it's also largely redundant with what's already live: both lead with "Rivox:", both contain "AI," "Quiz," and "Study Plan(ner)" — the suggestion just reorders those same words and adds "Maker"/"-ner" suffixes that don't fit.
- **Suggested next step:** No title change needed as literally proposed. If keyword-order testing is still wanted, any candidate must be verified character-count-first (as the 2026-08-29 revision already was) before considering it — e.g. reordering to lead with "Quiz Maker" instead of "Study Plan" would need to drop something else to stay ≤30 chars. Not worth spending effort on without evidence the current order under-performs; this item exists mainly to record the fact-check so a future pass doesn't blindly implement the beta-suggested (invalid) string.
- **Risks:** None from not acting. The risk this item guards against is the opposite: implementing the suggested string as-is would break Play Console validation.
- **Source:** 2026-09-07 beta feedback report; `docs/store/LISTING.md:10,20` (current title + documented 30-char limit).

### B33 — Launch Loop: demo video + community feedback posts

- **Status:** backlog (proposed 2026-09-07)
- **Area:** marketing, growth
- **MoSCoW:** Could have
- **Why it exists:** Beta feedback: "Package a clean video demo to share on communities like r/AndroidApps and r/SideProject for direct feedback." This is a genuine, low-cost distribution lever with no code dependency — but it is **not a coding task**: it requires the app owner to record a real screen-capture demo, write community-appropriate copy (both subreddits have strict self-promotion rules — r/SideProject expects a maker's personal story, r/AndroidApps expects a direct, no-hype feature demo), and post/monitor it personally. An agent cannot execute this step.
- **Suggested next step:** Record a 30-60s screen capture covering the actual "aha!" moment (per B27's finding: onboarding → first Built-in AI generation, zero key entry) rather than a feature-tour montage — matches what both communities respond to best. Post to r/SideProject first (maker-story framing) once B28 (shareable results) ships, since a visual export is exactly the kind of asset that performs well as a post's hero image/clip. Track referral traffic via the site's existing (or to-be-added, see B22) Search Console / basic analytics, not vanity upvote counts.
- **Risks:** None to the codebase — purely a marketing action item. Main risk is reputational (rule-breaking self-promo posts get removed/banned) if community norms aren't followed; not an engineering risk.
- **Source:** 2026-09-07 beta feedback report.

### B34 — Camera-to-Quiz (OCR ingestion into Library)

- **Status:** backlog (proposed 2026-09-07)
- **Area:** library, ai, ocr
- **MoSCoW:** Should have
- **Why it exists:** Beta feedback: "Give us Camera-to-Quiz (OCR scanning of physical pages)." Verified: **zero OCR/camera capability exists anywhere today** — `pubspec.yaml` has only `file_picker: ^12.1.2`; no `camera`, `image_picker`, or `google_mlkit_text_recognition` package; Library ingestion (`my_library_screen.dart:99-101`) is strictly `FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['txt','md','pdf'])`. This is the most-requested genuinely new capability in the report and a real product differentiator (turns physical textbooks/notes into quiz material, not just already-digital files) — a ground-up feature with no existing scaffolding.
- **Suggested next step (structural plan):**
  - **Packages:** `camera: ^0.11.x` (capture) + `google_mlkit_text_recognition: ^0.15.x` (on-device OCR, no network call needed — consistent with this app's local-first/privacy stance, unlike a cloud OCR API).
  - **Permissions:** `android.permission.CAMERA` in `AndroidManifest.xml`; runtime permission request via the existing permission-handling pattern already used for mic access (Whisper voice interview) — mirror that, don't invent a new pattern.
  - **New screen:** `lib/features/library/presentation/camera_scan_screen.dart` — live camera preview, capture button, optional multi-page capture (a running list of captured page images before final OCR), a review step showing extracted text per page with basic manual-edit capability (OCR is never perfect — do not silently trust it) before committing.
  - **New service:** `lib/core/services/ocr_service.dart` — wraps `TextRecognizer(script: TextRecognitionScript.latin)`, takes an `InputImage` per captured page, returns concatenated recognized text.
  - **Ingestion:** the extracted (and user-reviewed) text feeds into the **existing** Library ingestion path — no new Isar schema needed; it should ultimately produce the same `LibrarySource`/chunk shape `file_picker`-based `.txt` ingestion already produces (check `lib/data/local/models/` for the exact existing source-content model and reuse its constructor, don't fork a parallel model for "camera-sourced" content).
  - **Entry point:** a "Scan pages" button next to the existing "Upload file" button on `my_library_screen.dart`.
- **Risks:** OCR accuracy varies with lighting/handwriting (works best on printed text) — the mandatory review-before-commit step exists specifically to prevent bad-quality quizzes being silently generated from misread text. `google_mlkit_text_recognition` increases APK size (ML Kit native libraries) — measure the size delta before committing, and check it doesn't conflict with the Play Console bitmap-downsampling concern already fixed for `file_picker` (B-fix 2026-08-29) — camera-captured images should be downsampled the same way before OCR/storage.
- **Google-advice cross-check (2026-09-07):** External "how Google would build this" feedback independently named the same capability ("Lens Study" — point camera at a blackboard/textbook/plaque, instantly get a quiz), confirming this is the right priority, not a new idea. One addition worth folding in: a fast "Scan → instant quiz" path that skips straight to quiz generation from a single capture (no multi-page session, no Library commit) for the common "one photo of a slide" case, with the existing multi-page-review-then-ingest flow above as the deliberate v1 path when the user wants it saved to Library too. Both can share the same `ocr_service.dart`.
- **Source:** 2026-09-07 beta feedback report; `pubspec.yaml` (confirmed no existing OCR/camera package), `lib/features/library/presentation/my_library_screen.dart:99-101` (confirmed file-only ingestion).

### B35 — Daily Pack: timestamped video chapters/summary

- **Status:** backlog (proposed 2026-09-07)
- **Area:** learn, daily content
- **MoSCoW:** Could have
- **Why it exists:** Beta feedback: "Clickable YouTube video summaries/timestamps in our Daily Packs." Verified the Daily Pack already does real, embedded, tap-to-play YouTube video (`lib/shared/widgets/in_app_youtube_player.dart`, `youtube_player_flutter`) with an AI-selected video (`daily_content_service.dart:409-426`) and a short caption-style subtitle (2026-08-26 log) — not just a link-out. A `YoutubeTranscriptFetcher` (`lib/data/remote/ai/youtube_transcript_fetcher.dart`) already fetches full caption text via YouTube's public `timedtext` endpoint, but only for module summarization (`learning_orchestrator.dart:606`) — its own `_stripTimedText` helper explicitly **discards timing data**, and there is no in-app timestamp display, chapter list, or "jump to timestamp" UI anywhere. This is a real gap, but a moderate one since the hardest part (fetching transcripts at all) is already solved.
- **Suggested next step:** `_stripTimedText`'s discarded timing data is the actual blocker — `timedtext`'s XML response already contains per-line `start`/`dur` attributes; keep them instead of stripping (return a `List<TranscriptLine>` with `text`/`startSeconds` rather than a flat string) and feed the full timed transcript into a new LLM prompt asking for 3-5 chapter markers (`{"timestampSeconds": N, "label": "..."}`), reusing the existing JSON-forcing `LlmManager.completeJson` path (same pattern as B1/chat's `{"reply": "..."}` envelope — don't add a new plain-text completion path). UI: a small chapter-chip row below `InAppYoutubePlayer` in `daily_content_detail_screen.dart`; tapping a chip seeks the embedded `YoutubePlayer` controller to that timestamp (the package already exposes `seekTo`).
- **Risks:** Transcript availability/quality varies by video (auto-captions can be poor or missing entirely) — must degrade gracefully to today's plain-video experience (no chapter row) when no usable transcript exists, not block video display. One extra LLM call per Daily Pack video adds latency/cost — should be cached alongside the existing Daily Pack sidecar file, not re-fetched every view.
- **Google-advice cross-check (2026-09-07):** External "how Google would build this" feedback pitched this as using "Google's advanced video-understanding models" to auto-skip intro/sponsor segments — that specific capability is not a public third-party API (Google does not expose a sponsor-segment-detection endpoint for arbitrary YouTube videos); fact-checked to avoid scoping something inaccessible. The real, already-existing equivalent for "skip the fluff" is the community-maintained **SponsorBlock** API (free, public, crowdsourced sponsor/intro/outro segment timestamps for millions of videos) — worth combining with this item's LLM-derived chapter markers: query SponsorBlock by video ID first (skip segments if data exists), fall back to the transcript-derived chapters above when it doesn't.
- **Source:** 2026-09-07 beta feedback report; `lib/data/remote/ai/youtube_transcript_fetcher.dart` (existing, timing data discarded), `lib/shared/widgets/in_app_youtube_player.dart` (existing embedded player, confirmed `seekTo`-capable via `youtube_player_flutter`).

### B36 — Local `.rivox` encrypted export/import (no-cloud sharing)

- **Status:** backlog (proposed 2026-09-07)
- **Area:** learn, sharing, privacy
- **MoSCoW:** Should have
- **Why it exists:** Beta feedback: "Let us export a lightweight, encrypted file format (.rivox) to share custom modules with classmates over WhatsApp without cloud syncing." Unlike B13/B18/B31 (which need accounts + a backend), this is genuinely **cloud-free** and fits this app's existing "local-first, privacy-focused" positioning better than any other item in this report — a real differentiator, not a compromise. `quiz_repository.dart:350`'s existing `exportData()` already produces a JSON shape of sessions/questions (currently a raw local-backup format, not a shareable/encrypted artifact) — a real, if partial, starting point.
- **Suggested next step (structural plan):**
  - **File format:** a `.rivox` file = AES-256-GCM-encrypted JSON payload (a learning path or quiz, in the same shape `exportData()`/`LearningPath`'s existing serialization already produces — do not invent a new schema, reuse the existing `toJson()` on whatever model is being shared) + a small unencrypted header (format version, content type, a human-readable title) so the app can show "Alice shared 'Intro to Biology' with you" before decrypting.
  - **Encryption:** derive a key from a short share-code (e.g. a 6-digit PIN shown to the sharer, entered by the receiver) via PBKDF2 — avoids needing any server-issued key exchange; add the `cryptography` or `pointycastle` package (check for an existing crypto dependency first — `secure_key_storage.dart` may already pull one in for the BYOK key storage, reuse it rather than adding a second crypto library).
  - **Export flow:** a "Share module" button on `path_detail_screen.dart` → generates the PIN, writes the `.rivox` file to a temp path, shares it via the **already-present** `share_plus` (`SharePlus.instance.share(ShareParams(files: [...]))`) — WhatsApp/any share-sheet target works automatically, no WhatsApp-specific integration needed.
  - **Import flow:** register `.rivox` as a recognized file type for `FilePicker.pickFile` on an existing "Import" entry point (or a new one on `my_library_screen.dart`/`path_detail_screen.dart`), prompt for the PIN, decrypt, validate the header's content type, then insert via the existing Isar repository write path for that content type (no new schema — imported content becomes an ordinary local `LearningPath`/`Quiz`, indistinguishable from one generated locally).
- **Risks:** A weak PIN is brute-forceable if the file is intercepted — acceptable for the stated "share with a classmate over WhatsApp" threat model (casual sharing, not a security-hardened credential store), but must not be described as more secure than it is. Must validate imported content strictly (author-controlled JSON is untrusted input) before writing to Isar — reuse whatever validation `exportData()`'s import counterpart (if one exists) or the existing quiz-import path already does, rather than trusting the decrypted JSON blindly.
- **Source:** 2026-09-07 beta feedback report; `lib/data/local/repositories/quiz_repository.dart:350` (`exportData()`, existing partial JSON export); `pubspec.yaml` (`share_plus` already present); app's own "local-first" README positioning.

### B37 — Voice interview: speech-delivery feedback + persona-aware scoring

- **Status:** backlog (proposed 2026-09-07)
- **Area:** career, ai, voice
- **MoSCoW:** Should have
- **Why it exists:** Beta feedback: "Give us feedback on our speaking pace and filler words, and let us choose different interviewer personas (Strict vs. Friendly)." Verified B2 ("Voice interview agent," partial/STT-shipped) is transcribe-then-score-**text**-only: `whisper_stt_service.dart:344-361` requests `response_format: 'json'` and reads only `data['text']` — NVIDIA's Whisper endpoint supports `verbose_json` for word/segment timestamps, but it's never requested, so **no timing data exists even latently**; `interview_rubric_scorer.dart:26-93` scores substance/relevance only, with zero pace/WPM/filler-word logic anywhere. `voice_interview_speech_coaching.dart` is static canned copy, not derived from actual speech. Persona **does** exist and is real (`InterviewPersona` `hr`/`tech`, `interview_persona.dart:2-16`, wired through `PromptBuilder._interviewInstruction`) — but it only changes which questions get generated, never flows into the scorer, so "Strict vs. Friendly" tone in feedback doesn't exist today despite persona selection already being live.
- **Suggested next step:**
  - **Delivery metrics (the larger half of this item):** switch the Whisper request to `response_format: 'verbose_json'` in `whisper_stt_service.dart`, parse the returned segment/word timestamps, and compute: words-per-minute (word count ÷ total spoken duration from first-to-last segment), filler-word count (simple regex/wordlist match against "um," "uh," "like," "you know" on the transcript — cheap, no ML needed), and total pause time (gaps between segments above a threshold). Surface these as a small stats row on the results screen alongside the existing rubric score — additive, not a replacement for the substance score.
  - **Persona-aware scoring:** thread `interviewPersona` (already available at the call site, `voice_interview_hub_screen.dart:157`) into `InterviewRubricScorer.scoreOpenAnswers`, and add a persona-conditioned tone instruction to the judge prompt (`interview_rubric_scorer.dart:55-66`) — e.g. `strict` = terse, critical, no encouragement; `friendly` = warm, leads with a strength before a critique. This only changes the LLM prompt's tone instruction, not the underlying rubric criteria — low risk to scoring accuracy.
  - Do not add "Strict vs Friendly" as new personas distinct from the existing `hr`/`tech` — reframe the existing personas' scoring tone instead, or add a separate, orthogonal `ScoringTone` enum if the user wants persona (question mix) and tone (feedback style) to vary independently — a genuine design decision worth confirming before implementing, not assumed here.
- **Risks:** Filler-word detection via wordlist is crude (false positives on words used meaningfully, e.g. "like" as a verb) — set expectations as directional feedback, not a precise linguistic analysis. `verbose_json` may increase response payload size/latency slightly — measure before shipping.
- **Google-advice cross-check (2026-09-07):** External "how Google would build this" feedback independently named the same delivery-metrics idea (pace, filler words) plus an additional "overall confidence level" metric and a fully real-time (Gemini Live-style) conversational interview rather than record-then-score. Confidence-level scoring is a genuine stretch goal on top of this item — if pursued, derive it from a combination of pace variance, filler-word density, and pause frequency already computed above (a simple weighted heuristic, not a new ML model) and present it as a rough directional indicator, not a precise psychological measurement. The fully real-time conversational format is a much larger, separate undertaking — see new **B42**, not folded in here, since it needs a streaming STT/TTS pipeline this app doesn't have (current Whisper integration is batch-only, confirmed in B2).
- **Source:** 2026-09-07 beta feedback report; `lib/core/services/whisper_stt_service.dart:344-361`, `lib/data/remote/ai/interview_rubric_scorer.dart:26-93`, `lib/core/constants/interview_persona.dart:2-16`, `lib/data/remote/ai/prompt_builder.dart:103-127` (all confirmed via direct read this session).

### B38 — Flashcards already use SM-2 (superset of Leitner) — no algorithm change

- **Status:** backlog (proposed 2026-09-07)
- **Area:** learn, flashcards
- **MoSCoW:** Won't have (algorithm)
- **Why it exists:** Beta feedback: "Upgrade the new flashcards to automatically handle Spaced Repetition (Leitner system)." Verified B11 (done 2026-08-29) already ships a textbook **SM-2** implementation, not a simpler fixed-interval system: `lib/data/local/models/flashcard.dart:28-35` stores `easeFactor` (default 2.5), `intervalDays`, `repetitions`, `nextReviewAt`; `flashcard_repository.dart`'s `SpacedRepetition` class implements the standard SM-2 ease-factor formula and 1/6/interval×EF progression. SM-2's continuous per-card ease/interval model is functionally a **superset** of Leitner's simpler discrete-box approximation of the same idea — implementing Leitner on top would be a regression in scheduling sophistication, not an upgrade. **This beta ask is already satisfied, and the literal request (swap to Leitner) should not be implemented.**
- **Suggested next step:** No algorithm change. If the real underlying want is *visibility* into the schedule (Leitner's boxes are more visually intuitive than an opaque ease-factor number), consider a small presentation-only addition: show "Reviewing again in {intervalDays} days" and a coarse difficulty label (e.g. derived from `easeFactor` bands: "hard"/"medium"/"easy") on the flashcard review UI, instead of changing the underlying scheduling math. Purely additive UI if pursued — no schema or repository change needed (`easeFactor`/`intervalDays` already exist).
- **Risks:** None from not acting. The risk this item guards against is a future pass literally implementing "Leitner" as requested, which would replace already-good SM-2 with a strictly less sophisticated system.
- **Source:** 2026-09-07 beta feedback report; `docs/BACKLOG.md` B11 (already shipped); `lib/data/local/models/flashcard.dart:28-35`, `lib/data/local/repositories/flashcard_repository.dart` `SpacedRepetition` class (verified via direct read this session).

### B39 — Learning path visual mind-map view

- **Status:** backlog (proposed 2026-09-07)
- **Area:** learn, ux
- **MoSCoW:** Could have
- **Why it exists:** Beta feedback: "Turn the modules into a visual, interactive mind map." Verified `path_detail_screen.dart:374-618` renders modules as a plain `ListView` of expandable `AppCard`/`ListTile` rows — no graph/canvas/positioning logic exists, and a repo-wide search for "mind map"/"graph"/"TreeView"/"node" in `lib/` returns zero matches. This is a large, genuinely greenfield UI gap with no existing groundwork (no node/edge model, no graph-rendering package) — the highest-effort, most speculative item in this report, appropriately Could have rather than Should/Must.
- **Suggested next step:** Do not build a from-scratch graph-layout engine. Evaluate an existing package first (e.g. `graphview` on pub.dev, force-directed or tree layout) against this app's actual data shape — a learning path's modules are already a linear/sequential dependency chain (each step locks until the previous completes, per `path_detail_screen.dart`'s existing lock/check/play icon logic), not a general graph, so a **tree** layout (not a free-form mind map) is the honest fit for the data that exists today. Scope v1 as an alternate view toggle next to the existing list (not a replacement — the list view works and is simpler to navigate linearly), reusing the same step/lock/progress data already loaded, no new Isar schema.
- **Risks:** Real UX risk of building a novelty visualization that's harder to use than the existing linear list for actually working through a path in order — mitigate by keeping it an optional view toggle, not a replacement, and by being honest that the underlying data is a sequential chain, not a rich graph, so the "mind map" framing may not fit as well as the beta user imagines once built.
- **Source:** 2026-09-07 beta feedback report; `lib/features/learn/presentation/path_detail_screen.dart:374-618` (confirmed linear list, no graph structure); repo-wide grep confirming no existing graph/mind-map code.

### B40 — On-device AI via ML Kit GenAI APIs (Gemini Nano / AICore)

- **Status:** backlog (proposed 2026-09-07)
- **Area:** ai, llm, platform
- **MoSCoW:** Could have
- **Why it exists:** "How Google would build this" feedback pitched running generation "entirely offline" via Gemini Nano for zero cost/latency and total privacy. Fact-checked: Google's real, public path for this is **ML Kit GenAI APIs**, backed by Gemini Nano through Android **AICore**, available to third-party Android apps on supported devices (Pixel and select other flagship devices with an AICore-capable chip — not universal across all Android hardware). Important scope correction: unlike the pitch's implication of a general "generate quizzes / summarize / build study paths" model, ML Kit GenAI ships as a **fixed set of task-specific APIs** (summarization, proofreading, rewriting, image description) as of this writing — there is no general instruct/chat endpoint that reliably emits this app's structured JSON quiz/path schema the way Built-in AI (NVIDIA NIM) does today. So this is a real, on-device, free, private option for **some** sub-tasks, not a drop-in replacement for the whole generation pipeline.
- **Suggested next step:** Evaluate ML Kit GenAI's **Summarization** API specifically as an on-device alternative for one already-existing task: Library content summarization / module summarization (currently server-side via `learning_orchestrator.dart`'s LLM calls) — a good fit since summarization is exactly one of the fixed task types offered. Do not attempt to force quiz-JSON generation through it; that stays on Built-in/BYOK (`LlmManager`) until/unless Google ships a general on-device instruct API. Device-gate the feature (check AICore availability at runtime) and fall back to the existing cloud path transparently when unavailable — never a hard requirement.
- **Risks:** Device fragmentation (AICore isn't on most Android phones yet) means this can only ever be a bonus fast-path, not a primary architecture, until availability broadens. Two parallel summarization code paths (on-device + cloud) add maintenance surface — worth it only if the on-device path meaningfully saves cost/latency for the subset of users who have it.
- **Source:** 2026-09-07 "how Google would build this" feedback; `docs/BACKLOG.md` B3 (existing blocked on-device attempt via MLC, a different unrelated blocker); Google ML Kit GenAI APIs public documentation (Summarization/Proofreading/Rewriting/Image Description, AICore-backed, as of this app's knowledge cutoff — re-verify current API surface before implementing, as this is an actively evolving Google product area).

### B41 — Google Drive/Workspace folder sync for auto-flashcard generation

- **Status:** backlog (proposed 2026-09-07)
- **Area:** learn, library, integrations
- **MoSCoW:** Could have
- **Why it exists:** "How Google would build this" feedback pitched pointing the app at a Google Drive folder so lecture Slides/Docs auto-become flashcard decks in the background. Verified this app's only content-ingestion path today is manual file upload (`file_picker`, `.txt`/`.md`/`.pdf` — see B34's research) — there is no cloud-folder monitoring of any kind. Unlike B13 (Rivox's own accounts/cross-device sync, which needs a real backend), this specific integration does **not** require Rivox to have its own accounts system: a user can grant Drive read-only access via **Google Sign-In** purely for this feature, with the OAuth token used for direct client-side Drive API calls — no Rivox backend involved, consistent with the app's local-first stance (the content still lands in local Isar, same as any other ingested source).
- **Suggested next step (structural plan):**
  - **Packages:** `google_sign_in: ^6.x` (auth) + `googleapis: ^13.x` (official Dart-maintained Drive API v3 client) — both well-established, Google-maintained packages, not third-party wrappers.
  - **Scope:** request the narrowest viable Drive scope (`drive.readonly` or, better, `drive.file` if only app-picked files/folders need access, per Google's own least-privilege guidance) — avoid requesting full Drive access.
  - **New screen:** a "Connect Google Drive" entry point in `my_library_screen.dart` (alongside the existing "Upload file" button) → Google's folder picker (Drive Picker API) to choose one folder to monitor.
  - **Content conversion:** Google Slides/Docs support direct "export as" via the Drive API (`files.export` with `mimeType: text/plain` or `application/pdf`) — convert to plain text the same way, then feed into the **existing** Library ingestion path (reuse whatever chunking/embedding step already runs on uploaded `.txt`/`.pdf`, no new pipeline).
  - **"Background monitoring":** true always-on folder watching needs a push/webhook mechanism (Drive API supports `changes.watch`, but that requires a reachable server endpoint — this app has none). A more honest v1: periodic check (e.g. on app foreground, or a daily background task via the existing `background_daily_tasks.dart` pattern) for new/changed files in the selected folder via `files.list` with a `modifiedTime` filter, not real push notifications.
- **Risks:** OAuth token storage/refresh must go through the existing secure-storage pattern already used for BYOK keys (`secure_key_storage.dart`), not a new ad hoc mechanism. Google API quota/rate limits apply per-project — monitor usage if this scales. Slides/Docs → plain-text export loses visual structure (diagrams, images) — set expectations that this captures text content, not visual slide layout.
- **Source:** 2026-09-07 "how Google would build this" feedback; `lib/features/library/presentation/my_library_screen.dart:99-101` (confirmed manual-upload-only today); `lib/data/secure/secure_key_storage.dart` (existing secure-storage pattern to reuse).

### B42 — Realtime conversational voice interview (Gemini Live-style)

- **Status:** backlog (proposed 2026-09-07)
- **Area:** career, ai, voice
- **MoSCoW:** Won't have (this cycle)
- **Why it exists:** "How Google would build this" feedback pitched a fully real-time, bidirectional voice conversation — the AI interrupts, asks follow-ups live, and reads emotional cues — versus today's (and B37's planned) record-a-full-answer-then-score model. This is a fundamentally different, much larger architecture: it needs a **streaming** speech-to-text + streaming LLM + low-latency text-to-speech pipeline operating in a continuous loop, not a batch transcribe-then-judge call. Confirmed this app's current voice stack is batch-only end to end — `whisper_stt_service.dart` calls NVIDIA's Whisper endpoint once per full recording (B2's own entry already notes "Whisper is batch not streaming"), and there is no TTS integration at all today.
- **Suggested next step:** Do not start before B37 (delivery-metrics + persona-aware scoring on the existing batch model) ships and proves the simpler, cheaper version is actually valued by users — real-time voice infra (a streaming STT provider, a low-latency LLM turn-taking loop, and a TTS voice) is a materially larger cost and engineering lift than anything else in this batch, and BYOK/NVIDIA-NIM-equivalent realtime endpoints would need to be researched fresh (not assumed available on the current provider stack). If pursued later, treat it as its own dedicated research spike before any implementation commitment.
- **Risks:** Real, ongoing per-minute cost for any realtime voice API (materially higher than batch STT); latency/quality of open realtime voice APIs varies significantly by provider; a half-working "realtime" experience (laggy, talks over the user) is worse than the current clean record-then-score flow — this is the reason it's Won't have this cycle rather than Could have.
- **Source:** 2026-09-07 "how Google would build this" feedback; `docs/BACKLOG.md` B2 (existing batch-only Whisper confirmation), B37 (the prerequisite simpler version); `lib/core/services/whisper_stt_service.dart` (confirmed batch-only call pattern).

### B43 — Lock-screen "answer to unlock" gamification

- **Status:** backlog (proposed 2026-09-07)
- **Area:** gamification, platform
- **MoSCoW:** Won't have (not feasible)
- **Why it exists:** "How Google would build this" feedback pitched a lock-screen widget that requires answering a quiz question to unlock the phone, turning doom-scrolling into micro-learning. Fact-checked: modern Android does **not** expose a public API letting a regular third-party app gate device unlock behind in-app content — that level of control over the lock/unlock flow is reserved for system-level components and Device Admin/Kiosk-mode APIs meant for MDM and parental-control use cases, not a mainstream consumer app, and Play Store policy would very likely reject (or at minimum heavily scrutinize) an app that interferes with the standard unlock flow. This is the one item in this "how Google would build it" report that isn't actually buildable by any third party, including a well-resourced one, without Google building new OS-level plumbing first.
- **Suggested next step:** Do not build an unlock gate. The buildable version of the same underlying goal (a glanceable, low-friction daily-question surface) is a **regular Android home-screen widget** — already proposed and scoped as **B19** ("Home-screen widget (streak / daily quiz)") — showing "today's question" and letting the user tap through to answer, without blocking or gating anything. Point any future work here at B19 instead.
- **Risks:** None — this item is intentionally Won't have. The risk it guards against is a future pass attempting to build a fake "unlock gate" via an always-on-top overlay (Android's `SYSTEM_ALERT_WINDOW`/"draw over other apps" permission) to simulate the effect — that pattern is exactly the kind of aggressive overlay behavior Play Store policy and Android's own permission review process specifically target, and would put the entire app at review risk. Explicitly do not attempt an overlay-based workaround.
- **Source:** 2026-09-07 "how Google would build this" feedback; `docs/BACKLOG.md` B19 (the buildable equivalent); Android public API surface / Play Store developer policy on device-control permissions (general platform knowledge, not a specific doc in this repo).

### B44 — Screen-time-aware streak nudge via Android UsageStatsManager

- **Status:** backlog (proposed 2026-09-07)
- **Area:** gamification, platform, retention
- **MoSCoW:** Could have
- **Why it exists:** "How Google would build this" feedback pitched syncing with "Google Fit / Digital Wellbeing" to nudge users who are scrolling social media instead of protecting their study streak. Fact-checked: this claim is imprecise — **Google Fit** is a fitness/health-activity API (steps, workouts) with no per-app screen-time data, and there is no public "Digital Wellbeing sync API" for third-party apps either. The real, correct mechanism for what's actually being asked (how long has the user spent in which apps recently) is Android's own **`UsageStatsManager`**, gated behind the special `PACKAGE_USAGE_STATS` "Usage Access" permission (user-granted manually in system Settings, not a standard runtime permission prompt) — a genuinely different, if less elegant, path than the pitch implied, but a real and buildable one.
- **Suggested next step:** Evaluate a Flutter plugin wrapping `UsageStatsManager` (check pub.dev for current maintenance status/API shape before committing — package landscape here changes; do not assume a specific package name without verifying it's current) or a custom platform channel if none is well-maintained. Flow: user opts in explicitly (Settings toggle, clearly explaining what "Usage Access" grants and why) → app periodically checks recent foreground time for a small user-configured "distracting apps" list → if a configurable threshold is crossed while today's study streak/daily quiz is still incomplete, fire a local notification via the existing `NotificationService` pattern (mirrors B29/support-nag's channel approach) nudging back to the app. Must be opt-in only and clearly explained — Usage Access is a sensitive permission users are rightly cautious about granting.
- **Risks:** `PACKAGE_USAGE_STATS` is a sensitive, manually-granted permission — over-asking for it (or asking before explaining why) risks user trust and uninstalls; must be strictly opt-in with a clear explanation, never a blocking gate. Google Play has specific policy requirements around apps requesting this permission — review current Play Console policy on "Usage Access" before shipping, not just the Android API docs. iOS has no equivalent API at all (Apple's Screen Time API is not exposed to third-party apps this way) — this item is Android-only by nature, not a cross-platform gap to fix later.
- **Source:** 2026-09-07 "how Google would build this" feedback (fact-checked: no such Google Fit/Digital Wellbeing sync API exists); `docs/BACKLOG.md` B19/B29 (existing local-notification pattern to reuse); Android `UsageStatsManager` public API (general platform knowledge).
