# Enhancements Log

## 2026-08-29 — Backlog batch: mark-for-review, achievement badges, AI eval CI, generation UX contract

- **Type:** enhancement
- **Area:** exam, dashboard, ci, ux, quiz, learn
- **Files:** `quiz_play_screen.dart`; `achievement_badges.dart` (new), `dashboard_screen.dart`, `test/achievement_badges_test.dart` (new); `.github/workflows/ai-eval.yml` (new); `generation_job_service.dart`, `generation_job_overlay_binding.dart` (new), `api_limit_dialog.dart`, `create_quiz_screen.dart`, `learn_screen.dart`, `daily_content_detail_screen.dart`; `lib/l10n/app_en.arb` + generated locale files.
- **Problem / Goal:** Ship the Must/Should backlog items B12, B14, B16, B17 (2026-08-29 MoSCoW pass): mock-exam question flagging, live-computed achievement badges, a scheduled CI gate on the live model probe, and de-duplicated/consistent AI-generation error-recovery UX.
- **Solution:**
  - **B17** — in-memory `_flaggedIndices` on `quiz_play_screen.dart`, gated to `quizKind == mock`; AppBar flag toggle + a jump-to-flagged chip row using the existing `_goTo(index)`. No schema change (flags don't need to outlive the attempt).
  - **B16** — `AchievementBadgesSection` renders 8 fixed milestones computed live from `DashboardStats` (already returned by `StatsRepository.getDashboardStats()`) — no new persistence, no unlock history. Streak badges key off `longestStreak` so an earned badge isn't revoked when today's streak breaks.
  - **B12** — `.github/workflows/ai-eval.yml` (daily cron + `workflow_dispatch`) runs `test/model_generation_live_probe_test.dart` against the real Built-in AI backend, keeping its existing 10/10-per-task bar. Requires a `BUILT_IN_AI_API_KEY` repo secret (not something an agent can add) — skips (not fails) until it's set.
  - **B14** — `GenerationJobService.startPath`/`startDailyContent` now map errors via `AppException.from(...)` like `startQuiz` already did. New `generation_job_overlay_binding.dart` extracts the verified-identical overlay/strip boolean derivation and the background-success-auto-navigate `ref.listen` shape shared by `create_quiz_screen.dart` and `learn_screen.dart` (path) — `daily_content_detail_screen.dart` was deliberately left on its own derivation since its success path refreshes in place rather than navigating, a genuinely different shape. Added `onRetry` to `showAppErrorDialog`'s generic fallback dialog, wired from all three generation screens.
- **Regression risks:** None expected for B12/B16/B17 (additive, no shared-file changes beyond the new l10n keys). B14 touches the generation error-mapping path for path/daily-content — `flutter test` covers no direct widget interaction here, so the exact dialog wiring is unverified by automated test, consistent with how these screens were already tested (or not) before.
- **Verified:** `flutter analyze` (0 new errors/warnings, project-wide issue count unchanged at 2171/5 warnings), `flutter test --exclude-tags=live` (133/133 passed, up from 114 with B16's 19 new tests), `flutter test test/achievement_badges_test.dart` (19/19).

## 2026-08-27 — Every AI provider follows the 10/10 JSON gate

- **Type:** enhancement
- **Area:** ai, quiz, learn
- **Files:** `ai_output_gate.dart`, `ai_json_client.dart`, `openai_compatible_provider.dart`, `claude_provider.dart`, `gemini_provider.dart`, `local_mlc_provider.dart`, `quiz_json_parser.dart`, `interview_rubric_scorer.dart`
- **Problem / Goal:** 10/10 output rules (valid JSON, real values, no stubs/placeholders) were Built-in/Nemotron-centric; BYOK Gemini/Claude/custom quiz could skip extract + strict retry.
- **Solution:** `AiOutputGate.requireJsonOutput` / `needsStrictRetry` is the shared gate. All JSON completions (OpenAI-compatible, Gemini, Claude) extract JSON then retry once on invalid output. Quiz parsers/providers (including on-device MLC) use the same gate before parse.
- **Regression risks:** One extra retry on BYOK models that return messy JSON (latency). Invalid output still fails after retry instead of showing garbage.
- **Verified:** `flutter test` ai_output_gate + must_gates QuizJsonParser.

## 2026-08-26 — Nemotron fallback 10/10 on all generation tasks

- **Type:** enhancement
- **Area:** ai, quiz, learn
- **Files:** `ai_output_gate.dart`, `ai_json_client.dart`, `openai_compatible_provider.dart`, `provider_connection_tester.dart`, `test/model_generation_live_probe_test.dart`, `test/ai_output_gate_test.dart`
- **Problem / Goal:** Nemotron Nano scored ~3–8/10 on live probe — `json_object` mode broke quiz schema; chain-of-thought burned tokens on long path prompts leaving empty `content`.
- **Solution:** Skip `response_format: json_object` for reasoning-channel models; send `chat_template_kwargs: {enable_thinking: false}` on all Nemotron requests so JSON lands in `content`; centralized via `AiOutputGate.requestExtrasForModel()`.
- **Regression risks:** Nemotron loses extended reasoning (intentional for JSON tasks); Llama unchanged; BYOK Nemotron/custom nano models get same extras when model id matches.
- **Verified:** Live probe — Nemotron **10/10** all 9 tasks; unit tests pass.

## 2026-08-26 — Live model probe + unified output gate for all providers

- **Type:** enhancement
- **Area:** ai, quiz, learn
- **Files:** `ai_output_gate.dart`, `ai_json_client.dart`, `openai_compatible_provider.dart`, `learning_orchestrator.dart`, `test/model_generation_live_probe_test.dart`, `test/ai_output_gate_test.dart`
- **Problem / Goal:** Confirm each Built-in model against exact generation prompts; enforce Rivox JSON/leak rules on BYOK models too.
- **Solution:** Added `AiOutputGate` (JSON parse + instruction-leak checks) applied to OpenAI-compatible, Gemini, and Claude JSON paths. Live probe tests 9 generation tasks with exact prompts; router chain must score 10/10. Module notes and path use `validateContent` retry.
- **Regression risks:** BYOK models that return non-JSON or reasoning leaks now fail fast with clear errors; slightly stricter than before for custom providers.
- **Verified:** Live probe — Llama 3.2 **10/10** all tasks; router chain **10/10**; Nemotron ~3.9/10 alone (fallback only).

## 2026-08-26 — Built-in AI model routing and AI greeting test

- **Type:** enhancement
- **Area:** ai, providers
- **Files:** `built_in_ai_router.dart`, `ai_json_client.dart`, `openai_compatible_provider.dart`, `provider_connection_tester.dart`, `providers_screen.dart`, `app_en.arb`
- **Problem / Goal:** Built-in AI broke when NIM models retire (410); test connection did not show a real AI reply from the draft provider.
- **Solution:** `BuiltInAiRouter` retries alternate NIM models on 404/410/EOL for Built-in chat, quiz, and connection tests. Test connection sends "Hi" via the draft config and shows the model reply in a dialog.
- **Regression risks:** Built-in may use fallback model silently; greeting test uses more tokens than old 8-token ping.
- **Verified:** `flutter test` on router, must_gates, widget_test.

## 2026-08-26 — No native ad in article reader

- **Type:** enhancement
- **Area:** ads, learn
- **Files:** `resource_webview_screen.dart`
- **Problem / Goal:** User requested ad-free in-app article reader.
- **Solution:** Removed `ScrollableNativeAdSlot` from `ResourceWebViewScreen` (loading, external, blocked, and WebView states).
- **Regression risks:** Native ads remain on History, saved articles, library, results, daily pack, insights.
- **Verified:** IDE lints on touched path.

## 2026-08-26 — Scrollable dismissible native ads

- **Type:** enhancement
- **Area:** ads, history, learn, quiz, library
- **Files:** `bottom_native_ad_slot.dart`, `history_screen.dart`, `saved_articles_screen.dart`, `resource_webview_screen.dart`, `daily_content_detail_screen.dart`, `results_screen.dart`, `my_library_screen.dart`, `insights_expand_sheet.dart`
- **Problem / Goal:** Fixed bottom native ads blocked History content; users could not dismiss ads.
- **Solution:** `ScrollableNativeAdSlot` lives inside scroll content (like Insights) with a top-right close button; dismissed until pull-refresh remounts ad epoch. History/saved articles/results/library/daily pack use inline placement; reader keeps ad below webview with dismiss.
- **Regression risks:** Native unit IDs unchanged; UMP gate unchanged; webview ad not in same scroll as page content.
- **Verified:** IDE lints on touched paths.

## 2026-08-26 — Native ads bottom-only; banner ads removed

- **Type:** enhancement
- **Area:** ads, dashboard, history, learn, quiz, library
- **Files:** `bottom_native_ad_slot.dart`, `dashboard_screen.dart`, `history_screen.dart`, `saved_articles_screen.dart`, `resource_webview_screen.dart`, `daily_content_detail_screen.dart`, `results_screen.dart`, `my_library_screen.dart`, `insights_expand_sheet.dart`, `quiz_play_screen.dart`
- **Problem / Goal:** Native ad below AI brief on Home; banners on History and other screens. User wanted native at bottom on History, saved articles, library, results, etc., and no banners.
- **Solution:** Removed Home native ad; added `BottomNativeAdSlot` (native + SafeArea) on History, saved articles, in-app reader, daily pack, quiz results, My library, and insights sheet. All `BannerAdWidget` usages removed from screens; results banner preload dropped.
- **Regression risks:** Release still uses production native unit in release builds; UMP gate unchanged; `BannerAdWidget` file retained but unused.
- **Verified:** IDE lints on touched paths.

## 2026-08-26 — Dashboard insights charts: live goal, day labels, trend, refresh, native ad

- **Type:** enhancement
- **Area:** dashboard, insights, ads
- **Files:** `study_minutes_provider.dart`, `stats_repository.dart`, `dashboard_charts.dart`, `insights_expand_sheet.dart`, `dashboard_screen.dart`, `home_refresh.dart`, l10n
- **Problem / Goal:** Study goal ring stale in insights; weekly chart showed 0–6 instead of day names; no overall activity trend; no refresh or native ad in insights sheet.
- **Solution:** `todayStudyMinutesProvider` live-updates goal ring (15s tick + pull refresh). Weekly chart uses last 7 calendar days with localized weekday names (`DateFormat.E`). Added 14-day activity trend line chart (questions solved/day). Insights sheet now self-loads stats, has refresh button, and shows `NativeAdWidget`.
- **Regression risks:** `DashboardStats.activityTrend` new field; weekly buckets no longer Mon–Sun aggregate (chronological last 7 days); production ad units unchanged.
- **Verified:** IDE lints on touched paths.

## 2026-08-26 — MCQ answer/explanation consistency in quiz prompts

- **Type:** enhancement
- **Area:** quiz, AI prompts
- **Files:** `quiz_consistency_prompt.dart`, `prompt_builder.dart`, `generated_quiz.dart`, `openai_compatible_provider.dart`, `claude_provider.dart`, `local_mlc_provider.dart`, `test/must_gates_test.dart`
- **Problem / Goal:** MCQ generation could key one answer (e.g. Liver) while the explanation defended another (e.g. skin as largest organ), especially when scope qualifiers ("internal" vs "overall") were ambiguous.
- **Solution:** Added `QuizConsistencyPrompt` with mandatory cross-check rules and the largest-organ example; wired into all non-interview quiz prompts and provider system messages. Parser now accepts alternate LLM schema (`question_text`, letter-keyed `options`, `correct_answer` A–D).
- **Regression risks:** Exact-count and dedup validation unchanged; interview voice/open rubrics unchanged; app schema still uses `options` array + `correctIndex`.
- **Verified:** `flutter test test/must_gates_test.dart` (24/24 pass).

## 2026-08-26 — Daily pack video subtitle replaces AI summary

- **Type:** enhancement
- **Area:** learn, daily content, l10n
- **Files:** `daily_content_detail_screen.dart`, `app_en.arb`, `app_*.arb`, `app_localizations*.dart`
- **Problem / Goal:** Today's learning pack video showed a long AI-generated description; user wanted a short hint like "Watch relevant video for {topic/goal}".
- **Solution:** Video section now shows `dailyContentVideoSubtitle(topic)` using pack topic, else first learner goal, else `dailyContentVideoSubtitleForGoal`. Article summary unchanged. Stored video summary still used in history/notifications only.
- **Regression risks:** Daily pack still requires article + video; in-app YouTube player unchanged; non-en l10n stubs remain English until translated.
- **Verified:** IDE lints on touched paths.

## 2026-08-25 — Enable native ads on Home; confirm production banner ID

- **Type:** enhancement
- **Area:** ads, dashboard
- **Files:** `native_ad_widget.dart`, `dashboard_screen.dart`
- **Problem / Goal:** Confirm production banner unit `ca-app-pub-5325876102788151/5482634804` is wired everywhere; native unit `…/7017032152` existed but was debug-only and unused.
- **Solution:** Verified all `BannerAdWidget` / preload paths use `AdUnitIds.bannerAdUnitId` (`5482634804`). Re-enabled `NativeAdWidget` for release with UMP consent + retry; placed medium native template on Home below Today's AI brief.
- **Regression risks:** Quiz play remains ad-free; production unit IDs unchanged; native hides when unfilled (no layout jump after load failure).
- **Verified:** `flutter test` (ad_unit_ids + suite).

## 2026-08-25 — Quick quiz count options 5/10/15/20 in UI and prompt

- **Type:** enhancement
- **Area:** quiz, create quiz
- **Files:** `create_quiz_screen.dart`, `prompt_builder.dart`, `test/must_gates_test.dart`, `test/widget_test.dart`
- **Problem / Goal:** Question count must match the four app options (5, 10, 15, 20) in both UI and the initial AI prompt.
- **Solution:** Replaced slider with ChoiceChips for the four fixed counts. Prompt MANDATORY block states user-selected count and allowed values from `AppConstants.questionCounts`.
- **Regression risks:** Built-in clamp still caps at 20; parser exact-count validation unchanged.
- **Verified:** `flutter test`.

## 2026-08-25 — Settings Support section separated from AI & library

- **Type:** enhancement
- **Area:** settings, UX
- **Files:** `settings_screen.dart`
- **Problem / Goal:** Support Rivox and watch-ad actions were buried inside the collapsed “AI & library” section.
- **Solution:** New expandable **Support** section placed directly below AI & library with support hub link and optional watch-ad button; AI section keeps providers, help-improve toggle, and library only.
- **Regression risks:** Support screen route and interstitial preload unchanged; section expand/collapse state is independent.
- **Verified:** `flutter analyze` on touched file.

## 2026-08-25 — Multi-source article scoring (not Wikipedia-first)

- **Type:** enhancement
- **Area:** learning paths, daily content
- **Files:** `learning_article_resolver.dart`, `daily_content_fallbacks.dart`, `resource_link_validator.dart`, `test/learning_article_resolver_test.dart`
- **Problem / Goal:** Article resolver always picked the first reachable Wikipedia hit; other allowlisted sources (tutorials, Khan, Investopedia, wikiHow) were ignored unless hardcoded per topic.
- **Solution:** `LearningArticleResolver` gathers candidates from coding tutorials, Wikipedia search, and heuristic allowlisted URLs, scores by topic/goal overlap + source fit + query rank, validates reachability on top-ranked picks. Path modules without articles get up to 2 top-scored fallbacks.
- **Regression risks:** More network calls during path fallback (parallel gather still bounded); org goal validation gate unchanged; homepage/heuristic URLs penalized in scoring and dropped if unreachable.
- **Verified:** `flutter test` (82/82 pass).

## 2026-08-25 — Generic goal-aware article resolver (learn anything)

- **Type:** enhancement
- **Area:** learning paths, daily content
- **Files:** `learning_article_resolver.dart`, `daily_content_fallbacks.dart`, `resource_link_validator.dart`, `learning_orchestrator.dart`, `path_prompt_builder.dart`, `test/learning_article_resolver_test.dart`
- **Problem / Goal:** Per-topic hardcoded article lists (dental, agile, AI agent, etc.) do not scale for "learn anything" — new goals would keep breaking until manually patched.
- **Solution:** `LearningArticleResolver` builds search queries from module title + user goal + path title, searches Wikipedia live, validates reachability, and falls back to slug guesses. Path generation passes primary goal context into embed verification; daily pack uses the same resolver before legacy buckets.
- **Regression risks:** Org goals still pass through validation agent; coding topics still prefer tutorial sites first; extra Wikipedia API calls on path generation fallback; cached paths unchanged until regenerated.
- **Verified:** `flutter test` (79/79 pass).

## 2026-08-25 — CS/coding daily articles prefer GFG, W3Schools, tutorial sites

- **Type:** enhancement
- **Area:** daily content, learning paths
- **Files:** `coding_tutorial_sources.dart`, `daily_content_fallbacks.dart`, `daily_content_service.dart`, `path_prompt_builder.dart`, `test/coding_tutorial_sources_test.dart`
- **Problem / Goal:** Computer science and coding goals fell back to Wikipedia; users want GeeksforGeeks, W3Schools, MDN, and similar tutorial sites.
- **Solution:** `CodingTutorialSources` maps CS/coding topics to curated allowlisted tutorial URLs; daily fallbacks try these before Wikipedia; LLM prompts and path builder instruct preferring hands-on tutorial sites for programming topics.
- **Regression risks:** Curated URLs must stay reachable; business/career topics still avoid coding bootcamp articles; org-domain flow unchanged.
- **Verified:** `flutter test test/coding_tutorial_sources_test.dart`; analyze on touched paths.

## 2026-08-25 — Open knowledge API layer (Wikipedia, Wikidata, arXiv, Europe PMC, Gutendex)

- **Type:** feature
- **Area:** goals, daily content, quiz/path grounding, agent rules
- **Files:** `lib/core/services/open_knowledge/*`, `goal_topic_resolver.dart`, `topic_grounding_service.dart`, `daily_content_service.dart`, `.cursor/rules/open-knowledge-apis.mdc`, `test/open_knowledge_service_test.dart`
- **Problem / Goal:** LLM-only grounding for facts/URLs; need Rivox-specific rules and connectors for free/open data sources per ingestion spec.
- **Solution:** `OpenKnowledgeService` routes topics to Wikipedia, Wikidata (org names), Europe PMC (biomedical), arXiv (STEM), Gutendex (literature) with shared Dio User-Agent, in-memory TTL cache, and soft failures. Injects `OPEN KNOWLEDGE` blocks into goal resolution and daily pack prompts. Cursor rule documents integration points and YouTube oEmbed vs optional `YOUTUBE_API_KEY`.
- **Regression risks:** Extra network calls on generation (cached 10 min); arXiv/PMC/Gutendex are prompt context only (not daily-pack allowlist); duplicate OPEN KNOWLEDGE skipped in daily service when resolver already enriched.
- **Verified:** `flutter test test/open_knowledge_service_test.dart` + existing grounding tests; analyze on touched paths.

## 2026-08-25 — Org domain goals: always resolve + never empty daily pack

- **Type:** enhancement
- **Area:** goals, daily content, quiz guardrail
- **Files:** `goal_topic_resolver.dart`, `topic_grounding_service.dart`, `daily_content_fallbacks.dart`, `daily_content_service.dart`, `topic_goal_relevance.dart`, tests
- **Problem / Goal:** Org/domain goals like `elsai.ai` could still fail with "could not find relevant content" or weak resolution when web/LLM failed; Wikipedia slug URLs 404'd for domain topics.
- **Solution:** Deterministic fallback resolution when web + LLM fail; Wikipedia API search for org daily articles; org-specific video fallbacks with trusted embed check; offline minimum pack items so `ensureTodaysContent` never returns null; org goals treated as on-goal in relevance gate.
- **Regression risks:** Org daily pack may use related AI/startup Wikipedia when company page missing; offline minimum skips live URL validation; normal non-domain topics unchanged.
- **Verified:** `flutter test test/goal_topic_resolver_test.dart test/topic_grounding_service_test.dart test/topic_goal_relevance_test.dart`; analyze on touched paths.

## 2026-08-25 — Web grounding for opaque goals (domain + Wikipedia)

- **Type:** enhancement
- **Area:** quiz, learn paths, daily content, goals
- **Files:** `topic_grounding_service.dart`, `goal_topic_resolver.dart`, `test/topic_grounding_service_test.dart`, `test/goal_topic_resolver_test.dart`
- **Problem / Goal:** Org/domain goals like `elsai.ai` relied on LLM memory alone; needed real web facts before generation.
- **Solution:** Minimum-viable open grounding: fetch homepage meta (title/description) and Wikipedia summary when available. `GoalTopicResolver` uses grounded scope first; existing LLM JSON fallback unchanged when fetch fails. Only runs for `needsResolution()` goals — normal topics untouched.
- **Regression risks:** Extra network calls (8s timeout) for domain goals only; offline/ blocked sites fall back to LLM; Wikipedia miss for unknown startups still uses LLM; resolution cache unchanged.
- **Verified:** `flutter test test/topic_grounding_service_test.dart test/goal_topic_resolver_test.dart`; analyze on touched paths.

## 2026-08-25 — Goal topic think-step (org/domain names like elsai.ai)

- **Type:** enhancement
- **Area:** quiz, learn paths, daily content, goals
- **Files:** `goal_topic_resolver.dart`, `learning_orchestrator.dart`, `prompt_builder.dart`, `path_prompt_builder.dart`, `daily_content_service.dart`, `quiz_generation_request.dart`, `resilient_ai_provider.dart`, `test/goal_topic_resolver_test.dart`
- **Problem / Goal:** Opaque goals such as `elsai.ai` produced irrelevant generic content because the model was not told what the org/product is.
- **Solution:** Before quiz/path/daily generation, detect domain/org-like goals and run a cheap LLM JSON "think" step (`effectiveTopic`, `learningScope`, `avoid`). Inject scope into prompts; cache resolutions in memory. Does not count against Built-in quota (`skipQuota: true`).
- **Regression risks:** Extra LLM call adds latency for domain goals only; normal topics unchanged; resolution cache clears on process restart.
- **Verified:** `flutter test test/goal_topic_resolver_test.dart`; analyze on touched paths.

## 2026-08-25 — Voice interview Whisper en-US + English speaking coaching

- **Type:** enhancement
- **Area:** career, voice interview
- **Files:** `built_in_whisper_config.dart`, `whisper_stt_service.dart`, `interview_voice_input_bar.dart`, `voice_interview_speech_coaching.dart`, `voice_interview_hub_screen.dart`, `quiz_play_screen.dart`, `.cursor/skills/interviewer-voice/SKILL.md`
- **Problem / Goal:** Voice interview must use Whisper API in English; users need realtime on-screen guidance to speak slowly, loudly, and clearly in English.
- **Solution:** `stopAndTranscribeInterview()` always sends `language=en-US` to NVIDIA Whisper NVCF; hub blocks start without `WHISPER_API_KEY`; English coaching banner with rotating tips while recording (slow / loud / clear / English).
- **Regression risks:** Voice interview answers always transcribed as English regardless of app UI locale; LLM rubric scoring unchanged.
- **Verified:** `flutter analyze` on touched paths.

## 2026-08-25 — Topic-specific quiz and daily content scope

- **Type:** enhancement
- **Area:** quiz, daily content, learning paths
- **Files:** `topic_specificity_prompt.dart`, `prompt_builder.dart`, `path_prompt_builder.dart`, `daily_content_service.dart`, `daily_content_fallbacks.dart`, `test/topic_specificity_prompt_test.dart`
- **Problem / Goal:** Compound goals like "Islamic history" and "Bio medical" produced parent-domain basics (fasting month, cell biology) instead of the named subfield.
- **Solution:** `TopicSpecificityPrompt` injects scope/forbidden rules into quiz prompts; beginner track suppressed for scoped topics; daily pack prompts and fallbacks include history/biomedical buckets.
- **Regression risks:** Competitive exam prompt unchanged; overly narrow scope on edge topics — monitor feedback.
- **Verified:** `flutter test test/topic_specificity_prompt_test.dart`.

## 2026-08-24 — Rivox 1.0.1 release (version bump + store bundle)

- **Type:** enhancement
- **Area:** release, android, versioning
- **Files:** `pubspec.yaml`, `app_constants.dart`, `test/widget_test.dart`, `docs/RELEASE_NOTES_1.0.1.md`
- **Problem / Goal:** Ship consolidated Rivox rebrand + bugfix batch as Play Store release 1.0.1 (version code 2).
- **Solution:** Bumped `1.0.0+1` → `1.0.1+2`; updated version test; built split APKs + release AAB with `--dart-define-from-file=tool/.local_dart_defines.json`; added `docs/RELEASE_NOTES_1.0.1.md`.
- **Regression risks:** Version code must monotonically increase on Play; Built-in/Whisper keys remain dart-define only (never committed).
- **Verified:** `flutter test` — 39/39 passed; split APK + AAB build exit 0.

## 2026-08-24 — Rivox full app rebrand (in-app + store assets)

- **Type:** enhancement
- **Area:** branding, onboarding, settings, l10n, android, ios, legal, store
- **Files:** `assets/branding/rivox_logo.png`, `assets/branding/rivox_feature_graphic.png`, `docs/store/featureGraphic.png`, `pubspec.yaml`, `app_constants.dart`, `app_theme.dart`, `splash_screen.dart`, `AndroidManifest.xml`, `ios/Runner/Info.plist`, `lib/l10n/app_*.arb`, `lib/l10n/app_localizations_*.dart`, `assets/legal/*.md`, `hosting/assets/*`, `README.md`, `docs/store/LISTING.md`, `demo_quiz_service.dart`, tests
- **Problem / Goal:** Rebrand product from Learn Anything to **Rivox — The AI App for Learning Anything** across launcher icons, in-app copy, legal, and Play Store collateral.
- **Solution:** Copied user-provided logo and feature graphic into `assets/branding/` and `docs/store/featureGraphic.png`; regenerated launcher icons via `flutter_launcher_icons` (Android mipmaps + iOS AppIcon). Updated platform labels to **Rivox** (launcher/home screen). Set l10n `appName` = Rivox and `organizationTagline` = The AI App for Learning Anything across all 14 ARBs + generated Dart. Replaced product-name strings (support, share, settings, demo quiz, legal markdown). Shifted theme seed/accent toward cyan→purple gradient (`#00B4D8` → `#9D4EDD`). Play Store listing draft title: **Rivox: Learn Anything** (21 chars); full tagline in description/subtitle.
- **Regression risks:** Package/bundle IDs and deep-link scheme `learnanything` unchanged. Daily pack `skipQuota: true`; results banner `…/5482634804`; voice interview one-time entitlement; Built-in/BYOK quota order unchanged. Do not revert AdSense/hosting ad slot wiring when updating branding assets.
- **Verified:** `dart run flutter_launcher_icons` exit 0; `flutter analyze` on touched Dart paths — no issues.

## 2026-08-24 — Hosting website feature image + content refresh

- **Type:** enhancement
- **Area:** hosting, branding
- **Files:** `hosting/index.html`, `hosting/styles.css`, `hosting/assets/feature_image.png`, `hosting/assets/rivox_icon.png`, `hosting/assets/favicon.png`
- **Problem / Goal:** Public site needed the correct Rivox feature graphic and copy that reflects shipped capabilities (Built-in + BYOK, voice interview, daily pack, career/exam prep) instead of generic three-bullet hero.
- **Solution:** Copied user-provided feature image to `hosting/assets/feature_image.png`; refreshed hero tagline/subcopy, meta/og descriptions, and alt text; expanded features section to six shipped capabilities (no chatbot or on-device LLM claims). Refreshed icon/favicon from `assets/branding/app_icon.png`. Added `.hero-tagline` gradient style.
- **Regression risks:** AdSense integration untouched (`ads.js`, slot IDs, `ins` placeholders, head loader). Do not replace `ads.txt` with `app-ads.txt`. Do not add a second homepage banner without a new Display slot ID for `homeBottom`.
- **Verified:** Assets copied; HTML/CSS updated locally; Firebase Hosting deploy.

## 2026-08-24 — Hosting website Rivox rebrand

- **Type:** enhancement
- **Area:** hosting, branding
- **Files:** `hosting/index.html`, `hosting/privacy/index.html`, `hosting/terms/index.html`, `hosting/styles.css`, `hosting/assets/rivox_icon.png`, `hosting/assets/favicon.png`, `hosting/assets/feature_image.png`
- **Problem / Goal:** Public Firebase Hosting site still showed legacy Learn Anything branding after app launcher icon rebrand to Rivox.
- **Solution:** Rebranded page titles, meta/og tags, header logo text, hero copy, footer, and legal page shells to **Rivox — The AI App for Learning Anything**. Copied `assets/branding/app_icon.png` to `hosting/assets/rivox_icon.png` and `favicon.png`; replaced hero feature image from user-provided asset. Shifted accent colors to cyan→purple gradient via CSS variables (`--accent`, `--accent-end`).
- **Regression risks:** AdSense integration untouched (`ads.js`, slot IDs, `ins` placeholders, head loader). Do not replace `ads.txt` with `app-ads.txt`. Do not add a second homepage banner without a new Display slot ID for `homeBottom`. In-app legal markdown (`assets/legal/`) still says Learn Anything until a separate legal update.
- **Verified:** Hosting HTML/CSS updated locally; image assets copied; no changes to `hosting/ads.js`, `ads.txt`, or `app-ads.txt`.

## 2026-08-24 — App launcher icon (R squircle rebrand)

- **Type:** enhancement
- **Area:** branding, android, ios
- **Files:** `assets/branding/app_icon.png`, `pubspec.yaml`, `android/app/src/main/res/mipmap-*/`, `android/app/src/main/res/drawable-*/ic_launcher_foreground.png`, `android/app/src/main/res/values/colors.xml`, `ios/Runner/Assets.xcassets/AppIcon.appiconset/`
- **Problem / Goal:** Replace legacy Learn Anything launcher icon with new squircle R mark on dark indigo background.
- **Solution:** Copied user-provided icon to `assets/branding/app_icon.png`; pointed `flutter_launcher_icons` at it with `#05050A` adaptive background; ran `dart run flutter_launcher_icons` to regenerate Android mipmaps/adaptive layers and iOS AppIcon set.
- **Regression risks:** Package/bundle IDs unchanged; splash still uses gradient-only `launch_background.xml` (no icon image). No Flutter `web/` target — favicons not updated.
- **Verified:** `dart run flutter_launcher_icons` exit 0; mipmap-hdpi through xxxhdpi and iOS AppIcon PNGs timestamped 2026-08-24.

## 2026-08-24 — Competitive exam logical reasoning quiz quality

- **Type:** enhancement
- **Area:** quiz, exam_prep, ai prompts
- **Files:** `competitive_exam_prompt.dart`, `prompt_builder.dart`, `quiz_generation_request.dart`, `learning_orchestrator.dart`, `mock_create_screen.dart`, `resilient_ai_provider.dart`, `test/must_gates_test.dart`
- **Problem / Goal:** User on logical reasoning got generic/basic riddles instead of SSC/Banking/CAT-style mock questions.
- **Solution:** Researched competitive exam LR syllabi (syllogism, seating, puzzles, coding-decoding, etc.). Added `CompetitiveExamPrompt` block when exam type is competitive or topic/units match reasoning. Passes `examType`, `examName`, and syllabus unit titles into generation. Suppresses beginner-track wording for non-easy competitive papers. Simplified strategy preserves exam context.
- **Regression risks:** Non-exam learning quizzes unchanged unless topic contains "reasoning"; interview/career prompts untouched; beginner track still applies for easy difficulty.
- **Verified:** Unit test for reasoning prompt block; analyze on touched paths; split release APK rebuild.

## 2026-08-24 — Remove on-device local LLM (Built-in + BYOK only)

- **Type:** enhancement
- **Area:** llm, onboarding, settings, ai
- **Files:** `llm_manager.dart`, `ai_readiness_service.dart`, `ai_engine_mode_store.dart`, `local_llm_flags.dart`, `onboarding_provider_step.dart`, `providers_screen.dart`, `learning_orchestrator.dart`, `lib/l10n/app_*.arb`, `app_localizations_*.dart`
- **Problem / Goal:** Product uses Built-in AI and user-owned cloud providers only; on-device local LLM concept removed from routing, onboarding, and Settings.
- **Solution:** `LlmManager.resolve()` is cloud-only. Persisted `local` engine mode migrates to `cloud` on load. Onboarding shows add-provider or skip (Built-in). Settings engine section is Built-in hint only (no local download/delete UI). Updated onboarding subtitle l10n across all locales.
- **Regression risks:** Daily pack `skipQuota: true`; auto daily quiz `countBuiltinQuota: false`; results banner unit `…/5482634804`; voice interview one-time entitlement; Built-in/BYOK quota and fallback order unchanged. Do not re-enable `kLocalLlmEnabled` without full MLC packaging.
- **Verified:** `flutter analyze` on touched paths (no errors); split release APK build.

## 2026-08-23 — Hosting AdSense Display slot 3346149333

- **Type:** enhancement
- **Area:** hosting
- **Files:** `hosting/ads.js`, `hosting/index.html`, `hosting/privacy/index.html`, `hosting/terms/index.html`, `docs/BACKLOG.md` B10
- **Problem / Goal:** B10 — fixed website banners stayed hidden without a real Display slot ID.
- **Solution:** Wired production slot `3346149333` (client `ca-pub-5325876102788151`) on `homeTop`, `homeBottom`, and `doc`. Loader stays once in each page head; `ads.js` pushes one ad per reserved `ins`. Did not replace `ads.txt` with `app-ads.txt`. Did not use this slot as an in-app AdMob unit (`…/5482634804` unchanged).
- **Regression risks:** Auto ads still depend on AdSense site approval. Reusing one slot on multiple positions is allowed; do not invent extra slot IDs. Do not mix `ca-app-pub` AdMob IDs into website banners.
- **Verified:** Slot values in `ads.js`; `ads.txt` untouched; hosting deploy attempted.

## 2026-08-23 — Persist 2026-08-23 l10n keys in every ARB

- **Type:** enhancement
- **Area:** l10n
- **Files:** `lib/l10n/app_*.arb`, `app_localizations.dart`, `app_localizations_*.dart`
- **Problem / Goal:** B4 — ARB regen could drop `goalTooVague`, `learnPastPathsTitle`, `settingsDailyQuizFrequency`, `settingsAlarmSound`, `interviewVoiceComingSoon`. `resultsNoAnswer` was `-` in non-en ARBs.
- **Solution:** Added the five keys plus `resultsNoAnswer` = `Not answered` to every locale ARB. English stubs for non-en. Also added daily-quiz slot strings for B7.
- **Regression risks:** Non-en copy stays English until translated. Do not regenerate from ARB after removing these keys.
- **Verified:** Keys present in all 14 ARBs; Dart getters retained.

## 2026-08-23 — Daily quiz frequency slot UX

- **Type:** enhancement
- **Area:** quiz, settings, dashboard
- **Files:** `quiz_of_the_day_service.dart`, `daily_quiz_scheduler.dart`, `background_daily_tasks.dart`, `dashboard_screen.dart`, `app_providers.dart`, settings/history/quiz-play invalidates, l10n
- **Problem / Goal:** B7 — Frequency 1–3 looked one-and-done after the first completed daily quiz.
- **Solution:** Home shows "Daily quiz N of M" when frequency > 1. Incomplete quiz is reused. Next slot generates on Generate tap only. First quiz of the day can still auto-schedule. Background Workmanager does not spawn slots 2–3.
- **Regression risks:** Users with frequency 2–3 must tap Generate for later slots (quota-safe). Do not auto-generate all N.
- **Verified:** `flutter analyze` on touched paths.

## 2026-08-23 — Local LLM stays deferred (existing API keys)

- **Type:** enhancement (docs / product decision)
- **Area:** ai, llm
- **Files:** `docs/BACKLOG.md` B3
- **Problem / Goal:** B3 asked whether to build on-device LLM.
- **Solution:** Continue using Built-in / BYOK cloud keys. Do not enable or implement local LLM. `kLocalLlmEnabled` remains false.
- **Regression risks:** None — no runtime change.
- **Verified:** Docs only.

## 2026-08-23 — Hosting AdSense display slots blocked-on-IDs

- **Type:** enhancement (docs)
- **Area:** hosting
- **Files:** `hosting/ads.js`, `docs/BACKLOG.md` B10
- **Problem / Goal:** B10 — fixed banners stay hidden without Display slot IDs.
- **Solution:** Repo/env/docs search found no real `data-ad-slot` numbers. Left slots empty; documented where to paste IDs. Did not invent IDs. Did not replace `ads.txt` with `app-ads.txt`.
- **Regression risks:** Auto ads may still serve; fixed banners stay hidden until real slot IDs are pasted and hosting is redeployed.
- **Verified:** Search for `ca-pub` / `data-ad-slot` — client only, no slot numbers.

## 2026-08-23 — Production banner + rewarded interstitial units

- **Type:** enhancement
- **Area:** ads, quiz results, settings/providers, release
- **Files:** `ad_service.dart`, `ad_unit_ids.dart`, `banner_ad_widget.dart`, `results_screen.dart`, `built_in_quota_dialog.dart`, `test/ad_unit_ids_test.dart`, `docs/BUILT_IN_AI.md`
- **Problem / Goal:** Results banner and AI Providers Watch-ad must use baked production AdMob units only (no test publisher, no empty dart-define).
- **Solution:** Results `BannerAdWidget` already loads `prodBannerAdUnitId` (`…/5482634804`). Quota unlock now loads `prodRewardedInterstitialAdUnitId` (`…/5832808964`) first, then the production rewarded unit if that format does not fill. Standard interstitial stays thank-you-only.
- **Regression risks:** Rewarded interstitial fill can fail on some devices — fallback still grants quota via the production rewarded unit. Support/Settings sponsored ads remain interstitials and must not call `grantAdBonus`.
- **Verified:** Wired to `AppConstants` production IDs; no `ca-app-pub-3940256099942544` test publisher in runtime IDs.

## 2026-08-23 — Missing l10n getters + resultsNoAnswer

- **Type:** enhancement
- **Area:** l10n
- **Files:** `lib/l10n/app_localizations_ar.dart`, `app_localizations_bn.dart`, `app_localizations_de.dart`, `app_localizations_en.dart`, `app_localizations_es.dart`, `app_localizations_fr.dart`, `app_localizations_hi.dart`, `app_localizations_ja.dart`, `app_localizations_ml.dart`, `app_localizations_mr.dart`, `app_localizations_pt.dart`, `app_localizations_ta.dart`, `app_localizations_te.dart`, `app_localizations_zh.dart`
- **Problem / Goal:** Non-English locale implementations were missing `goalTooVague`, `learnPastPathsTitle`, `settingsDailyQuizFrequency`, `settingsAlarmSound`, and `interviewVoiceComingSoon`; `resultsNoAnswer` still returned `-`.
- **Solution:** Inserted the five English stub getters immediately after `goalTopicsRequired` in every non-en locale Dart file; changed `resultsNoAnswer` to `Not answered` in all 14 locale Dart files.
- **Regression risks:** Non-en locales use English stubs until translated. Regenerating l10n from ARB will drop these keys unless each ARB also defines them (except `app_en.arb`, which already has them).
- **Verified:** Grep confirmed all five getters and `resultsNoAnswer => 'Not answered'` in every `app_localizations_*.dart`.

## 2026-08-23 — app-ads.txt + official Play Store links

- **Type:** enhancement
- **Area:** hosting, support, store, legal
- **Files:** `hosting/app-ads.txt`, `hosting/index.html`, `hosting/styles.css`, `hosting/privacy/index.html`, `hosting/terms/index.html`, `support_screen.dart`, `app_constants.dart`, `assets/legal/privacy_v1_en.md`, `assets/legal/terms_v1_en.md`, `docs/store/LISTING.md`
- **Problem / Goal:** AdMob needs `app-ads.txt` at the Firebase Hosting root; Share/Rate still treated the listing as unreleased.
- **Solution:** Added `hosting/app-ads.txt` (same publisher line as `ads.txt`); Rate opens the official Play listing; Share appends that URL; public site + in-app legal/store drafts now link to it.
- **Regression risks:** Hosting `public` remains `hosting/`; do not replace `ads.txt` (website AdSense) with `app-ads.txt` (AdMob). Rate falls back to the unreleased snackbar only if the store URL fails to launch.
- **Verified:** `app-ads.txt` content matches the required AdMob line; Support Rate/Share wired to `AppConstants.playStoreUrl`.

## 2026-07-29 — Full PC migration backup zip + guide

- **Type:** enhancement
- **Area:** tooling
- **Files:** `docs/MIGRATION_BACKUP.md`, `c:\dev\learn-anything-backup-2026-07-29.zip` (sibling archive)
- **Problem / Goal:** Move Learn Anything to a new PC with source, Firebase configs, Play signing secrets, and Built-in AI dart defines intact.
- **Solution:** Documented restore steps; staged robocopy excluding build caches; zip includes key.properties, keystores, and `.local_dart_defines.json`.
- **Regression risks:** Zip contains secrets — must stay private; do not commit archive into the repo or public remotes.
- **Verified:** Staging Test-Path checks for secrets before zip; archive written outside repo.

## 2026-07-28 — Fix hosting layout alignment / CSS load

- **Type:** enhancement
- **Area:** hosting
- **Files:** `hosting/index.html`, `hosting/styles.css`, `hosting/privacy/index.html`, `hosting/terms/index.html`, `firebase.json`
- **Problem / Goal:** Live homepage rendered unstyled (stacked links, no padding) — stylesheet not applying / layout misaligned.
- **Solution:** Centered `.page` shell, flex topbar with aligned logo+wordmark, cache-busted CSS link, light `color-scheme`, shorter CSS cache headers.
- **Regression risks:** Relative `styles.css` on home; absolute `/styles.css?v=…` on legal pages.
- **Verified:** Firebase Hosting deploy exit 0.

## 2026-07-28 — AdSense on Firebase Hosting

- **Type:** enhancement
- **Area:** hosting, monetization
- **Files:** `hosting/index.html`, `hosting/privacy/index.html`, `hosting/terms/index.html`, `hosting/ads.js`, `hosting/ads.txt`, `hosting/styles.css`, `assets/legal/privacy_v1_en.md`
- **Problem / Goal:** Add Google AdSense (`pub-5325876102788151`) banner support on the public site.
- **Solution:** Site-wide AdSense client script + `google-adsense-account` meta (Auto ads); `ads.txt`; banner placeholders wired via `ads.js` slot config; privacy copy mentions website AdSense.
- **Regression risks:** Fixed banners stay hidden until Display slot IDs are pasted into `hosting/ads.js`; Auto ads must be enabled in AdSense for the site to show ads without slots. Do not reuse AdMob (`ca-app-pub`) unit IDs as AdSense slots.
- **Verified:** Firebase Hosting deploy exit 0; ads.txt at site root.

## 2026-07-28 — Hosting minimalist landing redesign

- **Type:** enhancement
- **Area:** hosting, branding
- **Files:** `hosting/index.html`, `hosting/styles.css`
- **Problem / Goal:** Restyle public site to a clean white minimalist layout (logo nav, serif hero, feature image, orange CTA) while keeping support contact.
- **Solution:** Spoony/minimal topbar + split hero with feature graphic; features strip; support mailto hassmireventures@gmail.com; light theme shared with privacy/terms.
- **Regression risks:** Dark gold theme removed; legal pages now light background via shared CSS.
- **Verified:** Firebase Hosting deploy exit 0.

## 2026-07-28 — Hosting homepage brand, feature image, support

- **Type:** enhancement
- **Area:** hosting, branding
- **Files:** `hosting/index.html`, `hosting/styles.css`, `hosting/assets/learn_anything_logo.png`, `hosting/assets/feature_image.png`
- **Problem / Goal:** Public site needed logo, feature graphic, clearer support contact, and a stronger black/gold brand look.
- **Solution:** Full-bleed feature hero, header logo lockup, support card with hassmireventures@gmail.com, gold/silver dark theme; assets copied under `hosting/assets/`.
- **Regression risks:** Privacy/terms pages still use shared `styles.css` (gold accents); asset filenames use underscores (no spaces).
- **Verified:** Assets copied; Firebase Hosting deploy exit 0.

## 2026-07-28 — Privacy/terms contact details on Firebase Hosting

- **Type:** enhancement
- **Area:** legal, hosting, store
- **Files:** `hosting/privacy/index.html`, `hosting/terms/index.html`, `assets/legal/privacy_v1_en.md`, `assets/legal/terms_v1_en.md`
- **Problem / Goal:** Play listing uses `https://learn-anything-43970.web.app/privacy`; contact block needed clear publisher/support details.
- **Solution:** Contact sections now list Hassmire Ventures, hassmireventures@gmail.com, and the hosting website; last-updated set to July 28, 2026; redeployed Firebase Hosting.
- **Regression risks:** In-app legal markdown ships with next app release; live site is already updated.
- **Verified:** Hosting deploy exit 0; live privacy page shows publisher + support email.

## 2026-07-26 — Quota restore, grounded paths, interview drill, l10n

- **Type:** enhancement
- **Area:** quota, learn, career, library, l10n, background
- **Files:** `background_daily_tasks.dart`, `daily_content_service.dart`, `daily_content_detail_screen.dart`, `drill_create_screen.dart`, `learning_orchestrator.dart`, `generation_job_service.dart`, `learn_screen.dart`, `path_detail_screen.dart`, `app_shell.dart`, `app_en.arb`, `app_localizations*.dart`, `docs/BUILT_IN_AI.md`
- **Problem / Goal:** Rolling 24h Built-in quota must restore in background/resume; daily content must not swallow quota errors; career drills need resume/JD grounding and self-intro; completed paths need regenerate CTA; library errors and “From my content” need l10n.
- **Solution:** `quotaRestoreTask` Workmanager (~15 min) + `restoreIfExpired()` on every callback; daily pack quota preflight + rethrow `BuiltInQuotaExceededException`; interview drill themes/company/grounded mode + orchestrator self-intro prepend; Learn “From my content” grounded path; path completion card; app resume invalidates `builtInQuotaProvider`; new l10n keys; BUILT_IN_AI.md rolling 24h note.
- **Regression risks:** Workmanager 15 min minimum on Android; temporary grounded consent when generating from library; self-intro prepends only when resume indexed.
- **Verified:** Lints clean on edited Dart files; l10n stubs added to all locale implementations.

## 2026-07-26 — RAG sourceTypes + library excerpt priority in prompts

- **Type:** enhancement
- **Area:** quiz, learn, RAG, goal agent
- **Files:** `lib/core/agents/goal_agent.dart`, `lib/data/remote/ai/learning_orchestrator.dart`, `lib/data/remote/ai/path_prompt_builder.dart`, `lib/data/remote/ai/prompt_builder.dart`
- **Problem / Goal:** Quiz/path/GoalAgent RAG calls passed `enabledSourceUuids` but not `sourceTypes`, so resume/JD/notes boost was skipped; prompts lacked explicit library-excerpt priority guidance.
- **Solution:** Fetch `knowledgeRepository.enabledSourceTypes(goalMode)` at each `AiRequestContext` call site and pass `sourceTypes`; add brief resume/JD/notes priority + light-normalization notes to path and quiz prompt builders when RAG is present.
- **Regression risks:** RAG prompt prefix formatting in quiz/path generation; grounded RAG weaker until user opts into chunk send.
- **Verified:** Lints clean on edited Dart files; all three `AiRequestContext` call sites now pass `sourceTypes`.

## 2026-07-26 — Split release APK with Built-in AI key

- **Type:** enhancement
- **Area:** android, release
- **Files:** `android/app/build.gradle.kts` (Crashlytics mapping upload tasks hard-disabled), `tool/.local_dart_defines.json` (gitignored), `.gitignore`
- **Problem / Goal:** Produce signed `--split-per-abi` release APKs with the existing Built-in AI key for device install.
- **Solution:** Built via `--dart-define-from-file`; Crashlytics `uploadCrashlyticsMappingFile*` tasks disabled so local builds do not depend on Google DNS; key kept out of git.
- **Regression risks:** Client-embedded Built-in key remains extractable — rotate if leaked; Crashlytics deobfuscation mapping not uploaded from this local path.
- **Verified:** `flutter build apk --release --split-per-abi` exit 0 — arm64 39.6MB, armeabi-v7a 38.0MB, x86_64 41.2MB under `build/app/outputs/flutter-apk/`.

## 2026-07-24 — Challenge share/import l10n getters

- **Type:** enhancement
- **Area:** l10n, quiz share, settings
- **Files:** `app_localizations.dart`, `app_localizations_*.dart`, `app_*.arb` (non-en stubs; `app_en.arb` already had keys)
- **Problem / Goal:** Add localization for challenge share CTA and Settings import-challenge strings across all locales.
- **Solution:** Added `resultsShareChallengeCta`, `settingsImportChallenge`, `settingsImportChallengeSubtitle`, `settingsImportChallengeReady`, and `settingsImportChallengeFailed` to the abstract class and every locale implementation; mirrored English values into non-en ARBs that already had related keys.
- **Regression risks:** Non-en locales currently use English stubs for these keys until translated; regenerating l10n from ARB should keep placement after `resultsShareText` / `settingsImportData`.
- **Verified:** Grep confirmed all five keys present in abstract + 14 locale Dart files and matching ARB stubs.

## 2026-07-24 — Daily content copy: article and video

- **Type:** enhancement
- **Area:** l10n, daily content
- **Files:** `app_localizations_*.dart` (non-en), `app_*.arb` (non-en)
- **Problem / Goal:** Daily content strings still said “article or video” / “learning resource” in non-English locale files after English was updated.
- **Solution:** Replaced `dailyContentReadyBody`, `dailyContentCardSubtitle`, and `dailyContentGenerating` with article-and-video wording across remaining locales (ARB keys present only for subtitle + generating).
- **Regression risks:** Non-en ARBs still omit `dailyContentReadyBody` (Dart fallbacks carry the English string); regenerating l10n from ARB alone would not rewrite that key until added to each ARB.
- **Verified:** Grep confirmed no remaining old English strings in `lib/l10n`.

## 2026-07-21 — Insights tokens + topic legend; settings cleanup

- **Type:** enhancement
- **Area:** dashboard, settings, privacy
- **Files:** `insights_expand_sheet.dart`, `dashboard_charts.dart`, `settings_screen.dart`, l10n
- **Problem / Goal:** Insights AI usage lacked a clear token total; topic pie had no titles; Help improve lacked explanation.
- **Solution:** Insights shows `settingsAiTokensTodayLabel` total; topic pie legend with title+count; Help improve info dialog for anonymized signals.
- **Regression risks:** Topic chart aspect ratio tightened for legend space.
- **Verified:** Static review + analyze on touched paths.

## 2026-07-21 — Transcript-first module notes + regenerate

- **Type:** enhancement
- **Area:** learn, ai
- **Files:** `learning_orchestrator.dart`, `path_detail_screen.dart`, `module_notes_cache.dart`, l10n
- **Problem / Goal:** Notes should prioritize video captions; disclose usage only after content; allow regenerating cached notes.
- **Solution:** Harden summarize prompt for transcript-only grounding when captions exist; JSON is notes-only; `usedTranscript` from fetch only; always show source footer; Regenerate button; cache key bumped to `module_notes_v2`.
- **Regression risks:** Summarizer still uses Built-in/BYOK quota; old v1 cache ignored (fresh generate or regenerate); footer never embeds meta into markdown body.
- **Verified:** Analyze on touched paths.

## 2026-07-20 — Keystore backup + signed split release APK

- **Type:** enhancement
- **Area:** android, release, store, docs
- **Files:** `android/app/upload-keystore.jks` (gitignored copy for Gradle), `.gitignore`, `android/key.properties.example`, `docs/PLAY_STORE_CHECKLIST.md`
- **Problem / Goal:** Offline keystore backup and a signed `--split-per-abi` release APK with Built-in AI key retained via dart-define.
- **Solution:** Backed up jks/`key.properties` to OneDrive `LearnAnything-Secrets`; placed keystore where Gradle `android/app` signing expects it; built release APKs with upload signing (no `ALLOW_DEBUG_SIGNING`).
- **Regression risks:** Client-embedded Built-in key remains extractable — rotate if leaked; keep OneDrive backup private; do not commit keystore files.
- **Verified:** `flutter build apk --release --split-per-abi` exit 0 — arm64 39.2MB, armeabi-v7a 37.6MB, x86_64 40.8MB under `build/app/outputs/flutter-apk/`.

## 2026-07-19 — Firebase Hosting for privacy / terms

- **Type:** enhancement
- **Area:** store, legal, firebase, docs
- **Files:** `hosting/`, `firebase.json`, `app_constants.dart`, `docs/store/LISTING.md`, `docs/PLAY_STORE_CHECKLIST.md`
- **Problem / Goal:** Serve live privacy/terms pages required for Play Store without a custom domain yet.
- **Solution:** Static Firebase Hosting site from legal markdown; merge `hosting` into `firebase.json`; deploy to `learn-anything-43970`; point `AppConstants` at `*.web.app` URLs.
- **Regression risks:** Custom domain `learnanything.app` still needs DNS before switching URLs back; keep hosting HTML in sync with `assets/legal` markdown.
- **Verified:** `firebase deploy --only hosting` exit 0.

## 2026-07-17 — Prod AdMob, Crashlytics, Firestore rules, store drafts

- **Type:** enhancement
- **Area:** ads, firebase, crashlytics, android, store, docs
- **Files:** `app_constants.dart`, `ad_unit_ids.dart`, `AndroidManifest.xml`, `ci.yml`, `pubspec.yaml`, `app_bootstrap.dart`, `main.dart`, `anon_analytics_sync.dart`, `firestore.rules`, `firebase.json`, `android/settings.gradle.kts`, `android/app/build.gradle.kts`, `.gitignore`, `test/ad_unit_ids_test.dart`, `docs/store/LISTING.md`, `docs/PLAY_STORE_CHECKLIST.md`, `docs/BUILT_IN_AI.md`, `tool/check_release_hygiene.dart`
- **Problem / Goal:** Ship agent-doable Play Store gates: real AdMob IDs, crash reporting, Firestore rules, local upload keystore, listing drafts.
- **Solution:** Baked all production AdMob IDs and removed `USE_TEST_ADS` path; manifest prod App ID; CI builds without test-ad define; `firebase_crashlytics` + `AppLogger.crashSink`; deployed `firestore.rules` and defaulted `ENABLE_FIRESTORE_ANALYTICS` on; generated gitignored upload keystore; store listing drafts.
- **Regression risks:** Real ad units may show live ads in debug; analytics writes need App Check for stronger abuse resistance; losing the local keystore blocks Play updates for that upload key; hosted privacy/terms URLs still must be live before store.
- **Verified:** Hygiene gate pass; unit tests for AdMob IDs; Firestore deploy exit 0; keystore files present and gitignored patterns added.

## 2026-07-17 — Firebase FlutterFire configure (learn-anything-43970)

- **Type:** enhancement
- **Area:** firebase, android, ios, docs
- **Files:** `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, `scripts/configure_firebase.ps1`, `test/firebase_availability_test.dart`, `test/widget_test.dart`, `docs/PLAY_STORE_CHECKLIST.md`, `docs/reviews/production-readiness.md`
- **Problem / Goal:** Replace `REPLACE_WITH_*` Firebase placeholders with real project config so `Firebase.initializeApp` can run.
- **Solution:** `flutterfire configure --project=learn-anything-43970` for Android + iOS; keep `isConfigured` helpers; leave `ENABLE_FIRESTORE_ANALYTICS` default false; refresh configure script and tests.
- **Regression risks:** Client API keys are public-by-design — do not enable Firestore writes without Console rules/App Check; CI/local builds now attempt Firebase init when options resolve.
- **Verified:** Configure exit 0; no placeholder values in google-services.json; `DefaultFirebaseOptions.isConfigured` true.

## 2026-07-17 — Smart generation size + background wait

- **Type:** enhancement
- **Area:** quiz, learn, ai, ui
- **Files:** `generation_sizing.dart`, `generation_job_service.dart`, `generation_overlay.dart`, `create_quiz_screen.dart`, `learn_screen.dart`, l10n, `PROJECT_LOG.md`
- **Problem / Goal:** Long quiz/path waits felt blocking; Built-in jobs needed leaner payloads and an explicit way to keep generating while browsing.
- **Solution:** Clamp Built-in quizzes to max 10 Qs without explanations and paths to 4 modules; overlay shows **Continue in background** after 10s (`continueInBackground` keeps the job running); non-blocking strip on Create/Learn when overlay is dismissed; leave-screen also detaches UI wait.
- **Regression risks:** Soft Cancel still differs from background (cancel stops UI wait and marks cancelled); Create Quiz pops when continuing in background if `canPop`; Built-in clamps override user depth/count with a snackbar.
- **Verified:** IDE lints clean on touched files.

## 2026-07-17 — Faster quiz/path generation (cloud-only, lean prompts)

- **Type:** enhancement
- **Area:** ai, quiz, learn, settings, onboarding
- **Files:** `built_in_ai_config.dart`, `path_prompt_builder.dart`, `learning_orchestrator.dart`, `llm_manager.dart`, `local_llm_flags.dart`, `providers_screen.dart`, `onboarding_provider_step.dart`, `ai_provider.dart`, `generation_job_service.dart`, `learn_screen.dart`, `docs/BUILT_IN_AI.md`, l10n
- **Problem / Goal:** Quiz/path generation felt much slower than the classic OneDrive AI Quiz App (cloud BYOK, lean path prompts, no local LLM).
- **Solution:** Switch Built-in to `meta/llama-3.1-8b-instruct` with BYOK-like sampling/90s timeout; prefer BYOK over Built-in when both have keys; shrink path prompt to 4–6 modules (1–2 docs each); disable on-device MLC (`kLocalLlmEnabled=false`) and hide local engine UI. Follow-up: `AiProviderType.builtin` now shares `BuiltInAiConfig` model/URL (no leftover Nemotron 49B default); `GenerationJobService.startPath` default `moduleCount` is 6; Learn path-depth control is 4/5/6 (was 6/10/12, which the prompt clamped anyway).
- **Regression risks:** Smaller Built-in model may produce slightly weaker quizzes; existing installs refresh Built-in model id on next seed; path plans are shorter (max 6 modules).
- **Verified:** Static wiring; compared hot path to classic orchestrator/path prompt; local UI gated; seed refresh path confirmed. Test with rebuild + `--dart-define=BUILT_IN_AI_API_KEY=...` or BYOK.

## 2026-07-17 — AI brief Home-only + connection tip dialog; no em dashes

- **Type:** enhancement
- **Area:** settings, ai, l10n
- **Files:** `providers_screen.dart`, `settings_screen.dart`, `ai_study_pulse_service.dart`, `app_en.arb`, `app_localizations_*.dart`, other locale ARBs
- **Problem / Goal:** Keep the persistent AI brief on Home only; Providers Test connection should show an ephemeral tip (not Home cache); remove em/en dashes from app copy.
- **Solution:** Removed pulse cards from Settings/Providers; added `AiStudyPulseService.loadOnce` + one-shot dialog after handshake; prompt + output sanitize dashes; replaced `—`/`–` (and mojibake) with ASCII ` - ` / `-` across l10n and lib copy.
- **Regression risks:** Test connection still takes longer (handshake + chat); dialog tip does not update Home brief; Home daily cache unchanged.
- **Verified:** Static wiring; lib scan shows zero em/en dashes.

## 2026-07-16 — AI Study Pulse on Settings / Providers

- **Type:** enhancement
- **Area:** settings, ai
- **Files:** `settings_screen.dart`, `providers_screen.dart`
- **Problem / Goal:** Home had the AI brief probe; Settings “Test connection” only pinged `/models` and Settings AI section had no pulse card.
- **Solution:** Reuse `AiStudyPulseCard` on Settings → AI and Providers; editor **Test connection** also refreshes the study pulse and shows the brief or **AI Offline**.
- **Regression risks:** Test connection takes longer (handshake + chat); still does not burn Built-in quota.
- **Verified:** Static wiring; lints on touched screens.

## 2026-07-16 — AI Study Pulse connection probe on Home

- **Type:** enhancement
- **Area:** dashboard, ai
- **Files:** `ai_study_pulse_service.dart`, `ai_status_service.dart`, `ai_study_pulse_card.dart`, `dashboard_screen.dart`, `llm_manager.dart`, `ai_json_client.dart`, `built_in_ai_config.dart`, l10n
- **Problem / Goal:** Users needed a clear way to confirm AI chat endpoints work (not only `/models` handshake), with personalized content or an explicit offline state.
- **Solution:** Home “Today’s AI brief” card calls a short JSON chat completion using goal/weak/focus context; caches once per day; never records Built-in quota; shows `AI Offline` on failure; tap refreshes and re-checks the status badge.
- **Regression risks:** First open of the day hits the chat API (45s timeout); empty/unparseable model text surfaces as offline; quota unchanged but still uses network/tokens on the provider side.
- **Verified:** IDE lints clean on touched files.

## 2026-07-16 — Built-in AI default + quotas + rewarded ads

- **Type:** enhancement
- **Area:** ai, onboarding, settings, ads
- **Files:** `built_in_ai_config.dart`, `built_in_ai_quota.dart`, `provider_repository.dart`, `ai_provider.dart`, `llm_manager.dart`, `ai_request_pipeline.dart`, `learning_orchestrator.dart`, `welcome_screen.dart`, `providers_screen.dart`, `ad_service.dart`, `built_in_quota_dialog.dart`, `docs/BUILT_IN_AI.md`, l10n
- **Problem / Goal:** Silent default cloud AI without onboarding engine picker; meter shared key with ads unlock; keep Local Coming soon.
- **Solution:** Seed `AiProviderType.builtin` from `--dart-define=BUILT_IN_AI_API_KEY`; legal-only onboarding page; 5 free gens/day +3 per rewarded ad (max 3); unlock sheet; BYOK uncapped; Local still gated.
- **Regression risks:** Client-side key is extractable; create a real production rewarded AdMob unit; rotate any key that was pasted in chat.
- **Verified:** Static wiring; run release with dart-define + smoke generate / quota dialog.

## 2026-07-15 — Local LLM Coming soon + split release

- **Type:** enhancement
- **Area:** llm, onboarding, settings, release
- **Files:** `local_llm_flags.dart`, `llm_manager.dart`, `app_providers.dart`, `onboarding_provider_step.dart`, `providers_screen.dart`, l10n (`app_en.arb` + locales), `MLC_ANDROID_SETUP.md`
- **Problem / Goal:** Windows `mlc4j` packaging is blocked; shipable release should not offer a broken on-device path.
- **Solution:** `kLocalLlmComingSoon` gate — local visible but disabled (Coming soon); ignore persisted local mode in resolve/UI; cloud + skip unchanged. Clean `flutter build apk --release --split-per-abi` with `ALLOW_DEBUG_SIGNING`.
- **Regression risks:** Flip `kLocalLlmComingSoon` only after `mlc4j` exists; do not re-enable downloads while stub runtime remains.
- **Verified:** (pending split APK sizes after build)

## 2026-07-15 — MLC Windows package: TIR shims, blocked on tvm_ffi ABI

- **Type:** enhancement
- **Area:** llm, android, docs, tooling
- **Files:** `scripts/mlc_compile_launch.py`, `scripts/mlc_tvm_compat.py`, `docs/MLC_ANDROID_SETUP.md`, venv `mlc_llm` wheel patches (`T.int32()` after strip)
- **Problem / Goal:** Finish host `mlc_llm package` so `android/mlc/dist/lib/mlc4j` exists for real on-device engine.
- **Solution:** Compat shim (PrimExpr/SizeVar/`is_size_var`); fixed bare `T.int32` left by kwarg strip; compile launcher smoke path. Phi-2 weights cached. Hits hard stop: PyPI `apache-tvm-ffi` 0.1.12 vs `mlc-ai-nightly` Stringify ABI → `0xc0000005` in `tvm_ffi.dll` during `attach_sampler` parse. Documented Linux/WSL or rebuild ffi / drop-in mlc4j.
- **Regression risks:** Leaving Stringify import renames in place will keep crashing compile; do not ship partially patched host DLLs as required for packaging.
- **Verified:** Crash Event Log (fault module `tvm_ffi.dll`); smoke import dies after shim on `attach_sampler`; no `mlc4j` yet.

## 2026-07-14 — Local LLM status UI + delete; MLC package blocked

- **Type:** enhancement
- **Area:** llm, settings, docs
- **Files:** `providers_screen.dart`, `local_llm_channel.dart`, `LlmMethodChannel.kt`, `ModelDownloadService.kt`, `MLC_ANDROID_SETUP.md`
- **Problem / Goal:** Users could not see model storage path, download progress, Online vs stub, or free space by deleting weights; packaging needs local mlc-llm.
- **Solution:** Surface path + progress + status chip + Delete model; strict config ready gate; docs for full zip. Packaging attempt: missing `MLC_LLM_SOURCE_DIR` / `mlc_llm` — rebuild is stub arm64 until dist exists.
- **Regression risks:** Without hosted full zip, Download still incomplete by design; delete clears engine handle.
- **Verified:** Channel `deleteModel` + Settings confirm dialog wired.

## 2026-07-14 — MLC package script + on-device readiness path

- **Type:** enhancement
- **Area:** llm, android, docs
- **Files:** `scripts/package_mlc.ps1`, `docs/MLC_ANDROID_SETUP.md`
- **Problem / Goal:** No Windows packaging helper for `mlc4j`; on-device Online requires packaged runtime, not model download alone.
- **Solution:** Add `package_mlc.ps1` (validates `MLC_LLM_SOURCE_DIR`, runs `mlc_llm package`); document drop-in prebuilt `android/mlc/dist/lib/mlc4j` so Gradle enables real `LocalLLMEngine` / Online when RAM + model + runtime OK.
- **Regression risks:** Without mlc4j dist, builds still use stub — expected; packaging still needs local mlc-llm + conda.
- **Verified:** Script present; dist absent on this machine (stub path unchanged).

## 2026-07-13 — Settings chips removed; goal buttons; appearance SegmentedButton

- **Type:** enhancement
- **Area:** settings
- **Files:** `lib/features/settings/presentation/settings_screen.dart`
- **Problem / Goal:** Section jump ActionChips cluttered Settings; Switch/Add goal heights mismatched; appearance SegmentedButton font felt smaller than title.
- **Solution:** Removed jump chips + GlobalKeys; shared minimumSize/compact style on goal outline buttons; SegmentedButton uses titleSmall + comfortable density.
- **Regression risks:** Long translated “Switch goal” labels may still ellipsize — intentional.
- **Verified:** IDE lints clean; visual QA in dark mode recommended.

## 2026-07-13 — UI/UX ARB Should-gate implementations

- **Type:** enhancement
- **Area:** ux, ui, a11y, settings, onboarding, learn, quiz, dashboard, i18n, branding
- **Files:** `supported_languages.dart`, `app.dart`, `resource_webview_screen.dart`, `quiz_play_screen.dart`, `welcome_screen.dart`, `settings_screen.dart`, `support_screen.dart`, `dashboard_screen.dart`, `mock_create_screen.dart`, `skill_matrix_screen.dart`, `dashboard_charts.dart`, `metric_honesty_banner.dart`, `tour_steps.dart`, `providers_screen.dart`, `app_en.arb`, `app_localizations_en.dart`, `README.md`
- **Problem / Goal:** Complete ARB UI/UX Should items — broken locales, multiplayer leftovers, WebView safety, a11y, settings discoverability, honesty on exam/career metrics, brand strings, ads framing.
- **Solution:** Ship-ready locale allowlist (drop broken ta/bn/ml/mr); user sites open externally; Semantics on quiz/onboarding/charts; Settings jump chips; MetricHonestyBanner on exam/career surfaces; donate-first Support; brand “Learn Anything” copy; HTTPS warning for custom providers; README updated.
- **Regression risks:** Users previously on Tamil/Bengali/etc. fall back to English; user library URLs no longer render in-app WebView; Settings is now Stateful — verify ExpansionTile jump scroll on long lists.
- **Verified:** `dart analyze` on touched files (settings export fields fixed); `flutter test` passed in session.

## 2026-07-13 — ARB Must-gate production upgrades

- **Type:** enhancement
- **Area:** security, privacy, devops, onboarding, ai, testing, governance
- **Files:** `android/app/build.gradle.kts`, `ModelDownloadService.kt`, `ModelCatalog.kt`, `AndroidManifest.xml`, `network_security_config.xml`, `ai_consent_gate.dart`, `ad_consent_service.dart`, `app_bootstrap.dart`, `anon_analytics_sync.dart`, `ad_unit_ids.dart`, `app_constants.dart`, `onboarding_provider_step.dart`, `welcome_screen.dart`, `isar_service.dart`, `app_logger.dart`, `.github/workflows/ci.yml`, `tool/check_release_hygiene.dart`, `test/ai_platform_test.dart`, `test/must_gates_test.dart`, `docs/adr/0001-product-wedge.md`
- **Problem / Goal:** Implement ARB Must items (Q1–Q8, Q11, M1–M4, M9) for limited production readiness.
- **Solution:** Release signing via `key.properties` (CI `ALLOW_DEBUG_SIGNING`); Zip Slip–safe unzip + optional SHA pin; cleartext off + network security config; chunk send default opt-in false; UMP consent fail-closed before ads; hygiene CI + release APK build; demo-first onboarding CTA; Firestore analytics writes gated off; AI platform unit tests; AppLogger scrub + crash sink hook; Isar schema version file; product-wedge ADR.
- **Regression risks:** Ads may not load until UMP succeeds; grounded RAG weaker until user opts into chunk send; release builds fail without keystore unless `ALLOW_DEBUG_SIGNING=true`; set `ModelCatalog.EXPECTED_ARCHIVE_SHA256` before relying on model downloads in prod.
- **Verified:** `dart run tool/check_release_hygiene.dart`; `flutter test` — 26 tests passed.

## 2026-07-13 — Multi-model ARB codebase review docs

- **Type:** enhancement
- **Area:** docs, governance, production-readiness
- **Files:** `docs/reviews/*` (MASTER_REPORT, executive-summary, product/ui/ux/ai/architecture/backend/frontend/security/governance/compliance/scalability/cloud/performance/code-simplification/technical-debt/risk-register/production-readiness/billion-dollar-roadmap/action-items)
- **Problem / Goal:** Independent multi-model Architecture Review Board assessment of the full repo against billion-user / UX-first ambitions; produce actionable backlog without applying code fixes.
- **Solution:** Parallel reviews (Sonnet, Composer, Grok, GPT-5.6) synthesized into consensus vs lone findings, scorecard (~43/100), **Not Ready** verdict, and 30/90/12-month roadmaps under `docs/reviews/`.
- **Regression risks:** None to runtime — documentation only. Do not treat “Approve with Conditions” minority as store clearance; gates in `production-readiness.md` remain required.
- **Verified:** All 21 required review files written; index in `MASTER_REPORT.md`.

## 2026-07-13 — Settings rename top + reminder Save

- **Type:** enhancement
- **Area:** settings, reminders, onboarding
- **Files:** `lib/features/settings/presentation/settings_screen.dart`, `lib/features/reminders/presentation/reminder_setup_sheet.dart`
- **Problem / Goal:** Profile rename was buried under Your goals; reminder sheet had no explicit Save/Done so onboarding/settings felt unfinished and summary lagged.
- **Solution:** Rename `AppCard` first in Settings (above ExpansionTiles); ReminderSetupSheet Save button closes sheet; `reminderPrefsTickProvider` refreshes `ReminderSummaryButton` subtitle.
- **Regression risks:** Toggle auto-save still runs; Save is idempotent schedule + dismiss — avoid treating double schedule as failure.
- **Verified:** IDE lints on touched files; open sheet from Settings + onboarding recommended.

## 2026-07-13 — Settings dark contrast + compact headers

- **Type:** enhancement
- **Area:** settings, theme, dashboard
- **Files:** `lib/shared/widgets/dashboard/dashboard_page_scaffold.dart`, `geometric_wavy_header.dart`, `lib/core/theme/app_theme.dart`, `settings_screen.dart`, `providers_screen.dart`
- **Problem / Goal:** Settings body used a forced light surface under dark-mode text (unreadable ExpansionTiles); wavy headers were oversized.
- **Solution:** Theme-aware scaffold background; ExpansionTile/ListTile contrast; darker `onSurfaceVariant`; header default height 112 (Settings 100); compact Providers AppBar.
- **Regression risks:** Home/Learn/History headers also shorter; verify badge/back actions still fit.
- **Verified:** IDE lints clean; visual QA in dark + light mode recommended.

## 2026-07-09 — Provider guidance and empty-state hints

- **Type:** enhancement
- **Area:** settings, onboarding, learn
- **Files:** `lib/shared/widgets/guidance/provider_guide_sheet.dart`, `external_link_confirm_dialog.dart`, `empty_state_guide.dart`, `providers_screen.dart`, `onboarding_provider_step.dart`, `learn_screen.dart`
- **Problem / Goal:** API key setup was opaque; empty Learn states gave no next step.
- **Solution:** Per-provider guide bottom sheet with numbered steps and browser confirm; dismissible contextual hints on Learn empty paths/topics.
- **Regression risks:** External URL launches; hint dismissal persistence via `GuidancePreferencesStore`.
- **Verified:** Code compiles; manual provider guide flow recommended.

## 2026-07-09 — Dashboard visual redesign (inspired layout)

- **Type:** enhancement
- **Area:** dashboard, navigation, theme
- **Files:**
  - `lib/core/theme/app_theme.dart` — purple/coral palette, typography getters, 24/16 spacing, nav indicator
  - `lib/shared/widgets/dashboard/geometric_wavy_header.dart`
  - `lib/shared/widgets/dashboard/horizontal_feature_card.dart`
  - `lib/shared/widgets/dashboard/vertical_recommendation_card.dart`
  - `lib/shared/widgets/dashboard/dashboard_section_header.dart`
  - `lib/shared/widgets/dashboard/filter_chip_row.dart`
  - `lib/shared/widgets/dashboard/dashboard_chart_card.dart`
  - `lib/shared/widgets/dashboard/dashboard_charts.dart`
  - `lib/features/dashboard/presentation/dashboard_screen.dart`
  - `lib/features/dashboard/presentation/recommendations_expand_sheet.dart`
  - `lib/features/dashboard/presentation/insights_expand_sheet.dart`
  - `lib/shared/widgets/main_bottom_nav.dart`
  - `lib/shared/navigation/recommendation_navigation.dart`
  - `pubspec.yaml` — added `community_charts_flutter`
  - `lib/l10n/app_en.arb`, `app_localizations.dart`, `app_localizations_*.dart` — See all, recommendations, filter labels
- **Problem / Goal:** Dashboard needed mockup-inspired visual polish (gradients, wavy header, horizontal feature cards, vertical recommendation rows, filter chips) while keeping all existing Riverpod data, section ordering, routes, and l10n semantics unchanged.
- **Solution:**
  - Replaced `SliverAppBar` with `GeometricWavyHeader` (greeting + goal context subtitle).
  - Quiz of the Day + top recommendations in a horizontal `ListView` with `HorizontalFeatureCard` (primary coral / secondary white).
  - Learning Pulse + weak/focus topics as a Business-style horizontal row (blue-gradient primary + secondary cards).
  - "See all" opens `recommendations_expand_sheet` (coral header, `FilterChipRow`, `VerticalRecommendationCard` list).
  - Analytics charts migrated from `fl_chart` to `community_charts_flutter` inside `DashboardChartCard` (`AspectRatio` 1.7).
  - Bottom nav restyled: outlined icons (Home / Learn / Play / History), white bar, upward shadow, purple M3 indicator pill.
  - Presentation-only: no changes to providers, repos, `DashboardSectionPlanner`, or router.
- **Regression risks:** Chart rendering when stats empty or `degradeCharts` active; horizontal card overflow on compact widths (~360dp); recommendation sheet empty state; `AiStatusBadge` contrast on purple header.
- **Verified:** `flutter analyze` on changed files (no errors); manual device test recommended for pull-to-refresh, dark mode, and Play tab hide when Firebase unavailable.

## 2026-07-09 — Goal persistence and multi-goal

- **Type:** enhancement
- **Area:** settings, onboarding
- **Files:** `lib/core/models/saved_goal.dart`, `lib/core/services/secondary_goals_store.dart`, `lib/data/local/repositories/learner_repository.dart`, `lib/features/settings/presentation/settings_screen.dart`
- **Problem / Goal:** Settings did not show onboarding goal; no switch/add goal.
- **Solution:** `SavedGoal` model + `SecondaryGoalsStore` JSON persistence; settings card listens to `learnerProfileProvider`; switch goal and add goal actions; stop clearing context on mode chip tap.
- **Regression risks:** Isar schema migration for existing installs; exam/career bootstrap on goal switch.
- **Verified:** build_runner for Isar; manual onboarding → settings check.

## 2026-07-09 — Dashboard insights expand + Balanced font

- **Type:** enhancement
- **Area:** dashboard, settings
- **Files:** `lib/features/dashboard/presentation/insights_expand_sheet.dart`, `lib/features/dashboard/presentation/dashboard_screen.dart`, `lib/features/settings/presentation/settings_screen.dart`
- **Problem / Goal:** Insights only visible via layout mode; Balanced label overflowed SegmentedButton.
- **Solution:** "More insights" button opens bottom sheet; FittedBox on layout segments; analytics loading skeleton.
- **Regression risks:** Chart rendering when stats empty or health degradation active.
- **Verified:** Code compiles.

## 2026-07-09 — Onboarding redesign

- **Type:** enhancement
- **Area:** onboarding
- **Files:** `lib/features/onboarding/presentation/welcome_screen.dart`
- **Problem / Goal:** Disjointed flow (goal before name); no reminders; layout always beginner.
- **Solution:** 4 steps: name → goal+topics → habits/reminders → AI provider; layout default by goal mode; reminder opt-in on step 3.
- **Regression risks:** Existing users skip onboarding; splash gate unchanged.
- **Verified:** Code compiles; fresh install test recommended.

## 2026-07-10 — AI cost dashboard and grounded mode

- **Type:** enhancement
- **Area:** settings, quiz
- **Files:** `lib/core/services/usage_tracker.dart`, `lib/features/settings/presentation/settings_screen.dart`, `lib/features/quiz/presentation/results_screen.dart`, `lib/l10n/app_en.arb`, `app_localizations*.dart`
- **Problem / Goal:** No visibility into daily AI token use; no citation transparency when quizzes use library material.
- **Solution:** Settings AI & Library card shows tokens used today (persisted `AiUsageDaily`); toggles for send-chunks and economy mode; quiz results show "Grounded in your library" with source labels when citation chunk IDs present.
- **Regression risks:** Token totals mismatch if usage recorded outside `UsageTracker`; citation labels missing if chunks deleted after quiz.
- **Verified:** `flutter analyze`; manual grounded quiz → results citation check recommended.

## 2026-07-10 — Remove multiplayer and slim release APK

- **Type:** enhancement
- **Area:** build, navigation, multiplayer
- **Files:**
  - Deleted: `lib/features/multiplayer/`, `lib/data/remote/firestore/multiplayer_repository.dart`, `lib/core/services/deep_link_service.dart`
  - `lib/core/router/app_router.dart`, `lib/shared/widgets/main_bottom_nav.dart`, `lib/features/shell/presentation/app_shell.dart`, `lib/features/dashboard/presentation/dashboard_screen.dart`, `lib/features/quiz/presentation/create_quiz_screen.dart`, `lib/core/providers/app_providers.dart`, `lib/core/personalization/ui_personalization_controller.dart`, `lib/core/constants/app_constants.dart`, `lib/main.dart`
  - `pubspec.yaml` — removed `mobile_scanner`, `qr_flutter`, `app_links`, `fl_chart`
  - `android/app/src/main/AndroidManifest.xml` — removed `CAMERA` permission and multiplayer join intent filters
  - `android/app/build.gradle.kts` — ABI splits, `isMinifyEnabled`, `isShrinkResources`
  - `android/app/proguard-rules.pro` — Flutter/Firebase/Ads/Play Core keep rules
- **Problem / Goal:** Universal release APK was ~99.5 MB; multiplayer (ML Kit QR scanner, Firestore rooms, deep links) was unused scope for a slim single-player build.
- **Solution:** Removed multiplayer feature and dependencies; collapsed shell to 3 tabs (Home / Learn / History); enabled per-ABI APK splits plus R8 minify/shrink for release builds. Kept ads, Firebase analytics, YouTube, WebView, and local multiplayer history display.
- **Regression risks:** Old multiplayer history entries still show via `QuizKind.multiplayer` filter; `aiquiz://join/...` deep links no longer open a room; bottom-nav branch indices are 0=Home, 1=Learn, 2=History; tour no longer includes Play step.
- **Verified:** `dart analyze` on touched router/shell/quiz files (no errors); `flutter build apk --release --split-per-abi` — `app-arm64-v8a-release.apk` 38.8 MB, `app-armeabi-v7a-release.apk` 37.1 MB (was ~99.5 MB universal).

## 2026-07-10 — Learn, History, Settings dashboard scaffold migration

- **Type:** enhancement
- **Area:** learn, history, settings
- **Files:**
  - `lib/features/learn/presentation/learn_screen.dart`
  - `lib/features/history/presentation/history_screen.dart`
  - `lib/features/settings/presentation/settings_screen.dart`
  - `lib/l10n/app_en.arb`, `app_localizations*.dart` — `historySessionCount`
- **Problem / Goal:** Learn, History, and Settings still used legacy `Scaffold`/`AppShellAppBar` while dashboard introduced `DashboardPageScaffold`, section headers, and horizontal feature cards.
- **Solution:**
  - Learn: `DashboardPageScaffold` with goal-context subtitle, pull-to-refresh invalidating personalization/decision providers, `DashboardSectionHeader`, weak-topic horizontal `HorizontalFeatureCard` carousel (200dp).
  - History: wavy header with session-count subtitle, clear-all in header actions, filter chips in slivers, history rows with `dashboardCardRadius` and quiz-kind left accent border.
  - Settings: `DashboardPageScaffold` with back + `AiStatusBadge`; settings grouped into `ExpansionTile` sections using `settingsSection*` l10n keys.
- **Regression risks:** Pull-to-refresh on Learn does not reload paths FutureBuilder; horizontal weak-topic carousel inside vertical scroll; settings ExpansionTile state not persisted across rebuilds; goal switch/add bootstrap unchanged.
- **Verified:** `flutter analyze` on three screen files (no errors).

## 2026-07-10 — Onboarding UI alignment with dashboard design system

- **Type:** enhancement
- **Area:** onboarding
- **Files:**
  - `lib/features/onboarding/presentation/welcome_screen.dart`
  - `lib/features/onboarding/presentation/splash_screen.dart`
  - `lib/features/onboarding/presentation/onboarding_provider_step.dart`
  - `lib/l10n/app_en.arb`, `app_localizations*.dart` — `onboardingStepProgress`
- **Problem / Goal:** Onboarding still used legacy SafeArea + flat progress bar and ad-hoc icon boxes while Home/Learn/History adopted `GeometricWavyHeader`, `AppTheme` tokens, and dashboard card styling.
- **Solution:**
  - Welcome: `GeometricWavyHeader` with per-step title/icon, coral progress bar, notch-safe back overlay; pages wrapped in `DashboardAnimatedSection` with `AppTheme.pageHorizontal` spacing and `AppCard` forms.
  - Goal mode chips use `AppTheme.sectionAccent` for selected state; removed obsolete `layoutMode` / `layoutModeOverride` writes from `_finishOnboarding`.
  - Splash: purple→coral gradient and top safe-area padding on logo stack.
  - Provider step: `AppCard` form + legal consent inset; `showHeader: false` when title lives in parent header.
- **Regression risks:** Existing users skip onboarding; splash gate (`profile == null` → `/welcome`) unchanged; 4-step PageView validation and reminder sheet on habits page; `requireLegalConsent: true` on provider step; tour/legal/guidance after onboarding unchanged.
- **Verified:** `dart analyze lib/features/onboarding` (no errors).

## 2026-07-10 — Static wavy headers on dashboard tabs

- **Type:** enhancement
- **Area:** dashboard, learn, history, settings, navigation
- **Files:**
  - `lib/shared/widgets/dashboard/dashboard_page_scaffold.dart` — fixed header `Column` + `embedInShell` for tab pages
  - `lib/features/dashboard/presentation/dashboard_screen.dart` — Home header pinned outside scroll
  - `lib/features/learn/presentation/learn_screen.dart` — `embedInShell: true`, `Positioned.fill` in overlay stack
  - `lib/features/history/presentation/history_screen.dart` — `embedInShell: true`
- **Problem / Goal:** Wavy `GeometricWavyHeader` scrolled away with page content on Home, Learn, and History; nested `Scaffold` in shell tabs broke the fixed-header layout.
- **Solution:** Pin header in a top-level `Column`; only body slivers scroll inside `Expanded` + `CustomScrollView`. Tab pages (Home/Learn/History) use `embedInShell: true` to omit inner `Scaffold` inside `AppShell`; pushed Settings keeps full `Scaffold` for `Material`.
- **Regression risks:** Pull-to-refresh only affects scroll body; Settings `ExpansionTile` sections unchanged; bottom nav and header actions unchanged.
- **Verified:** IDE lints clean on touched scaffold/screen files.

## 2026-07-10 — User-friendly ad policy (results banner + opt-in only)

- **Type:** enhancement
- **Area:** ads, quiz, settings, support, dashboard
- **Files:**
  - `lib/features/quiz/presentation/quiz_play_screen.dart` — removed forced every-3-quiz interstitial
  - `lib/core/services/ad_frequency_store.dart` (deleted), `test/ad_frequency_store_test.dart` (deleted), `app_bootstrap.dart`
  - `lib/shared/widgets/banner_ad_widget.dart` — enabled in release builds
  - `lib/core/personalization/dashboard_section_planner.dart`, `dashboard_screen.dart` — removed home native ad slot
  - `lib/l10n/app_en.arb`, `app_localizations*.dart` — updated `supportFaqAdsAnswer`
- **Problem / Goal:** Forced post-quiz interstitials and debug-only banners conflicted with a low-annoyance ad policy; FAQ mentioned rewarded ads that do not exist.
- **Solution:** Ads are now (1) optional interstitial via Settings “Watch ad to support” or Support screen, and (2) banner on quiz results only. Removed `AdFrequencyStore` and dashboard native ad placement.
- **Regression risks:** Settings/Support interstitial preload unchanged; quiz submit → results navigation no longer blocked by interstitial; banner loads on all builds (test AdMob IDs until production IDs restored).
- **Verified:** IDE lints on touched files; release APK build.
