# Compliance & Privacy Review

## Stated posture

Local-first; API keys on-device; cloud analytics opt-in; in-app legal (`assets/legal/*`).

## Finding — Policy vs implementation drift

**Evidence:** Public URLs `example.com`; `sendChunksToProvider` default true; ads before consent; optional Firestore; hardcoded analytics salt.  
**Severity:** High  
**Recommended:** Align privacy/terms with reality; host real URLs; opt-in chunk send; fix UMP sequencing.  
**Owner:** Privacy + Legal + Eng

## Framework readiness (aspirational)

| Framework | Status |
|-----------|--------|
| GDPR | Incomplete — consent gaps, DSR ops impossible without identity, retention unclear |
| CCPA | Incomplete — no sale/share clarity for analytics/ads paths |
| SOC2 / ISO27001 | Not started — no access control, audit export, change mgmt beyond PROJECT_LOG |
| COPPA / under-13 | Terms say not directed to under-13; education apps attract minors — age assurance missing |
| Google Play / UMP | Fail-open risk |

## Data inventory (high level)

| Data | Location | Notes |
|------|----------|-------|
| API keys | Secure storage | Good |
| Quizzes/history | Isar | Device-bound |
| Documents/chunks | Isar | May leave device via RAG |
| Anon events | Firestore optional | Weak anonymization |
| Ads IDs | AdMob | Consent critical |

## Required controls before EU/public scale

1. Lawful basis + consent records for ads/analytics/RAG export  
2. Retention & deletion for local + cloud  
3. DSR playbook (needs identity or device-bound procedure)  
4. DPIA for AI processing of user documents  
5. AI transparency (grounded vs generative; model/provider disclosure)

## Score

Compliance **3.1/10**
