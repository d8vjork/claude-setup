# claude-setup

Shared Claude Code user settings and statusline for a team environment.

Installs a custom `settings.json` and a statusline script into `~/.claude/`.

## What's included

- **`settings.json`** — Claude Code user settings with a curated set of plugins enabled and sensible defaults (`sonnet` model, auto-compact on, away summary off).
- **`statusline.sh`** — Status line script for Mac/Linux (requires `jq`).
- **`statusline.ps1`** — Status line script for Windows (PowerShell, no extra dependencies).

Both statusline scripts display the active model, current working directory, rate-limit usage (5h and weekly), and context window percentage with color-coded thresholds.

## Installation

The installer will ask you what to install:

| Option | What happens |
|--------|-------------|
| **1) Statusline only** | Copies the statusline script, adds/updates only the `statusLine` key in your existing `settings.json` |
| **2) Full settings + statusline** | Copies the statusline script and replaces `settings.json` (existing file is backed up) |
| **3) Full settings only** | Replaces `settings.json` without installing the statusline |

### Mac / Linux

```bash
git clone <repo-url> claude-setup
cd claude-setup
./install.sh
```

Requires `jq` when using the statusline (or when installing full settings without statusline).

### Windows

Open PowerShell and run:

```powershell
git clone <repo-url> claude-setup
cd claude-setup
powershell -ExecutionPolicy Bypass -File install.ps1
```

No extra dependencies required on Windows — the statusline uses PowerShell's built-in JSON support.

> **Note:** ANSI colors in the statusline require Windows Terminal, VS Code terminal, or any other VT100-capable terminal (standard on Windows 10+).

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
