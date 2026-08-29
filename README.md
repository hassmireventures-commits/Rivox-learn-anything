# Rivox — The AI App for Learning Anything

AI-native, adaptive learning app built with Flutter. **Local-first** solo learning with BYOK AI providers. On-device MLC is **disabled / coming soon** (`kLocalLlmEnabled = false`). Monetization is light ads + optional donations.

## Features

- Personalized home (Beginner / Intermediate / Advanced layouts)
- Learning paths, priority topics, and “next up” recommendations
- Demo quiz onboarding — try the app **without an API key**
- Quiz generation via OpenAI, Gemini, Claude, Grok, DeepSeek, OpenRouter, custom HTTPS endpoints (Built-in AI available when configured at build time)
- Personal Knowledge Base (uploads + grounded mode when you opt in)
- Exam countdown and career skill practice (heuristic estimates — clearly labeled)
- Reminders, guidance tour, in-app help & legal
- Opt-in anonymized analytics (off by default; cloud writes gated)

## Setup

```bash
flutter pub get
dart run build_runner build
flutter run
```

Release Android builds need `android/key.properties` (see `android/key.properties.example`), or set `ALLOW_DEBUG_SIGNING=true` for compile-only checks.

### Firebase (optional)

Project id in `firebase_options.dart` / `google-services.json`. Multiplayer rooms were **removed**; analytics collections (`anon_events`, `global_prompt_stats`) stay disabled unless `--dart-define=ENABLE_FIRESTORE_ANALYTICS=true` and rules/App Check are in place.

## Privacy

- API keys stay in `flutter_secure_storage`
- Cloud sync / analytics is **off by default**
- Library chunks are **not** sent to providers until you opt in (Settings → AI)

## Goal modes (exam & career)

Planned depth is documented in [docs/EXAM_AND_CAREER_MODULES.md](docs/EXAM_AND_CAREER_MODULES.md). UI shows honesty banners on estimate metrics.

## Architecture highlights

```
lib/core/          theme, router, AI platform, healing, guidance
lib/data/          Isar, AI providers, vector/RAG, secure storage, local LLM (gated off)
lib/features/      dashboard, learn, quiz, settings, onboarding, exam, career, …
docs/reviews/      Architecture Review Board reports
docs/adr/          Architecture decision records
docs/PLAY_STORE_CHECKLIST.md   Store gate status
```

## CI

`flutter analyze`, `flutter test`, release hygiene gate, `flutter build apk --release`, and `flutter build appbundle --release` (with `ALLOW_DEBUG_SIGNING` / test ads defines for CI compile checks). Store uploads still need a real upload keystore and prod dart-defines — see [docs/PLAY_STORE_CHECKLIST.md](docs/PLAY_STORE_CHECKLIST.md).
