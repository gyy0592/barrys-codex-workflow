#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_home=${CODEX_HOME:-"$HOME/.codex"}
skill_dir="$codex_home/skills/tmux-codex-supervisor"
error_skill_dir="$codex_home/skills/workflow-error-transition"

"$repo_dir/scripts/uninstall_agents_rules.sh"

if [ -d "$skill_dir" ]; then
  rm -rf "$skill_dir"
  test ! -e "$skill_dir"
  printf 'SKILL_REMOVED %s\n' "$skill_dir"
else
  printf 'SKILL_NOT_FOUND %s\n' "$skill_dir"
fi

if [ -d "$error_skill_dir" ]; then
  rm -rf "$error_skill_dir"
  test ! -e "$error_skill_dir"
  printf 'SKILL_REMOVED %s\n' "$error_skill_dir"
else
  printf 'SKILL_NOT_FOUND %s\n' "$error_skill_dir"
fi
