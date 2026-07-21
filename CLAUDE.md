# Global Rules

## Response Style
- Answer in the user's language (match their input language)
- Multiple conclusions → table format
- Decision points → CLI select menu with pros/cons and a recommended marker per option
- In responses that call tools, keep prose minimal (a line or two) and put the tool call up front. Long analysis, tables, and design belong in responses with no tool call — a tool call appended after long prose tends to leak as text and fail.

---

## Working Principles

Universal principles for how to work (to prevent recurring inefficiency). Project-agnostic.

- **Evidence over guessing**: if a guess at the cause misses twice, immediately pin down the root cause with logs, reproduction, or data. Do not stack guess-based fixes.
- **Confirm async work before proceeding**: treat a background task (agent or job) as "in progress" only after confirming its launch-success signal (an id, etc.). Without that signal, don't assume it started — re-check.
- **Automate repeated waiting**: don't hand-repeat the same polling or waiting; wrap it into a single background job.
- **Validate a script's first output**: if the result is empty or wrong, don't move to the next step. When shell variable substitution gets tangled, use a more robust approach (e.g. Python).
- **Save tokens**: don't re-read a file already read. Don't read large files or logs whole — grep or range-read only the needed part. Delegate broad investigation to a subagent and take only the conclusion.
- **Lint before committing, not after**: run the linter/formatter on changed files before invoking the commit, so the pre-commit hook doesn't reject and force a full re-commit. Fix unused imports and import order in the same pass as the edit.
- **Build structured tool args as data, not hand-written JSON**: for tools taking rich structured input (esp. with non-ASCII text or quotes), assemble the argument as a normal value, never hand-concatenate an escaped JSON string — manual escaping fails repeatedly.

---

## Skills

Invoke these automatically when the trigger condition is met (full details in each skill's SKILL.md):

- **daily-reflection** — end of day, or the user asks to reflect. **First session of the day**: check CronList and schedule if missing.
- **reflection-journal** — the user asks about past reflection history or how their workflow evolved

Run implementation autonomously — no confirmation prompts except genuine open design decisions (use a CLI select menu).

---

## Code Quality

Applies to every code edit, regardless of task type:

### Naming
- Follow the established convention of the language/framework the codebase uses (PEP 8, Airbnb, Google, etc.).
- Be consistent with the surrounding code — don't introduce a new style in an isolated edit.

### Comments
Self-Documenting Code by default. Add a comment only when the **why** is non-obvious (hidden constraint, workaround, subtle invariant). If a name would become too long for readability, use a short comment as the tradeoff. Never describe what — only why.

### Error Handling
Validate and handle errors at system boundaries only (user input, external APIs). Trust internal code and framework guarantees. Do not add defensive checks for scenarios that cannot happen.

### Tool-specific Rules
If the project already has configured tools (linter, formatter, type checker, test runner), run them on changed files before committing. If no tools are configured, leave that choice to the project setup.

---

## Package Management

- Never hardcode secrets, API keys, or passwords — always use env vars.
- Use whatever package manager the project already uses. Don't swap it without a project-level decision.
- (Full setup conventions → **project-setup** skill.)
