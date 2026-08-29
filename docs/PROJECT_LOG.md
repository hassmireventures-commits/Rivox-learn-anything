# Learn Anything â€” Project Log

Master index for all changes. **Agents must read this file and the relevant section log before making code changes.**

## Section logs

| Log | Purpose |
|-----|---------|
| [FEATURES_LOG.md](logs/FEATURES_LOG.md) | Shipped capabilities and major feature deliveries |
| [ENHANCEMENTS_LOG.md](logs/ENHANCEMENTS_LOG.md) | UX and quality improvements |
| [BUGFIX_LOG.md](logs/BUGFIX_LOG.md) | Bug fixes and regression notes |
| [BACKLOG.md](BACKLOG.md) | Open / Coming soon / partial work (not shipped) |
| [RETRO_2026-08-23.md](logs/RETRO_2026-08-23.md) | 27-bug + hosting + ads workstream retro |

## Chronological index

| Date | Type | Title | Log |
| 2026-08-29 | bugfix | Dino Run unplayable on mobile with "Request Desktop Site" enabled | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-29 | release | Website deployed live to Firebase Hosting (learn-anything-43970.web.app) — mini games, ads, SEO fixes | — |
| 2026-08-29 | enhancement | Website SEO audit and fixes (site was not indexed at all) | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-08-29 | feature | Website: native ads, opt-in support ad, mini games (Dino Run) | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-08-29 | release | Rivox 1.0.5 (build 6) — see [RELEASE_NOTES_1.0.5.md](RELEASE_NOTES_1.0.5.md) | — |
| 2026-08-29 | bugfix | file_picker upgrade fixes Play Console bitmap-downsampling flag; migrates breaking API | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-29 | enhancement | Achievement slide carousel sorted by progress; native ad on Support | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-29 | bugfix | Flashcards "N due for review" count never refreshed after reviewing | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-29 | bugfix | CI `flutter analyze` step always failed; cleaned up real pre-existing warnings | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-29 | bugfix | AI eval CI gate failed on single-model flake, not a real regression | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-29 | enhancement | Backlog batch: mark-for-review, achievement badges, AI eval CI, generation UX contract (B12/B14/B16/B17) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-29 | feature | MoSCoW feature research pass — B11–B21 added to backlog | [BACKLOG](BACKLOG.md) |
| 2026-08-29 | bugfix | Leftover agent debug logger ran on every generation in production | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-27 | enhancement | Every AI provider follows the 10/10 JSON gate | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | enhancement | Nemotron fallback 10/10; disable thinking for JSON | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | enhancement | Live model probe + AiOutputGate for BYOK | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | bugfix | Built-in primary auto-routing; path JSON retry | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | bugfix | AI brief leak; Llama 3.2 primary model | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | bugfix | Generic article resolver for any goal | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | enhancement | Built-in model routing; AI greeting test | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | bugfix | Built-in AI model EOL → Nemotron Nano | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | bugfix | Built-in AI key secure-storage fallback | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | enhancement | Article reader ad-free | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | enhancement | Scrollable dismissible native ads | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | enhancement | Native ads bottom-only; banners removed | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | bugfix | Study goal ring label + real-time progress | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | enhancement | Insights charts: live goal, trend, refresh, native ad | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | bugfix | Alarm reminder Dismiss action | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | bugfix | Banner/native ads consent + debug test IDs | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-26 | enhancement | MCQ answer/explanation consistency prompts | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | enhancement | Daily pack video subtitle replaces AI summary | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-26 | bugfix | Daily quiz day rollover + ad refresh on pull | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | enhancement | Native ads on Home; banner ID verified | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | bugfix | Trim over-count quiz to requested N | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | AI offline Built-in + BYOK generation blocked | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | enhancement | Quick quiz count options 5/10/15/20 | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | bugfix | Quiz exact count in prompt, no post-trim | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | Quick quiz count, duplicates, vague errors | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | enhancement | Settings Support section separated | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | bugfix | Banner ads saved articles, reader, history | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | enhancement | Multi-source article scoring | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | enhancement | Generic goal-aware article resolver | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | bugfix | Dental/dentist path missing articles | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | Saved articles not cleared on data reset | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | Irrelevant daily pick + duplicate path articles + button sizing | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | Daily pick notification repeat + redundant video button | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | In-app article reader (Read in app) | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | Learn background scroll + daily pack YouTube search | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | feature | Agentic goal content validation gate | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | elsai.ai Elsaid Maher Wikipedia/quiz drift blocked | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | Onboarding swipe-back goes to previous step | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | bugfix | Priority batch: notifications, goals, ads, path focus | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | enhancement | CS/coding articles prefer GFG, W3Schools, tutorials | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | bugfix | Missing ResourceWebViewScreen import blocked release build | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | feature | Open knowledge API layer + agent ingestion rules | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | enhancement | Org domain goals always resolve + daily pack never empty | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | enhancement | Web grounding for opaque goals (domain + Wikipedia) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | enhancement | Goal topic think-step for org/domain goals | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | enhancement | Voice interview Whisper en-US + English coaching | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | bugfix | Results banner: real ad online, hide only offline | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-25 | feature | Article bookmarks | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-08-25 | enhancement | Topic-specific quiz and daily content scope | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-25 | bugfix | User feedback: topic scope, daily pack, voice, settings, ad | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Continue in background + daily pack generation | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Learn tab stuck after path detail return | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | enhancement | Rivox full app rebrand (in-app + store assets) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-24 | bugfix | Hosting stale hero image cache + AdSense blank banner | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Duplicate ic_launcher_background blocked split APK build | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | enhancement | Hosting website feature image + content refresh | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-24 | enhancement | Hosting website Rivox rebrand | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-24 | enhancement | App launcher icon (R squircle rebrand) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-24 | bugfix | AI usage empty state with token count | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Voice interview contrast, STT, open-only questions | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Daily pack career video + default/chime alarm sounds | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | enhancement | Competitive exam logical reasoning quiz quality | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-24 | bugfix | MCQ with only one answer option | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | enhancement | Remove on-device local LLM (Built-in + BYOK only) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-24 | feature | Voice interview hub (HR/Tech, captions, one-time use) | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-08-24 | bugfix | Results banner ad load reliability | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Auto-generation exempt from Built-in AI quota | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Daily learning pack generation + alarm sound preview | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | bugfix | Live API limit countdown on Home | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-24 | feature | Voice interview Whisper STT | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-08-23 | bugfix | Website AdSense unfilled + duplicate slot fix | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-23 | enhancement | Hosting AdSense Display slot 3346149333 | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-23 | enhancement | Persist 2026-08-23 l10n keys in every ARB | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-23 | enhancement | Daily quiz frequency slot UX | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-23 | enhancement | Local LLM stays deferred (existing API keys) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-23 | enhancement | Hosting AdSense display slots blocked-on-IDs | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-23 | bugfix | Article relevance no longer empties resources | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-23 | bugfix | Delete leftover Android study_alarm channel | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-23 | feature | Product backlog + 27-bug workstream retro | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-08-23 | enhancement | Production banner + rewarded interstitial units | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-23 | bugfix | User-reported batch: mail, quota, paths, quiz, history, ads | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-08-23 | feature | Backlog: in-app learning chatbot | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-08-23 | enhancement | Missing l10n getters + resultsNoAnswer | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-08-23 | enhancement | app-ads.txt + official Play Store links | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-29 | enhancement | Full PC migration backup zip + guide | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-28 | enhancement | Fix hosting layout alignment / CSS load | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-28 | enhancement | AdSense on Firebase Hosting | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-28 | enhancement | Hosting minimalist landing redesign | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-28 | enhancement | Hosting homepage brand, feature image, support | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-28 | enhancement | Privacy/terms contact details on Firebase Hosting | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-26 | feature | Library-first learning, interview grounding, From my content | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-26 | enhancement | Quota restore, grounded paths, interview drill, l10n | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-26 | enhancement | RAG sourceTypes + library excerpt priority in prompts | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-26 | enhancement | Split release APK with Built-in AI key | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-24 | bugfix | Clear-data refresh, text share deep link, daily pack BG + goals UI | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-24 | feature | Android deep links via app_links | [FEATURES_LOG](logs/FEATURES_LOG.md) |
|------|------|-------|-----|
| 2026-07-24 | bugfix | Built-in key rebuild + challenge share + pulse/daily reset | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-24 | enhancement | Challenge share/import l10n getters | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-24 | bugfix/enhancement | Daily pack dual free sources + support contact | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-24 | enhancement | Daily content copy: article and video | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-23 | bugfix | History Daily study: content-only + validated snapshots | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-22 | bugfix | In-app YouTube playback (showControls + minSdk) | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-22 | bugfix/feature | Daily pack: validate links + in-app detail | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-22 | bugfix/feature | Engagement: ads, reminders, QOTD background, daily content | [BUGFIX_LOG](logs/BUGFIX_LOG.md) / [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-21 | bugfix | Localized support-ad + font strings (all locales) | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | bugfix | Support interstitial, l10n scrub, Tamil restore | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | bugfix | Thirteen locale/reminder/ads/insights edge cases | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | bugfix | Locale fonts, reminder permission, support rewarded | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | enhancement | Insights tokens + topic legend; settings cleanup | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-21 | bugfix | Release APK compile: l10n import + prompt_builder | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | bugfix | One-time readiness/coverage zero migration | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | enhancement | Transcript-first module notes + regenerate | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-21 | bugfix | Readiness 0%, path-only skills, YT reject memory | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | feature | Structured markdown module notes + cache | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-21 | bugfix | Goals mandatory, Tamil, guardrails, Learn quota freeze | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-21 | feature | Tamil locale + mandatory goal topics + topic guardrail | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-20 | bugfix | YouTube transcript DioClient import path | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-20 | bugfix | Twelve UX / generation bugfixes | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-20 | feature | Module summarizer + goal relevance gate | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-20 | bugfix | AI brief stays offline after returning to Built-in | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-20 | enhancement | Keystore backup + signed split release APK | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-19 | enhancement | Firebase Hosting for privacy / terms | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-17 | enhancement | Prod AdMob, Crashlytics, Firestore rules, store drafts | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-17 | enhancement | Firebase FlutterFire configure (learn-anything-43970) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-17 | bugfix | Play Store agent-doable gates | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-17 | bugfix | History/Home labels, quiz options, ads, QOTD after reset | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-17 | enhancement | Smart generation size + background wait | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-17 | enhancement | Faster quiz/path generation (cloud-only, lean prompts) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-17 | enhancement | AI brief Home-only + connection tip dialog; no em dashes | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-16 | enhancement | AI Study Pulse on Settings / Providers | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-16 | enhancement | AI Study Pulse connection probe on Home | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-16 | bugfix | Text alignment + PrimaryButton / SegmentedButton layout | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-16 | bugfix | Quiz timer, empty/timeout UX, quota, background jobs | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-16 | bugfix | Built-in overlay crash + Nemotron model / quiz speed | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-16 | bugfix | Built-in provider resolution + debug reporting | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-16 | bugfix | Built-in quota, rewarded ID, engine seed (Bugbot) | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-16 | enhancement | Built-in AI default + quotas + rewarded ads | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-15 | enhancement | Local LLM Coming soon + split release | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-15 | enhancement | MLC Windows package: TIR shims, blocked on tvm_ffi ABI | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-14 | bugfix | Keyboard hide, Settings KeepAlive, local LLM UX + delete | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-14 | enhancement | Local LLM status UI + delete; MLC package blocked | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-14 | bugfix | Settings tiles, LLM limits, keyboard, stuck overlays | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-14 | enhancement | MLC package script + on-device readiness path | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-13 | bugfix | Gemini Dio leak, tokens 0, Learn badge, onboarding dark | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-13 | enhancement | Settings chips removed; goal buttons; appearance SegmentedButton | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-13 | bugfix | Release lint NetworkSecurityConfig + split APK build blockers | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-13 | enhancement | UI/UX ARB Should-gate implementations | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-13 | enhancement | ARB Must-gate production upgrades | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-13 | enhancement | Multi-model ARB codebase review docs | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-13 | enhancement | Settings rename top + reminder Save | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-13 | bugfix | Smart localâ†’cloud AI routing | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-13 | bugfix | Generation error dialog unfreezes tabs | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-13 | bugfix | Local LLM DownloadManager Unsupported path | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-13 | enhancement | Settings dark contrast + compact headers | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-12 | feature | Hybrid local LLM (MLC) + explicit engine choice | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-09 | feature | Guidance layer (onboarding, help, legal, tour) | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-09 | enhancement | Provider guidance and empty-state hints | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-09 | enhancement | Dashboard visual redesign (inspired layout) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-09 | bugfix | New quiz creation freeze + provider validation | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-09 | bugfix | YouTube scroll lock after unavailable video | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-09 | feature | Project log workflow + cursor rule | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-09 | enhancement | Goal persistence, switch/add secondary goals | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-09 | enhancement | Dashboard insights sheet + Balanced button fix | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-09 | feature | Reminder popup + alarm scheduling | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-09 | enhancement | Onboarding flow redesign | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-10 | feature | AI Platform layer (governance, security, optimization) | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-10 | feature | Personal Knowledge Base + RAG | [FEATURES_LOG](logs/FEATURES_LOG.md) |
| 2026-07-10 | enhancement | AI cost dashboard and grounded mode | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-10 | bugfix | Release APK compile blockers | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-10 | enhancement | Remove multiplayer and slim release APK | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-10 | enhancement | Learn, History, Settings dashboard scaffold migration | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-10 | enhancement | Onboarding UI alignment with dashboard design system | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-10 | bugfix | Settings blank screen, History polish, Quiz-of-the-Day results tap | [BUGFIX_LOG](logs/BUGFIX_LOG.md) |
| 2026-07-10 | enhancement | Static wavy headers on dashboard tabs | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |
| 2026-07-10 | enhancement | User-friendly ad policy (results banner + opt-in only) | [ENHANCEMENTS_LOG](logs/ENHANCEMENTS_LOG.md) |

## Workflow

1. Read this index and open the relevant section log.
2. Check **Regression risks** for the area you are editing.
3. Implement the change.
4. Append a dated entry to the correct section log and add a row here.
