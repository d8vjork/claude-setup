#!/bin/bash
# Installs Claude user settings and statusline to ~/.claude/
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

mkdir -p "$CLAUDE_DIR"

cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
chmod +x "$CLAUDE_DIR/statusline.sh"

if [ -f "$CLAUDE_DIR/settings.json" ]; then
  echo "Backing up existing settings.json -> settings.json.bak"
  cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
fi

cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"

echo "Done. Claude settings and statusline installed to $CLAUDE_DIR"
