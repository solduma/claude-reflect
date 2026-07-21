---
name: dev-workflow
description: The user's standard issue→branch→commit→PR→merge workflow for any code implementation task (feat/fix/refactor). Invoke at the START of implementation work in a git project — when turning a request into GitHub issues, creating feature branches, making commits, or opening/merging PRs. Covers the 13-step flow, commit message convention, and PR template. Not for research/design-only tasks (analysis with no code change).
---

# Development Workflow

The user's standard flow for implementation work. Run autonomously — no confirmation prompts at any step (except genuine open design decisions, which use a CLI select menu with pros/cons + a recommended option).

## Mental model

`Query > Problem = Issue > Task`
- **Problem = Issue**: an independent unit extracted from the query. N problems → N issues.
- **Task**: the implementation steps that resolve one issue.

## The 13 steps

1. **Analyze query**: break it into independent problem units.
2. **Plan**: list tasks and dependencies per issue. For open questions (ambiguous requirements, multiple valid approaches), present a CLI select menu with pros/cons and a recommendation before proceeding.
3. **Check existing issues**: `gh issue list` — reuse if duplicate. `gh issue view <n> --comments` — skip if a "Starting:" comment already exists (someone else is on it).
4. **Create issues**: one per problem (`gh issue create`).
5. **Create feature branch**: `feat/<slug>` or `fix/<slug>` off `main`.
6. **Work in parallel**: independent issues/tasks concurrently; dependencies first.
7. **Announce task start**: `gh issue comment <n> --body "Starting: <task>"` before each task.
8. **Commit per task**: narrow-scoped commit after the pre-commit hook passes.
9. **Adversarial verify**: independently verify all changes before opening the PR. For any change to what the user visually sees (`web/` UI — charts, overlays, layout, styling), verify in a REAL browser per the **browser-verify** skill — lint/build passing is not sufficient.
10. **Push → PR**: `gh pr create` with the PR template and `Closes #<n>` in the body.
11. **Resolve conflicts → merge**: `gh pr merge --merge --delete-branch`.
12. **Delete local branch**: `git branch -d <branch>`.
13. **Close issue**: auto-closed via `Closes #<n>`; otherwise `gh issue close <n>`.

**Research/design tasks**: no commit, push, or PR — analysis only.

## Commit convention

Format: `<type>(<optional scope>): <subject>` — imperative, lowercase, no period.
Types: `feat` / `fix` / `refactor`.
End the message with:

```
Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

## PR template

```markdown
## Summary
- <what changed and why>

## Test Plan
- [ ] <what was tested>

Closes #<n>
```

## Interactive-command note

If the user must run a command themselves (e.g. an interactive login like `gcloud auth login`), suggest they type `! <command>` in the prompt so its output lands in the session.
