# AI Review

## Architecture (what exists)

- Providers: `lib/data/remote/ai/providers/*`, factory, `LlmManager` cloud vs local
- Orchestration: `learning_orchestrator.dart`
- Middleware: `ai_request_pipeline.dart`, policy `assets/ai/ai_policy_v1.json`, `prompt_firewall.dart`, `output_validator.dart`, `ai_consent_gate.dart`, audit/token budget
- Healing: `resilient_ai_provider.dart`, circuit breaker
- RAG: `rag_context_builder.dart`, `knowledge_vector_store.dart`
- Agents: `goal_agent.dart` (prompt-templated, not tool-loop agent)

## Finding — RAG is hash BoW, not embeddings

**Evidence:** 32-dim `token.hashCode % 32` (`knowledge_vector_store.dart`); ASCII-only tokenization.  
**Severity:** High  
**Options:** Provider embeddings; on-device ST; BM25 hybrid; rename “experimental.”  
**Recommended:** BM25/hybrid + honest UX now; provider embeddings short-term; on-device embeddings when MLC matures.  
**Effort:** M–L **Owner:** AI

## Finding — Governance is advisory / inconsistently applied

**Evidence:** Pipeline `execute()` reportedly unused; quiz parser may skip `OutputValidator`; firewall is short denylist; RAG chunks not treated as untrusted.  
**Severity:** High  
**Options:** Manual calls; mandatory local gateway; remote signed policy.  
**Recommended:** One mandatory gateway for all AI ops; structure RAG as untrusted context; default chunks off-device.  
**Effort:** L **Owner:** AI Platform

## Finding — Educational correctness unmeasured

**Evidence:** Shape-only validation; LLM-suggested YouTube URLs; no golden evals.  
**Severity:** High  
**Recommended:** Schema+consistency checks now; exam-mode verifier pass + flag-question; eval harness 90 days.  
**Effort:** M–Epic **Owner:** AI + Learning Quality

## Finding — Prompt firewall theater

**Evidence:** `blockedPromptPatterns` static list.  
**Severity:** Medium–High  
**Recommended:** Isolation framing + moderation for any hosted tier; expand beyond regex.  
**Owner:** AI Safety

## Finding — Client-only token caps

**Evidence:** Local audit totals. Acceptable for BYOK; Critical if first-party relay ships without server enforcement.  
**Owner:** AI + Backend

## Recommendations summary

| Priority | Action |
|----------|--------|
| P0 | Opt-in chunk send; RAG untrusted framing; wire validators on quiz path |
| P1 | Eval set + verifier for exam_prep |
| P2 | Real retrieval; model routing/fallback metrics |
| P3 | Hosted tier with server budgets + moderation |

## Score

AI **5.3/10** · Innovation of plumbing **7.5/10** · Quality of retrieval/safety **~3/10**
