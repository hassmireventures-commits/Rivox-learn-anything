# Technical Debt Register

| ID | Debt | Area | Severity | Paydown |
|----|------|------|----------|---------|
| TD1 | ~9 tests / 230+ files | QA | Critical | Critical-path suite |
| TD2 | Debug signing + placeholders | Release | Critical | Flavors + CI gates |
| TD3 | Hash RAG labeled as PKB/RAG | AI | High | BM25/embeddings + rename |
| TD4 | God screens / orchestrator | Frontend/Arch | Medium | Incremental extract |
| TD5 | No Isar migration harness | Data | High | Versioned migrations |
| TD6 | Multiplayer remnants | Cleanup | Low | Purge sprint |
| TD7 | Stale README (multiplayer, project id) | Docs | Medium | Rewrite |
| TD8 | Partial l10n / Tamil mojibake | i18n | High | Cut or fix + CI UTF-8 |
| TD9 | Client-only AI policy | AI | Medium | Gateway + server later |
| TD10 | Exact alarms + cleartext | Android | Medium–High | Policy cleanup |
| TD11 | Partial export/import | Data | High | Versioned full backup |
| TD12 | No crash pipeline | SRE | High | Sentry/Crashlytics |
| TD13 | Heuristic “ML” labeling | Honesty | Medium | Rename + eval harness |
| TD14 | ApplicationId / brand mismatch | GTM | Medium | Align pre-scale |

## Refactoring plan (ordered)

1. Safety/release debt (TD2, TD10 cleartext, Zip Slip)  
2. Trust/privacy debt (consent, chunk default)  
3. Test harness (TD1)  
4. Data durability (TD5, TD11)  
5. AI quality naming + retrieval (TD3, TD13)  
6. Structural (TD4, TD6)  
7. Platform (accounts) — Epic, scheduled after 1–5
