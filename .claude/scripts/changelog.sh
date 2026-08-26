#!/usr/bin/env bash
# Tells a Claude agent working on an older install of this template what
# changed upstream and how to migrate. Read-only: prints information,
# never edits files. Ships inside .claude/scripts/, so it travels with
# .claude/ into any project that ran install.sh.
#
# Usage: .claude/scripts/changelog.sh

set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_DIR="${CLAUDE_PROJECT_DIR:-$(cd "$SCRIPT_DIR/../.." && pwd)}/docs"
README_URL="https://raw.githubusercontent.com/ud20-dev/claude-dev-workflow/main/README.md"
CHANGELOG_URL="https://raw.githubusercontent.com/ud20-dev/claude-dev-workflow/main/CHANGELOG.md"

LOCAL_VERSION=$(grep -m1 -oE '[0-9]+\.[0-9]+\.[0-9]+' "$DOCS_DIR/CLAUDE.md" 2>/dev/null)
REMOTE_VERSION=$(curl -sf --max-time 3 "$README_URL" 2>/dev/null | grep -m1 -oE '[0-9]+\.[0-9]+\.[0-9]+')

echo "Installed template version : ${LOCAL_VERSION:-unknown}"
echo "Latest published version   : ${REMOTE_VERSION:-unknown (offline or fetch failed)}"
echo

if [ -z "$LOCAL_VERSION" ]; then
  echo "Could not read the installed version from docs/CLAUDE.md. Nothing to compare."
  exit 0
fi

if [ -n "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" = "$REMOTE_VERSION" ]; then
  echo "Already up to date. Nothing to migrate."
  exit 0
fi

echo "----------------------------------------------------------------------"
echo "WHAT CHANGED (upstream CHANGELOG.md)"
echo "----------------------------------------------------------------------"
REMOTE_CHANGELOG=$(curl -sf --max-time 3 "$CHANGELOG_URL" 2>/dev/null)
if [ -n "$REMOTE_CHANGELOG" ]; then
  echo "$REMOTE_CHANGELOG"
else
  echo "(offline: could not fetch the upstream CHANGELOG.md, showing known migration steps only)"
fi
echo

LOCAL_MAJOR="${LOCAL_VERSION%%.*}"
REMOTE_MAJOR="${REMOTE_VERSION%%.*}"

if [ -z "$REMOTE_MAJOR" ]; then
  echo "Could not determine whether migration is needed (no published version fetched). Try again with a network connection."
  exit 0
fi

if [ "$LOCAL_MAJOR" = "$REMOTE_MAJOR" ]; then
  echo "No structural migration needed. Same major version, see the changelog above for what's new."
  exit 0
fi

if [ "$LOCAL_MAJOR" -ge 2 ] 2>/dev/null; then
  echo "No known migration steps for this jump yet. Check the changelog above for what changed."
  exit 0
fi

if [ "$REMOTE_MAJOR" != "2" ]; then
  echo "No specific migration steps written for jumping straight from $LOCAL_VERSION to $REMOTE_VERSION."
  echo "The only known structural migration covers 1.x -> 2.x (below) — it may not cover everything"
  echo "for a bigger jump. Check the changelog above, and use docs/CLAUDE.md's own update procedure"
  echo "(step 3: compare docs/CLAUDE.md, .claude/, .github/workflows/ against the latest clone) to"
  echo "catch anything a version-specific guide would miss."
  echo
fi

EM_DASH=$(printf '\xe2\x80\x94')

cat <<EOF
----------------------------------------------------------------------
MIGRATION REQUIRED: 1.x to 2.x. Two breaking changes.
----------------------------------------------------------------------

PART A — FIFO to LIFO reordering
----------------------------------------------------------------------
These files switched from FIFO (append at the bottom) to LIFO (newest
entry on top), each with a "<!-- SENTINEL -->" marker showing exactly
where the next entry goes:

  docs/DECISIONS.md
  docs/CHANGELOG.md
  docs/frontend/ERRORS.md
  docs/backend/ERRORS.md
  docs/frontend/FEEDBACK.md
  docs/backend/FEEDBACK.md

Session loading is also automatic now via a SessionStart hook
(.claude/hooks/session-start.sh) instead of the old manual
"Lis docs/CLAUDE.md..." prompt. Nothing to do there but stop typing it.

PART B — docs/PROGRESS.md split by layer
----------------------------------------------------------------------
The single docs/PROGRESS.md (FIFO) is replaced by docs/frontend/PROGRESS.md
and docs/backend/PROGRESS.md (LIFO, independent per-layer session
numbering), so a frontend dev and a backend dev on separate branches
stop colliding on the same file. docs/PROGRESS.md itself becomes a
generated file, rebuilt from those two — see docs/CLAUDE.md > "Fusion
des PROGRESS.md" and .claude/scripts/merge-progress.sh. On GitHub with
Actions enabled, .github/workflows/merge-progress.yml does this
automatically on every push to main.

Migration steps for an agent to follow by hand. Never on a dirty
working tree: run \`git status\` first and stop if uncommitted changes
exist. This touches real project history, not disposable files.

1. For each file in PART A that has real entries: read every "### "
   block under its main section, reverse their order (newest entry
   first), and add "<!-- SENTINEL: ... -->" right after the section
   heading, above the first entry. Never edit the content of an entry,
   only its position in the file.
2. In docs/frontend/ERRORS.md, docs/backend/ERRORS.md,
   docs/frontend/FEEDBACK.md, docs/backend/FEEDBACK.md specifically:
   entries with "Date : ${EM_DASH}" are generic seed knowledge, not
   project history. Leave their relative order alone and keep them as
   a block at the bottom. Only reverse-order the entries that carry a
   real date, and place that reversed block above the dateless ones.
3. Add "La plus recente en haut" (or equivalent) to each file's header
   comment block if it isn't already there.
4. For docs/PROGRESS.md (PART B): don't try to auto-split its past
   sessions by layer — a session can cover both, and guessing loses
   information. Instead: rename it to docs/PROGRESS-archive.md (kept,
   read-only, historical reference — link to it once from
   docs/CHANGELOG.md), then copy docs/frontend/PROGRESS.md and
   docs/backend/PROGRESS.md (empty, ready for new sessions) from the
   temporary clone made in docs/CLAUDE.md's update procedure (step 2) —
   run this step after that clone exists, not before. Only after that,
   docs/PROGRESS.md is regenerated by .claude/scripts/merge-progress.sh
   and becomes a generated file.
5. Copy any new files the template added outside of docs/ too, not
   just inside it: .claude/hooks/, .claude/scripts/, .claude/SKILLS/,
   .claude/settings.json keys, and .github/workflows/ — same
   additive-only rule as docs/CLAUDE.md (see its "Mise à jour du
   template" section, step 3).
6. Show the user a \`git diff\` before considering this done. This
   reorders and moves real project history, they should see exactly
   what moved.
7. Once confirmed, update the version line at the top of
   docs/CLAUDE.md to match the new installed version.
EOF
