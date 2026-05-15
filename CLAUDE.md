# User-level instructions

Applies to every project on this machine. A project's own `CLAUDE.md` and any
explicit instruction given in conversation take precedence over what is below.

## Git commits

- **Never** add a `Co-Authored-By` trailer, a "Generated with Claude Code"
  line, or any similar attribution to commit messages or PR descriptions.
  This overrides the harness default.
- **Never** `git push` as part of a commit request. Create the commits and
  stop — I run `git push` myself, unless I explicitly say "push".

## Multi-step work

For any non-trivial feature, refactor, or multi-file bug-fix, use the
**`orchestrated-feature`** skill: plan first, orchestrate implementer
subagents, route discovered gaps/bugs into `CURRENT_ISSUES.md`, then split
commits. For a trivial one-line edit, skip the orchestration and just make
the change.
