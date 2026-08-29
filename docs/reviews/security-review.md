# Security Assessment

## Threat model (condensed)

| Asset | Threat | Likelihood | Impact |
|-------|--------|------------|--------|
| API keys (secure storage) | Exfil via custom HTTP baseUrl / MITM cleartext | Med–High | High |
| Model archives | Zip Slip / tampered weights | Med | Critical |
| User documents (PKB) | Sent to 3rd parties by default; injection via RAG | High | High |
| Firestore analytics | Spam / poisoning / cost bomb | High if enabled | High |
| WebView | Malicious user site + unrestricted JS | Med | Med–High |
| Release integrity | Debug signing | High (current config) | Critical |

## Critical / High findings

### F-S1 Debug release signing
**Evidence:** `android/app/build.gradle.kts` release → debug keystore.  
**Severity:** Critical  
**Recommended:** Upload keystore + Play App Signing; CI secrets. **Effort:** S

### F-S2 Zip Slip / unverified model unzip
**Evidence:** `ModelDownloadService.kt` `File(targetDir, entry.name)` unsanitized; no SHA pin.  
**Severity:** Critical  
**Recommended:** Path canonicalize + reject `..`; SHA-256 pin. **Effort:** S–M

### F-S3 Cleartext traffic
**Evidence:** `AndroidManifest.xml` `usesCleartextTraffic="true"`.  
**Severity:** High  
**Recommended:** Disable; scoped network security config for debug only. **Effort:** S

### F-S4 Credential to arbitrary endpoints
**Evidence:** Custom `baseUrl` + bearer (`openai_compatible_provider.dart`).  
**Severity:** High  
**Recommended:** HTTPS-only; allowlist official; advanced confirm for custom. **Effort:** M

### F-S5 Ad consent fail-open
**Evidence:** `ad_consent_service.dart` / `app_bootstrap.dart` ads before consent resolves.  
**Severity:** Critical (privacy/compliance)  
**Recommended:** Block ads until UMP actionable; NPA fallback. **Effort:** M

### F-S6 Firestore client writes without rules
**Severity:** High  
**Recommended:** Deny + Functions or disable. **Effort:** M

### F-S7 Prompt injection / RAG injection
**Severity:** High  
**Recommended:** Untrusted context framing; firewall on chunks; moderation for hosted. **Effort:** M–L

### F-S8 WebView unrestricted JS
**Severity:** Medium–High  
**Recommended:** External browser for user sites. **Effort:** S

### F-S9 Static analytics salt
**Evidence:** `app_constants.dart`  
**Severity:** Medium  
**Recommended:** Per-install salt. **Effort:** S

## OWASP / AI vectors

| Class | Status |
|-------|--------|
| Secrets | Keys in secure storage — good; cleartext/custom URL — bad |
| XSS | WebView risk |
| CSRF | N/A (no cookie session API) |
| Injection | Prompt + Zip Slip |
| SSRF | Custom provider URLs (user-driven) |
| Broken auth | No auth (reduces some risk, blocks recovery) |
| Supply chain | Model download; CI lacks vuln scan |

## Security roadmap

| Phase | Actions |
|-------|---------|
| Week 1 | Signing, Zip Slip, cleartext, consent gate, chunk default off |
| 30d | HTTPS provider policy, WebView harden, Firestore posture, secret scanning in CI |
| 90d | App Check, crash/PII scrubbing, moderation for free tier, MobSF/Semgrep |
| 12 mo | SOC2-oriented controls with backend identity |

## Score

Security **3.3/10**
