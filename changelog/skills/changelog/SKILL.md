---
name: changelog
description: How to write and maintain a project's CHANGELOG.md (Keep a Changelog + SemVer) as brief, product-like release notes that also render cleanly as GitHub releases. Use whenever you add, edit, or review a CHANGELOG.md entry, cut a release, or land user-visible work in a project that has a CHANGELOG.md.
---

# Maintaining CHANGELOG.md

Any project that has a `CHANGELOG.md` keeps it current. When work lands that a
user, integrator, or downstream agent would notice, add an entry. The changelog
is release notes for a product: written for the person consuming the release,
not for whoever wrote the diff. Each version section is also pasted into a
GitHub release, so it must read well there too.

## Format

Follow [Keep a Changelog](https://keepachangelog.com/en/1.1.0/) and
[SemVer](https://semver.org/):

```markdown
# Changelog

All notable changes to this project are documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/), and this project adheres to [Semantic Versioning](https://semver.org/).

## [Unreleased]

## [1.1.0] - 2026-09-06

### Added

- Lambda layer support.
- Correct local responses for streaming functions.

## [1.0.1] - 2026-08-18

### Changed

- Built release binaries with Go 1.26.6.

### Fixed

- Bodyless HTTP responses no longer fail.

## [1.0.0] - 2026-08-05

### Added

- First release
```

- New work goes under `## [Unreleased]`, grouped into `### Added`,
  `### Changed`, `### Fixed`, `### Deprecated`, `### Removed`, `### Security`
  (only the sections you need, in that order). Keep `## [Unreleased]` even
  when it is empty.
- Released versions are `## [X.Y.Z] - YYYY-MM-DD`, newest first.
- One bullet per change, describing the outcome, not the commit.

## Before the first release

While nothing has been released yet (no version headings, only
`## [Unreleased]`), the changelog holds a single `### Added` section with one
bullet, `First release`, and nothing else: no other bullets, no other sections.
Everything before the first version *is* the first release. Itemised entries
start with the work that lands after that first version is tagged.

## Writing an entry

- **One line per bullet.** Never hard-wrap a bullet across lines: GitHub
  releases render the wrapped line breaks literally and the notes look broken.
  Same for the preamble paragraph: one line each.
- **Brief.** Aim for a bullet under ~80 characters. This is a guideline, not a
  hard limit: go longer only when the reader genuinely needs the extra words
  (a breaking change with a migration step, a security fix's scope), and even
  then keep it to one sentence.
- **Outcome first.** Name the capability or fix as the user perceives it
  ("Lambda layer support.", "Bodyless HTTP responses no longer fail."), not
  how it was built.
- **Keep what users type or see** in backticks: config keys, flags, commands,
  public API names, formats. Drop internal struct, method, and file names,
  private helpers, refactor mechanics, and internal caps that are not
  user-visible.
- **No commit-style prefixes** (`feat(...)`, `fix:`, `chore:`); the section
  heading already says what kind of change it is.
- **Collapse** several related commits into the one entry they add up to.
  Purely internal work (refactors, tests, CI) gets no entry unless a user would
  notice it.
- End each bullet with a full stop.

**Litmus test:** could a user of the release tell what changed and whether it
affects them, without reading the source? If the entry only makes sense with
the diff open, rewrite it.

Before → after, from a real project:

> Before: `- **Response streaming** (\`url.invoke_mode: RESPONSE_STREAM\`): a
> function wrapped in \`awslambda.streamifyResponse\` now gets its real HTTP
> status code, headers, and cookies back on its local route, instead of the raw
> \`http-integration-response\` frame ... leaking straight through as the body.`
> (eleven wrapped lines)
>
> After: `- Correct local responses for streaming functions.`

## Cutting a release

1. Rename `## [Unreleased]` content into a new `## [X.Y.Z] - YYYY-MM-DD`
   section, choosing the version by SemVer from what it contains (`Removed` or
   a breaking `Changed` → major; `Added` → minor; only `Fixed` → patch).
2. Leave an empty `## [Unreleased]` heading above it.
3. The new section's body, as is, is the GitHub release notes.
