# Governance Assessment

## What exists (positive)

- `docs/PROJECT_LOG.md` + section logs + Cursor rule — excellent change discipline
- Bundled AI policy asset + audit log + consent UI
- Exam/career design doc with honest gaps

## Gaps

| Area | Gap |
|------|-----|
| ADR / RFC | None found |
| Branch / PR policy | Not documented in-repo |
| Coding standards | flutter_lints only |
| Release governance | No flavor gates / checklist automation |
| AI governance | Policy client-side; enforcement incomplete |
| Design system | Emerging widgets; no token/docs site |
| API governance | No first-party API versioning |
| Data governance | Retention for audit/telemetry unclear |

## Recommendations

1. **ADR folder** `docs/adr/` for decisions (local LLM ABI, BYOK vs hosted, Isar migrations).
2. **RFC for Epics** (accounts, freemium AI).
3. **Release checklist as CI** (fail on placeholders, test ads, debug signing, cleartext).
4. **PR policy:** require tests for `core/ai_platform` and parsers; 1 reviewer when team >1.
5. **AI policy:** treat bundled JSON as UX defaults; server-signed policy when hosted.
6. **Design system brief:** document colors/type/components in `docs/design/`.

## Score

Governance **4.4/10**
