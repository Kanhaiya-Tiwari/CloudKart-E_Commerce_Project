#!/usr/bin/env bash
set -euo pipefail

# Automated helper script for the daily-automated-commit workflow.
# Appends a daily entry to AUTOMATED_DAILY_COMMITS.md and commits if today's
# entry is not yet present. Exits cleanly with a message if no change needed.

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null || echo "$PWD")"
FILE="$REPO_ROOT/AUTOMATED_DAILY_COMMITS.md"

# Use UTC date for consistency across runners
TODAY="$(date -u +%Y-%m-%d)"

if [ -f "$FILE" ] && grep -q "$TODAY" "$FILE"; then
  echo "Skipped: no safe, meaningful improvement found today."
  exit 0
fi

if [ ! -f "$FILE" ]; then
  cat > "$FILE" <<'EOF'
# Automated daily commits

This file logs automated daily runs that provide small, safe repository upkeep.

EOF
fi

echo "- $TODAY: Automated run — add daily log entry." >> "$FILE"

# Configure committer identity (per requested git identity)
git config user.name "Kanhaiya-Tiwari"
git config user.email "kanhaiyatiwari506@gmail.com"

# Stage changes and commit if there are staged changes
git add "$FILE"

if git diff --cached --quiet; then
  echo "No staged changes to commit. Exiting.";
  exit 0
fi

BRANCH="$(git rev-parse --abbrev-ref HEAD || echo main)"
COMMIT_MSG="chore(ci): automated daily log $TODAY"

git commit -m "$COMMIT_MSG"

# Push using the token provided by Actions (persist-credentials must be true)
git push origin "$BRANCH"

echo "Committed and pushed: $COMMIT_MSG"
