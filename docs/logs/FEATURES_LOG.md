# Features Log

## 2026-09-08 — Learner Memory: daily-refreshed context snapshot for chat

- **Type:** feature
- **Area:** chat, personalization
- **Files:** new `lib/core/services/learner_memory.dart`, `lib/core/services/learner_memory_service.dart`, `lib/core/services/learner_memory_scheduler.dart`, `test/learner_memory_service_test.dart`; additive edits to `lib/features/onboarding/presentation/splash_screen.dart`, `lib/core/providers/home_refresh.dart`, `lib/features/chat/presentation/chat_screen.dart`, `lib/data/remote/ai/chat_service.dart`.
- **Problem / Goal:** User asked for a consolidated "memory" — study goals, library content, quiz pattern, daily article history — refreshed once a day instead of recomputed on every run, explicitly not while a generation job is busy, and force-refreshed when the learner asks about their own recent activity. Confirmed with the user the quiz-pattern piece should be a local statistical rollup (no AI call, no network, no quota cost).
- **Solution:** `LearnerMemoryScheduler` mirrors `DailyQuizScheduler`'s exact shape (calendar-day-keyed JSON sidecar, `_running` guard, best-effort/never-throws) with one added guard: skip while `GenerationJobService.isBusy`, without marking the day done, so it retries at the next opportunity instead of missing a day. `LearnerMemoryService.compute()` assembles the snapshot entirely from data this app already computes elsewhere — goals via `LearnerRepository`, library via `KnowledgeRepository.allEnabledSources()`, quiz pattern (per-topic average accuracy, streaks, frequently-missed topics) via the same `QuizSession`/`QuizRepository.getWrongQuestions()` data `StatsRepository`/chat's own summary already use, recent daily content via the existing `NotificationHistoryStore` — no new tracking, no LLM call. Wired to refresh on app bootstrap (`splash_screen.dart`, same fire-and-forget pattern as the other daily schedulers) and on day rollover (`home_refresh.dart`). Chat force-refreshes it (still respecting the busy-guard) when a cheap local keyword heuristic detects a "how am I doing" / "my progress" / "what did I get wrong" style question, then passes the cached snapshot into `ChatService.sendMessage` as a new, additive prompt section — the existing recent-quiz/wrong-answer summary logic in `chat_service.dart` is untouched.
- **Regression risks:** None expected — entirely additive (new optional param, new scheduler call sites); a failure anywhere in the compute/persist path is caught and simply retried later, never surfaced to the user.
- **Verified:** New unit tests (15) for the extracted pure aggregation functions (`topicAccuracyFrom`, `computeStreaks`, `frequentlyMissedFrom`) and the scheduler's skip-decision logic (`shouldSkip`) — no live Isar/Riverpod needed, mirroring `SpacedRepetition.review`'s pure-function-extraction precedent in `flashcard_repository.dart`. `flutter analyze` (0 new issues, 35 pre-existing baseline); `flutter test --exclude-tags=live` (195 passed/1 skipped, up from 180).

## 2026-09-07 — Website blog (B25 first batch) + second mini game (2048)

- **Type:** feature
- **Area:** hosting (website), seo, content
- **Files:** new `hosting/blog/index.html` + 3 post pages (`byok-ai-quiz-generation/`, `local-first-flashcards-spaced-repetition/`, `ai-quiz-competitive-exam-prep/`), new `hosting/games/2048/index.html`, new `hosting/games/vendor/2048/*` (vendored third-party), `hosting/games/index.html`, `hosting/sitemap.xml`, nav updates across `hosting/index.html`/`privacy`/`terms`/`games`/`games/dino`.
- **Problem / Goal:** User asked to add blog content and more mini games. Blog content is backlog B25's own first-batch scope ("3-5 pages targeting the highest-winnability phrases... each a real, substantive page, not thin SEO filler") — used the three long-tail phrases B25 itself already identified as winnable (BYOK AI quiz generation, local-first flashcards, AI quiz for competitive exams) rather than inventing new topics.
- **Solution:**
  - **Blog:** 3 real, substantive posts (each explains the underlying concept in its own right — how BYOK pricing works, how the SM-2 spaced-repetition algorithm works, what AI practice quizzes are and aren't good for in competitive-exam prep — with a genuine FAQ section each, not just marketing copy), plus a `/blog` hub page listing them as cards (reusing the existing `.game-grid`/`.game-card` styles, no new CSS needed). Each post carries its own canonical/OG/Twitter tags and a `BlogPosting` JSON-LD block. `Blog` added to the site nav on every existing page.
  - **Second mini game (2048):** vendored, unmodified, from `gabrielecirulli/2048` (MIT License — the same license family/verification rigor as the existing Dino Run game). Fetched directly from the canonical GitHub repo (all 10 JS files + stylesheet + LICENSE, syntax-checked with `node --check`), matching this app's own established "genuinely open-source, verified license" bar. The game's own `keyboard_input_manager.js` already handles touch/swipe natively — no mobile-compat shim needed, unlike Dino Run. One necessary adaptation (not to the vendored files themselves, only to the page's own copy of the widget's static markup): renamed one inner `<p class="game-intro">` to `.puzzle-intro` to avoid a real CSS class collision with the site's own `.game-intro` (a section-level class used site-wide on every mini-game page) — confirmed via grep that no vendored JS references that class, so the rename is purely cosmetic and touches nothing functional. A non-disruptive native ad (`data-la-slot="gamesBottom"`, same slot Dino Run already uses) sits below the game, not overlaid on it.
  - Added both to `hosting/sitemap.xml` with today's date.
- **Regression risks:** None expected — all additive pages/nav links; Dino Run's own page/vendored files untouched.
- **Verified:** Programmatic tag-balance check (all touched/new pages, exactly one `<h1>` each), JSON-LD parse-validity on all 3 new blog posts, internal-link resolution check (every `href` across all 10 touched/new pages resolves to a real route), and `node --check` syntax validation on all 10 vendored 2048 JS files. No visual/browser test possible from this environment.

## 2026-09-07 — Real Firebase Analytics (GA4) integration

- **Type:** feature
- **Area:** analytics, privacy
- **Files:** `lib/core/services/app_bootstrap.dart`, `lib/core/router/app_router.dart`, `lib/features/settings/presentation/settings_screen.dart`, `lib/l10n/app_en.arb` + `app_localizations_en.dart`, `pubspec.yaml`/`pubspec.lock`.
- **Problem / Goal:** User noticed the Firebase console's Analytics dashboard was never updating. Root cause confirmed by direct search: `firebase_analytics` was never a dependency and zero `FirebaseAnalytics`/`logEvent` calls existed anywhere — the app's only existing Firebase-bound telemetry is a separate, custom, already-opt-in anonymized event stream to Firestore (`anon_events`, see `anon_analytics_sync.dart`), not the real GA4 SDK the console dashboard actually reads from. This wasn't a regression; the integration had simply never been built.
- **Solution:** Added `firebase_analytics` and wired a `FirebaseAnalyticsObserver` into `appRouter`'s `observers` for automatic screen-view tracking. Collection is gated behind the exact same "Help improve Rivox" opt-in (`LearnerProfile.helpImproveOptIn`) the existing anonymized telemetry already uses — `setAnalyticsCollectionEnabled` is set from the stored preference at startup (`app_bootstrap.dart`, best-effort, never blocks boot) and kept live-in-sync from the same Settings toggle handler that already existed. Defaults to **off** until the learner opts in, consistent with this app's local-first/opt-in-by-default privacy stance — the SDK's own collection gate means the router observer can stay always-registered with zero network effect while disabled. Updated the toggle's subtitle copy (English) to honestly reflect that it now also covers app usage analytics, not just the narrower anonymized signals it described before.
- **Regression risks:** None expected for users who don't opt in (default state, matches today's behavior exactly). For users who do opt in, this sends standard Firebase Analytics screen-view/event data to Google — a real, disclosed change in what "Help improve Rivox" means going forward.
- **Verified:** `flutter analyze` (0 new issues, same 35 pre-existing project-wide); `flutter test --exclude-tags=live` (180 passed/1 skipped, no regressions).

## 2026-09-07 — Agentic RAG chat: propose-and-confirm quiz/path generation, all-library grounding, learning-history awareness

- **Type:** feature
- **Area:** chat, ai, ads
- **Files:** `lib/data/remote/ai/chat_service.dart`, new `lib/data/remote/ai/chat_reply_result.dart`, `lib/features/chat/presentation/chat_screen.dart`, new `lib/features/chat/presentation/chat_action_chip.dart`, new `lib/features/chat/presentation/chat_generation_status.dart`, new `lib/shared/widgets/built_in_chat_quota_dialog.dart`, `lib/data/local/repositories/knowledge_repository.dart`, `lib/core/services/generation_job_service.dart`, `lib/data/remote/ai/ai_output_gate.dart`, `lib/core/providers/app_providers.dart`; new tests `test/chat_reply_result_test.dart` + additions to `test/chat_service_test.dart`.
- **Problem / Goal:** User asked chat to work "agentic" — able to trigger real quiz/learning-path generation and read across all uploaded library content — plus check the generation quota (offering to watch an ad if exhausted), show the chat message quota, add a chat avatar, and ground answers in the user's own quiz/answer history.
- **Solution:**
  - **Propose-then-confirm actions:** chat's JSON envelope extended from `{"reply": "..."}` to include an optional `action` (`proposeQuiz`/`proposePath` + topic/params). The model can only *propose* — an inline `ChatActionChip` on the assistant bubble is the only thing that can actually start a generation, persisted via the previously-unused `ChatMessage.contextRef` field (no schema change). Tap sequence mirrors `create_quiz_screen.dart`/`learn_screen.dart`'s real pre-flight exactly: `job.isBusy` check, connectivity, goal-required check, prompt-firewall sanitize, a cheap synchronous `TopicGoalRelevanceGate.evaluate` (not the screens' async LLM-backed guardrail — a deliberate v1 scope reduction, since a blocking modal doesn't translate to an inline chip), then **explicit `BuiltInAiQuota.instance.ensureCanGenerate()`** — critical, since neither `GenerationJobService.startQuiz`/`startPath` nor chat's own pipeline call enforces this quota on their own (chat's own LLM call deliberately bypasses it via `skipQuota: true`, since chat replies are metered separately). On exhaustion, shows the existing `showBuiltInQuotaDialog` (watch-ad-to-unlock) and retries on success, exactly like the two existing screens.
  - **`GenerationJobService.startPath` gained an optional `focus` param** (previously hardcoded `_topic = 'Learning path'` and never forwarded a topic to the orchestrator, which already accepted one) — additive, default `null` preserves `learn_screen.dart`'s existing call site.
  - **All-library grounding for chat specifically:** new `KnowledgeRepository.allEnabledSources()`/`allEnabledSourceUuids()`/`allEnabledSourceTypes()` (no `goalMode` filter — confirmed goal-mode scoping is a relevance mechanism, not the actual consent boundary, which is a separate global `AiConsentGate.sendChunksToProvider` toggle). Chat now calls these instead of the goal-scoped variants; quiz/path/GoalAgent generation's existing goal-scoped calls are untouched.
  - **Learning-history awareness:** new `ChatService._buildLearningHistorySummary()` folds the learner's recent completed quizzes (topic + accuracy, via existing `QuizRepository.getRecent`) and recent wrong answers (via existing `QuizRepository.getWrongQuestions`) into the prompt, so chat can answer "what did I get wrong?" / "how am I doing on X?" without the library-RAG path being involved at all.
  - **Chat's own quota, applied consistently:** a new `showBuiltInChatQuotaDialog` (mirrors `built_in_quota_dialog.dart`'s exact shape/watch-ad flow, targeting `BuiltInChatQuota` instead) replaces the previous generic error message when chat's own daily message quota is exhausted, with retry-on-unlock. A slim banner at the top of the chat screen shows remaining messages today (hidden entirely for BYOK users, who aren't limited by this quota).
  - **Chat avatar:** a small circular `rivox_logo.png` avatar next to the "Chat" title and on every assistant bubble/typing indicator (falls back to a generic icon if the asset fails to load).
  - **`AiOutputGate` allowlist parity:** appended `"action"` to the JSON-recovery root-key/preferred-key lists (two one-line appends) so the new envelope shape gets the same noisy-output recovery robustness as `questions`/`steps`/etc.
- **Regression risks:** None expected for existing generation flows (quiz/path/GoalAgent's goal-scoped RAG calls and `startPath`'s existing call site are byte-for-byte unchanged); `ChatService.sendMessage`'s return type changed from `String` to `ChatReplyResult` but it has exactly one caller (`chat_screen.dart`), updated in the same change.
- **Known limitation:** cannot verify the model's actual live proposal behavior without spending real API quota — same caveat as when chat originally shipped.
- **Verified:** `flutter analyze` (0 new issues, same 35 pre-existing); `flutter test --exclude-tags=live` (180 passed/1 skipped, up from 167 — new coverage for the discriminated JSON envelope's parsing/degradation and `ChatProposedAction`'s defensive `fromJson` decoding).

## 2026-09-07 — Optional encrypted cloud backup/restore (backlog B13)

- **Type:** feature
- **Area:** accounts, infra
- **Files:** new `lib/data/remote/auth/auth_service.dart`, `lib/data/remote/backup/cloud_backup_service.dart`, `lib/data/remote/backup/backup_crypto.dart`, `lib/data/local/models/cloud_backup_state.dart` (+ generated), `lib/data/local/repositories/cloud_backup_repository.dart`, `lib/data/local/repositories/study_repository.dart`, `lib/core/providers/backup_providers.dart`, `lib/core/services/backup_flags.dart`, `lib/features/settings/presentation/backup_settings_screen.dart`, `lib/features/settings/presentation/backup_passphrase_sheet.dart`, `storage.rules`, `test/backup_crypto_test.dart`; additive edits to `pubspec.yaml`, `lib/data/local/isar_service.dart` (schema v1→2), `lib/core/router/app_router.dart` (+1 route), `lib/features/settings/presentation/settings_screen.dart` (+1 entry point, +sign-out on full reset), `firestore.rules`, `firebase.json`; new export/import methods on `learner_repository.dart`, `flashcard_repository.dart`, `chat_repository.dart`, `knowledge_repository.dart`.
- **Problem / Goal:** Ship backlog B13 — all user data (quiz history, learning paths, flashcards, chat, library uploads, streaks) lived in local-only Isar with no way to survive an uninstall or lost device. Needed an optional, privacy-preserving way to back it up.
- **Solution:** Verified two of B13's original assumptions against real code before building — Firebase Auth was not actually in the stack (only core/Firestore/Crashlytics were) and no `request.auth.uid`-scoped Firestore rule pattern existed anywhere — so both were built fresh rather than "extended." Google Sign-In only (targets the current async `google_sign_in` 7.x `GoogleSignIn.instance.initialize()`/`.authenticate()` API, not the older synchronous shape). Client-side end-to-end AES-256-GCM encryption (`package:cryptography`) with a PBKDF2-HMAC-SHA256-derived key from a user-chosen passphrase — Rivox/Firebase can never read backup contents; the salt lives as cleartext Firestore metadata (safe — a salt's job is defeating rainbow tables, not secrecy) so the key is re-derivable from the passphrase alone on a new device. One combined encrypted JSON manifest (all in-scope collections + `LearningPath`'s out-of-Isar step files) uploaded to Firebase Storage (`users/{uid}/backups/latest.enc`, since embedding-vector-heavy library content easily exceeds Firestore's 1 MiB document limit); a small metadata doc in Firestore holds only KDF params/schema version/size. Manual-only "Create backup now" / "Restore from backup" (no continuous sync, no conflict resolution, per B13's own "ship backup before sync" guidance) — restore requires an explicit destructive-action confirmation dialog before wiping in-scope local data, and a dedicated `IsarService.clearBackupInScopeData()` deliberately distinct from the existing `clearLearningData()` so restore can't touch collections intentionally excluded from backup scope (derived/regenerable signal like `TopicNode`/`RecommendationItem`, plus BYOK provider configs and operational logs). Ships dark behind `kCloudBackupEnabled = false`.
- **Regression risks:** None expected for normal (non-opted-in) usage — every touched shared file gained only additive members, and the new screen/route are unreachable while the feature flag is off. The one edit to existing logic (`settings_screen.dart`'s full-reset branch now also signs out of the cloud-backup account) is scoped to the "full reset" choice only, not the "learning-only" reset.
- **Known follow-ups:** Firebase console setup (enable Google provider, register SHA-1/SHA-256, regenerate config files) is required before sign-in works on a device or before the flag can be flipped on — a manual step, not something achievable by code. PBKDF2 at the shipped 600k-iteration default measured ~3.4s per derivation on the dev machine — acceptable for an infrequent, explicit, progress-dialog-gated action, but worth reducing (documented fallback: 210k iterations) if real-device feedback says otherwise. App Check, backup version history/rollback, and an account-deletion flow remain explicitly deferred.
- **Verified:** `flutter analyze` (0 new issues, same 35 pre-existing info-level lints); `flutter test --exclude-tags=live` (161 passed/1 skipped, up from 156 — 5 new tests in `backup_crypto_test.dart` covering encrypt/decrypt round-trip, wrong-passphrase failure, tampered-blob failure, truncated-blob failure, and a PBKDF2 timing benchmark). The actual sign-in/upload/download flow cannot be exercised by the automated suite without live Firebase + a real Google account + the console setup above — not claimed as covered.

## 2026-09-07 — In-app RAG chat (backlog B1)

- **Type:** feature
- **Area:** chat, learn, ai
- **Files (all new except the additive registrations):** `chat_message.dart` (+ generated `.g.dart`), `chat_repository.dart`, `built_in_chat_quota.dart`, `chat_service.dart`, `chat_screen.dart`, `test/built_in_chat_quota_test.dart`, `test/chat_service_test.dart`; additive edits to `app_router.dart` (+1 route), `app_providers.dart` (+2 providers), `isar_service.dart` (+1 schema), `app_exception.dart` (+1 subclass); `app.dart` (new `ChatEntryFab` wired into the global `Stack` alongside `GenerationTopBanner`), new `chat_entry_fab.dart`.
- **Problem / Goal:** Ship backlog B1 — an in-app assistant for follow-up questions on the learner's modules, quizzes, and library content, without duplicating the existing hardened AI-provider/quota/RAG infrastructure.
- **Solution:**
  - **Scope (v1):** one continuous chat thread per user, not multiple named threads — matches B1's actual ask, avoids thread-management UI.
  - **Persistence:** new `ChatMessage` Isar collection (`role`, `text`, `createdAt`, optional `contextRef`), registered additively in `IsarService`'s schema list and `clearLearningData()`. `ChatRepository` mirrors `FlashcardRepository`'s shape (`getHistory`, `appendMessage`).
  - **LLM call:** reuses `LlmManager.completeJson` unchanged — the chat system prompt instructs the model to reply `{"reply": "..."}` only, and `ChatService.parseReply` extracts it. Deliberately avoids adding a parallel plain-text completion path across every provider file, since this project has invested heavily in the existing JSON-forcing path being reliable. RAG grounding, consent gating, and audit logging are delegated to the existing `AiRequestPipeline`/`RagContextBuilder` (`sanitizeTopic` → `ensureTokenBudget` → `buildRag` → `completeJson`), matching how the real call sites (`learning_orchestrator.dart`, `background_daily_tasks.dart`) already use the pipeline's granular methods rather than its unused `execute()` wrapper (which hardcodes the generation quota — incompatible with a separate chat quota).
  - **Quota:** new `BuiltInChatQuota` — structurally mirrors `BuiltInAiQuota` (rolling 24h window, persisted JSON sidecar, rewarded-ad bonus) but is fully independent, with its own state file (`built_in_chat_quota.json`) and allowance (8 free messages/day, +3 per rewarded ad, up to 3 ads/day). Never reads or writes `BuiltInAiQuota`'s state — the just-reduced 1/day generation quota is untouched by chat usage. BYOK providers are not limited by this, matching existing precedent.
  - **UI:** `ChatScreen` at route `/chat` — message bubbles, composer, loading/typing state, empty state.
  - **Global entry point:** a `ChatEntryFab`, wired once into `app.dart`'s existing `Stack` (added alongside item 3's `GenerationTopBanner` specifically to avoid touching Home/Learn/Settings screen files, which a parallel change in the same batch was editing). Listens to the app's `GoRouter` directly (`appRouter.routerDelegate`) to hide itself on onboarding, the chat screen itself, active quiz play, and the providers screen (which already has its own bottom-right FAB), and to clear the bottom nav bar's height on the Home/Learn/History shell routes.
- **Regression risks:** None expected — every touched shared file (`app_router.dart`, `app_providers.dart`, `isar_service.dart`, `app_exception.dart`) only gained new, additive members; no existing route, provider, schema entry, or exception was changed. `AppException` is a `sealed class`, so the new `BuiltInChatQuotaExceededException` had to live in `app_exception.dart` itself rather than a new file — the only non-new-file edit besides the registrations.
- **Verified:** `flutter analyze` (0 new issues), `flutter test --exclude-tags=live` (156 passed/1 skipped/0 failed, up from 145 before this item — 15 new tests: 9 for `BuiltInChatQuota` allowance/rollover/bonus math, 6 for `{"reply": "..."}` parsing including markdown-fence and non-JSON fallback cases). Live chat replies not tested end-to-end (would burn real API quota) — a known, disclosed limitation, not a gap in the automated suite.

## 2026-08-29 — ASO report fact-check; Play Store listing revision

- **Type:** enhancement
- **Area:** store listing (docs only — no app/website code)
- **Files:** `docs/store/LISTING.md`
- **Problem / Goal:** User pasted an externally-sourced "ASO strategy report" covering Play Store metadata, Android Vitals thresholds, "Firebase App Indexing," and Custom Store Listings. Several claims looked fabricated or outdated (particularly the Firebase App Indexing section, which cited what looked like a defunct API and a garbled file path) — fact-checked every concrete, falsifiable claim against Google's own current docs before acting on any of it, rather than implementing on faith.
- **Findings (fact-checked against real Google docs):**
  - **Confirmed real:** Android Vitals bad-behavior thresholds (crash rate <1.09%, ANR rate <0.47%, rolling 28-day window); target SDK 36 (Android 16) requirement by 2026-08-31; Custom Store Listings support up to 50 listings, and organic-search-term targeting for a CSL is a real (if misdescribed) option — it's a post-click conversion lever, not a ranking mechanism, contrary to how the report framed it.
  - **Confirmed fabricated/outdated:** "Firebase App Indexing" (the `Indexables.noteDigitalDocumentBuilder()`/`FirebaseAppIndex.getInstance().update()` code) — this library was discontinued years ago per Firebase's own docs; the real 2026 replacement is Android App Links + a `.well-known/assetlinks.json` file, not any Firebase SDK call. The report's claimed 50-character Play Store title limit is also wrong — the real limit is 30 (confirmed on Google's listing-requirements page), matching what this repo's docs already had.
  - **Target SDK already compliant:** confirmed `android/app/build.gradle.kts` uses Flutter's dynamic `flutter.targetSdkVersion`, and the installed Flutter 3.47.1 defaults it to 36 — no code change needed.
  - **App Links deliberately not implemented:** traced the app's actual `DeepLinkHandler`/router and found no in-app route matches the website's real pages (`/privacy`, `/terms`, `/games`, `/games/dino`, `/`). Enabling site-wide Android App Links as the report described would hijack real visitors' taps into a broken in-app screen instead of the actual page. User confirmed: skip for now, revisit only with a genuine shareable in-app destination and a narrower reserved path.
- **Solution:** Revised the Play Store title/short description in `docs/store/LISTING.md` toward differentiator keywords ("Rivox: AI Study Plan & Quiz" / "Generate personalized AI study plans, quizzes, and voice interview drills.") — both lengths verified programmatically against the real limits (27/30, 74/80) — consistent with the 2026-08-29 SEO audit's finding that "Learn Anything" branding collides with unrelated existing products. Documented the real, actionable Play Console items (CSL targeting, Vitals monitoring) as manual next steps, and explicitly recorded what NOT to implement so the fabricated advice doesn't get acted on later.
- **Regression risks:** None — docs only, no app or website code changed this pass.
- **Verified:** All 5 concrete claims individually checked against Google's own current documentation (not assumed); title/description candidate lengths measured programmatically, not eyeballed.

## 2026-08-29 — Website SEO audit and fixes

- **Type:** enhancement
- **Area:** hosting (website)
- **Files:** new `hosting/robots.txt`, `hosting/sitemap.xml`; `hosting/index.html`, `hosting/privacy/index.html`, `hosting/terms/index.html`, `hosting/games/index.html`, `hosting/games/dino/index.html`, `hosting/styles.css`
- **Problem / Goal:** User asked to audit and optimize the site to rank for "all relevant keywords." Verified via `site:learn-anything-43970.web.app` search that the site is **not indexed by Google at all** — the single biggest issue, ahead of any on-page optimization. Also found via keyword research that both brand terms collide hard with unrelated existing products: "Rivox" is used by ~6 other unrelated apps (GPS tracker, AI stock app, screen-time app, messenger, a medical trial), and "Learn Anything" collides with several existing learning-platform domains (learnanything.com/io/xyz) already ranking for that exact phrase. Bare-brand or generic head-term (#1) ranking is not realistic; long-tail feature-specific phrases are the winnable target.
- **Solution:**
  - Added `robots.txt` (with sitemap reference) and `sitemap.xml` (all 5 real pages) — neither existed before.
  - Every page: added a self-referencing `<link rel="canonical">`, Open Graph `og:url`, and Twitter Card meta tags (none existed before).
  - Homepage: added `MobileApplication` + `FAQPage` JSON-LD structured data (both validated as parseable JSON); added a real FAQ section (content sourced from `docs/store/LISTING.md`'s verified feature copy, mirrored exactly in the schema per Google's structured-data requirement); refined title/meta description to lead with winnable long-tail differentiators (BYOK AI quiz generation, AI voice interview practice) identified via keyword research, rather than only generic branding.
  - Games pages: refined title/description toward "free browser dino game / endless runner, no download" phrasing — a genuinely winnable, high-traffic-potential niche independent of and not diluting the core app keywords.
  - Fixed empty `alt` on two hidden (CSS `display:none`) sprite `<img>` tags on the Dino Run page.
- **Regression risks:** None — additive metadata/pages only, no existing markup removed. Canonical URLs point at the current live `learn-anything-43970.web.app` domain (the planned `learnanything.app` custom domain isn't DNS-live yet per `app_constants.dart`'s own comment) — must be updated site-wide once that domain attaches, otherwise canonicals would point to a URL that no longer matches the served page.
- **Verified:** JSON-LD blocks parsed with `JSON.parse` (both valid); HTML tag balance checked programmatically on all 5 touched pages; local static-server route check confirms `/robots.txt`, `/sitemap.xml`, and all pages resolve. Cannot verify actual Google indexing/rich-result eligibility from this environment — that requires Search Console (needs the site owner's Google account) after deploy.
- **Not done (needs the user):** Google Search Console verification + sitemap submission; attaching the `learnanything.app` custom domain; any larger content build-out (blog, comparison pages) that the research flagged as what actual top-ranking competitors do at scale — flagged as a follow-up decision, not started unprompted given the scope.

## 2026-08-29 — Website: native ads, opt-in support ad, mini games (Dino Run)

- **Type:** feature
- **Area:** hosting (website, not the app)
- **Files:** `hosting/ads.js`, `hosting/index.html`, `hosting/styles.css`, `hosting/privacy/index.html`, `hosting/terms/index.html` (cache-bust bump only), new `hosting/games/index.html`, `hosting/games/dino/index.html`, `hosting/games/vendor/trex/*` (vendored third-party)
- **Problem / Goal:** Add native ads and an opt-in "support Rivox" ad placement to the marketing site, plus a mini endless-runner game (Dino Run) with a non-disruptive ad below it.
- **Solution:**
  - `ads.js` gained 3 new configurable slot keys (`native`, `support`, `gamesBottom`) — all placeholders requiring a real AdSense **In-article** ad unit to be created per slot (documented in the file's own header, matching the existing `homeBottom` placeholder pattern). Refactored the ad-wiring logic into a shared `wireAndPush()` used both by the page-load pass and a new `LA_ADSENSE.reveal(key, container)` for lazy, on-demand ad loading.
  - Homepage: added a native (in-article) ad between Features and Support, and a "View a sponsor message" button in the Support section that lazily loads a dedicated ad unit only when clicked — an honest, AdSense-policy-safe interpretation of "support by watching an ad" (no click-baiting language, no gated/rewarded content, since standard AdSense has no rewarded-video mechanic the way AdMob does in the app).
  - New `/games` hub and `/games/dino` — a real, working Dino Run endless runner. Vendored (unmodified) from `wayou/t-rex-runner` (BSD-3-Clause, itself based on Chromium's offline dinosaur game) under `hosting/games/vendor/trex/`, with the original `LICENSE` file kept alongside and credited on the game page. A native ad sits below the game in normal page flow (not an overlay), so it never interrupts gameplay.
- **Regression risks:** The 3 new ad slots stay inert (hidden via `hideBanner`) until real AdSense In-article unit IDs are pasted into `ads.js` — no broken ad requests ship. Vendored game assets add ~6KB (sprites) + ~90KB (game JS, mostly embedded base64 audio) to the site; not part of the Flutter app build.
- **Verified:** Local static-server route check (`/games`, `/games/dino`, all vendored asset paths) all resolve 200 under Firebase Hosting's `cleanUrls` convention; HTML tag balance checked programmatically (div/main/body/html open/close counts match) on all 3 touched/new pages — no visual/browser test possible from this environment.

## 2026-08-25 — Article bookmarks

- **Type:** feature
- **Area:** learn, daily content
- **Files:** `article_bookmark_store.dart`, `saved_articles_screen.dart`, `resource_webview_screen.dart`, `daily_content_detail_screen.dart`, `learn_screen.dart`, `app_router.dart`, `app_providers.dart`, `main.dart`, l10n
- **Problem / Goal:** Users wanted to save articles from daily picks and in-app reading for later.
- **Solution:** Local JSON bookmark store; bookmark toggle in article reader and daily pack; **Saved articles** entry on Learn tab; `/saved-articles` list screen opens saved URLs in-app.
- **Regression risks:** Bookmarks are device-local only (cleared with app data); no sync. WebView allowlist unchanged.
- **Verified:** Manual compile path; l10n keys added to all ARBs.

## 2026-08-24 — Voice interview hub (HR/Tech, captions, one-time use)

- **Type:** feature
- **Area:** career / interview
- **Files:** `voice_interview_hub_screen.dart`, `voice_interview_theme.dart`, `voice_interview_entitlement.dart`, `interview_persona.dart`, `interview_voice_input_bar.dart`, `interview_feedback_buttons.dart`, `quiz_play_screen.dart`, `results_screen.dart`, `prompt_builder.dart`, `learning_orchestrator.dart`, `skill_matrix_screen.dart`, `app_router.dart`, l10n
- **Problem / Goal:** Voice interview was a hidden drill button with no persona choice, no live caption UX, no HR vs technical results, no one-time free session, and no in-flow feedback mail.
- **Solution:** New `/career/voice-interview` hub with futuristic dark UI; HR vs Technical interviewer cards; live caption panel with waveform while recording; 1 free voice session per install (`VoiceInterviewEntitlement`); persona-specific prompts and results headers; Write feedback / Report issue mailto on results and locked hub; Career matrix primary Voice interview CTA.
- **Regression risks:** Whisper remains batch STT (not true streaming); entitlement persists locally (reinstall resets); LLM rubric scoring quota unchanged; text interview drills unlimited via `/career/drill/create`.
- **Verified:** `flutter analyze` on touched paths.

## 2026-08-24 — Voice interview Whisper STT

- **Type:** feature
- **Area:** career / interview
- **Files:** `built_in_whisper_config.dart`, `whisper_stt_service.dart`, `interview_voice_input_bar.dart`, `drill_create_screen.dart`, `quiz_play_screen.dart`, `app_providers.dart`, l10n, `.cursor/skills/interviewer-voice/SKILL.md`, `docs/BUILT_IN_AI.md`
- **Problem / Goal:** B2 voice interview was “Coming soon”; user supplied NVIDIA Whisper nvapi key for spoken interview answers.
- **Solution:** `WHISPER_API_KEY` dart-define; record WAV → NVIDIA `/v1/audio/transcriptions` (`openai/whisper-large-v3`); Career **Voice interview** navigates with `?voice=1`; mic bar on open questions; existing rubric scores transcribed text. Agent skill documents architecture.
- **Regression risks:** Key must stay dart-define only; mic permission required; Whisper is batch not realtime; LLM scoring quota unchanged for Built-in.
- **Verified:** `flutter analyze` on touched paths.

## 2026-08-23 — Product backlog + 27-bug workstream retro

- **Type:** feature (docs only)
- **Area:** docs
- **Files:** `docs/BACKLOG.md`, `docs/logs/RETRO_2026-08-23.md`, `docs/PROJECT_LOG.md`
- **Problem / Goal:** Capture deferred / Coming soon / residual work from the 27-bug + hosting + ads batch, and write a short retro.
- **Solution:** Living backlog (chatbot, voice interview, local LLM, l10n/ARB durability, article-relevance residual, leftover `study_alarm` channel, daily-quiz sequencing, device QA, ad fill, AdSense slots) plus dated retro. Chatbot and voice remain not built.
- **Regression risks:** None — documentation only.
- **Verified:** Docs only.

## 2026-08-23 — Backlog: in-app learning chatbot

- **Type:** feature (backlog only — not built)
- **Area:** chat, learn, ai
- **Files:** this log; `docs/BACKLOG.md` (B1)
- **Problem / Goal:** Users asked for a chatbot to ask follow-up questions about modules, quizzes, and uploaded library files.
- **Solution / feasibility:** Feasible as a later premium or quota-gated feature: reuse Built-in/BYOK `LlmManager.completeJson`, RAG from `AiRequestPipeline` + library chunks, and the existing 24h generation quota (each turn would consume quota unless a separate chat budget is added). Main risks are cost/quota burn, hallucination unless grounded, and a new persistence model for threads. **Do not ship a chatbot in this release.** Tracked as backlog item B1.
- **Regression risks:** None — documentation only.
- **Verified:** Research note only.

## 2026-07-26 — Library-first learning, interview grounding, From my content

- **Type:** feature
- **Area:** learn, career/interview, library, quota, daily content
- **Files:** `knowledge_vector_store.dart`, `rag_context_builder.dart`, `learning_orchestrator.dart`, `drill_create_screen.dart`, `learn_screen.dart`, `path_detail_screen.dart`, `built_in_ai_quota.dart`, `background_daily_tasks.dart`, `daily_content_*`, `knowledge_repository.dart`, l10n, `docs/PLAY_LAUNCH_GUIDE.md`
- **Problem / Goal:** Prefer uploaded resume/JD/notes over bare goal topics; self-intro drills; rolling 24h Built-in quota with background restore; daily pack quota/ads; path completion + content-based path shortcut; Play-ready release.
- **Solution:** Source-type RAG boost; resume/JD validation; interview self-intro question + company from JD; Learn �From my content� (grounded); path-complete CTA; epoch refresh after modules; transactional website index; 24h quota + Workmanager; daily pack Built-in preflight.
- **Regression risks:** Grounded mode needs library consent; resume heuristics may reject atypical CVs; Workmanager 15m minimum for quota restore; Built-in key still extractable from APK.
- **Verified:** `flutter analyze` on touched paths � 0 errors.

## 2026-07-22 � Daily content notifications + History Notifications

- **Type:** feature
- **Area:** notifications, history, engagement, background
- **Files:** `daily_content_service.dart`, `daily_content_scheduler.dart`, `background_daily_tasks.dart`, `notification_history_store.dart`, `history_screen.dart`, `main.dart`, l10n
- **Problem / Goal:** Engage users with a daily article/video push and a place to re-open past notifications.
- **Solution:** Once-per-day AI content pick (validated URL) + Workmanager task; local notify; JSON notification history; History tab SegmentedButton Quizzes | Notifications.
- **Regression risks:** Background generation needs network and goals; iOS background limited vs Android Workmanager.
- **Verified:** Static wiring + analyze on history/background paths.

## 2026-07-21 � Structured markdown module notes + cache

- **Type:** feature
- **Area:** learn, ai
- **Files:** `learning_orchestrator.dart`, `module_notes_cache.dart`, `path_detail_screen.dart`, l10n (`moduleNotesNoTranscriptFooter`)
- **Problem / Goal:** Module notes were plain text, in-memory only, and could leak `usedTranscript: false` into the body; Summarize button misaligned vs Module quiz.
- **Solution:** `ModuleNotesResult` with markdown JSON (`notes` + `source`); bottom sheet `Markdown` + theme styles; disk cache per `pathId+moduleIndex`; muted no-transcript footer; full-width Outlined Summarize above Primary quiz.
- **Regression risks:** Summarizer still uses Built-in/BYOK quota; footer only when `!usedTranscript`; cache survives regenerate unless user re-triggers with regenerate flag.
- **Verified:** `flutter analyze` on touched paths.

## 2026-07-21 � Tamil locale + mandatory goal topics + topic guardrail

- **Type:** feature
- **Area:** locale, onboarding, quiz, learn, ai
- **Files:** `supported_languages.dart`, `app_localizations.dart`, `learner_goal_guard.dart`, `topic_goal_guardrail.dart`, `welcome_screen.dart`, `create_quiz_screen.dart`
- **Problem / Goal:** Ship Tamil for app + quiz AI; require real syllabus/skills/topics; smarter on-goal checks.
- **Solution:** Tamil registered and ordered second; no onboarding skip; Create Quiz starts processing then guardrail; contextual topic hints from goals.
- **Regression risks:** Tamil UI strings may still have some legacy mojibake in generated dart; quiz AI language name is correct.
- **Verified:** Analyze clean on touched paths.

## 2026-07-20 � Module summarizer + goal relevance gate

- **Type:** feature
- **Area:** learn, quiz, ai
- **Files:** `learning_orchestrator.dart`, `youtube_transcript_fetcher.dart`, `topic_goal_relevance.dart`, `path_detail_screen.dart`, `create_quiz_screen.dart`, l10n
- **Problem / Goal:** Learners needed structured module notes (preferring video transcript) and Create Quiz needed to stay on-goal.
- **Solution:** `summarizeModule` fetches YouTube timedtext when possible, then AI notes sheet on unlocked modules; Create Quiz blocks off-goal topics and confirms borderline ones.
- **Regression risks:** Captions missing falls back to titles/links; summarizer uses Built-in/BYOK quota like other JSON completes.
- **Verified:** Analyze clean on touched paths; manual smoke of Summarize CTA recommended.

## Backfill � Shipped before 2026-07-09

- **AI-native quiz generation** � BYOK multi-provider (OpenAI, Gemini, Claude, Grok, DeepSeek, OpenRouter, custom)
- **Self-healing AI** � retry, circuit breaker, fallback provider, prompt simplification (`lib/core/healing/`)
- **Quiz of the day** � daily challenge on dashboard
- **Learning paths** � AI-generated modules with practice quizzes and resources
- **Multiplayer** � Firestore rooms (`lib/features/multiplayer/`)
- **Exam prep module** � syllabus, study plan, mock exams (`lib/features/exam/`)
- **Career prep module** � skill matrix, interview drills (`lib/features/career/`)
- **Personalization** � on-device telemetry, recommendation engine, dashboard section planner
- **Local-first storage** � Isar DB, secure API key storage
- **Opt-in anonymized analytics** � Firestore sync when enabled
- **Smart reminders (baseline)** � per-weekday scheduling, exam countdown, QOTD notifications

## 2026-07-09 � Project log workflow

- **Type:** feature
- **Area:** docs
- **Files:** `docs/PROJECT_LOG.md`, `docs/logs/*`, `.cursor/rules/project-log.mdc`
- **Problem / Goal:** No change history; risk of regressions across features.
- **Solution:** Structured logs + cursor rule requiring read-before / write-after.
- **Regression risks:** None.
- **Verified:** Files created.

## 2026-07-09 � Reminder popup and alarm scheduling

- **Type:** feature
- **Area:** reminders
- **Files:** `lib/features/reminders/presentation/reminder_setup_sheet.dart`, `lib/core/services/notification_service.dart`, `lib/core/services/reminder_preferences.dart`, `android/app/src/main/AndroidManifest.xml`
- **Problem / Goal:** Reminders buried in settings; inexact scheduling; no permission flow.
- **Solution:** Set Reminder button opens sheet on dashboard/settings; alarm mode with exact scheduling; notification permission request; snooze action; tap opens dashboard.
- **Regression risks:** Exam countdown and QOTD channels unchanged; verify daily reminders on Android 13+.
- **Verified:** Code compiles; device alarm test recommended.

## 2026-07-09 � Guidance layer (onboarding, help, legal, tour)

- **Type:** feature
- **Area:** guidance, onboarding, legal, learn
- **Files:**
  - `lib/core/constants/provider_guide_registry.dart`, `lib/core/guidance/*`
  - `lib/shared/widgets/guidance/*` � provider guide, dynamic app explainer, empty states, adaptive banner
  - `lib/features/guidance/presentation/*` � coach marks, help center, what's new
  - `lib/features/legal/presentation/legal_document_screen.dart`, `assets/legal/*`
  - `lib/features/onboarding/presentation/welcome_screen.dart`, `onboarding_provider_step.dart`
  - `lib/features/shell/presentation/app_shell.dart`, `lib/features/learn/presentation/learn_screen.dart`
  - `lib/data/remote/ai/path_prompt_builder.dart`, `learning_orchestrator.dart`
  - `lib/l10n/app_en.arb`, `app_localizations*.dart`
  - `pubspec.yaml` � `flutter_markdown`, `tutorial_coach_mark`
- **Problem / Goal:** Users stalled without API key help, legal trust, product tour, or deeper learning paths.
- **Solution:** Provider Guide Hub with external-link confirm; in-app privacy/terms; legal consent on onboarding; first-run coach marks + What's New; dynamic app preview on goal step; Learn path depth selector (6/10/12 modules); help center and settings replay tour.
- **Regression risks:** Tour timing on slow devices; legal consent blocking skip until accepted; path generation token cost with 12 modules; non-English l10n uses English fallback for new strings.
- **Verified:** `flutter pub get`; l10n patched across locales; release APK held until full device QA.

## 2026-07-10 � AI Platform layer

- **Type:** feature
- **Area:** ai_platform, security, governance
- **Files:** `lib/core/ai_platform/*`, `assets/ai/ai_policy_v1.json`, `lib/data/local/models/ai_audit_event.dart`, `lib/data/local/models/ai_usage_daily.dart`, `lib/core/providers/ai_platform_providers.dart`, `lib/data/remote/ai/learning_orchestrator.dart`, `lib/core/services/usage_tracker.dart`, `lib/main.dart`
- **Problem / Goal:** No centralized AI governance, prompt security, audit trail, or token budgeting across LLM calls.
- **Solution:** `AiPolicyRegistry` (versioned JSON caps), `PromptFirewall`, `OutputValidator`, `AiAuditLog` (Isar), `RagContextBuilder`, `AiRequestPipeline` middleware; persisted daily usage via `AiUsageDaily`; economy mode and send-chunks consent in Settings.
- **Regression risks:** Blocked prompts false positives; token cap blocking legitimate use; audit DB growth on heavy use.
- **Verified:** `flutter analyze` on touched modules; manual policy-cap and economy-mode QA recommended.

## 2026-07-10 � Personal Knowledge Base + RAG

- **Type:** feature
- **Area:** library, career, exam, learn
- **Files:** `lib/data/knowledge/*`, `lib/data/local/models/knowledge_source.dart`, `document_chunk.dart`, `user_website.dart`, `lib/data/vector/knowledge_vector_store.dart`, `lib/data/local/repositories/knowledge_repository.dart`, `lib/features/library/presentation/my_library_screen.dart`, `lib/features/learn/presentation/resource_webview_screen.dart`, `lib/core/agents/goal_agent.dart`, quiz/path orchestrator RAG hooks
- **Problem / Goal:** No document ingestion, chunk-level RAG, or user website indexing for grounded generation across goal modes.
- **Solution:** Upload txt/md/pdf; section-aware chunking; `KnowledgeVectorStore` with hash embeddings; `MyLibraryScreen` hub + entry points on career/exam/learn; RAG prepended to quiz, path, and GoalAgent prompts; citation chunk IDs on quiz sessions; user website allowlist in WebView (parallel to official domains).
- **Regression risks:** Large PDF index time; website fetch failures; Isar migration on upgrade; webview allowlist confusion with official domains.
- **Verified:** `build_runner` for new schemas; device QA for upload ? grounded quiz with citations.

## 2026-07-12 � Hybrid local LLM (MLC) + explicit engine choice

- **Type:** feature
- **Area:** ai, onboarding, settings, android
- **Files:** `docs/MLC_ANDROID_SETUP.md`, `android/app/build.gradle.kts`, `android/settings.gradle.kts`, `android/app/src/main/kotlin/.../llm/*`, `android/app/src/mlcStub|mlcEnabled/.../LocalLLMEngine.kt`, `lib/core/services/llm_manager.dart`, `ai_engine_mode_store.dart`, `ai_readiness_service.dart`, `lib/data/local_llm/local_llm_channel.dart`, `lib/data/remote/ai/providers/local_mlc_provider.dart`, `learning_orchestrator.dart`, `onboarding_provider_step.dart`, `providers_screen.dart`, l10n strings
- **Problem / Goal:** App was cloud-BYOK only; need on-device MLC as a first-class engine with an explicit user choice (never silent auto-route from API key presence).
- **Solution:** Kotlin `LocalLLMEngine` / RAM guard / `DownloadManager` + MethodChannel; Dart `LlmManager` routes by persisted `ai_engine_mode`; onboarding two-path UX and Settings engine selector; optional `mlc4j` Gradle include when packaged.
- **Regression risks:** Onboarding skip still allowed without choosing an engine (generation then prompts CTA); `AiStatusBadge` offline until mode chosen; cloud quiz/path paths unchanged when mode is cloud; arm64-only NDK filter; release minify needs MLC keep rules when `mlc4j` present; stub builds return clear native-not-packaged errors.
- **Verified:** IDE lints clean on touched Dart; full `flutter analyze` / device QA with packaged `mlc4j` recommended.

## 2026-07-24 � Android deep links via app_links
- **Type:** feature
- **Area:** deep links, android, routing
- **Files:** `pubspec.yaml`, `android/app/src/main/AndroidManifest.xml`, `lib/main.dart`, `lib/core/services/deep_link_handler.dart`
- **Problem / Goal:** Open the app from `learnanything://` URIs (cold/warm) and route via GoRouter.
- **Solution:** Add `app_links`; VIEW/BROWSABLE intent-filter with scheme `learnanything` on MainActivity (keep MAIN/LAUNCHER); bind and start `DeepLinkHandler` next to `NotificationService.bindRouter` in `main.dart`.
- **Regression risks:** Notification tap routing via `NotificationService.bindRouter` must remain; MAIN/LAUNCHER filter must stay; cold-start deep link must not race splash/onboarding navigation incorrectly.
- **Verified:** `flutter pub add app_links` succeeded (`app_links: ^7.0.0`); manifest + main wiring inspected.
