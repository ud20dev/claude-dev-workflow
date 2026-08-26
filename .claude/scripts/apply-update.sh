#!/usr/bin/env bash
# Applies the purely mechanical part of a template update: clones the
# latest claude-dev-workflow and copies over any whole file that's
# missing locally in .claude/hooks/, .claude/scripts/, .claude/SKILLS/,
# .github/workflows/, and docs/ (only files entirely absent — never an
# existing one). Never overwrites anything.
#
# What this deliberately does NOT touch, because it needs judgment a
# script can't safely automate:
#   - docs/CLAUDE.md: adding a missing line to a table without touching
#     a line the user may have reworded on purpose
#   - .claude/settings.json: merging in a new key without disturbing
#     existing ones
#   - structural migrations (e.g. FIFO -> LIFO reordering of real
#     session/decision history) — see .claude/scripts/changelog.sh
# Claude does those by hand right after this script runs, using the
# temporary clone this script leaves behind (path printed at the end —
# not deleted automatically, so it's still there for that comparison).
#
# Usage: .claude/scripts/apply-update.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
REPO_TARBALL_URL="https://github.com/ud20-dev/claude-dev-workflow/archive/refs/heads/main.tar.gz"

cd "$PROJECT_DIR"

if [ -d "$PROJECT_DIR/.git" ] && [ -n "$(git -C "$PROJECT_DIR" status --porcelain 2>/dev/null)" ]; then
  echo "Error: working tree not clean. Commit or stash first — this stays safely" >&2
  echo "revertable with git restore/checkout only if it started from a clean state." >&2
  exit 1
fi

command -v curl >/dev/null 2>&1 || { echo "Error: curl is required." >&2; exit 1; }
command -v tar >/dev/null 2>&1 || { echo "Error: tar is required." >&2; exit 1; }

TMPDIR="$(mktemp -d)"

echo "Fetching latest claude-dev-workflow..."
TARBALL="$TMPDIR/claude-dev-workflow.tar.gz"
if ! curl -fsSL "$REPO_TARBALL_URL" -o "$TARBALL"; then
  echo "Error: failed to fetch the latest template (network issue?). Nothing was changed." >&2
  exit 1
fi
if [ ! -s "$TARBALL" ]; then
  echo "Error: fetched file is empty. Nothing was changed." >&2
  exit 1
fi
tar -xz -C "$TMPDIR" --strip-components=1 -f "$TARBALL"
rm -f "$TARBALL"

ADDED=()

copy_if_missing() {
  local src="$1" dest="$2"
  [ -e "$dest" ] && return 0
  mkdir -p "$(dirname "$dest")"
  cp "$src" "$dest"
  ADDED+=("$dest")
}

copy_missing_files_under() {
  local src_dir="$1" dest_dir="$2"
  [ -d "$src_dir" ] || return 0
  while IFS= read -r -d '' f; do
    rel="${f#"$src_dir"/}"
    copy_if_missing "$f" "$dest_dir/$rel"
  done < <(find "$src_dir" -type f -print0)
}

for sub in hooks scripts SKILLS; do
  copy_missing_files_under "$TMPDIR/.claude/$sub" "$PROJECT_DIR/.claude/$sub"
done
copy_missing_files_under "$TMPDIR/.github/workflows" "$PROJECT_DIR/.github/workflows"
copy_missing_files_under "$TMPDIR/docs" "$PROJECT_DIR/docs"

chmod +x "$PROJECT_DIR"/.claude/hooks/*.sh "$PROJECT_DIR"/.claude/scripts/*.sh 2>/dev/null || true

echo
if [ "${#ADDED[@]}" -eq 0 ]; then
  echo "Rien à ajouter mécaniquement — tous les fichiers du template (hors contenu de docs/CLAUDE.md et settings.json) sont déjà présents."
else
  echo "Fichiers ajoutés (jamais rien écrasé) :"
  printf '  %s\n' "${ADDED[@]}"
fi

echo
echo "Reste à faire à la main (jugement requis, pas automatisable) :"
echo "  - docs/CLAUDE.md : comparer avec $TMPDIR/docs/CLAUDE.md, ajouter les lignes manquantes sans toucher aux lignes déjà présentes"
echo "  - .claude/settings.json : comparer avec $TMPDIR/.claude/settings.json, ajouter les clés manquantes"
echo "  - Migrations structurelles éventuelles : voir .claude/scripts/changelog.sh"
echo "  - Une fois confirmé : mettre à jour la ligne de version dans docs/CLAUDE.md, ajouter une entrée dans docs/CHANGELOG.md, puis supprimer le clone temporaire : rm -rf $TMPDIR"
