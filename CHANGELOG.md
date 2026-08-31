# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

## [2.2.0] - 2026-08-31

### Added

- `docs/frontend/FEEDBACK.md`: new generic (`Date : —`) pattern — mixing a viewport-height section (`svh`/`vh`/`min-h-screen`) with fixed-pixel-height content inside it looks fine on small/medium screens but leaves the content stranded in empty space on large ones.

## [2.1.0] - 2026-08-24

### Added

- `.claude/scripts/apply-update.sh`: automates the purely mechanical part of a template update — clones the latest template and copies any file entirely missing locally in `.claude/hooks/`, `.claude/scripts/`, `.claude/SKILLS/`, `.github/workflows/`, and `docs/`, never overwriting anything. Leaves only `docs/CLAUDE.md` (line-level additions) and `.claude/settings.json` (new keys) for judgment-based comparison, instead of six separate locations checked by hand. `docs/CLAUDE.md` > "Mise à jour du template" now calls it at step 2.
- `docs/CLAUDE.md` > "Aiguillage" now routes security work to `SECURITY.md` explicitly (previously only reachable via the catch-all "neither layer" row — a security bug on either layer would never surface it).
- A closing note under the "Index — quand lire quoi" table: grep `### ` titles in `ERRORS.md`/`FEEDBACK.md`/`DECISIONS.md` before reading one in full, once it's grown large.

### Changed

- `.claude/hooks/session-start.sh` no longer injects the full "Mise à jour du template" procedure (~24% of `docs/CLAUDE.md`'s word count) on every session — only when an update is actually available. Same content, still fully readable on demand, just not force-fed on the vast majority of sessions where it's not actionable.

### Fixed

- `.claude/scripts/merge-progress.sh`: a session entry containing a fenced code block whose content happened to start with `### Session` was misparsed as a new session boundary, silently fragmenting that entry. Session splitting is now fence-aware.
- `.claude/scripts/merge-progress.sh`: two sessions sharing the same date had their order inverted in the merged output (older one first). Fixed the sort key so ties resolve to source order (newest-on-top, per the LIFO convention).
- `.claude/scripts/apply-update.sh`: a failed fetch (no network, DNS failure) was silently swallowed — `curl`'s exit status was lost in the `curl | tar` pipe (an empty stream still makes `tar` exit 0), so the script reported "nothing to add" instead of failing loudly. Now fetches to a file first and checks both the exit code and that the file isn't empty before extracting.
- `.claude/scripts/changelog.sh`: a project on 1.x checking for updates against a hypothetical future 3.x+ release would silently get the "1.x to 2.x" migration text as if it were complete and correct for that jump. Now warns explicitly when the known migration steps don't cover the actual version gap.

## [2.0.0] - 2026-08-24

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