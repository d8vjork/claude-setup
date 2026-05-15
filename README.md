# claude-setup

Shared Claude Code user settings, statusline, and plugins for a team
environment.

Installs a custom `settings.json`, a user-level `CLAUDE.md`, and a statusline
script into `~/.claude/`. The repo also doubles as a Claude Code **plugin
marketplace** (see [Orchestration plugin](#orchestration-plugin)).

## What's included

- **`settings.json`** — Claude Code user settings with a curated set of plugins enabled and sensible defaults (`sonnet` model, auto-compact on, away summary off).
- **`CLAUDE.md`** — user-level instructions applied to every project: git-commit rules (no co-author trailer, never push on a commit request) and a pointer to the orchestration workflow.
- **`statusline.sh`** — Status line script for Mac/Linux (requires `jq`).
- **`statusline.ps1`** — Status line script for Windows (PowerShell, no extra dependencies).
- **`orchestration/`** — a bundled Claude Code plugin; this repo is its marketplace.

Both statusline scripts display the active model, current working directory, rate-limit usage (5h and weekly), and context window percentage with color-coded thresholds.

## Installation

The installer will ask you what to install:

| Option | What happens |
|--------|-------------|
| **1) Statusline only** | Copies the statusline script, adds/updates only the `statusLine` key in your existing `settings.json` |
| **2) Full settings + statusline** | Copies the statusline script and the `CLAUDE.md`, and replaces `settings.json` (existing files are backed up) |
| **3) Full settings only** | Copies the `CLAUDE.md` and replaces `settings.json` without installing the statusline |

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

## Orchestration plugin

`orchestration/` is a Claude Code plugin bundled in this repo, which also acts
as the marketplace that serves it. Installing the full `settings.json` enables
it automatically — `settings.json` lists `claude-setup` under
`extraKnownMarketplaces` and `orchestration@claude-setup` under
`enabledPlugins`, so Claude Code fetches and activates the plugin from GitHub
on next launch.

It provides:

- **`orchestrated-feature` skill** — a multi-agent workflow. The main session
  (Opus) plans the change, spawns parallel Sonnet `feature-implementer`
  subagents, routes any gaps/bugs they discover into a `CURRENT_ISSUES.md`
  file, then splits the result into commits with a Haiku `commit-splitter`
  subagent. It triggers automatically on multi-step feature/refactor work and
  can be invoked explicitly with `/orchestrated-feature`.
- **`feature-implementer` agent** (Sonnet) — implements one scoped unit of a plan.
- **`commit-splitter` agent** (Haiku) — splits a working tree into logical commits.

### Testing the plugin locally before pushing

```bash
/plugin marketplace add /path/to/claude-setup
/plugin install orchestration@claude-setup
```

Once the repo is pushed to GitHub, any machine that installs the full
`settings.json` gets the plugin with no extra steps.

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
