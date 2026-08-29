# Play Store pending checklist

Operational gate list for a limited public Play Store release. Derived from [production-readiness.md](reviews/production-readiness.md) and Built-in AI / ads docs.

**Legend:** ✅ agent-done / verified in repo · ⏳ blocked on you (accounts, keys, store)

## Must pass before store upload

1. **Release signing** — ✅ Local upload keystore generated (`android/upload-keystore.jks` + gitignored `key.properties`). ✅ Backed up to `OneDrive\LearnAnything-Secrets\`. ⏳ Add GitHub secrets and remove CI `ALLOW_DEBUG_SIGNING` for store pipelines.
2. **Prod AdMob + rewarded unit** — ✅ All production unit IDs baked (banner, interstitial, native, rewarded, rewarded interstitial); test-ad path removed; Android manifest uses prod App ID.
3. **Privacy / terms + UMP** — ✅ UMP gates ads (fail-closed). ✅ In-app legal assets under `assets/legal/`. ✅ Hosted on Firebase Hosting (`https://learn-anything-43970.web.app/privacy` and `/terms`). ⏳ Optional: attach custom domain `learnanything.app`; complete Play listing Data safety.
4. **Firebase / Firestore** — ✅ Client config for `learn-anything-43970`. ✅ `firestore.rules` deployed; opt-in analytics writes default on (`ENABLE_FIRESTORE_ANALYTICS`). ⏳ Optional App Check.
5. **Network & observability** — ✅ Cleartext off. ✅ `firebase_crashlytics` wired via `AppLogger.crashSink` after Firebase init.
6. **CI release artifact** — ✅ CI builds `apk` + `appbundle` release (debug signing for compile only; prod ad IDs). ✅ Local signed split release APKs built with upload keystore + Built-in AI dart-define (`build/app/outputs/flutter-apk/`). ⏳ Store AAB via upload key secrets in CI / Play Console.
7. **Locales & a11y** — ✅ Blocked locales unregistered. ✅ Quiz play Semantics.
8. **Store listing** — ✅ Drafts in [store/LISTING.md](store/LISTING.md). ⏳ Feature graphic, screenshots, content rating, production release in Play Console.
9. **Built-in keys** — ⏳ Rotate any leaked keys before public store; prefer BYOK or proxy.

## Related docs

- [production-readiness.md](reviews/production-readiness.md) — full ARB gate table
- [BUILT_IN_AI.md](BUILT_IN_AI.md) — quota + Built-in AI
- [store/LISTING.md](store/LISTING.md) — listing copy drafts
- Project logs under `docs/logs/` for regression notes after each gate lands
