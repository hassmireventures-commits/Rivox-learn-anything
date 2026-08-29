# Cloud Architecture

## Current state

- Client-heavy; Firebase optional and largely unconfigured
- No IaC, no multi-region, no CDN for content, no auto-scaling surfaces owned by the product
- AI inference: user’s cloud providers or on-device MLC (arm64, ≥6GB RAM)

## Target architecture (90-day → 12-month)

```
[Mobile clients]
    │ HTTPS
[API Gateway / BFF]
    ├─ Auth (Firebase Auth / Cognito / Auth0)
    ├─ AI Gateway (quotas, moderation, routing, spend caps)
    ├─ Sync API (encrypted learning state)
    ├─ Analytics ingest (App Check, rate limits)
    └─ Config / kill switches / model registry
         │
    [Managed DB] [Object storage] [Queue] [Observability]
```

## Scale tiers

| Users | Cloud needs |
|-------|-------------|
| <10K beta | Crash reporting, flavors, deny Firestore client writes |
| 100K | BFF, App Check, CDN for static/legal, basic HA single region |
| 1M | Multi-AZ DB, queues for indexing, regional failover plan |
| 10M+ | Multi-region active-passive → active-active for sync/AI gateway; edge caching |
| 100M+ | Global traffic mgmt, data residency partitions, dedicated AI capacity |

## HA / DR

Today: device backups only (partial export).  
Target: RPO/RTO defined per data class; encrypted cloud backup; regional failover for gateway.

## FinOps note

BYOK shifts AI cost to users (good for margins, bad for UX). Hosted free tier requires hard server-side budgets, abuse detection, and unit economics before growth spend.
