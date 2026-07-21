:arrow_down: *Read this in another language: generated from [claude-reflect](https://github.com/solduma/claude-reflect)*

# claude-reflect

A self-evolving kit for Claude Code: global rules, reusable skills, and daily self-reflection that continuously sharpens how you work.

## What's inside

```
claude-reflect/
├── CLAUDE.md                    # Global rules — response style, working principles, code quality, package management
├── skills/                      # Skills installed by default
│   ├── daily-reflection/        #   Daily retrospective → distill principles → evolve CLAUDE.md
│   └── reflection-journal/      #   Browse the history of past reflections
├── examples/skills/             # Example skills produced by daily-reflection in practice
│   ├── dev-workflow/            #   Example: issue → branch → commit → PR → merge pipeline
│   ├── project-setup/           #   Example: project scaffolding (linters, env, pre-commit)
│   ├── hexagonal-architecture/ #   Example: ports & adapters design principles
│   └── browser-verify/         #   Example: frontend UI verification via headless Chrome
├── launchd/install.sh           # macOS launchd scheduler (auto-runs daily-reflection at 21:43)
├── crontab.example              # Linux crontab equivalent
├── install.sh                   # Bootstrap script (backup, copy, dry-run, uninstall)
└── README.md
```

## Core skills (installed by default)

| Skill | Trigger | What it does |
|---|---|---|
| **daily-reflection** | First session of the day (auto-schedule), user asks to reflect, cron fires, end of a long task, or repeated failures | Reviews today's work for inefficiencies (token waste, repeated failures, wasted effort), distills universal prevention principles, and updates `~/.claude/CLAUDE.md`. Records the change in the reflection journal. |
| **reflection-journal** | User asks about past reflections, or Claude Code needs to reference previously derived principles | Reads `~/.claude/reflection-journal.md` and shows trends: added/modified/removed principles, skill evolution, inefficiency trends. |

## Example skills (in `examples/skills/`)

These are **real skills that emerged from daily-reflection**. They are not installed by default; copy the ones you want into `skills/` or use them as templates for your own.

| Skill | Trigger | What it does |
|---|---|---|
| **dev-workflow** | A `feat`/`fix`/`refactor` task requires code changes in a git repo | Guides the issue → branch → commit → PR → merge pipeline, commit conventions, and PR template. |
| **project-setup** | Creating a new project, adding linters, wiring env config, writing first tests | Sets up `uv` (Python) / `pnpm` (Node), `.env`/`APP_ENV` rules, pre-commit hooks, ruff/ESLint/pytest configs. |
| **hexagonal-architecture** | Designing or reviewing codebase layering | Applies ports & adapters principles: pure domain core, dependency inversion, import-linter boundaries. |
| **browser-verify** | A `web/` change alters what the user visually sees | Captures a headless-Chrome screenshot to verify the actual rendered result before merging/deploying. |

## Install

```bash
git clone https://github.com/solduma/claude-reflect.git
cd claude-reflect
./install.sh
```

`./install.sh` will ask whether to install in **hard** or **soft** mode:

| Mode | Effect |
|---|---|
| **hard** | Replace `~/.claude/CLAUDE.md` with the claude-reflect template. |
| **soft** | Keep your existing `~/.claude/CLAUDE.md` and use Claude to merge the template's **Working Principles** and **Skills** sections. |

In both modes, the core skills `daily-reflection` and `reflection-journal` are copied into `~/.claude/skills/`.

You can also run non-interactively:

```bash
./install.sh hard    # replace CLAUDE.md
./install.sh soft    # merge into existing CLAUDE.md
./install.sh dry     # preview only
./install.sh uninstall
```

### Add an example skill

```bash
cp -r examples/skills/dev-workflow ~/.claude/skills/
```

### Schedule auto-reflection (optional)

After installing, you can set up daily auto-reflection:

**macOS:**
```bash
bash launchd/install.sh
```

**Linux:**
```bash
crontab crontab.example
```

## Usage

Once installed, invoke skills from Claude Code:

```
/daily-reflection       # Run today's retrospective
/reflection-journal     # Browse reflection history
/dev-workflow           # Start a feature/fix task (if copied from examples)
```

When `daily-reflection` is scheduled, it runs every weekday evening, reviews the day's work, and updates `~/.claude/CLAUDE.md` based on the inefficiencies it finds.

## Customize

1. Fork the repo and edit `CLAUDE.md` to match your preferences.
2. Keep your own skills in `skills/` so `install.sh` copies them automatically.
3. Put example/template skills in `examples/skills/`.

## Uninstall

```bash
./install.sh uninstall
```

## License

MIT
