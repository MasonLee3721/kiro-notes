#!/bin/bash
set -e

AGENTS_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_ROOT="$(cd "$AGENTS_DIR/.." && pwd)"
SKILLS_SRC="$AGENTS_DIR/skills"
KIRO_SKILLS_DEST="${HOME}/.kiro/steering/skills"
SNAPSHOT_DIR="${HOME}/.kiro/skills_snapshots"

MODE=${1:-"dry-run"}
SKILL_TARGET=${2:-""}
FORCE_FLAG=${3:-""}

# Validate SKILL_TARGET to prevent path traversal
if [ -n "$SKILL_TARGET" ]; then
  if [[ ! "$SKILL_TARGET" =~ ^[a-zA-Z0-9_-]+$ ]]; then
    echo "❌ Error: Invalid skill target '$SKILL_TARGET'. Alphanumeric, hyphen, and underscore only."
    exit 1
  fi
fi

get_checksum() {
  local dir=$1
  if [ -d "$dir" ]; then
    (cd "$dir" && find . -type f ! -name ".installed_checksum" -exec md5sum {} + | sort -k2 | md5sum | awk '{print $1}')
  else
    echo "NONE"
  fi
}

echo "=== Running Kiro Adapter (Mode: $MODE, Skill Target: ${SKILL_TARGET:-ALL}) ==="

case "$MODE" in
  dry-run)
    if [ ! -d "$SKILLS_SRC" ]; then
      echo "❌ Error: Source skills directory $SKILLS_SRC does not exist!"
      exit 1
    fi

    if [ -n "$SKILL_TARGET" ] && [ ! -d "$SKILLS_SRC/$SKILL_TARGET" ]; then
      echo "❌ Error: Target skill '$SKILL_TARGET' not found in $SKILLS_SRC!"
      exit 1
    fi

    echo "[Dry-Run] Destination: $KIRO_SKILLS_DEST"
    echo "[Dry-Run] Comparing SSOT vs Destination Checksums & Diff:"

    for skill_path in "$SKILLS_SRC"/*; do
      if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        if [ -n "$SKILL_TARGET" ] && [ "$SKILL_TARGET" != "$skill_name" ]; then
          continue
        fi

        src_hash=$(get_checksum "$skill_path")
        dest_hash=$(get_checksum "$KIRO_SKILLS_DEST/$skill_name")

        if [ "$dest_hash" = "NONE" ]; then
          status="[NEW] (Destination does not exist)"
        elif [ "$src_hash" = "$dest_hash" ]; then
          status="[UNCHANGED] (Hashes match)"
        else
          status="[MODIFIED] (Destination differs from SSOT!)"
        fi

        echo "  - Skill: $skill_name | Status: $status"
        echo "    SSOT Hash: $src_hash | Dest Hash: $dest_hash"
      fi
    done
    echo "[Dry-Run] Completed. No files altered."
    ;;

  apply)
    if [ ! -d "$SKILLS_SRC" ]; then
      echo "❌ Error: Source skills directory $SKILLS_SRC does not exist!"
      exit 1
    fi

    if [ -n "$SKILL_TARGET" ] && [ ! -d "$SKILLS_SRC/$SKILL_TARGET" ]; then
      echo "❌ Error: Target skill '$SKILL_TARGET' not found in $SKILLS_SRC!"
      exit 1
    fi

    echo "[Apply] Syncing skills from $SKILLS_SRC to $KIRO_SKILLS_DEST..."
    mkdir -p "$SNAPSHOT_DIR"
    mkdir -p "$KIRO_SKILLS_DEST"

    for skill_path in "$SKILLS_SRC"/*; do
      if [ -d "$skill_path" ]; then
        skill_name=$(basename "$skill_path")
        if [ -n "$SKILL_TARGET" ] && [ "$SKILL_TARGET" != "$skill_name" ]; then
          continue
        fi

        dest_dir="$KIRO_SKILLS_DEST/$skill_name"
        src_hash=$(get_checksum "$skill_path")
        dest_hash=$(get_checksum "$dest_dir")

        # Conflict check fail-closed
        if [ "$dest_hash" != "NONE" ] && [ "$src_hash" != "$dest_hash" ] && [ "$FORCE_FLAG" != "--force" ]; then
          echo "❌ Conflict Error: Skill $skill_name at $dest_dir differs from SSOT. Pass '--force' to overwrite."
          exit 1
        fi

        snapshot_time=$(date +%Y%m%d_%H%M%S_%N)
        if [ -d "$dest_dir" ]; then
          echo "[Snapshot] Backing up pre-existing $skill_name -> $SNAPSHOT_DIR/${skill_name}_${snapshot_time}"
          cp -r "$dest_dir" "$SNAPSHOT_DIR/${skill_name}_${snapshot_time}"
        else
          echo "[Snapshot] Initial install for $skill_name. Recording empty marker."
          mkdir -p "$SNAPSHOT_DIR/${skill_name}_${snapshot_time}_INITIAL"
        fi

        rm -rf "$dest_dir"
        mkdir -p "$dest_dir"
        cp -r "$skill_path"/* "$dest_dir/"
        echo "$src_hash" > "$dest_dir/.installed_checksum"
        echo "✅ [Apply] Synced $skill_name (Hash: $src_hash) -> $dest_dir"
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
      echo "❌ Error: No backup snapshot found for skill '$SKILL_TARGET' in $SNAPSHOT_DIR"
      exit 1
    fi

    echo "[Rollback] Restoring $SKILL_TARGET from snapshot $latest_snapshot..."
    dest_dir="$KIRO_SKILLS_DEST/$SKILL_TARGET"
    rm -rf "$dest_dir"

    if [[ "$latest_snapshot" == *"_INITIAL" ]]; then
      echo "✅ [Rollback] Initial install snapshot reverted. Removed $dest_dir."
    else
      cp -r "$latest_snapshot" "$dest_dir"
      echo "✅ [Rollback] Restored $SKILL_TARGET successfully."
    fi
    ;;

  *)
    echo "Usage: $0 [dry-run|apply|rollback] [skill_name] [--force]"
    exit 1
    ;;
esac
