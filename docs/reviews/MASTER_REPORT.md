# MASTER REPORT — AI Architecture Review Board

**Product:** Learn Anything (`ai_quiz_app`)  
**Review date:** 2026-07-13  
**Models:** `claude-sonnet-5-thinking-high`, `composer-2.5-fast`, `cursor-grok-4.5-high-fast`, `gpt-5.6-sol-medium`  
**Method:** Independent adversarial reviews → synthesis (no forced agreement)  
**Intent:** Evaluate the repository as a future global learning platform. UX and long-term trust first; light ads + donations only; assume millions of users eventually.

---

## 1. Phase-1 repository discovery

### Structure

| Path | Role |
|------|------|
| `lib/core/` | Router, theme, AI platform, healing, guidance, services, agents |
| `lib/data/` | Isar models/repos, remote AI providers, vector/RAG, knowledge, secure storage, local LLM channel |
| `lib/features/` | dashboard, learn, quiz, history, settings, onboarding, guidance, reminders, exam, career, library, support, legal |
| `lib/shared/` | Widgets, navigation helpers |
| `lib/l10n/` | Multi-locale generated strings |
| `assets/ai/`, `assets/legal/` | Policy + legal markdown |
| `android/.../llm/` | MLC download/runtime (Kotlin) |
| `docs/` | PROJECT_LOG, exam/career design, MLC setup |
| `.github/workflows/ci.yml` | analyze + test only |

### Stack

Flutter ^3.11.5 · Riverpod · go_router · Isar Community · Dio · Firebase Core/Firestore (optional) · Google Mobile Ads · flutter_secure_storage · local notifications · WebView/YouTube · hybrid MLC on Android.

### Architecture style

**Local-first client monolith**, feature-sliced UI, repository pattern over Isar, AI request middleware + resilient provider wrapper. No first-party backend, auth, or sync plane. All inference is BYOK device→provider or on-device MLC.

### AI integrations

OpenAI-compatible, Claude, Gemini, Grok/DeepSeek/OpenRouter patterns via factory; `LearningOrchestrator`; `AiRequestPipeline` / policy / firewall / audit / RAG; `GoalAgent`; local MLC channel.

### Data & infra assumptions

Isar = SoR (~24 collections). Keys in secure storage. Optional Firestore `anon_events` / `global_prompt_stats`. CI: no release build, no iOS job, no security scan. Firebase options largely placeholders.

---

## 2. Round-table synthesis

### Consensus (2+ models) — Act on

| Finding | Models | Severity |
|---------|--------|----------|
| Production config unsafe (debug signing, test ads, placeholder Firebase/legal) | All 4 | Critical |
| Test suite negligible (~3 files) | All 4 | Critical |
| BYOK-first onboarding blocks mass market | All 4 | Critical/High |
| Hash-bag RAG (32-dim) not semantic | All 4 | High |
| `sendChunksToProvider` default true / PII consent unused | All 4 | High |
| No accounts / cross-device sync | All 4 | High |
| Cleartext traffic enabled | All 4 | High |
| Firestore rules missing / client aggregate writes unsafe | All 4 | High |
| AI governance incomplete vs marketing | All 4 | High |
| Accessibility near-absent | All 4 | High |
| CI insufficient for release | All 4 | High |
| God screens (settings/dashboard/orchestrator) | All 4 | Medium |
| Product scope sprawl vs core loop depth | All 4 | Medium |
| Monetization (ads+donate+BYOK) incompatible with billion-dollar path | All 4 | Medium/High |

### Lone-model findings — Consider

| Finding | Model | Notes |
|---------|-------|-------|
| Zip Slip in `ModelDownloadService.unzip` + no archive hash pin | Sonnet | Critical; validate immediately |
| Ad UMP consent async fail-open before ads load | GPT | Critical privacy/compliance |
| `AiRequestPipeline.execute()` unused; quiz path skips full validation | GPT / Grok | Governance theater risk |
| Arbitrary `baseUrl` + bearer key exfiltration | GPT | High security |
| Hardcoded `analyticsSalt` | Composer | Medium privacy |
| Tamil `????` mojibake; exact-alarm permissions | Grok | High l10n / Medium Play policy |
| Demo-first onboarding via existing `DemoQuizService` | Sonnet/Composer | High UX ROI quick path |

### Disagreements

| Topic | Positions | Board resolution |
|-------|-----------|------------------|
| Production verdict | 3× Not Ready; 1× Approve with Conditions (Composer) | **Not Ready** for public scale; Conditions list is the **minimum bar for store 1.0**, not for “platform ready” |
| Score overall | 41–46 / 100 | Average **~43/100** |
| Local LLM strategy | Premium/high-RAM vs mass-market offline | Treat as **premium/offline tier**; mass market needs hosted or demo path |

---

## 3. Engineering scorecard (board average)

| Area | Avg /10 |
|------|--------:|
| Product Vision | 6.8 |
| UI | 6.5 |
| UX | 4.8 |
| Accessibility | 2.3 |
| AI | 5.3 |
| Architecture | 5.5 |
| Backend | 2.0 |
| Frontend | 6.3 |
| APIs | 4.3 |
| Performance | 5.0 |
| Security | 3.3 |
| Governance | 4.4 |
| Compliance | 3.1 |
| Testing | 1.6 |
| DevOps | 3.0 |
| Scalability | 2.5 |
| Maintainability | 5.3 |
| Documentation | 6.0 |
| Code Quality | 5.5 |
| Innovation | 7.5 |
| Enterprise Readiness | 1.5 |

### Overall: **43 / 100**

---

## 4. Final ARB recommendation

### **Not Ready for Production**

**Justification:** Stacked release blockers (signing, cleartext, placeholders, test ads, legal URLs), Critical/High security and privacy defects, ornamental test coverage, governance not consistently enforced, RAG quality below “grounded learning” claims, and no identity/sync path for retention at scale. Innovation and local-first craft are real assets — they do not outweigh foundation gaps for a public global launch.

**Conditions that would move to “Approve with Conditions” (closed beta / limited store):** see [production-readiness.md](production-readiness.md) gate checklist.

---

## 5. Document index

| Deliverable | File |
|-------------|------|
| Executive summary | [executive-summary.md](executive-summary.md) |
| Product | [product-review.md](product-review.md) |
| UI / UX | [ui-review.md](ui-review.md), [ux-review.md](ux-review.md) |
| AI | [ai-review.md](ai-review.md) |
| Architecture / Backend / Frontend | [architecture-review.md](architecture-review.md), [backend-review.md](backend-review.md), [frontend-review.md](frontend-review.md) |
| Security / Governance / Compliance | [security-review.md](security-review.md), [governance-review.md](governance-review.md), [compliance-review.md](compliance-review.md) |
| Scale / Cloud / Performance | [scalability-roadmap.md](scalability-roadmap.md), [cloud-architecture.md](cloud-architecture.md), [performance-review.md](performance-review.md) |
| Debt / Simplification / Risks | [technical-debt.md](technical-debt.md), [code-simplification.md](code-simplification.md), [risk-register.md](risk-register.md) |
| Production / Roadmaps | [production-readiness.md](production-readiness.md), [billion-dollar-roadmap.md](billion-dollar-roadmap.md), [action-items.md](action-items.md) |

---

## 6. Reviewer artifacts

Independent reviews: [Sonnet](d630a547-346b-42ab-a5a3-280932653059) · [Composer](3987d363-4ec1-436d-886d-5da8abc75181) · [Grok](ce8db96a-6ce6-4d1b-b969-77e2df9473db) · [GPT](044c6677-ff98-486c-9199-eebd9ae373f9)
