# User-level instructions

Applies to every project on this machine. A project's own `CLAUDE.md` and any
explicit instruction given in conversation take precedence over what is below.

## Git commits

- **Never** add a `Co-Authored-By` trailer, a "Generated with Claude Code"
  line, or any similar attribution to commit messages or PR descriptions.
  This overrides the harness default.
- **Never** `git push` as part of a commit request. Create the commits and
  stop — I run `git push` myself, unless I explicitly say "push".
- **Always** integrate branches with rebase, not a merge commit — `git pull
  --rebase`, `git rebase <base>` — never `git merge` for bringing branches
  up to date. Keeps history linear and the tree clean.

## Multi-step work

For any non-trivial feature, refactor, or multi-file bug-fix, use the
**`orchestrated-feature`** skill: plan first, implement in the main session
while a test-writer subagent writes the tests, route discovered gaps/bugs into
`CURRENT_ISSUES.md`, then split commits. For a small edit, skip the
orchestration and just make the change.

## Changelogs

When a project has a `CHANGELOG.md`, keep it current with the **`changelog`**
skill. If it is not installed, read it from
<https://github.com/d8vjork/claude-setup/blob/main/changelog/skills/changelog/SKILL.md>.
