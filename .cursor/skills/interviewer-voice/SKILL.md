---
name: interviewer-voice
description: >-
  Voice interview agent using NVIDIA Whisper STT for spoken answers and
  existing LLM rubric scoring. Use when implementing or debugging interview
  voice capture, transcription, or career drill voice mode.
---

# Interviewer voice (Whisper STT)

## Purpose

Let users **speak** open interview answers; transcribe with **NVIDIA Whisper Large v3**, then score with the existing text rubric (`InterviewRubricScorer`).

This is **not** a realtime voice agent (no TTS / back-and-forth yet). Flow: record → transcribe → edit text → submit → LLM judge.

## Architecture

| Layer | File | Role |
|-------|------|------|
| Config | `lib/core/services/built_in_whisper_config.dart` | `WHISPER_API_KEY` dart-define, model `openai/whisper-large-v3`, NVCF base URL, `interviewLanguage=en-US` |
| STT | `lib/core/services/whisper_stt_service.dart` | Mic permission, WAV record (`record` pkg), multipart POST `/audio/transcriptions` |
| UI bar | `lib/features/career/presentation/interview_voice_input_bar.dart` | Record / Stop / transcribe into answer field |
| Entry | `lib/features/career/presentation/drill_create_screen.dart` | **Voice interview** → same drill gen, navigates to `/quiz/play/:id?voice=1` |
| Play | `lib/features/quiz/presentation/quiz_play_screen.dart` | Shows mic bar when `voiceMode` (query `voice=1`) on open questions |
| Scoring | `lib/data/remote/ai/interview_rubric_scorer.dart` | Unchanged — scores transcribed text |

## Build-time secrets

Never commit keys. Add to gitignored `tool/.local_dart_defines.json`:

```json
{
  "BUILT_IN_AI_API_KEY": "nvapi-…",
  "WHISPER_API_KEY": "nvapi-…"
}
```

Release:

```powershell
flutter build apk --release --split-per-abi `
  --dart-define-from-file=tool/.local_dart_defines.json
```

LLM and Whisper may use **different** nvapi keys or the same key if your NVIDIA account allows both NIMs.

## NVIDIA API

- **Endpoint:** `POST https://b702f636-f60c-4a3d-a6f4-f3568c13bd7d.invocation.api.nvcf.nvidia.com/v1/audio/transcriptions`
- **Auth:** `Authorization: Bearer {WHISPER_API_KEY}`
- **Body:** `multipart/form-data` with `file` (WAV), `model=openai/whisper-large-v3`, `language=en-US`, `response_format=json`
- **Response:** `{ "text": "…" }`

Do **not** send audio through the chat/completions JSON path.

## Permissions

- Android: `RECORD_AUDIO` in `AndroidManifest.xml`
- iOS: `NSMicrophoneUsageDescription` in `Info.plist`
- Runtime: `permission_handler` → `Permission.microphone`

## Quota

Whisper calls are **separate** from Built-in LLM daily quota today. Interview **scoring** still consumes Built-in quota when the default provider is Built-in.

## Regression risks

- Missing `WHISPER_API_KEY` → voice button works but mic shows “not available on this build”
- Do not embed keys in repo, docs, or skills with real values
- STT is batch/offline only (Whisper NIM); no streaming partial transcripts
- Future realtime agent needs TTS + session state — track as backlog B2 extension

## Verified manually

- Career → Voice interview → open question → Record → Stop → text appears → submit → rubric scores

## Next steps (not shipped)

- TTS to read questions aloud
- Realtime WebSocket ASR for live interviewer
- Premium gate / separate STT quota
- Map app locale → BCP-47 for `language` param
