#!/usr/bin/env bash
# claude-dev-workflow installer.
#
# Run from the root of the project you want to scaffold:
#
#   curl -fsSL https://raw.githubusercontent.com/ud20-dev/claude-dev-workflow/main/install.sh | bash
#
# Copies docs/, .claude/ (settings.json, hooks/, scripts/, SKILLS/) and
# .github/workflows/merge-progress.yml into the current directory. Purely
# additive — refuses to run if any of those already exist, never
# overwrites anything.
#
# Also works from a local clone (no network needed): if this script is
# run by path and a docs/ folder sits right next to it, that local copy
# is used as the source instead of downloading one.

set -euo pipefail

REPO_TARBALL_URL="https://github.com/ud20-dev/claude-dev-workflow/archive/refs/heads/main.tar.gz"
TARGET_DIR="$(pwd)"
CLEANUP_DIR=""

trap '[ -n "$CLEANUP_DIR" ] && rm -rf "$CLEANUP_DIR"' EXIT

SCRIPT_DIR=""
if [ -n "${BASH_SOURCE:-}" ] && [ -f "${BASH_SOURCE[0]}" ]; then
  SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
fi

if [ -n "$SCRIPT_DIR" ] && [ -d "$SCRIPT_DIR/docs" ]; then
  SRC_DIR="$SCRIPT_DIR"
else
  command -v curl >/dev/null 2>&1 || { echo "Error: curl is required." >&2; exit 1; }
  command -v tar >/dev/null 2>&1 || { echo "Error: tar is required." >&2; exit 1; }
  CLEANUP_DIR="$(mktemp -d)"
  SRC_DIR="$CLEANUP_DIR"
  echo "Fetching claude-dev-workflow..."
  curl -fsSL "$REPO_TARBALL_URL" | tar -xz -C "$SRC_DIR" --strip-components=1
fi

SRC_DOCS="$SRC_DIR/docs"
SRC_CLAUDE="$SRC_DIR/.claude"
SRC_WORKFLOW="$SRC_DIR/.github/workflows/merge-progress.yml"
DEST_DOCS="$TARGET_DIR/docs"
DEST_CLAUDE="$TARGET_DIR/.claude"
DEST_WORKFLOW="$TARGET_DIR/.github/workflows/merge-progress.yml"

if [ ! -d "$SRC_DOCS" ]; then
  echo "Error: $SRC_DOCS not found — the fetched template looks incomplete." >&2
  exit 1
fi

CONFLICTS=()
[ -e "$DEST_DOCS" ] && CONFLICTS+=("$DEST_DOCS")
[ -e "$DEST_CLAUDE/settings.json" ] && CONFLICTS+=("$DEST_CLAUDE/settings.json")
[ -e "$DEST_CLAUDE/hooks" ] && CONFLICTS+=("$DEST_CLAUDE/hooks")
[ -e "$DEST_CLAUDE/scripts" ] && CONFLICTS+=("$DEST_CLAUDE/scripts")
[ -e "$DEST_CLAUDE/SKILLS" ] && CONFLICTS+=("$DEST_CLAUDE/SKILLS")
[ -e "$DEST_WORKFLOW" ] && CONFLICTS+=("$DEST_WORKFLOW")

if [ "${#CONFLICTS[@]}" -gt 0 ]; then
  echo "Error: already present, nothing was touched:" >&2
  printf '  %s\n' "${CONFLICTS[@]}" >&2
  echo "Merge or remove these manually before retrying." >&2
  exit 1
fi

mkdir -p "$DEST_CLAUDE"
cp -R "$SRC_DOCS" "$DEST_DOCS"
[ -f "$SRC_CLAUDE/settings.json" ] && cp "$SRC_CLAUDE/settings.json" "$DEST_CLAUDE/settings.json"
[ -d "$SRC_CLAUDE/hooks" ] && cp -R "$SRC_CLAUDE/hooks" "$DEST_CLAUDE/hooks"
[ -d "$SRC_CLAUDE/scripts" ] && cp -R "$SRC_CLAUDE/scripts" "$DEST_CLAUDE/scripts"
[ -d "$SRC_CLAUDE/SKILLS" ] && cp -R "$SRC_CLAUDE/SKILLS" "$DEST_CLAUDE/SKILLS"
chmod +x "$DEST_CLAUDE"/hooks/*.sh "$DEST_CLAUDE"/scripts/*.sh 2>/dev/null || true
if [ -f "$SRC_WORKFLOW" ]; then
  mkdir -p "$TARGET_DIR/.github/workflows"
  cp "$SRC_WORKFLOW" "$DEST_WORKFLOW"
fi

echo
echo "Installed into $TARGET_DIR:"
echo "  docs/ (dont docs/frontend/PROGRESS.md et docs/backend/PROGRESS.md — chacun édité par sa couche ; docs/PROGRESS.md racine est généré, ne pas éditer)"
echo "  .claude/settings.json"
echo "  .claude/hooks/session-start.sh"
echo "  .claude/scripts/changelog.sh"
echo "  .claude/scripts/merge-progress.sh"
echo "  .claude/SKILLS/ (bum-dev, minmax, unslop)"
if [ -f "$DEST_WORKFLOW" ]; then
  echo "  .github/workflows/merge-progress.yml — fusionne docs/PROGRESS.md automatiquement à chaque push sur main (nécessite GitHub Actions ; sinon lancer .claude/scripts/merge-progress.sh à la main)"
fi
echo
echo "Start a Claude Code session here — docs/CLAUDE.md and the latest sessions"
echo "of docs/frontend/PROGRESS.md and docs/backend/PROGRESS.md load automatically."
