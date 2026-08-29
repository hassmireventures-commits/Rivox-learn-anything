# Action Items — Prioritized Backlog

## Immediate quick wins (≤2 weeks)

| ID | Action | Owner | Effort |
|----|--------|-------|--------|
| Q1 | Release signing + CI secret keystore | DevOps | S |
| Q2 | Zip Slip sanitize + SHA pin models | Android/Security | S–M |
| Q3 | Disable cleartext traffic | Mobile | S |
| Q4 | Default `sendChunksToProvider=false` | Privacy/AI | S |
| Q5 | Block ads until UMP consent ready | Privacy/Mobile | M |
| Q6 | Flavor gates: fail on placeholders / test ads / example.com | DevOps | S |
| Q7 | CI `flutter build apk --release` | DevOps | S |
| Q8 | Demo-first onboarding via `DemoQuizService` | Product/UX | S–M |
| Q9 | Fix or remove broken locales | PM/i18n | M |
| Q10 | README rewrite (drop multiplayer; correct Firebase id) | Eng | S |
| Q11 | Disable Firestore client writes or add rules+App Check | Backend | S–M |
| Q12 | Purge multiplayer dead strings | Frontend | S |
| Q13 | HTTPS + warn for custom provider baseUrl | Security | M |
| Q14 | Per-install analytics salt | Privacy | S |

## 30-day plan

| ID | Action | Owner |
|----|--------|-------|
| M1 | Unit tests: parsers, firewall, validator, recommendation, circuit, consent | QA/Eng |
| M2 | Integration: onboarding → quiz → results | QA |
| M3 | Crash reporting + scrubbing | SRE |
| M4 | Isar schema version + migration tests | Data |
| M5 | RAG untrusted framing + firewall on chunks | AI |
| M6 | WebView: user sites external | Security |
| M7 | Semantics pass quiz/onboarding | A11y |
| M8 | Settings split / simplify first-run | Frontend/Product |
| M9 | Product wedge decision documented (ADR) | CEO/PM |
| M10 | Import size limits + schema validation | Data |

## 90-day roadmap

| ID | Action | Owner |
|----|--------|-------|
| N1 | BM25/hybrid or provider embeddings | AI |
| N2 | Optional encrypted backup / account foundation | Backend |
| N3 | Freemium AI design + server-side budgets | Product/Backend |
| N4 | Exam verifier + flag-question | AI/PM |
| N5 | Coverage ratchet + dependency/secret scanning | DevOps |
| N6 | iOS CI job | DevOps |
| N7 | Proper PDF parser | Data |
| N8 | Domain boundary refactor (AI gateway mandatory) | Architect |

## 12-month strategic roadmap

| Theme | Outcomes |
|-------|----------|
| Platform | Identity, sync, entitlements, kill switches |
| Monetization | Free / Pro / Enterprise live |
| Quality | Eval harness, educator review ops |
| Ecosystem | Content packs, early API |
| Compliance | GDPR ops, a11y WCAG, regional ads |
| Scale | Multi-region BFF, FinOps dashboards |

## Prioritized backlog (MoSCoW)

**Should (UI/UX):** Q9, Q10, Q12, M6–M8 — **implemented 2026-07-13** (see ENHANCEMENTS_LOG)  
**Should (remaining eng):** Q13 partial (HTTPS warn done), Q14, M5, M10, N1–N5  
**Could:** N6–N8, marketplace experiments  
**Won’t (now):** Full multiplayer rebuild, 1B-user infra, enterprise SSO before sync

### Must follow-ups (still manual / secrets)

- Add real `android/key.properties` + upload keystore for Play (CI may use `ALLOW_DEBUG_SIGNING`).
- Set `ModelCatalog.EXPECTED_ARCHIVE_SHA256` when hosting the production model archive.
- Host `learnanything.app/privacy` and `/terms` (constants updated; pages must exist).
- Wire `AppLogger.crashSink` to Crashlytics/Sentry with a real project.
- Store builds: `--dart-define=USE_TEST_ADS=false` and production AdMob app id in the manifest/flavor.

---

## ARB closing recommendation

**Not Ready for Production.** Re-run a focused ARB after Must items complete for limited store consideration.
