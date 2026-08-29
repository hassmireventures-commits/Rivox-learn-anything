# Play Store launch guide (2026-07-26)

Use this after installing the latest signed split APKs / AAB from `build/app/outputs/`.

## Artifacts to upload

| Artifact | Path | Use |
|----------|------|-----|
| **Preferred (Play)** | `build/app/outputs/bundle/release/app-release.aab` | Play Console production / testing track |
| Split APKs | `build/app/outputs/flutter-apk/app-*-release.apk` | Sideload / internal QA (arm64 for most phones) |

Built-in AI key is compile-time only (`tool/.local_dart_defines.json`, gitignored). Rotate the key before a public launch if it was shared in chat/logs.

## Play Console steps

1. Open [Google Play Console](https://play.google.com/console) → app **Learn Anything**.
2. **Release → Production** (or start with **Internal testing** / **Closed testing**).
3. Create a new release → upload **`app-release.aab`**.
4. Complete release notes (see [store/LISTING.md](store/LISTING.md)).
5. Ensure these are finished (still often blocked on human accounts):
   - Store listing: short/full description, screenshots, feature graphic
   - Content rating questionnaire
   - **Data safety** form (local AI keys, ads, Crashlytics)
   - Privacy policy URL: `https://learn-anything-43970.web.app/privacy`
   - Terms URL: `https://learn-anything-43970.web.app/terms`
6. Review → **Send for review** / roll out to testers first, then production %.

## Signing

- Local upload keystore: `android/app/upload-keystore.jks` + gitignored `android/key.properties`
- Backup: OneDrive `LearnAnything-Secrets` (do not commit)

## Post-launch smoke checks

- Built-in AI generates quiz / path / daily pack; quota dialog + rewarded ad
- Library website add (HTTPS) — no ghost failed rows
- Interview drill with resume → self-intro question
- Language switch (Settings) updates UI strings
- Module complete → path progress updates without pull-to-refresh
- Path complete → offer another path; Learn → **From my content**

See also [PLAY_STORE_CHECKLIST.md](PLAY_STORE_CHECKLIST.md).
