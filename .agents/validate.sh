#!/bin/bash
set -e

echo "=== Running Agent Skills 3.0 Security & Path Scanner ==="

ERRORS=0

# 1. Check for hardcoded paths like /home/agent or /home/node
echo "[Check 1] Hardcoded Home Paths..."
if grep -r -n -E "(/home/agent|/home/node)" /home/agent/notes/.agents/skills/ 2>/dev/null; then
  echo "❌ Error: Hardcoded home path detected!"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Pass: No hardcoded home paths found."
fi

# 2. Check for proc environ hacks
echo "[Check 2] Dangerous /proc Access..."
if grep -r -n "/proc/1/environ" /home/agent/notes/.agents/skills/ 2>/dev/null; then
  echo "❌ Error: Dangerous /proc/1/environ access detected!"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Pass: No dangerous /proc access found."
fi

# 3. Check for exposed secrets/tokens
echo "[Check 3] Exposed Tokens & Keys..."
if grep -r -n -E "(ghp_[A-Za-z0-9]{36}|github_pat_[A-Za-z0-9_]{82}|DISCORD_TOKEN=[^\$])" /home/agent/notes/.agents/skills/ 2>/dev/null; then
  echo "❌ Error: Hardcoded token or API key detected!"
  ERRORS=$((ERRORS + 1))
else
  echo "✅ Pass: No hardcoded secrets detected."
fi

# 4. Check SKILL.md YAML Frontmatter
echo "[Check 4] SKILL.md Frontmatter Presence..."
for skill_file in $(find /home/agent/notes/.agents/skills -name "SKILL.md"); do
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
