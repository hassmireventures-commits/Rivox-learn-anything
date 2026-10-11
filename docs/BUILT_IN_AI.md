# Built-in AI

The app ships a silent **Built-in AI** default (OpenAI-compatible HTTP API). User-facing copy never names the upstream host or “free” tier.

## Model

Default model id (code only): `meta/llama-3.2-11b-vision-instruct` (primary; stable JSON). Fallback: `nvidia/nemotron-3-nano-30b-a3b`.

**Model routing:** `BuiltInAiRouter` retries alternate NIM models on HTTP 404/410 **or** unusable output (chain-of-thought / instruction leaks from Nemotron). Applies to quiz generation, JSON completion, readiness handshake, and connection tests.

Sampling: `temperature=0.4`, `top_p=0.9`, `frequency_penalty=0`, `presence_penalty=0`.

Quiz `max_tokens` is capped (`min(3072, 280 × questionCount)`) for speed. Path/JSON calls use `3072`. Dio timeout is **90s** (same as BYOK).

Cloud resolve uses the user’s **default** provider first (including Built-in when selected). Other BYOK keys and Built-in are tried after. Quiz generation still has resilient fallbacks; the Home AI brief falls back to Built-in if a non-Built-in probe fails.

## Build-time API key

Inject the key at compile time (do **not** commit secrets):

```powershell
flutter build apk --debug `
  --dart-define=BUILT_IN_AI_API_KEY=YOUR_KEY_HERE

flutter build apk --release --split-per-abi `
  --dart-define=BUILT_IN_AI_API_KEY=YOUR_KEY_HERE
```

Empty define: Built-in row still seeds, but generations fail until a key is provided or the user adds their own provider.

## NVIDIA services: vision, OCR, embeddings, safety (2026-10-11)

One key per capability, so each has its own rate-limit bucket. Any missing key falls back to `BUILT_IN_AI_API_KEY`; on 401/403/429 a call fails over to the next key (`NvidiaAiConfig.keysFor`). All live in the gitignored `tool/.local_dart_defines.json`:

| Define | Used for | Model | Probed 2026-10-11 |
|---|---|---|---|
| `NVIDIA_VISION_API_KEY` | Photo questions in chat | `meta/llama-3.2-11b-vision-instruct` | 200, 3s to over 90s (free-tier queue) |
| `NVIDIA_OCR_API_KEY` | Cloud OCR fallback, photo text | `nvidia/nemotron-parse` | 200, about 1s |
| `NVIDIA_EMBED_API_KEY` | Semantic library search | `nvidia/nemotron-3-embed-1b` (2048-d) | 200, about 1s |
| `NVIDIA_SAFETY_API_KEY` | Chat safety guard | `nvidia/nemotron-3.5-content-safety` | 200, about 1s |
| `NVIDIA_SPARE_API_KEY` | Failover for all of the above | | |

Release build:

```powershell
flutter build appbundle --release --dart-define-from-file=tool/.local_dart_defines.json
```

**GitHub Actions secrets:** the same names are repository secrets. Upload or refresh them from the local file (values are never printed):

```powershell
gh auth login                                                    # once
powershell -ExecutionPolicy Bypass -File tool/push_ci_secrets.ps1 -DryRun   # list names
powershell -ExecutionPolicy Bypass -File tool/push_ci_secrets.ps1           # set them
```

`ci.yml` writes `tool/.local_dart_defines.json` from the secrets before the release build checks; `ai-eval.yml` runs the NVIDIA live probe nightly (informational).

Live check (skipped without keys):

```powershell
flutter test test/nvidia_live_probe_test.dart --dart-define-from-file=tool/.local_dart_defines.json
```

Not used: `moonshotai/kimi-k3` (171s at max effort, no answer in 180s at low), `nvidia/riva-translate-4b-instruct-v2` (101s and a wrong translation), the rerank endpoint (end of life 2026-05-18), and Gemma 3 / Phi-3 vision (404 for this account). Re-probe before adopting any of them.

**Built-in fallback fix:** `nvidia/nemotron-3-nano-30b-a3b` reached end of life on 2026-09-01 (HTTP 410), so the Built-in fallback silently failed whenever the primary did. It is now `nvidia/nemotron-3.5-lightning-30b-a3b` (JSON in `content`, about 4s for a 2-question quiz).

**Key safety:** keys compiled into an APK can be extracted. They were also shared in a chat on 2026-10-11. Rotate them in the NVIDIA console before the public release, and move these calls behind a server (for example a Firebase Function) when usage grows.

## Whisper STT (voice interview)

Inject a separate key for NVIDIA Whisper Large v3 (speech-to-text):

```powershell
flutter build apk --release --split-per-abi `
  --dart-define=WHISPER_API_KEY=YOUR_NVAPI_KEY_HERE
```

Or combine with Built-in LLM in `tool/.local_dart_defines.json` (gitignored):

```json
{
  "BUILT_IN_AI_API_KEY": "nvapi-…",
  "WHISPER_API_KEY": "nvapi-…"
}
```

Used by **Career → Voice interview** → mic on open answers. Endpoint: `https://b702f636-f60c-4a3d-a6f4-f3568c13bd7d.invocation.api.nvcf.nvidia.com/v1/audio/transcriptions` (NVCF Whisper Large v3). Do not use `integrate.api.nvidia.com/v1/audio/transcriptions` — it returns 404.

See `.cursor/skills/interviewer-voice/SKILL.md` for agent implementation notes.

Treat APK embedding as **obfuscation only**. Rotate keys if exposed.

On each launch, `ensureBuiltInSeeded` refreshes Built-in’s model/base URL from code so upgrades apply without reinstall.

## Quotas (Built-in only)

| Rule | Value |
|------|-------|
| Free generations / rolling 24h window | 5 |
| Bonus per rewarded ad | +2 |
| Max rewarded ads / day | 3 |

Allowance resets on a **rolling 24-hour window** from when the period started (not at local midnight). Background Workmanager and app resume call `restoreIfExpired()` so expired windows refresh even when the app was closed.

Own API keys are **not** limited by this quota. When Built-in quota is exhausted and a BYOK fallback provider is configured, quiz generation uses the fallback instead of blocking.

Quota is recorded only after a successful Built-in response is persisted (quiz/path) or successfully applied (interview scoring).

## Rewarded ads (quota unlock)

Production units are baked into `AppConstants` (never test IDs, never blank dart-defines). Quiz results use `prodBannerAdUnitId`. AI Providers / quota unlock uses `prodRewardedInterstitialAdUnitId` first, then `prodRewardedAdUnitId` if that format does not fill. Never reuse the standard interstitial ID for unlock. Watching a rewarded interstitial grants **+2** generations (up to `maxRewardedAdsPerDay`). Standard interstitials (Settings / Support “sponsored”) are thank-you only and **never** unlock quota.

See [PLAY_STORE_CHECKLIST.md](PLAY_STORE_CHECKLIST.md).

## Related flags

- `kLocalLlmEnabled` / `kLocalLlmComingSoon` in `lib/core/services/local_llm_flags.dart` — on-device MLC is **disabled** (`kLocalLlmEnabled = false`) until `mlc4j` is packaged.
