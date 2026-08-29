# Scalability Roadmap

## What fails first

| Scale | First failures |
|-------|----------------|
| **100K** | BYOK churn; crash blindness; store policy (ads/legal/signing); support email; Isar growth |
| **1M** | No accounts → retention collapse; RAG quality complaints; locale/a11y backlash; Firestore cost/abuse if naïve |
| **10M** | Need AI gateway, moderation, CDN/content, release trains; client-only ceiling |
| **100M** | Identity, anti-abuse, regional compliance, payments/entitlements mandatory |
| **1B** | Different product: federated learning outcomes, marketplace, enterprise distribution |

## Migration path

```
Hardened Flutter client
  → Modular client + thin BFF (auth, AI proxy, analytics)
    → Service-oriented (sync, entitlements, moderation, content)
      → Event-driven learning platform (outcomes graph, marketplace)
        → Multi-region global control plane
```

## Component scale notes

| Component | Limit today | Next step |
|-----------|-------------|-----------|
| Frontend | Device CPU/DB | Isolates, indexed queries |
| AI | User API quotas | Hosted pool + budgets |
| Auth | None | Optional accounts |
| DB | Single-device Isar | Sync + server SoR for cloud features |
| Search/RAG | O(n) hash | BM25/ANN + embeddings |
| Notifications | Local exact alarms | Prefer inexact; FCM later |
| Logging | debugPrint | Crash + privacy-aware telemetry |
| Analytics | Client Firestore | Server aggregation |

## Score

Scalability **2.5/10**
