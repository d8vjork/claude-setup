# claude-setup

Shared Claude Code user settings and statusline for a team environment.

Installs a custom `settings.json` and a `statusline.sh` script into `~/.claude/`.

## What's included

- **`settings.json`** — Claude Code user settings with a curated set of plugins enabled and sensible defaults (`sonnet` model, auto-compact on, away summary off).
- **`statusline.sh`** — A status line script that displays the active model, current working directory, rate-limit usage (5h and weekly), and context window percentage with color-coded thresholds.

## Requirements

- [Claude Code](https://claude.ai/code) installed
- `jq` (used by `statusline.sh` to parse the JSON payload from the CLI)

## Installation

```bash
git clone <repo-url> claude-setup
cd claude-setup
./install.sh
```

The script will:

1. Copy `statusline.sh` to `~/.claude/statusline.sh` and make it executable.
2. Back up any existing `~/.claude/settings.json` to `settings.json.bak`, then copy the new one in place.

## Statusline format

```
Sonnet 4.6 · /path/to/project · 5h 12% / wk 4% · Context 8% used
```

Color thresholds:

| Metric | Yellow | Red |
|--------|--------|-----|
| Context | ≥ 50% | ≥ 80% |
| 5h rate limit | ≥ 70% | ≥ 90% |
| Weekly rate limit | ≥ 60% | ≥ 85% |
