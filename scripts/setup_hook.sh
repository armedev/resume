#!/bin/bash

REPO_ROOT="$(git rev-parse --show-toplevel 2>/dev/null)"

if [ -z "$REPO_ROOT" ]; then
  echo "❌ Not inside a git repository. Please run this from your resume repo."
  exit 1
fi

HOOK_SOURCE="$REPO_ROOT/hooks/post-commit"
HOOK_DEST="$REPO_ROOT/.git/hooks/post-commit"

if [ ! -f "$HOOK_SOURCE" ]; then
  echo "❌ Hook file not found at hooks/post-commit"
  exit 1
fi

cp "$HOOK_SOURCE" "$HOOK_DEST"
chmod +x "$HOOK_DEST"

echo "✅ Post-commit hook installed!"
echo ""
echo "From now on, every time you commit a change to resume.json:"
echo "  - Docker will spin up RxResume"
echo "  - A PDF will be generated at output/resume.pdf"
echo "  - The PDF will be auto-committed"
echo ""
echo "⚠️  Make sure Docker Desktop is running when you commit."
