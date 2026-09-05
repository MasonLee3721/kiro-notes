#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_FAIL_DIR="$SCRIPT_DIR/skills/test_fail_temp"

cleanup() {
  rm -rf "$TEST_FAIL_DIR" 2>/dev/null || true
  rm -rf "$SCRIPT_DIR/skills/test_conflict" 2>/dev/null || true
  rm -rf "$SCRIPT_DIR/skills/test_initial" 2>/dev/null || true
  rm -rf "$SCRIPT_DIR/skills/test_ssot_del" 2>/dev/null || true
  
  rm -rf "${HOME}/.gemini/config/skills/test_conflict" 2>/dev/null || true
  rm -rf "${HOME}/.gemini/config/skills/test_initial" 2>/dev/null || true
  rm -rf "${HOME}/.gemini/config/skills/test_initial_ssot" 2>/dev/null || true
  rm -rf "${HOME}/.gemini/config/skills/test_ssot_del" 2>/dev/null || true
  rm -rf "${HOME}/.gemini/config/skills_snapshots/test_"* 2>/dev/null || true

  rm -rf "${HOME}/.kiro/steering/skills/test_conflict" 2>/dev/null || true
  rm -rf "${HOME}/.kiro/steering/skills/test_initial" 2>/dev/null || true
  rm -rf "${HOME}/.kiro/steering/skills/test_initial_ssot" 2>/dev/null || true
  rm -rf "${HOME}/.kiro/steering/skills/test_ssot_del" 2>/dev/null || true
  rm -rf "${HOME}/.kiro/skills_snapshots/test_"* 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "=== Running Agent Skills 3.0 Comprehensive Negative & Boundary Tests ==="

# 1. Test validate.sh on bad skill input
echo "[Negative Test 1] Hardcoded Path & Secret Scanner Failure Check..."
mkdir -p "$TEST_FAIL_DIR"
cat << 'EOF' > "$TEST_FAIL_DIR/SKILL.md"
---
name: test-fail
version: 1.0.0
owner: test
description: test fail
---
Token: ghp_123456789012345678901234567890123456
Path: /home/agent/test
Proc: /proc/1/environ
EOF

if bash "$SCRIPT_DIR/validate.sh" 2>/dev/null; then
  echo "❌ Error: validate.sh failed to catch bad input!"
  exit 1
else
  echo "✅ Pass: validate.sh successfully caught bad input and exited with non-zero code."
fi
cleanup

# 2. Test adapters non-existent target failure check
echo "[Negative Test 2] Adapters Non-existent Target Failure Check..."
if bash "$SCRIPT_DIR/adapters/agy.sh" dry-run does-not-exist 2>/dev/null; then
  echo "❌ Error: agy.sh dry-run returned 0 for non-existent target!"
  exit 1
else
  echo "✅ Pass: agy.sh dry-run returned non-zero for non-existent target."
fi

if bash "$SCRIPT_DIR/adapters/kiro.sh" dry-run does-not-exist 2>/dev/null; then
  echo "❌ Error: kiro.sh dry-run returned 0 for non-existent target!"
  exit 1
else
  echo "✅ Pass: kiro.sh dry-run returned non-zero for non-existent target."
fi

# 3. Test Conflict Fail-Closed without --force & Force Apply & Hash UNCHANGED
echo "[Negative Test 3] Conflict Fail-Closed & Force Apply & UNCHANGED Check..."
mkdir -p "$SCRIPT_DIR/skills/test_conflict"
cat << 'EOF' > "$SCRIPT_DIR/skills/test_conflict/SKILL.md"
---
name: test_conflict
version: 1.0.0
owner: test
description: test conflict
---
SSOT_CONTENT
EOF

for adapter in "$SCRIPT_DIR/adapters/agy.sh" "$SCRIPT_DIR/adapters/kiro.sh"; do
  adapter_name=$(basename "$adapter")
  echo "  Testing $adapter_name conflict fail-closed..."
  
  if [ "$adapter_name" = "agy.sh" ]; then
    dest_path="${HOME}/.gemini/config/skills/test_conflict"
  else
    dest_path="${HOME}/.kiro/steering/skills/test_conflict"
  fi

  mkdir -p "$dest_path"
  echo "CONFLICT_MODIFIED_CONTENT" > "$dest_path/SKILL.md"

  # Must fail closed without --force
  if bash "$adapter" apply test_conflict 2>/dev/null; then
    echo "❌ Error: $adapter_name apply did not fail on conflict without --force!"
    exit 1
  else
    echo "✅ Pass: $adapter_name apply failed closed on [MODIFIED] conflict without --force."
  fi

  # Apply with --force must succeed and overwrite content to match SSOT
  if bash "$adapter" apply test_conflict --force >/dev/null; then
    if diff -q "$SCRIPT_DIR/skills/test_conflict/SKILL.md" "$dest_path/SKILL.md" >/dev/null; then
      echo "✅ Pass: $adapter_name apply --force successfully overwritten content matching SSOT."
    else
      echo "❌ Error: $adapter_name apply --force content mismatch!"
      exit 1
    fi
  else
    echo "❌ Error: $adapter_name apply failed with --force!"
    exit 1
  fi

  # Hash match dry-run must report UNCHANGED
  if bash "$adapter" dry-run test_conflict | grep -q "UNCHANGED"; then
    echo "✅ Pass: $adapter_name dry-run reported [UNCHANGED] after forced sync."
  else
    echo "❌ Error: $adapter_name dry-run did not report UNCHANGED!"
    exit 1
  fi
done

# 4. Test Initial Install Rollback
echo "[Negative Test 4] Initial Install Rollback Check..."
mkdir -p "$SCRIPT_DIR/skills/test_initial"
cat << 'EOF' > "$SCRIPT_DIR/skills/test_initial/SKILL.md"
---
name: test_initial
version: 1.0.0
owner: test
description: test initial
---
INITIAL_CONTENT
EOF

for adapter in "$SCRIPT_DIR/adapters/agy.sh" "$SCRIPT_DIR/adapters/kiro.sh"; do
  adapter_name=$(basename "$adapter")
  if [ "$adapter_name" = "agy.sh" ]; then
    dest_path="${HOME}/.gemini/config/skills/test_initial"
  else
    dest_path="${HOME}/.kiro/steering/skills/test_initial"
  fi

  rm -rf "$dest_path"
  bash "$adapter" apply test_initial >/dev/null
  if [ ! -d "$dest_path" ]; then
    echo "❌ Error: $adapter_name failed initial install!"
    exit 1
  fi

  bash "$adapter" rollback test_initial >/dev/null
  if [ -d "$dest_path" ]; then
    echo "❌ Error: $adapter_name initial rollback did not remove destination folder!"
    exit 1
  else
    echo "✅ Pass: $adapter_name initial install rollback successfully removed initial destination."
  fi
done

# 5. Test Rollback after SSOT Skill Deletion
echo "[Negative Test 5] Rollback After SSOT Skill Deletion Check..."
for adapter in "$SCRIPT_DIR/adapters/agy.sh" "$SCRIPT_DIR/adapters/kiro.sh"; do
  adapter_name=$(basename "$adapter")
  if [ "$adapter_name" = "agy.sh" ]; then
    dest_path="${HOME}/.gemini/config/skills/test_ssot_del"
  else
    dest_path="${HOME}/.kiro/steering/skills/test_ssot_del"
  fi

  # Create initial SSOT skill
  mkdir -p "$SCRIPT_DIR/skills/test_ssot_del"
  cat << 'EOF' > "$SCRIPT_DIR/skills/test_ssot_del/SKILL.md"
---
name: test_ssot_del
version: 1.0.0
owner: test
description: test ssot del
---
ORIGINAL_SSOT_VERSION
EOF

  # Step 1: Initial apply (creates _INITIAL snapshot)
  bash "$adapter" apply test_ssot_del >/dev/null

  # Step 2: Update SSOT content and re-apply --force (creates non-INITIAL snapshot of ORIGINAL_SSOT_VERSION)
  cat << 'EOF' > "$SCRIPT_DIR/skills/test_ssot_del/SKILL.md"
---
name: test_ssot_del
version: 2.0.0
owner: test
description: test ssot del v2
---
UPDATED_SSOT_VERSION
EOF
  bash "$adapter" apply test_ssot_del --force >/dev/null

  # Step 3: Simulate local change in dest
  echo "CORRUPTED_DEST_CONTENT" > "$dest_path/SKILL.md"

  # Step 4: Remove SSOT source directory entirely
  rm -rf "$SCRIPT_DIR/skills/test_ssot_del"

  # Step 5: Rollback must succeed using stored snapshot even when SSOT is deleted
  if bash "$adapter" rollback test_ssot_del >/dev/null; then
    restored_content=$(cat "$dest_path/SKILL.md")
    if echo "$restored_content" | grep -q "ORIGINAL_SSOT_VERSION"; then
      echo "✅ Pass: $adapter_name rollback succeeded after SSOT deletion and restored snapshot."
    else
      echo "❌ Error: $adapter_name rollback content after SSOT deletion incorrect!"
      exit 1
    fi
  else
    echo "❌ Error: $adapter_name rollback failed when SSOT source directory was deleted!"
    exit 1
  fi
done

cleanup

echo "=== All 5 Comprehensive Negative & Boundary Tests Passed Successfully ==="

