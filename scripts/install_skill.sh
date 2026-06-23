#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_home=${CODEX_HOME:-"$HOME/.codex"}
skill_dir="$codex_home/skills/tmux-codex-supervisor"
error_skill_dir="$codex_home/skills/workflow-error-transition"

mkdir -p "$skill_dir/templates" "$skill_dir/scripts"
mkdir -p "$error_skill_dir"

"$repo_dir/scripts/install_agents_rules.sh"

rm -f \
  "$skill_dir/scripts/capture_tmux_screen.sh" \
  "$skill_dir/scripts/send_tmux_message.sh" \
  "$skill_dir/scripts/verify_delivery.sh"

sed "s#__WORKFLOW_ROOT__#$repo_dir#g" "$repo_dir/SKILL.md" > "$skill_dir/SKILL.md"
cp "$repo_dir/templates/"*.md "$skill_dir/templates/"
cp "$repo_dir/scripts/"*.sh "$skill_dir/scripts/"
chmod +x "$skill_dir/scripts/"*.sh
cp "$repo_dir/skills/workflow-error-transition/SKILL.md" "$error_skill_dir/SKILL.md"

printf 'SKILL_INSTALLED %s\n' "$skill_dir"
printf 'SKILL_INSTALLED %s\n' "$error_skill_dir"
