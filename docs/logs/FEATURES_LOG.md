# Features Log

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
