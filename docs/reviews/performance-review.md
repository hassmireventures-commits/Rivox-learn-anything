# Performance Review

## Findings

### P1 — O(n) RAG retrieval
**Evidence:** `knowledge_vector_store.retrieve()` loads all chunks.  
**Severity:** Medium → High as libraries grow  
**Recommended:** Source-scoped queries + isolate; ANN later.

### P2 — Full-table quiz scans
**Evidence:** Stats/history/daily quiz patterns scanning sessions.  
**Severity:** Medium–High  
**Recommended:** Indexed Isar queries + aggregates.

### P3 — Main-isolate heavy work
**Evidence:** PDF/indexing; large JSON import.  
**Severity:** Medium  
**Recommended:** Background isolates; size limits.

### P4 — Startup blocking
**Evidence:** Heavy init before `runApp`.  
**Severity:** Medium  
**Recommended:** Defer non-critical init; measure TTID.

### P5 — Bundle / APK
**Evidence:** MLC native + models; abiFilters arm64 for LLM.  
**Severity:** Medium (install conversion)  
**Recommended:** Dynamic feature / on-demand model download (already direction); size budget in CI.

### P6 — Network
AI latency dominated by providers; healing helps availability more than p50 latency. Streaming UX if not universal should be standardized.

## Bundle / rendering

No automated size or golden performance CI. Add APK size gate and basic timeline traces for quiz generation path.

## Score

Performance **5.0/10**
