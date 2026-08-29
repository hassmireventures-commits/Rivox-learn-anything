# Code Simplification Plan

## Mission

Reduce complexity without cutting capability users need.

## Hotspots

| Item | Est. impact |
|------|-------------|
| Purge multiplayer remnants (l10n, tour, quiz_kind, export fields) | −noise, fewer bugs |
| Wire or delete dead AI pipeline paths | −false assurance |
| Split god screens into widgets/routes | −LOC per file, +testability |
| Consolidate JSON preference stores | −state fragmentation |
| Remove unused Firestore/multiplayer docs from README | −cognitive load |
| Deduplicate provider guide / connection test flows | −maintenance |
| Locale cut: ship only complete locales | −broken UX surface |

## Estimates (order-of-magnitude)

| Lever | LOC / complexity |
|-------|------------------|
| Dead multiplayer + stale docs | Small (−1–2k string/docs surface) |
| Settings/dashboard extract | Neutral LOC, −cognitive complexity |
| Delete unused governance stubs if not wired | Small |
| Dependencies | Review `file_picker` beta, charts — keep if used |
| Bundle | Stub MLC flavors already help; avoid shipping unused assets |

## Principles

1. Prefer **demo content + fewer modes** over more incomplete modes.  
2. Prefer **one AI gateway** over scattered middleware calls.  
3. Prefer **external browser** over complex WebView allowlists for user sites.  
4. Prefer **honest feature names** (keyword retrieval ≠ vector RAG).

## Maintenance reduction

Expected: fewer freeze regressions when pure-logic units are extracted and tested; faster PR review once screens split.
