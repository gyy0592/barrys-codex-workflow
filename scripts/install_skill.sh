#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_home=${CODEX_HOME:-"$HOME/.codex"}
skill_dir="$codex_home/skills/tmux-codex-supervisor"

mkdir -p "$skill_dir/templates" "$skill_dir/scripts"

"$repo_dir/scripts/install_agents_rules.sh"

sed "s#__WORKFLOW_ROOT__#$repo_dir#g" "$repo_dir/SKILL.md" > "$skill_dir/SKILL.md"
cp "$repo_dir/templates/"*.md "$skill_dir/templates/"
cp "$repo_dir/scripts/"*.sh "$skill_dir/scripts/"
chmod +x "$skill_dir/scripts/"*.sh

printf 'SKILL_INSTALLED %s\n' "$skill_dir"
