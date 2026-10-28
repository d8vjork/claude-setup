---
name: orchestrated-feature
description: Workflow for non-trivial feature, refactor, or multi-step bug-fix work. The main session (Opus) plans and implements the change itself, a Sonnet test-writer subagent writes the tests in parallel from the plan, gaps/bugs/spec-questions discovered along the way go into CURRENT_ISSUES.md, and a Haiku subagent splits the result into clean commits. Use whenever asked to build a feature, do a refactor, or make a multi-file change; skip for small edits.
---

# Orchestrated feature workflow

You are the **planner and implementer**. You plan the change and write the
code yourself, in one context, because a fresh subagent would have to re-read
everything you already know. You delegate only the work that gains from a
separate agent: tests (written blind to your implementation), large mechanical
bulk, and commit splitting.

Run this in an Opus session. If the session is on another model, say so once
and suggest `/model opus` before starting; do not block on it.

## When to use this

Use it for a new feature, a refactor, or a bug-fix that spans several files
and benefits from a plan and its own tests.

**Skip it** for small or medium edits (one or two files, an obvious change):
make the change directly, run the relevant checks, and ignore the rest of this
skill. The workflow has overhead; do not spend it on small work.

## 1 — Plan

1. Resolve genuinely ambiguous requirements first (`AskUserQuestion`). Do not
   ask about things you can decide or verify yourself.
2. Explore the codebase enough to plan against its real conventions — do not
   plan in the abstract.
3. Write the plan to `.claude/plans/<feature-slug>.md` (create the folder and
   add `/.claude/plans/` to `.gitignore` if missing). Keep it strictly to what
   was asked; open questions and out-of-scope ideas go in
   `.claude/plans/PLAN_EXTRAS.md`. The plan is a short checklist, not a
   hand-off document:
   - the files to change and the change to each;
   - the **public interface** (functions, endpoints, flags, config keys) and
     the **behaviours** it must have, including edge cases and errors — the
     test-writer works from this section alone, so make it precise;
   - the verification commands (build, lint, test);
   - the intended **commit grouping**, in order.

## 2 — Implement and test in parallel

- **Spawn the test-writer first**, in the background, as soon as the plan's
  interface and behaviours are settled: `subagent_type:
  orchestration:test-writer` (fallback: `general-purpose` with `model:
  sonnet`). Its prompt carries the interface and behaviours section, the test
  files it owns, the test conventions to follow (point at an existing test
  file), and the test command. It must not wait for or read your
  implementation.
- **Implement the plan yourself** while it works. Match the codebase's
  conventions; verify as you go with the build and lint commands.
- **Bulk delegation, as an exception:** when part of the plan is large,
  repetitive, and independent of the rest (the same change across many files,
  generated boilerplate, a mechanical migration), hand that part to
  `orchestration:feature-implementer` (fallback: `general-purpose` with
  `model: sonnet`), with the exact files, the pattern to apply, and the check
  to run. Launch independent delegated parts in one message so they run in
  parallel, and never let a subagent touch files you or another agent own.
- **Converge:** when both sides are done, run the full test suite. A failing
  test means either the code misses the plan (fix the code) or the test
  misreads it (fix the test, or send it back to the test-writer with
  `SendMessage` if it is more than a small correction). The plan is the
  referee; if the plan itself was wrong, update it and say so.

## 3 — Route discovered issues

When you or a subagent find a gap, bug, spec-question, or deferred-work item
outside the plan:

- **Append it to `CURRENT_ISSUES.md` at the repo root**, creating the file if
  it does not exist. Never just surface it in chat and move on.
- Each entry records **Where** (file + line), **What** is wrong or missing,
  and the suggested **Fix**. If the file already has a structure, match it.
- Fix it inline only if it blocks the plan. Otherwise log it and continue —
  uncontrolled scope creep is exactly what this step prevents.

## 4 — Changelog

If the project has a `CHANGELOG.md` and the change is user-visible, add the
entry yourself following the `changelog` skill. If that skill is not
installed, read it from
<https://github.com/d8vjork/claude-setup/blob/main/changelog/skills/changelog/SKILL.md>.

## 5 — Split commits

Once everything is implemented and the suite is green:

- Hand the working tree to `subagent_type: orchestration:commit-splitter`
  (fallback: `general-purpose` with `model: haiku`), passing the plan's
  commit grouping so it does not have to infer it from the diff.
- Check its report: every changed file committed, nothing unrelated swept in.

## Git rules (always)

- **No `Co-Authored-By` / "Generated with Claude" trailer** on any commit or PR.
- **Do not push.** Create commits only, unless explicitly told to push.
- If the repo is on its default branch, create a feature branch first.

## Agents not installed?

The agents ship with the `orchestration` plugin of the
[`d8vjork/claude-setup`](https://github.com/d8vjork/claude-setup) marketplace
(`/plugin marketplace add d8vjork/claude-setup`, then
`/plugin install orchestration@claude-setup`). Without it, use the
`general-purpose` fallbacks above and paste the matching agent's instructions
from `orchestration/agents/` in that repo into the prompt.
