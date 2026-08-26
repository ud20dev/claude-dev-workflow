#!/usr/bin/env bash
# SessionStart hook: injects docs/CLAUDE.md + the latest sessions of both
# docs/frontend/PROGRESS.md and docs/backend/PROGRESS.md into context
# automatically, and checks the template version in silence.
set -uo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-.}"
DOCS="$PROJECT_DIR/docs"
TEMPLATE_README_URL="https://raw.githubusercontent.com/ud20-dev/claude-dev-workflow/main/README.md"
SESSIONS_KEPT=3

# 1. Version check - silent unless there's an actual update. No network / no match → say nothing.
UPDATE_AVAILABLE=0
if [ -f "$DOCS/CLAUDE.md" ]; then
  LOCAL_VERSION=$(grep -m1 -oE '[0-9]+\.[0-9]+\.[0-9]+' "$DOCS/CLAUDE.md" 2>/dev/null)
  REMOTE_VERSION=$(curl -sf --max-time 2 "$TEMPLATE_README_URL" 2>/dev/null | grep -m1 -oE '[0-9]+\.[0-9]+\.[0-9]+')

  if [ -n "$LOCAL_VERSION" ] && [ -n "$REMOTE_VERSION" ] && [ "$LOCAL_VERSION" != "$REMOTE_VERSION" ]; then
    UPDATE_AVAILABLE=1
    echo "TEMPLATE UPDATE AVAILABLE: installed $LOCAL_VERSION, latest $REMOTE_VERSION. Mention it to the user once; run .claude/scripts/changelog.sh for what changed and how to migrate, only apply it if they agree."
    echo "---"
  fi
fi

# 2. Orchestrator file - fixed reference content, loaded every time. The
#    "Mise à jour du template" section (~24% of the file's words) is only
#    ever actionable on the rare session where an update is actually
#    available — it's dropped from the injected copy otherwise and read on
#    demand instead (Claude can still open docs/CLAUDE.md directly). Same
#    content either way, never rewritten, just not force-fed every session.
if [ -f "$DOCS/CLAUDE.md" ]; then
  if [ "$UPDATE_AVAILABLE" = "1" ]; then
    cat "$DOCS/CLAUDE.md"
  else
    awk '
      /^## Mise à jour du template$/ { skip=1; next }
      skip && /^## / { skip=0 }
      !skip { print }
    ' "$DOCS/CLAUDE.md"
  fi
  echo "---"
fi

# 3. frontend/PROGRESS.md + backend/PROGRESS.md - everything up to "## Sessions"
#    in full (current-state tables), then only the latest N session entries
#    (delimiter: "### Session"). The layer of the upcoming task isn't known
#    yet at session start, so both are loaded; docs/PROGRESS.md (root) is
#    never loaded here — it's a generated, merged-on-main snapshot, not the
#    working memory. See docs/CLAUDE.md > "Fusion des PROGRESS.md".
for LAYER_PROGRESS in "$DOCS/frontend/PROGRESS.md" "$DOCS/backend/PROGRESS.md"; do
  if [ -f "$LAYER_PROGRESS" ]; then
    awk -v n="$SESSIONS_KEPT" '/^### Session/{c++} c>n{next} 1' "$LAYER_PROGRESS"
    echo "---"
  fi
done
