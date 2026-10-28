# claude-setup

Shared Claude Code user settings, statusline, and plugins for a team
environment.

Installs a custom `settings.json`, a user-level `CLAUDE.md`, and a statusline
script into `~/.claude/`. The repo also doubles as a Claude Code **plugin
marketplace** (see [Plugins](#plugins)).

## What's included

- **`settings.json`** — Claude Code user settings with a curated set of plugins enabled and sensible defaults (`sonnet` model, auto-compact on, away summary off), plus permissions: `acceptEdits` mode, an allowlist for read-only checks and routine local work (staging, committing, rebasing, Compose dev containers, local dev URLs), and `ask` rules for anything destructive or outward-facing (`git push`, `reset`, `rm`, `sudo`, publishing, secrets). Commands Claude Code already auto-allows are left out.
- **`CLAUDE.md`** — user-level instructions applied to every project: git-commit rules (no co-author trailer, never push on a commit request) and pointers to the orchestration and changelog skills.
- **`statusline.sh`** — Status line script for Mac/Linux (requires `jq`).
- **`statusline.ps1`** — Status line script for Windows (PowerShell, no extra dependencies).
- **`orchestration/`** and **`changelog/`** — bundled Claude Code plugins; this repo is their marketplace.

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

## Plugins

This repo bundles Claude Code plugins and also acts as the marketplace that
serves them. Installing the full `settings.json` enables them automatically —
`settings.json` lists `claude-setup` under `extraKnownMarketplaces` and each
plugin under `enabledPlugins`, so Claude Code fetches and activates them from
GitHub on next launch.

Without the full settings, add them by hand:

```bash
/plugin marketplace add d8vjork/claude-setup
/plugin install orchestration@claude-setup
/plugin install changelog@claude-setup
```

### Orchestration

- **`orchestrated-feature` skill** — the feature workflow. The main session
  (Opus) plans the change and implements it itself, while a Sonnet
  `test-writer` subagent writes the tests in parallel from the plan's
  interface and behaviours. Gaps/bugs found along the way go into
  `CURRENT_ISSUES.md`, and a Haiku `commit-splitter` subagent splits the
  result into commits. It triggers automatically on multi-step
  feature/refactor work and can be invoked explicitly with
  `/orchestrated-feature`.
- **`test-writer` agent** (Sonnet) — writes tests from the plan, without
  reading the implementation.
- **`feature-implementer` agent** (Sonnet) — takes large, mechanical slices
  the main session delegates as an exception.
- **`commit-splitter` agent** (Haiku) — splits a working tree into logical
  commits, following the plan's grouping.

### Changelog

- **`changelog` skill** — Keep a Changelog + SemVer rules for `CHANGELOG.md`:
  brief one-line entries (around 80 characters) that also render cleanly as
  GitHub releases, and a single `First release` entry until the first version
  ships.

### Testing the plugins locally before pushing

```bash
/plugin marketplace add /path/to/claude-setup
/plugin install orchestration@claude-setup
/plugin install changelog@claude-setup
```

Once the repo is pushed to GitHub, any machine that installs the full
`settings.json` gets the plugins with no extra steps.

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
