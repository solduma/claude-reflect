---
name: reflection-journal
description: Query and analyze the history of daily reflections. Triggers: user asks about past reflections/principles/skill changes, or Claude Code needs to reference previously derived principles during decision-making. Supports date range filtering, keyword search, principle trend analysis, and skill change history.
---

# Reflection Journal

Read and analyze the accumulated daily reflection history in `~/.claude/reflection-journal.md`.

## Trigger conditions (Claude Code decides from context)

Invoke this skill when any of the following is true:

1. **User query** — The user asks about past reflections, principle evolution, skill change history, or inefficiency trends.
2. **Decision reference** — Before adding a new principle to CLAUDE.md, check the journal to avoid duplicating existing principles.
3. **Skill improvement** — When modifying or adding a skill, reference past similar changes and their lessons.
4. **Periodic review** — Synthesize reflection trends monthly or quarterly to provide insights to the user.

## Query and analysis

### Basic queries

Read the journal file and process according to the request:

| Request type | Handling |
|---|---|
| Full history | Print newest-first. If the file is large, show only recent N days. |
| Date range | Filter to a specific period only. |
| Keyword | Show only entries containing a specific keyword. |
| Recent N days | Tail-like query. |

### Analysis modes

Choose the appropriate mode based on the request:

1. **Principle trend** — Show principles added/modified/removed over time
2. **Skill change history** — How skills have evolved
3. **Inefficiency trend** — Per-axis (token waste / repeated failures / wasted effort) over time
4. **Keyword search** — Find entries matching a keyword

### Output format

#### Summary view (default)
```
📋 reflection-journal: 2026-07-14 ~ 2026-07-21 (8 entries)

[Principle trend]
  Added 5 | Modified 1 | Removed 0

[Inefficiency trend]
  Token waste      ████▁▁▁▁▁▁  4
  Repeated failure ██▁▁▁▁▁▁▁▁▁  2
  Wasted effort    ▁▁▁▁▁▁▁▁▁▁▁  0

[Last 3 entries]
  07-21: token_waste=2 repeated_failures=1 — "Build structured tool args as data"
  07-20: token_waste=1              — "Validate script first output"
  07-19: repeated_failures=1        — "Evidence over guessing"
```

#### Detail view (specific date)
```
## 2026-07-21

### CLAUDE.md changes
- **Added**: "Build structured tool args as data, not hand-written JSON"
- **Modified**: none
- **Removed**: none

### Skills changes
- **daily-reflection**: added journal recording step (step 5)

### Inefficiency summary
| Axis | Count | Example |
|---|---|---|
| Token waste | 2 | Same file read 3 times |
| Repeated failures | 1 | Shell variable substitution error |
```

## Principles
- If the journal file doesn't exist, report "No reflection history yet."
- If the file is large, read only the last N days and suggest "Use /reflection-journal full for the complete history."
- Focus on summaries, not raw data dumps.
- When invoked for decision reference, extract only the relevant principles and omit the rest.
