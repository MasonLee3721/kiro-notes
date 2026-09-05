#!/bin/bash
set -e

# Dynamically derive repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
SKILLS_DIR="$REPO_ROOT/.agents/skills"

echo "=== Running Agent Skills 3.0 Security & Path Scanner ==="
echo "Repo Root: $REPO_ROOT"
echo "Skills Dir: $SKILLS_DIR"

if [ ! -d "$SKILLS_DIR" ]; then
  echo "❌ Error: Skills directory $SKILLS_DIR does not exist!"
  exit 1
fi

SKILL_FILES=$(find "$SKILLS_DIR" -type f 2>/dev/null || true)
if [ -z "$SKILL_FILES" ]; then
  echo "❌ Error: No skill files found in $SKILLS_DIR to scan!"
  exit 1
fi

ERRORS=0

# 1. Check for hardcoded absolute paths like /home/agent or /home/node
echo "[Check 1] Hardcoded Home Paths..."
if grep -r -n -E "(/home/agent|/home/node)" "$SKILLS_DIR" 2>/dev/null; then
  echo "❌ Error: Hardcoded absolute home path detected!"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Pass: No hardcoded home paths found."
fi

# 2. Check for proc environ hacks
echo "[Check 2] Dangerous /proc Access..."
if grep -r -n "/proc/1/environ" "$SKILLS_DIR" 2>/dev/null; then
  echo "❌ Error: Dangerous /proc/1/environ access detected!"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Pass: No dangerous /proc access found."
fi

# 3. Check for exposed secrets/tokens
echo "[Check 3] Exposed Tokens & Keys..."
if grep -r -n -E "(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{82}|DISCORD_TOKEN=[^\$])" "$SKILLS_DIR" 2>/dev/null; then
  echo "❌ Error: Hardcoded token or API key detected!"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Pass: No hardcoded secrets detected."
fi

# 4. Check SKILL.md YAML Frontmatter Presence & Format
echo "[Check 4] SKILL.md Frontmatter Presence..."
for skill_file in $(find "$SKILLS_DIR" -name "SKILL.md"); do
  if ! head -n 1 "$skill_file" | grep -q "^---"; then
    echo "❌ Error: $skill_file missing YAML frontmatter opening '---'"
    ERRORS=$((ERRORS + 1))
  fi
done
echo "✅ Pass: SKILL.md frontmatter check complete."

if [ $ERRORS -gt 0 ]; then
  echo "FAILED: $ERRORS security/path validation error(s) found."
  exit 1
fi

echo "=== All Validation Checks Passed Successfully ==="
