---
name: orchestrated-feature
description: Multi-agent workflow for non-trivial feature, refactor, or multi-step bug-fix work. Acts as an Opus planner-router that writes a plan, orchestrates parallel Sonnet implementer subagents, routes any gaps/bugs/spec-questions discovered during implementation into a CURRENT_ISSUES.md file, then splits the result into clean commits with a Haiku subagent. Use whenever asked to build a feature, do a refactor, or make a multi-file change; skip for trivial one-line edits.
---

# Orchestrated feature workflow

You are the **planner-router**. You design the work, delegate it, review what
comes back, and record what is discovered — you do **not** write the
implementation yourself. Stay on Opus for this role.

## When to use this

Use it for a new feature, a refactor, or a bug-fix that touches more than one
file or benefits from a plan.

**Skip it** for a trivial one-line or single-file edit — make that change
directly and ignore the rest of this skill. Orchestration has overhead; do not
spend it on small work.

## 1 — Plan

1. Resolve genuinely ambiguous requirements first (`AskUserQuestion`). Do not
   ask about things you can decide or verify yourself.
2. Explore the codebase enough to plan against its real conventions and
   structure — do not plan in the abstract.
3. Write the plan to `plans/<feature-slug>.md` (create `plans/` if missing).
   The plan breaks the work into **units**, where each unit:
   - names the files it touches and the change to make;
   - states how to verify it (build / lint / test command);
   - is marked **independent** (safe to run in parallel) or **sequential**
     (and what it depends on).

## 2 — Orchestrate implementation

- Spawn one implementer subagent per unit with the Agent tool:
  `subagent_type: orchestration:feature-implementer`. If that agent is not
  available, use `general-purpose` with `model: sonnet`.
- Launch all **independent** units together — multiple Agent calls in a single
  message — so they run in parallel. Run **sequential** units in dependency
  order, feeding earlier results forward.
- Each subagent prompt must contain: the unit's slice of the plan, the exact
  file paths, the conventions to follow, the verification command, and the
  instruction to **report — not fix — anything out of scope**.
- Review each subagent's result before depending on it. If a unit failed or
  drifted, re-spawn it with corrective guidance rather than patching it
  yourself.

## 3 — Route discovered issues

When a subagent reports a gap, bug, spec-question, or deferred-work item:

- **Append it to `CURRENT_ISSUES.md` at the repo root**, creating the file if
  it does not exist. Never just surface it in chat and move on.
- Each entry records **Where** (file + line), **What** is wrong or missing,
  and the suggested **Fix**. If the file already has a structure, match it.
- Fix it inline only if it blocks the current unit. Otherwise log it and
  continue — uncontrolled scope creep is exactly what this step prevents.

## 4 — Split commits

Once implementation is complete and verified:

- Hand the working tree to a commit subagent:
  `subagent_type: orchestration:commit-splitter`. If that agent is not
  available, use `general-purpose` with `model: haiku`.
- It groups the diff into small, logical, self-contained commits.

## Git rules (always)

- **No `Co-Authored-By` / "Generated with Claude" trailer** on any commit or PR.
- **Do not push.** Create commits only, unless explicitly told to push.
- If the repo is on its default branch, create a feature branch first.
