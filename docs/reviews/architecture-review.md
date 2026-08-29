# Architecture Review

## Current style

Local-first **modular client monolith**: `core` / `data` / `features` / `shared`. Riverpod composition root. No server-side domain services.

```
main → Isar + policy init → ProviderScope → go_router shell
features (UI) → providers → core services / ai_platform / healing
                         → data (Isar, AI providers, vector, knowledge)
```

## Finding — Missing platform plane

**Evidence:** No auth, sync, entitlements, remote config, kill switch, or first-party API.  
**Severity:** Critical for “global platform” ambition  
**Options:** Stay client; modular monolith + thin BFF; SOA; event-driven platform.  
**Recommended path:** Client modularization → **modular monolith BFF** → selective services (AI gateway, sync, analytics) → event-driven learning graph.  
**Effort:** Epic **Owner:** Solutions Architect

## Finding — Gravity wells

**Evidence:** `LearningOrchestrator`, `settings_screen`, `app_providers.dart` centralization.  
**Severity:** Medium  
**Recommended:** Extract use-cases (GenerateQuiz, SuggestPath, IngestDocument) behind ports; incremental, test-driven.  
**Owner:** Senior Architect

## Finding — State fragmentation

**Evidence:** Isar + secure storage + multiple JSON stores + native prefs.  
**Severity:** Medium  
**Recommended:** Document ownership map; consolidate non-secret prefs; versioned migrations.  
**Owner:** Data Architect

## Evolution roadmap

| Stage | When | Focus |
|-------|------|-------|
| Hardened client | Now–30d | Security, tests, migrations |
| Modular monolith + BFF | 90d | Auth optional, AI gateway, analytics ingest |
| Service-oriented | 6–12 mo | Sync, entitlements, moderation, content |
| Event-driven global | 12+ mo | Learning outcomes graph, marketplace |

## SOLID / coupling notes

- Good: provider abstraction, healing decorator, repository pattern
- Weak: UI↔domain mixing in mega screens; unused governance paths (dead abstraction)
- YAGNI risk: many modes before core loop proven
- DRY risk: multiplayer remnants still in l10n/tour

## Score

Architecture **5.5/10** · Scalability **2.5/10** · Maintainability **5.3/10**
