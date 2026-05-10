#!/bin/bash
# Claude Code statusLine
# Format: Opus 4.7 (high) · /cwd · 5h 45% · wk 23% · Context 20% used

input=$(cat)

DIR=$(echo "$input"     | jq -r '.workspace.current_dir // .cwd // empty')
MODEL=$(echo "$input"   | jq -r '.model.display_name // empty')
CTX=$(echo "$input"     | jq -r '.context_window.used_percentage // empty' | cut -d. -f1)
PCT_5H=$(echo "$input"  | jq -r '.rate_limits.five_hour.used_percentage // empty' | cut -d. -f1)
PCT_WK=$(echo "$input"  | jq -r '.rate_limits.seven_day.used_percentage // empty' | cut -d. -f1)

# Reasoning effort: not in the JSON payload as of v2.1.x. Try env vars set by
# the CLI, then any default in settings.json. Omit cleanly if unknown.
EFFORT="${CLAUDE_EFFORT:-${CLAUDECODE_EFFORT:-${CLAUDE_CODE_EFFORT:-}}}"
if [ -z "$EFFORT" ]; then
  EFFORT=$(jq -r '.effort // empty' ~/.claude/settings.json 2>/dev/null)
fi

DIM='\033[2m'
RESET='\033[0m'
CYAN='\033[36m'
YELLOW='\033[33m'
RED='\033[31m'
GREEN='\033[32m'

ctx_color="$GREEN"
if [ -n "$CTX" ]; then
  if   [ "$CTX" -ge 80 ]; then ctx_color="$RED"
  elif [ "$CTX" -ge 50 ]; then ctx_color="$YELLOW"
  fi
fi

pct_5h_color="$GREEN"
if [ -n "$PCT_5H" ]; then
  if   [ "$PCT_5H" -ge 90 ]; then pct_5h_color="$RED"
  elif [ "$PCT_5H" -ge 70 ]; then pct_5h_color="$YELLOW"
  fi
fi

pct_wk_color="$GREEN"
if [ -n "$PCT_WK" ]; then
  if   [ "$PCT_WK" -ge 85 ]; then pct_wk_color="$RED"
  elif [ "$PCT_WK" -ge 60 ]; then pct_wk_color="$YELLOW"
  fi
fi

SEP=" ${DIM}\xc2\xb7${RESET} "

parts=()
if [ -n "$MODEL" ]; then
  if [ -n "$EFFORT" ]; then
    parts+=("${MODEL} ${DIM}(${EFFORT})${RESET}")
  else
    parts+=("${MODEL}")
  fi
fi
[ -n "$DIR" ] && parts+=("${CYAN}${DIR}${RESET}")
if [ -n "$PCT_5H" ] || [ -n "$PCT_WK" ]; then
  credits=""
  [ -n "$PCT_5H" ] && credits="${DIM}5h${RESET} ${pct_5h_color}${PCT_5H}%${RESET}"
  if [ -n "$PCT_WK" ]; then
    [ -n "$credits" ] && credits="${credits} ${DIM}/${RESET} "
    credits="${credits}${DIM}wk${RESET} ${pct_wk_color}${PCT_WK}%${RESET}"
  fi
  parts+=("$credits")
fi
[ -n "$CTX" ] && parts+=("${DIM}Context${RESET} ${ctx_color}${CTX}%${RESET} ${DIM}used${RESET}")

out=""
for p in "${parts[@]}"; do
  if [ -z "$out" ]; then out="$p"; else out="${out}${SEP}${p}"; fi
done

printf '%b\n' "$out"
