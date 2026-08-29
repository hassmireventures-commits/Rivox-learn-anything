# Frontend Review

## Stack patterns

Riverpod + go_router shell; Material design system; feature presentation folders; shared dashboard widgets.

## Finding — Oversized screens

**Evidence:** `settings_screen.dart` (~1191), `dashboard_screen.dart` (~825), `welcome_screen.dart` (~795).  
**Severity:** Medium  
**Recommended:** Extract section widgets/routes; avoid big-bang rewrite.  
**Owner:** Frontend

## Finding — Re-render / jank risk

**Evidence:** Dashboard/history load all quizzes; RAG loads all chunks; heavy work on main isolate.  
**Severity:** Medium–High  
**Recommended:** Indexed queries, isolates, pagination.  
**Owner:** Frontend + Performance

## Finding — Accessibility

**Evidence:** ~4 Semantics sites; portrait lock; charts without summaries.  
**Severity:** High  
**Recommended:** Semantics/focus on quiz play, onboarding, settings; text scaler tests.  
**Owner:** Frontend + A11y

## Finding — Dead multiplayer surface

**Evidence:** Removed feature; strings/tour/export fields remain.  
**Severity:** Low  
**Recommended:** Purge. **Effort:** S **Owner:** Frontend

## Finding — WebView JS unrestricted for user hosts

**Evidence:** `resource_webview_screen.dart`  
**Severity:** Medium–High  
**Recommended:** Official docs in WebView; user sites external browser.  
**Owner:** Frontend + Security

## Duplication / over-engineering

- Guidance scaffolding is valuable, not overbuilt.
- AI platform layers risk dead code if not wired (pipeline).
- Prefer deleting unused paths over adding abstractions.

## Score

Frontend **6.3/10**
