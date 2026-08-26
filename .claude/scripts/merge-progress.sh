#!/usr/bin/env bash
# Rebuilds docs/PROGRESS.md (a generated file, never edited by hand) from
# docs/frontend/PROGRESS.md and docs/backend/PROGRESS.md.
#
# Why a split in the first place: two devs (frontend/backend) on separate
# branches used to both edit the same docs/PROGRESS.md, causing merge
# conflicts on every overlapping session. Each layer now owns its own file;
# this script does a mechanical, non-conflicting rebuild of the combined
# view, meant to run once, server-side, when a PR lands on main
# (.github/workflows/merge-progress.yml). Can also be run by hand on a
# project without GitHub Actions.
#
# Usage: .claude/scripts/merge-progress.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}"
DOCS_DIR="$PROJECT_DIR/docs"
FRONTEND_FILE="$DOCS_DIR/frontend/PROGRESS.md"
BACKEND_FILE="$DOCS_DIR/backend/PROGRESS.md"
OUT_FILE="$DOCS_DIR/PROGRESS.md"

for f in "$FRONTEND_FILE" "$BACKEND_FILE"; do
  [ -f "$f" ] || { echo "Error: $f not found." >&2; exit 1; }
done

TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TMPDIR"' EXIT

# --- last-modified timestamp, git history first, mtime as fallback (uncommitted file) ---
last_modified() {
  local file="$1" ts
  ts=$(git -C "$PROJECT_DIR" log -1 --format=%ct -- "$file" 2>/dev/null)
  if [ -z "$ts" ]; then
    ts=$(stat -f %m "$file" 2>/dev/null || stat -c %Y "$file" 2>/dev/null)
  fi
  echo "${ts:-0}"
}

# --- pull the lines between a "## Header" line and the next "---" ---
extract_block() {
  awk -v header="$2" '
    $0 == header { found=1; next }
    found && /^---$/ { exit }
    found { print }
  ' "$1"
}

FRONTEND_TS="$(last_modified "$FRONTEND_FILE")"
BACKEND_TS="$(last_modified "$BACKEND_FILE")"
if [ "$BACKEND_TS" -gt "$FRONTEND_TS" ]; then
  GLOBAL_SRC="$BACKEND_FILE"
else
  GLOBAL_SRC="$FRONTEND_FILE"
fi

PHASES="$(extract_block "$GLOBAL_SRC" "## Phases du projet")"
PHASE_ACTUELLE="$(extract_block "$GLOBAL_SRC" "## Phase actuelle")"
PROGRESSION="$(extract_block "$GLOBAL_SRC" "## Progression globale")"
STATUT_FRONTEND="$(extract_block "$FRONTEND_FILE" "## Statut frontend — Pages")"
STATUT_BACKEND="$(extract_block "$BACKEND_FILE" "## Statut backend — Endpoints & migrations")"

# --- split each file's Sessions into one file per entry, named so a plain
#     sort orders them chronologically: <YYYYMMDD>-<layer>-<seq>.md ---
split_sessions() {
  local file="$1" layer="$2"
  awk -v layer="$layer" -v outdir="$TMPDIR" '
    /^## Sessions$/ { insession=1; next }
    insession && /^<!-- SENTINEL/ { next }
    insession && /^```/ { infence = !infence; if (current != "") print > current; next }
    insession && !infence && /^### Session/ {
      n++
      key = "00000000"
      if (match($0, /[0-9]{2}\/[0-9]{2}\/[0-9]{4}/)) {
        d = substr($0, RSTART, 2); mo = substr($0, RSTART+3, 2); y = substr($0, RSTART+6, 4)
        key = y mo d
      }
      line = $0
      sub(/^### Session/, "### [" layer "] Session", line)
      # Sub-key counts DOWN from a high value so that, within the same date,
      # the entry encountered first (LIFO: newest-on-top in the source file)
      # gets a HIGHER sub-key and so sorts first under the final `sort -r`.
      outfile = outdir "/" key "-" layer "-" sprintf("%03d", 999 - n) ".md"
      print line > outfile
      current = outfile
      next
    }
    insession && current != "" { print > current }
  ' "$file"
}

split_sessions "$FRONTEND_FILE" "Frontend"
split_sessions "$BACKEND_FILE" "Backend"

SESSIONS=""
if ls "$TMPDIR"/*.md >/dev/null 2>&1; then
  for f in $(ls "$TMPDIR"/*.md | sort -r); do
    SESSIONS="$SESSIONS$(cat "$f")

"
  done
fi

{
  echo "# PROGRESS — Vue fusionnée"
  echo "> ⚠️ Fichier généré automatiquement. Ne jamais l'éditer à la main — toute modification faite ici sera écrasée à la prochaine fusion."
  echo "> Reconstruit à partir de \`docs/frontend/PROGRESS.md\` et \`docs/backend/PROGRESS.md\` à chaque merge sur \`main\`, par \`.github/workflows/merge-progress.yml\` (ou à la main via \`.claude/scripts/merge-progress.sh\` sur un projet sans GitHub Actions). Voir \`docs/CLAUDE.md\` > \"Fusion des PROGRESS.md\"."
  echo "> Pour une tâche en cours, lire \`docs/frontend/PROGRESS.md\` ou \`docs/backend/PROGRESS.md\` selon la couche — ce fichier-ci ne reflète que le dernier état mergé sur \`main\`, pas la branche en cours."
  echo
  echo "---"
  echo
  echo "## Phases du projet"
  echo "$PHASES"
  echo
  echo "---"
  echo
  echo "## Phase actuelle"
  echo "$PHASE_ACTUELLE"
  echo
  echo "---"
  echo
  echo "## Progression globale"
  echo "$PROGRESSION"
  echo
  echo "---"
  echo
  echo "## Statut frontend — Pages"
  echo "$STATUT_FRONTEND"
  echo
  echo "---"
  echo
  echo "## Statut backend — Endpoints & migrations"
  echo "$STATUT_BACKEND"
  echo
  echo "---"
  echo
  echo "## Sessions"
  echo "> Fusion de docs/frontend/PROGRESS.md et docs/backend/PROGRESS.md, triée par date — la plus récente en premier."
  echo
  printf '%s' "$SESSIONS"
} > "$OUT_FILE"

echo "docs/PROGRESS.md régénéré depuis frontend/PROGRESS.md + backend/PROGRESS.md."
