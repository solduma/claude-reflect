#!/bin/bash
set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"
SKILLS_DIR="$CLAUDE_DIR/skills"
BACKUP_DIR="$CLAUDE_DIR/backups/$(date +%Y%m%d_%H%M%S)"

MODE="${1:-interactive}"

# ── helpers ─────────────────────────────────────────────────────────────

install_skills() {
  for skill_dir in "$REPO/skills/"*/; do
    name="$(basename "$skill_dir")"
    mkdir -p "$SKILLS_DIR/$name"
    cp "$skill_dir/SKILL.md" "$SKILLS_DIR/$name/SKILL.md"
    echo "  + $name"
  done
}

remove_skills() {
  for skill_dir in "$REPO/skills/"*/; do
    name="$(basename "$skill_dir")"
    rm -f "$SKILLS_DIR/$name/SKILL.md"
    rmdir "$SKILLS_DIR/$name" 2>/dev/null || true
    echo "  - $name"
  done
}

prompt_mode() {
  echo ""
  echo "How do you want to install the global CLAUDE.md?"
  echo ""
  echo "  [hard] Replace ~/.claude/CLAUDE.md with the claude-reflect template."
  echo "         Choose this for a clean, opinionated starting point."
  echo ""
  echo "  [soft] Keep your existing ~/.claude/CLAUDE.md and use Claude to merge"
  echo "         the Working Principles and Skills sections from the template."
  echo "         Choose this if you already have custom rules you want to preserve."
  echo ""
  while true; do
    read -rp "Choose hard or soft (default: soft): " choice
    choice="${choice:-soft}"
    case "$choice" in
      hard|h) echo hard; return ;;
      soft|s) echo soft; return ;;
    esac
    echo "Please type 'hard' or 'soft'."
  done
}

merge_with_claude() {
  local template="$REPO/CLAUDE.md"
  local target="$CLAUDE_DIR/CLAUDE.md"

  echo ""
  echo "Running soft merge via Claude..."
  echo "  - Preserving your existing $target"
  echo "  - Merging Working Principles and Skills from the template"

  if command -v claude >/dev/null 2>&1; then
    claude -p "Read the existing ~/.claude/CLAUDE.md and the template at $template. Merge only the 'Working Principles' and 'Skills' sections from the template into the existing file. Preserve all existing content. Avoid duplicates. Do not touch other sections. Do not remove content. Keep the result concise." || {
      echo ""
      echo "⚠️  Claude merge failed. Falling back to hard replacement."
      hard_replace
      return
    }
  else
    echo ""
    echo "⚠️  claude CLI not found. Falling back to hard replacement."
    hard_replace
  fi
}

hard_replace() {
  mkdir -p "$BACKUP_DIR"
  if [[ -f "$CLAUDE_DIR/CLAUDE.md" ]]; then
    cp "$CLAUDE_DIR/CLAUDE.md" "$BACKUP_DIR/CLAUDE.md"
    echo "  Backup: $BACKUP_DIR/CLAUDE.md"
  fi
  cp "$REPO/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
  echo "  Replaced ~/.claude/CLAUDE.md with template"
}

print_onboarding() {
  echo ""
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo "  claude-reflect is installed"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
  echo ""
  echo "Core skills:"
  echo "  /daily-reflection       — run today's retrospective"
  echo "  /reflection-journal     — browse past reflections"
  echo ""
  echo "Auto-reflection (optional):"
  if [[ "$(uname)" == "Darwin" ]]; then
    echo "  bash $REPO/launchd/install.sh"
  else
    echo "  crontab $REPO/crontab.example"
  fi
  echo ""
  echo "Once scheduled, daily-reflection runs every weekday evening and"
  echo "updates ~/.claude/CLAUDE.md based on the day's inefficiencies."
  echo ""
  echo "Example skills you can copy:"
  echo "  cp -r $REPO/examples/skills/dev-workflow ~/.claude/skills/"
  echo "  cp -r $REPO/examples/skills/project-setup ~/.claude/skills/"
  echo "  cp -r $REPO/examples/skills/hexagonal-architecture ~/.claude/skills/"
  echo "  cp -r $REPO/examples/skills/browser-verify ~/.claude/skills/"
  echo ""
  echo "Uninstall: ./install.sh uninstall"
  echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
}

# ── modes ─────────────────────────────────────────────────────────────

case "$MODE" in
  dry)
    echo "=== Dry run ==="
    echo "Target: $CLAUDE_DIR"
    echo ""
    echo "[CLAUDE.md]"
    echo "  Source: $REPO/CLAUDE.md"
    echo "  Dest:   $CLAUDE_DIR/CLAUDE.md"
    echo "  (existing file → $BACKUP_DIR/ in hard mode)"
    echo ""
    echo "[Skills]"
    for skill_dir in "$REPO/skills/"*/; do
      name="$(basename "$skill_dir")"
      echo "  + $name → $SKILLS_DIR/$name/SKILL.md"
    done
    echo ""
    echo "[Scheduler]"
    if [[ "$(uname)" == "Darwin" ]]; then
      echo "  launchd: see $REPO/launchd/install.sh (run separately)"
    else
      echo "  crontab: see $REPO/crontab.example (register manually)"
    fi
    echo ""
    echo "To install: ./install.sh"
    exit 0
    ;;

  uninstall)
    echo "=== Uninstall ==="
    if ls "$CLAUDE_DIR/backups"/*/CLAUDE.md 2>/dev/null; then
      latest=$(ls -dt "$CLAUDE_DIR/backups"/*/ 2>/dev/null | head -1)
      cp "$latest/CLAUDE.md" "$CLAUDE_DIR/CLAUDE.md"
      echo "Restored CLAUDE.md from: $latest/CLAUDE.md"
    else
      echo "No backup found. Restore CLAUDE.md manually."
    fi
    remove_skills
    echo "Done."
    exit 0
    ;;

  hard)
    echo "=== Hard install ==="
    mkdir -p "$CLAUDE_DIR" "$SKILLS_DIR"
    hard_replace
    install_skills
    print_onboarding
    ;;

  soft)
    echo "=== Soft install ==="
    mkdir -p "$CLAUDE_DIR" "$SKILLS_DIR"
    merge_with_claude
    install_skills
    print_onboarding
    ;;

  interactive|*)
    echo "=== Claude Code Starter Kit install ==="
    selected=$(prompt_mode)
    "$0" "$selected"
    ;;
esac
