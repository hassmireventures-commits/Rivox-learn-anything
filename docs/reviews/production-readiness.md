# Production Readiness Report

## Verdict: **Not Ready** (limited progress)

Suitable for: internal alpha, designer/investor demos, power-user BYOK closed beta.  
Not suitable for: unrestricted public store until ⏳ items on [PLAY_STORE_CHECKLIST.md](../PLAY_STORE_CHECKLIST.md) clear.

## Gate checklist — minimum for “Approve with Conditions” (limited store)

| # | Gate | Status |
|---|------|--------|
| 1 | Release signing (not debug) | 🔶 Local upload keystore generated; CI still `ALLOW_DEBUG_SIGNING` for compile |
| 2 | No placeholder Firebase in release / or Firebase disabled | ✅ Real `learn-anything-43970` client config |
| 3 | Production AdMob IDs; test IDs blocked in release | ✅ Prod IDs baked; test-ad path removed |
| 4 | Real privacy/terms URLs | ✅ Firebase Hosting (`*.web.app`); custom domain optional |
| 5 | `usesCleartextTraffic=false` (or scoped) | ✅ |
| 6 | Zip Slip fix + model hash pin | ✅ Zip Slip fixed; empty SHA refused in **release** downloads |
| 7 | Ads blocked until UMP consent resolves | ✅ Interstitial/rewarded + banners |
| 8 | `sendChunksToProvider` default false + disclosure | ✅ |
| 9 | CI: `flutter build apk/appbundle --release` | ✅ (debug signing for CI) |
| 10 | Critical-path automated tests (onboarding→quiz→results + parsers) | ✅ Parser + demo sample + AdMob ID tests |
| 11 | Crash reporting with PII scrubbing | ✅ Crashlytics via `AppLogger.crashSink` + scrubbing |
| 12 | Broken locales removed or fixed | ✅ ta/bn/ml/mr unregistered from lookup |
| 13 | Firestore rules / App Check **or** cloud writes disabled | ✅ Rules deployed; writes default on; App Check optional |
| 14 | Accessibility baseline on quiz play | ✅ Progress / options / open-answer Semantics |
| 15 | README matches shipped features | ✅ MLC marked disabled / coming soon |

## QA posture

Critical-path unit coverage improved (parser + demo sample + AdMob IDs). Full widget/integration onboarding→results still thin.

## Observability

`AppLogger` scrubbing + Firebase Crashlytics sink after Firebase init (collection enabled in non-debug).

## SRE

No SLOs, error budgets, runbooks, or progressive delivery.

## Decision authority

Product owner + engineering lead before public production track.
