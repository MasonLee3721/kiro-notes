#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
SKILLS_SRC="$REPO_ROOT/.agents/skills"
KIRO_SKILLS_DEST="${HOME}/.kiro/skills"
SNAPSHOT_DIR="${HOME}/.kiro/skills_snapshots"

MODE=${1:-"dry-run"}
SKILL_TARGET=${2:-""}

echo "=== Running Kiro Adapter (Mode: $MODE, Skill Target: ${SKILL_TARGET:-ALL}) ==="

if [ ! -d "$SKILLS_SRC" ]; then
  echo "❌ Error: Source skills directory $SKILLS_SRC does not exist!"
  exit 1
fi

case "$MODE" in
  dry-run)
    echo "[Dry-Run] Calculating checksums and diff..."
    for skill_path in "$SKILLS_SRC"/*; do
      if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        if [ -n "$SKILL_TARGET" ] && [ "$SKILL_TARGET" != "$skill_name" ]; then
          continue
        fi
        echo "Skill: $skill_name"
        find "$skill_path" -type f -exec md5sum {} +
      fi
    done
    echo "[Dry-Run] Completed. No files altered."
    ;;

  apply)
    echo "[Apply] Creating backup snapshot before applying..."
    mkdir -p "$SNAPSHOT_DIR"
    mkdir -p "$KIRO_SKILLS_DEST"

    for skill_path in "$SKILLS_SRC"/*; do
      if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        if [ -n "$SKILL_TARGET" ] && [ "$SKILL_TARGET" != "$skill_name" ]; then
          continue
        fi

        # Take granular snapshot of single skill if exists
        if [ -d "$KIRO_SKILLS_DEST/$skill_name" ]; then
          snapshot_time=$(date +%Y%m%d_%H%M%S)
          echo "[Snapshot] Backing up $skill_name to $SNAPSHOT_DIR/${skill_name}_${snapshot_time}"
          cp -r "$KIRO_SKILLS_DEST/$skill_name" "$SNAPSHOT_DIR/${skill_name}_${snapshot_time}"
        fi

        # Sync single skill
        mkdir -p "$KIRO_SKILLS_DEST/$skill_name"
        cp -r "$skill_path"/* "$KIRO_SKILLS_DEST/$skill_name/"
        echo "✅ [Apply] Synced $skill_name -> $KIRO_SKILLS_DEST/$skill_name"
      fi
    done
    ;;

  rollback)
    if [ -z "$SKILL_TARGET" ]; then
      echo "❌ Error: Rollback requires specifying a skill target (e.g. ./kiro.sh rollback catalyst-analysis)"
      exit 1
    fi

    latest_snapshot=$(ls -td "$SNAPSHOT_DIR/${SKILL_TARGET}_"* 2>/dev/null | head -n 1 || true)
    if [ -z "$latest_snapshot" ]; then
      echo "❌ Error: No backup snapshot found for skill $SKILL_TARGET in $SNAPSHOT_DIR"
      exit 1
    fi

    echo "[Rollback] Restoring $SKILL_TARGET from snapshot $latest_snapshot..."
    rm -rf "$KIRO_SKILLS_DEST/$SKILL_TARGET"
    cp -r "$latest_snapshot" "$KIRO_SKILLS_DEST/$SKILL_TARGET"
    echo "✅ [Rollback] Restored $SKILL_TARGET successfully."
    ;;

  *)
    echo "Usage: $0 [dry-run|apply|rollback] [skill_name]"
    exit 1
    ;;
esac
