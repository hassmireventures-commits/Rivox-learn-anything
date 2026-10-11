# Competitor analysis: Rivox vs Duolingo, Coursera, and the AI-tutor field (2026-10-11)

Scope: any edtech app a learner could open instead of Rivox. Primary benchmarks are **Duolingo** (habit and retention) and **Coursera** (structured, credentialed learning). Secondary: the general AI assistants that now ship study modes, and the AI study-tool apps.

Method: features listed here are the competitors' publicly known positioning as of this writing. Anything marked *(verify)* should be re-checked against the competitor's current store listing or help pages before it is quoted in marketing copy. Nothing here is from private data.

## 1. Where each competitor wins

| Competitor | What it is best at | What a learner gives up there |
|---|---|---|
| **Duolingo** | Habit loop: streaks, streak freezes, XP, leagues, friend streaks, finely tuned push notifications, tiny daily sessions. Expanded beyond languages into math, music, and chess. AI features in its paid tier (answer explanations, roleplay and video-call practice) *(verify tier names and markets)*. | Fixed catalogue. You cannot learn woodworking, Godot, IELTS writing on your own notes, or your company's product. Paths are not built around your goal or exam date. |
| **Coursera** | Depth and credentials: university and industry courses, professional certificates, degrees, an AI coach inside courses *(verify name and availability)*. Strong for career switchers. | Long, fixed-pace courses; weak daily habit loop; most valuable parts are paid; no personal practice outside the catalogue. |
| **Khan Academy / Khanmigo** | Free, high-quality K-12 and early college content, Socratic AI tutor. | School subjects only; tutor is tied to its own content. |
| **Quizlet** | Flashcards from your own material, huge shared-set library, test modes. | Little structure beyond the set; AI features change often *(verify current AI features)*. |
| **ChatGPT study mode, Gemini guided learning, Claude learning mode** | General assistants that now teach step by step instead of handing over answers *(verify current names)*. Anything, any time. | No memory of a learning plan, no streaks or spaced repetition, no exam-shaped practice, no progress view. The learner has to drive every session. |
| **NotebookLM** | Grounded study from your own sources: summaries, audio overviews, generated quizzes and flashcards *(verify current feature set)*. | No daily habit, no plan, no adaptive next step. |
| **Speak, Praktika, ELSA (language speaking apps)** | Speaking practice with AI conversation partners. | Single skill. |

## 2. Where Rivox already competes

- **Learn anything, not a catalogue.** Any goal becomes a path, quizzes, flashcards, daily article and video. Since 2026-10-11 practice style adapts to the field (fitness form cues, DIY tool and safety scenarios, art technique, code reading, game-dev scenarios, exam-shaped items for IELTS/NEET/JEE/UPSC). See `lib/core/personalization/learning_domain.dart`.
- **Agentic, not navigational.** One "Next session" on Home; a chat agent that proposes quizzes and paths, quizzes you inside the chat, and now **fixes the plan itself** (adds, removes, renames, reorders modules with Undo; replaces a broken quiz). Duolingo and Coursera do not let the learner reshape the curriculum by talking to it.
- **Grounded in the learner's own material.** Library uploads, camera scan, job descriptions, resumes.
- **Exam and career modes.** Syllabus tracking, mocks, voice interview practice with scoring.
- **Local-first and BYOK.** Data stays on the device; power users bring their own key.

## 3. Gaps that cost us (and what shipped today)

| Gap vs leaders | Benchmark | Status |
|---|---|---|
| Streak only counted quiz days; no protection for one missed day | Duolingo streak freeze | **Shipped:** streak counts quizzes and quick questions; a freeze is earned per 7-day run (max 2) and applied automatically. |
| No XP or levels | Duolingo XP | **Shipped:** XP from quizzes, correct answers, and quick questions; levels at 100, 200, 300 XP steps. Shown in one quiet row on Home. |
| Generic reminders | Duolingo personalized, time-aware pushes | **Shipped:** evening streak-saver nudge naming the learner's weakest topic, only when the streak is at risk; **daily quick question answerable from the notification** (A/B/C buttons, works with the app closed). |
| Wrong-sense or off-goal content (the "Advanced English" quiz about a 1900s car) | Coursera's curated catalogue never has this failure | **Shipped:** goal, path, and module are composed before any lookup or prompt; wrong-sense Wikipedia hits are filtered. |
| Videos left the app | Coursera and Khan keep video in-app | **Shipped:** in-app video finder and player; YouTube app only as a last resort. |
| In-chat interactive practice | ChatGPT/Claude render quizzes in chat | **Shipped 2026-10-11 (morning):** in-chat quiz forms, quick replies, Markdown. |
| Leagues and friends | Duolingo leagues, friend streaks, friend quests | **Backlog B57** (needs accounts at scale; Could have). |
| Certificates of completion | Coursera certificates | **Backlog B58** (shareable completion card for a finished path; not an accredited credential). |
| Voice tutor conversation | Duolingo video call, Speak | Existing B42 (Won't, this cycle). |
| Web presence for "AI tutor" searches | Every leader ranks on its brand plus category terms | **Shipped:** AI-tutor positioning on the home page and five agentic-era posts; see `docs/logs/ENHANCEMENTS_LOG.md`. |

## 4. Positioning

**Rivox: the AI tutor that builds, runs, and fixes your study plan for anything you want to learn.**

- Against Duolingo: "Duolingo's daily habit, for any skill you choose, built around your goal."
- Against Coursera: "A course built for you in minutes, practice every day, and a tutor that changes the plan when it is wrong."
- Against general chatbots: "A chatbot answers. Rivox remembers your goal, plans your sessions, quizzes you, and keeps you coming back."

## 5. Conversion problem (Play Store: 900+ visitors, 75+ installs, about 8%)

An 8% store conversion rate is low for an education app. The listing still sells "AI quiz generator" while the product and graphic now say "AI tutor and study planner". Actions (see `docs/store/LISTING.md`, ASO 2026-10-11 section):

1. Title and short description lead with **AI Tutor** and **study planner** (the new feature graphic already does).
2. First three screenshots: (a) the chat tutor fixing a plan, (b) Home with streak and Next session, (c) in-chat quiz. Captions of five words or fewer.
3. Custom store listings per search intent: IELTS, NEET/JEE, coding interview, fitness and skills.
4. A store listing experiment on the icon and the first screenshot (Play Console > Store listing experiments), one variable at a time, 50/50, at least 7 days.
5. Ask for ratings after a positive moment (a perfect in-chat quiz, a 7-day streak), never after an error.

## 6. Next bets, ranked

1. **Leagues lite (B57):** weekly XP board against your own past weeks first (no accounts needed), friends later.
2. **Completion cards (B58):** shareable image when a path completes; doubles as organic acquisition.
3. **Streak repair offer:** after a break, one extra quick question restores yesterday once a month.
4. **Notification bandit:** rotate quick-question vs streak-saver vs daily pick copy and keep what gets opened (local, no server).
5. **Domain packs:** starter paths for the most common non-academic goals (fitness, cooking, drawing, game dev) so a new learner sees value before the first AI call.
