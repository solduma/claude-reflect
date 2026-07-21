---
name: daily-reflection
description: Review the day's work to identify inefficiencies (token waste, repeated failures, wasted effort) and distill prevention principles into the global CLAUDE.md. Triggers: first session of the day (auto-schedule), user request ("reflect"/"retrospective"), cron fire, end of a long task, or repeated failures detected. Principles must be project-agnostic. Records changes in reflection-journal.
---

# Daily Reflection

Review the day's work and evolve the global rules (`~/.claude/CLAUDE.md`) to **prevent recurrence** of inefficiencies. The goal is not self-criticism but **accumulation of prevention principles**.

## Trigger conditions (Claude Code decides from context)

Invoke this skill when any of the following is true:

1. **First session of the day** — Check `CronList` for today's reflection one-shot; if missing, run the scheduling procedure. Do this before any other work.
2. **User request** — The user says something that implies reflection: "reflect", "retrospective", "review today", "what could be improved", etc.
3. **Cron fire** — This skill is invoked directly by a scheduled cron job.
4. **End of a long task** — After completing complex implementation, debugging, or refactoring that produced meaningful lessons worth recording.
5. **Repeated failures detected** — After the same tool call or issue fails multiple times, suggesting a new principle is needed.

## Scheduling procedure (first session of the day)

1. Use `CronList` to check if today's reflection one-shot already exists — skip if it does.
2. If missing, use `CronCreate` to schedule a **one-shot for this evening**:
   - `recurring: false`
   - Pin the cron expression to today's date (e.g. `43 21 <today_DoM> <today_month> *` — avoid :00/:30).
   - `prompt`: "Run the daily-reflection skill to review today's work and update CLAUDE.md."
3. Inform the user in one line that the reflection is scheduled (mention the time).

## Reflection procedure

### 1. Gather history (token-efficient: summaries only)
- Today's git log: `git log --oneline --since="16 hours ago"` (actual output).
- Today's session logs: `~/.claude/projects/<project>/*.jsonl` modified today. **Do not read them whole** — if large, grep for failures, retries, and error patterns only (e.g. `grep -c` for failure counts).
- If you are the agent in the current session, use your first-hand experience of inefficiencies rather than re-reading logs.

### 2. Diagnose across 3 axes
- **Token waste**: re-reading the same file, reading large files whole, unnecessary broad greps, verbose intermediate explanations.
- **Repeated failures**: same tool call failing multiple times (format errors, wrong args), guess-based fixes that miss and require rework, repeated build/test failures.
- **Wasted effort**: proceeding without investigation then reverting, misjudging background task state, manual polling, sequential processing when parallel was possible.

### 3. Derive principles (universal only)
For each inefficiency, extract a **one-line prevention principle** that is project-agnostic:
- ❌ Bad (project-specific): "Use stream=True for reporter deepdive"
- ✅ Good (universal): "After two missed guesses, immediately pin down the root cause with logs or reproduction — don't stack guess-based fixes"
- Skip if the principle already exists in CLAUDE.md (only reword if reinforcement is needed).

### 4. Update CLAUDE.md
- Backup before change: `cp ~/.claude/CLAUDE.md ~/.claude/CLAUDE.md.bak-<YYYYMMDD>`.
- Add new principles concisely to the **"Working Principles"** section (verbosity is token waste — CLAUDE.md is loaded every session).
- If a principle grows into a domain-specific procedure, extract it into a separate skill and keep only the trigger in CLAUDE.md.

### 5. Record in reflection-journal
Append changes to `~/.claude/reflection-journal.md`:

```markdown
## 2026-07-21

### CLAUDE.md changes
- **Added**: "Build structured tool args as data, not hand-written JSON" — manual escaping of non-ASCII/quoted args failed repeatedly
- **Modified**: none
- **Removed**: none

### Skills changes
- **daily-reflection**: added journal recording step (step 5)
- **reflection-journal**: new skill

### Inefficiency summary
| Axis | Count | Example |
|---|---|---|
| Token waste | 2 | Same file read 3 times |
| Repeated failures | 1 | Shell variable substitution failed twice |
| Wasted effort | 0 | — |
```

Create the file if it doesn't exist. Append only — never overwrite.

### 6. Report summary
Present a table to the user: inefficiencies found → principles derived → whether CLAUDE.md was updated. If no changes were needed, honestly say "no new principles (existing ones suffice)".

## Principles
- **Universality**: CLAUDE.md applies to all projects. Project-specific facts go in project CLAUDE.md or memory.
- **Conciseness**: One principle = one line. If reflection makes CLAUDE.md bloated, that itself is token waste.
- **Honesty**: If there were no inefficiencies, say so. Don't fabricate principles.
- **Traceability**: All changes go into reflection-journal. This is how evolution over time is tracked.
