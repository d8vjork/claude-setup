#!/bin/bash
# Claude Code setup installer for Mac/Linux
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLAUDE_DIR="$HOME/.claude"

echo ""
echo "Claude Setup Installer"
echo "======================"
echo ""
echo "What would you like to install?"
echo ""
echo "  1) Statusline only"
echo "  2) Full settings (plugins, model, etc.) + statusline"
echo "  3) Full settings only (no statusline)"
echo ""
read -r -p "Enter choice [2]: " choice
choice="${choice:-2}"

case "$choice" in
  1) install_statusline=true;  install_settings=false ;;
  2) install_statusline=true;  install_settings=true  ;;
  3) install_statusline=false; install_settings=true  ;;
  *) echo "Invalid choice. Exiting."; exit 1 ;;
esac

mkdir -p "$CLAUDE_DIR"

if $install_statusline; then
  cp "$SCRIPT_DIR/statusline.sh" "$CLAUDE_DIR/statusline.sh"
  chmod +x "$CLAUDE_DIR/statusline.sh"
  echo "Installed statusline.sh -> $CLAUDE_DIR/statusline.sh"
fi

if $install_settings; then
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    echo "Backing up existing settings.json -> settings.json.bak"
    cp "$CLAUDE_DIR/settings.json" "$CLAUDE_DIR/settings.json.bak"
  fi

  if $install_statusline; then
    cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
  else
    # Strip the statusLine key since the script won't be installed
    if command -v jq &>/dev/null; then
      jq 'del(.statusLine)' "$SCRIPT_DIR/settings.json" > "$CLAUDE_DIR/settings.json"
    elif command -v python3 &>/dev/null; then
      python3 -c "
import json, sys
with open('$SCRIPT_DIR/settings.json') as f:
    d = json.load(f)
d.pop('statusLine', None)
print(json.dumps(d, indent=2))
" > "$CLAUDE_DIR/settings.json"
    else
      cp "$SCRIPT_DIR/settings.json" "$CLAUDE_DIR/settings.json"
      echo "Note: neither jq nor python3 found — statusLine key left in settings.json."
      echo "      Remove it manually if you are not using the statusline."
    fi
  fi

  echo "Installed settings.json -> $CLAUDE_DIR/settings.json"
fi

if ! $install_settings && $install_statusline; then
  # Statusline only — add/update just the statusLine key in settings.json
  STATUS_LINE_JSON='{"type":"command","command":"~/.claude/statusline.sh","padding":2}'
  if [ -f "$CLAUDE_DIR/settings.json" ]; then
    if command -v jq &>/dev/null; then
      tmp=$(mktemp)
      jq --argjson sl "$STATUS_LINE_JSON" '. + {statusLine: $sl}' "$CLAUDE_DIR/settings.json" > "$tmp"
      mv "$tmp" "$CLAUDE_DIR/settings.json"
      echo "Updated statusLine in existing settings.json"
    elif command -v python3 &>/dev/null; then
      python3 -c "
import json
with open('$CLAUDE_DIR/settings.json') as f:
    d = json.load(f)
d['statusLine'] = $STATUS_LINE_JSON
with open('$CLAUDE_DIR/settings.json', 'w') as f:
    json.dump(d, f, indent=2)
print('Updated statusLine in existing settings.json')
"
    else
      echo "Note: neither jq nor python3 found — could not patch settings.json."
      echo "      Add this manually to ~/.claude/settings.json:"
      echo '      "statusLine": '"$STATUS_LINE_JSON"
    fi
  else
    printf '{"statusLine": %s}\n' "$STATUS_LINE_JSON" > "$CLAUDE_DIR/settings.json"
    echo "Created settings.json with statusLine"
  fi
fi

echo ""
echo "Done. Claude settings installed to $CLAUDE_DIR"
