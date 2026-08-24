# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
> Slated for 2.0.0 — not released yet, `README.md` and `docs/CLAUDE.md` still show 1.1.0 on purpose. Both version lines only move together, in the same commit, the moment this is actually ready to ship — see the "Versioning" decision in `CONTRIBUTING.md` for why.

### Added

- Bunch of skills to improve dev workflow and code quality, including:
    - `unslop`: Removes AI patterns from writing and adds human voice.
    - `bum-dev`: Encourages minimalistic coding practices to avoid over-engineering.
    - `minmax`: Promotes removing complexity before adding new features.
- `SessionStart` hook (`.claude/hooks/session-start.sh`) that loads `docs/CLAUDE.md` and the latest sessions of `docs/frontend/PROGRESS.md` and `docs/backend/PROGRESS.md` automatically, and checks the template version in silence.
- `.claude/scripts/changelog.sh`: prints what changed upstream and, for a known major version jump, the migration steps to follow.
- One-liner remote install: `curl -fsSL .../install.sh | bash` from a project's root now scaffolds `docs/`, `.claude/` and `.github/workflows/` directly, no manual clone needed.
- `docs/PROGRESS.md` split into `docs/frontend/PROGRESS.md` and `docs/backend/PROGRESS.md`, each edited only by its own layer — a frontend dev and a backend dev on separate branches no longer collide on the same tracking file. Session numbering is independent per layer.
- `.claude/scripts/merge-progress.sh`: rebuilds `docs/PROGRESS.md` from the two layer files (tables recombined, sessions interleaved by date).
- `.github/workflows/merge-progress.yml`: runs the merge automatically, once, server-side, whenever `main` moves — including a PR merge. Falls back to running `merge-progress.sh` by hand on a project without GitHub Actions.

### Changed

- **Breaking**: `docs/PROGRESS.md` is now a generated file — never edit it by hand, it's rebuilt from `docs/frontend/PROGRESS.md` and `docs/backend/PROGRESS.md`. See migration steps in `.claude/scripts/changelog.sh`.
- `DECISIONS.md`, `CHANGELOG.md`, `ERRORS.md`, and `FEEDBACK.md` now use newest-first ordering with a `<!-- SENTINEL -->` marker at the insertion point, so new entries always go on top and the latest one is immediately visible.
- Template version check no longer runs as a manual step Claude performs each session — it's handled by the `SessionStart` hook instead.
- `install.sh` no longer requires cloning the whole repo as a subfolder of the target project; it fetches only what it needs and is purely additive (refuses instead of overwriting).
- Template update procedure now compares `.claude/` (`hooks/`, `scripts/`, `SKILLS/`, `settings.json`) and `.github/workflows/` against the installed project too, not just `docs/CLAUDE.md` — new automation files now reach existing installs on update, not just fresh ones.


## [1.1.0] - 2026-08-16

### Added

- Improved documentation structure for working with Claude on web projects.
- Installation scripts for setting up the project environment.

## [1.0.0] - 2026-05-09

- Initial release of the project with basic features and documentation.