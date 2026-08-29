# UX Review

> User experience is the board’s highest product priority.

## First impression / onboarding

Long path: identity → goals → habits → reminders → legal → AI engine/provider before proven value (`welcome_screen.dart`). Guidance layer (coach marks, provider sheets) is strong but compensates for structural friction.

## Finding — Core value gated behind technical setup

**Severity:** Critical  
**Evidence:** Provider step, `AiReadinessService`, empty-provider dashboard prompts.  
**Options:** Demo quizzes first; free hosted generations; local tiny model path.  
**Recommended:** Make `DemoQuizService` the default first five minutes; frame provider setup as “unlock unlimited/personalized.”  
**Effort:** S–M **ROI:** Highest UX lever **Owner:** Product/UX

## Finding — Empty / error / loading states uneven

**Evidence:** Empty-state guides exist on Learn; generation freezes and error dialogs appear repeatedly in BUGFIX_LOG.  
**Severity:** Medium–High  
**Recommended:** Global generation error recovery contract; skeleton loaders; never freeze tabs.  
**Owner:** Frontend + UX

## Finding — Ads framed as “support” can feel interruptive

**Evidence:** Support/Settings interstitial patterns; results banner.  
**Severity:** Medium  
**Recommended:** Rewarded opt-in only; never interrupt quiz play; donation deep link primary.  
**Owner:** Product/Growth

## Finding — Incomplete exam/career honesty

**Evidence:** `EXAM_AND_CAREER_MODULES.md` admits weak heuristics (fake syllabus %, binary readiness).  
**Severity:** Medium  
**Recommended:** Hide or banner incomplete metrics until real.  
**Owner:** PM

## Checklist snapshot

| Area | Status |
|------|--------|
| Navigation (shell) | Adequate |
| Discoverability | Mixed — guidance helps |
| Feedback / delight | Partial |
| Trust | Weakened by placeholders + grounded claims |
| Accessibility | Fail |
| Localization quality | Fail for some locales |

## Score

UX **4.8/10**
