#!/usr/bin/env bash
set -euo pipefail

SKILL_DIRS=(
  "$HOME/.agents/skills"
  "$HOME/.claude/skills"
  "$HOME/.config/opencode/skills"
)

COMMAND_DIR="$HOME/.config/opencode/command"
mkdir -p "$COMMAND_DIR"

DISCOVERED=""
COUNT=0

for skill_dir in "${SKILL_DIRS[@]}"; do
  [ -d "$skill_dir" ] || continue

  for skill_md in "$skill_dir"/*/SKILL.md; do
    [ -f "$skill_md" ] || continue

    dir_name=$(basename "$(dirname "$skill_md")")

    frontmatter=$(awk '/^---$/{if(++c==2) exit; next} c==1' "$skill_md")

    name=$(echo "$frontmatter" | grep '^name:' | head -1 | sed -e 's/^name:[[:space:]]*//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')
    [ -z "$name" ] && name="$dir_name"

    description=$(echo "$frontmatter" | grep '^description:' | head -1 | sed -e 's/^description:[[:space:]]*//' -e 's/^"//' -e 's/"$//' -e 's/^[[:space:]]*//' -e 's/[[:space:]]*$//')

    if echo "$DISCOVERED" | grep -qxF "$name"; then
      continue
    fi

    DISCOVERED="${DISCOVERED}${name}"$'\n'
    COUNT=$((COUNT + 1))

    cat > "$COMMAND_DIR/${name}.md" << MDEOF
---
description: ${description:-$name skill}
---

Activate the $name skill. Read its SKILL.md and follow the instructions exactly.
MDEOF

    echo "  ✓ $name"
  done
done

for cmd_file in "$COMMAND_DIR"/*.md; do
  [ -f "$cmd_file" ] || continue
  cmd_name=$(basename "$cmd_file" .md)
  if ! echo "$DISCOVERED" | grep -qxF "$cmd_name"; then
    echo "  ⚠ orphan: $cmd_name.md (no matching skill found)"
  fi
done

echo ""
echo "Synced $COUNT skill(s) to commands."
