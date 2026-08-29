# Executive Summary — Learn Anything ARB

**Date:** 2026-07-13  
**Panel:** Multi-model Architecture Review Board (Sonnet, Composer, Grok, GPT-5.6)  
**Scope:** Full repository (`ai_quiz_app` / Learn Anything)  
**Priority:** Best possible UX; long-term trust over short-term monetization

---

## Verdict

### **Not Ready for Production**

Three of four independent models voted **Not Ready**; one voted **Approve with Conditions** for closed beta only. Board consensus: **Not Ready** for public store scale. Suitable today for **controlled alpha / power-user BYOK demos**, not global consumer launch.

**Overall engineering score (board average): ~43 / 100**

---

## What this product is

A Flutter **local-first** AI learning client with:

- Multi-provider BYOK AI + hybrid on-device MLC LLM (Android)
- Personal Knowledge Base / RAG, quizzes, paths, exam & career modes
- AI platform middleware (policy, firewall, audit, consent, healing)
- Guidance/onboarding, reminders, ads (test IDs), optional donations
- Isar as system of record; optional Firestore analytics (unconfigured)

~230+ Dart files under `lib/`. Strong innovation relative to team size; weak production foundation.

---

## Consensus critical risks

| Risk | Evidence (representative) | Severity |
|------|---------------------------|----------|
| Release not store-safe | Debug signing (`android/app/build.gradle.kts`), test AdMob IDs, `example.com` legal URLs, Firebase placeholders | Critical |
| Near-zero automated tests | 3 test files / ~9 cases vs 230+ production files | Critical |
| Mass-market UX cliff | BYOK or multi-GB local model required before core value | Critical / High |
| Privacy defaults wrong | `sendChunksToProvider = true` by default; ad consent fail-open | High |
| RAG marketed beyond capability | 32-dim hash embeddings (`knowledge_vector_store.dart`) | High |
| No accounts / sync | Device wipe = progress loss; no billion-user path | High |
| Security gaps | Cleartext traffic, Zip Slip risk in model unzip, unrestricted WebView JS, no Firestore rules | Critical–High |
| AI governance advisory | Pipeline/validator not consistently enforced on quiz path | High |

---

## Strengths to protect

- Local-first + secure key storage posture
- Resilient AI layer (retry, circuit breaker, fallback)
- Design system / dashboard polish and guidance layer
- `docs/PROJECT_LOG.md` change discipline
- Differentiated ambition: hybrid LLM + PKB + exam/career modes

---

## What to do next (compressed)

**This week (release blockers):** Fix signing, cleartext, Zip Slip/hash pin, consent defaults, placeholder/ad/legal gates, CI release build.

**30 days:** Critical-path tests, demo-first onboarding, observability, Isar migrations, a11y baseline, locale quality gate.

**90 days:** Real retrieval (BM25/embeddings), optional encrypted backup/accounts, AI quality evals, freemium design.

**12 months:** Platform identity, hosted AI tier, enterprise/education SKU, marketplace foundations.

---

## Board recommendation to leadership

Do **not** optimize for more features. Optimize for:

1. Truthful trust (legal, privacy, safety, store config)
2. First value without API keys
3. Measured learning quality
4. Tested reliability + observability

Then scale narratives. Full detail: [MASTER_REPORT.md](MASTER_REPORT.md) · [action-items.md](action-items.md)
