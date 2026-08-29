# Backend Review

## Reality check

There is **no application backend**. “Backend” today = Isar local DB + optional Firestore client writes + third-party AI HTTP APIs.

## Finding — Firestore without rules / App Check / auth

**Evidence:** No `firestore.rules` in repo; `anon_analytics_sync.dart` writes `anon_events` and mutates `global_prompt_stats`; placeholder Firebase config.  
**Severity:** High (Critical if enabled in prod)  
**Options:** Disable cloud; strict rules + App Check; Cloud Functions ingress only.  
**Recommended:** Disable or Functions-only; never trust clients with global counters.  
**Effort:** M **Owner:** Backend + CISO

## Finding — No auth / identity

**Severity:** High for retention & enterprise  
**Recommended:** Optional anonymous→upgradeable auth + encrypted sync of learning state (keys stay local).  
**Effort:** Epic **Owner:** Backend

## Finding — Validation & error handling client-only

**Evidence:** Upload extension-only checks; import without size limits; swallowed bootstrap/Firebase errors.  
**Severity:** High  
**Recommended:** Strict schemas, atomic import, magic-byte sniffing, surface failures.  
**Owner:** Backend/Data

## Finding — Background jobs absent

No durable queue for indexing, embeddings, or analytics. Indexing/PDF on UI isolate.  
**Recommended:** Isolates now; server jobs when hosted tier exists.  
**Owner:** Backend + Mobile

## APIs

Provider adapters only — no versioned first-party public API. Platform API is a 12-month opportunity after gateway exists.

## Score

Backend **2.0/10** · APIs **4.3/10**
