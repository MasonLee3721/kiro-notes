#!/bin/bash
# AGY Adapter for Agent Skills 3.0
# Mode: dry-run by default

DRY_RUN=${1:-"dry-run"}
echo "=== Running AGY Adapter (Mode: $DRY_RUN) ==="

SKILLS_SRC="/home/agent/notes/.agents/skills"
AGY_SKILLS_DEST="${HOME}/.gemini/config/skills"

if [ "$DRY_RUN" = "dry-run" ]; then
  echo "[Dry-Run] Checking mapping diff from $SKILLS_SRC to $AGY_SKILLS_DEST..."
  find "$SKILLS_SRC" -type f
  echo "[Dry-Run] Completed. No files modified."
elif [ "$DRY_RUN" = "apply" ]; then
  mkdir -p "$AGY_SKILLS_DEST"
  cp -r "$SKILLS_SRC"/* "$AGY_SKILLS_DEST/"
  echo "[Apply] Skills mapped to $AGY_SKILLS_DEST successfully."
fi
