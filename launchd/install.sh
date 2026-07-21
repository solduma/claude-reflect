#!/bin/bash
# launchd LaunchAgent installer — auto-runs daily-reflection
#
# Triggers claude -p daily-reflection at ~21:00 weekdays.
# Unlike cron, launchd catches missed runs after sleep/wake.
#
#   ./launchd/install.sh          # Install
#   ./launchd/install.sh uninstall

set -euo pipefail

PROJECT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
AGENTS="$HOME/Library/LaunchAgents"
LABEL_PREFIX="com.claude.starter"

# Auto-detect claude CLI path
CLAUDE_BIN="$(command -v claude 2>/dev/null || echo "/usr/local/bin/claude")"

# daily-reflection: 21:43 weekdays (avoid :00/:30 stampede)
cat > "$AGENTS/$LABEL_PREFIX.daily-reflection.plist" <<PLIST
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
  <key>Label</key>
  <string>$LABEL_PREFIX.daily-reflection</string>
  <key>ProgramArguments</key>
  <array>
    <string>$CLAUDE_BIN</string>
    <string>-p</string>
    <string>Run the daily-reflection skill to review today's work and update CLAUDE.md.</string>
  </array>
  <key>WorkingDirectory</key>
  <string>$PROJECT</string>
  <key>StartCalendarInterval</key>
  <array>
    <dict><key>Weekday</key><integer>1</integer><key>Hour</key><integer>21</integer><key>Minute</key><integer>43</integer></dict>
    <dict><key>Weekday</key><integer>2</integer><key>Hour</key><integer>21</integer><key>Minute</key><integer>43</integer></dict>
    <dict><key>Weekday</key><integer>3</integer><key>Hour</key><integer>21</integer><key>Minute</key><integer>43</integer></dict>
    <dict><key>Weekday</key><integer>4</integer><key>Hour</key><integer>21</integer><key>Minute</key><integer>43</integer></dict>
    <dict><key>Weekday</key><integer>5</integer><key>Hour</key><integer>21</integer><key>Minute</key><integer>43</integer></dict>
  </array>
  <key>StandardOutPath</key>
  <string>$PROJECT/logs/reflection.log</string>
  <key>StandardErrorPath</key>
  <string>$PROJECT/logs/reflection.log</string>
  <key>ProcessType</key>
  <string>Background</string>
</dict>
</plist>
PLIST

launchctl load "$AGENTS/$LABEL_PREFIX.daily-reflection.plist"
echo "installed $LABEL_PREFIX.daily-reflection (21:43 weekdays, claude -p daily-reflection)"
