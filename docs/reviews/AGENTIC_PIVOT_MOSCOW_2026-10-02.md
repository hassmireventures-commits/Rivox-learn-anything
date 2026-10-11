# Agentic pivot — MoSCoW (2026-10-02)

Round-table direction: Rivox should feel **session-orchestrated** (one clear next step, shared agent protocol) rather than **feature-navigated** (tabs and grids). This doc tracks MoSCoW from the multi-model review; **Must** items were implemented in the same workstream.

## Must have — status

| ID | Item | Status | Implementation notes |
|----|------|--------|-------------------|
| M1 | Unified **Next session** on Home | **Done** | `nextSessionProvider`, `LearnerSessionPlanner`, `NextSessionCard` on dashboard |
| M2 | **Orchestrator action bus** | **Done** | `LearnerSessionAction` + `ProposedActionRunner` shared by Home and chat chips |
| M3 | **Autonomy tier policy** | **Done** | `AgentAutonomyPolicy` — allowlisted navigate auto + undo snackbar |
| M4 | **Quota preflight** before generation | **Done** | `showGenerationPreflightSheet` before quiz/path start |
| M5 | **Goal validation** on agent generation topics | **Done** | `GoalContentValidationAgent.validateGenerationTopic` in `ProposedActionRunner` |

### M1 — Next session ranking (v1)

1. Pending ready generation route (`GenerationJobService.pendingReadyRoute`)
2. Flashcards due (`flashcardsDueCountProvider`)
3. Exam ≤14 days → Study plan (`/exam/plan`)
4. `LearningOrchestrator.decideNext()` (skip pure “break” nudges → today’s pick)
5. Fallback → Daily content (`/daily-content`)

### M3 — Autonomy tiers

| Tier | Actions |
|------|---------|
| `autoWithUndo` | Allowlisted `navigate` only |
| `confirmExternal` | YouTube search |
| `confirmGeneration` | Quiz / path (preflight sheet + chip tap) |

## 2026-10-11 update

- **Expand propose kinds:** partly done. Chat now has `inlineQuiz` (answer in chat), `fixQuiz` (replace a broken quiz), and `editPath` (add, remove, rename, move modules).
- **New autonomy rule:** path edits are `autoWithUndo` (`AgentAutonomyPolicy.pathEditTier`): applied immediately, exact snapshot for Undo. `fixQuiz` stays `confirmGeneration` because it spends quota.
- **Navigate fix:** tab routes (`/dashboard`, `/learn`, `/history`) open with `go`, not `push` (blank History screen bug).
- Details: `docs/BACKLOG.md` B47 to B58.

## Should have (not in this pass)

- Expand propose kinds (resume quiz, voice debrief)
- Activity timeline in History
- Reminder → confirm sheet
- Learn screen as command surface

## Could have

- Collapse shell tabs after Activity timeline
- Chat playbooks with per-step caps
- B40 on-device ranking for offline next-step

## Won’t (this cycle)

- Chat-only home
- Silent auto quiz/path
- Model-supplied arbitrary routes
- Ads between propose and confirm

## Regression risks

- Navigate undo assumes a single `push`; deep stacks may need double pop.
- Next session and Learning Pulse can disagree until a single ranker SoT (learner memory) owns both.
- Generation preflight adds one sheet before quiz/path from chat and Home.

## Verified

- `flutter test test/learner_session_planner_test.dart`
- `flutter analyze` on touched agentic/dashboard/chat files
