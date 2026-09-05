#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_FAIL_DIR="$SCRIPT_DIR/skills/test_fail_temp"

cleanup() {
  rm -rf "$TEST_FAIL_DIR" 2>/dev/null || true
}
trap cleanup EXIT INT TERM

echo "=== Running Agent Skills 3.0 Negative Tests ==="

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

echo "=== All Negative Tests Passed Successfully ==="
