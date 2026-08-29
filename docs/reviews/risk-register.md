# Risk Register

| ID | Risk | Likelihood | Impact | Severity | Mitigation | Owner |
|----|------|------------|--------|----------|------------|-------|
| R1 | Store reject / malware flags (debug signing, cleartext) | High | Critical | Critical | Signing + cleartext fix | DevOps |
| R2 | Key theft via custom HTTP endpoint | Med | Critical | High | HTTPS + allowlist | Security |
| R3 | Zip Slip / tainted models | Med | Critical | Critical | Sanitize + hash pin | Android |
| R4 | GDPR/UMP consent violation (ads) | High | High | Critical | Block ads until consent | Privacy |
| R5 | Silent data loss on upgrade/reinstall | High | High | High | Migrations + backup/sync | Data |
| R6 | “Grounded” wrong answers → trust collapse | High | High | High | Real retrieval + evals | AI |
| R7 | Activation failure (BYOK wall) | High | Critical | Critical | Demo + freemium | Product |
| R8 | Firestore cost/abuse | Med if enabled | High | High | Disable/Functions | Backend |
| R9 | Regressions ship unchecked | High | High | High | Tests + CI build | QA |
| R10 | A11y/legal education procurement block | Med | High | High | WCAG program | A11y |
| R11 | Locale backlash (India markets) | High | Med | High | Ship complete locales only | PM |
| R12 | AI cost blowout if hosted without server budgets | Med future | Critical | High | Server quotas first | FinOps |
| R13 | Scope sprawl delays PMF | High | High | High | Wedge focus | CEO |
| R14 | Under-13 / school use without age design | Med | High | High | Age gating + policy | Trust |

## Residual risk acceptance

Board does **not** accept R1–R4, R7, R9 for public production. R12 must be designed before freemium launch.
