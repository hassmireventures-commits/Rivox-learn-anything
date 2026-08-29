# Product Review

## Finding — No clear wedge; feature sprawl at v1.0.0

**Evidence:** Concurrent surfaces: quiz, learn paths, exam, career, PKB/RAG, local LLM, reminders, recommendations, cost dashboard, guidance, ads (`lib/features/*`, `docs/EXAM_AND_CAREER_MODULES.md` gaps).  
**Impact:** User cognitive overload; Business unclear category leadership; Technical QA explosion.  
**Severity:** Medium–High  
**Options:** (1) Broad toolbox; (2) One wedge (e.g. exam prep); (3) Progressive disclosure with one hero journey.  
**Recommended:** (3) — hero “daily adaptive quiz / exam X,” defer career/library depth until NPS > 40.  
**Trade-offs:** Feature teams feel constrained. **Effort:** M **ROI:** Very high **Owner:** Product

## Finding — BYOK blocks activation

**Evidence:** `onboarding_provider_step.dart`, `llm_manager.dart`, provider guides.  
**Impact:** Extreme funnel drop; cannot reach millions.  
**Severity:** Critical  
**Options:** Hosted free tier; demo-first (`DemoQuizService`); local-only basic quizzes; partner credits.  
**Recommended:** Demo-first immediately + freemium hosted AI within 90 days; keep BYOK as privacy/Pro mode.  
**Effort:** S–Epic **ROI:** Existential **Owner:** Product + AI + Backend

## Finding — Monetization incompatible with ambition

**Evidence:** Test ads, donate placeholder, no IAP/subscription packages.  
**Severity:** High (strategic)  
**Options:** Stay lean BYOK tool; freemium hosted AI; B2B licensing.  
**Recommended:** Freemium + Pro + Enterprise; ads only on free results banner.  
**Effort:** Epic **ROI:** Highest if “billion-dollar” is literal **Owner:** CEO/PM

## Kano / RICE / MoSCoW (board view)

| Item | Kano | MoSCoW | RICE note |
|------|------|--------|-----------|
| Demo value before keys | Performance → Must | Must | Highest reach |
| Release/security hygiene | Basic | Must | Risk reduction |
| Real RAG | Attractive | Should | Differentiator when quality exists |
| Accounts/sync | Performance at scale | Should→Must | Retention |
| Exam verifier pass | Attractive | Should | Trust in exam vertical |
| Marketplace / enterprise | Delighters | Could (12 mo) | After foundation |
| More modes/features | Indifferent if unfinished | Won’t (now) | Scope control |

## Market positioning

**Why switch:** Privacy-forward local-first + multi-provider + on-device option vs ChatGPT wrappers.  
**Why stay:** Personal library investment + learning history (once sync/quality exist).  
**Moat today:** Thin — craft and breadth, not network effects or verified outcomes.  
**Moat target:** Verified learning outcomes + portable learner graph + educator marketplace.

## Score

Product Vision **6.8/10** · UX activation **4.8/10** · Enterprise readiness **1.5/10**
