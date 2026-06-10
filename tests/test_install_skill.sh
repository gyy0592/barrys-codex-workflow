#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

CODEX_HOME="$tmp_dir/codex" "$repo_dir/scripts/install_skill.sh" >/dev/null

skill_dir="$tmp_dir/codex/skills/tmux-codex-supervisor"
test -f "$skill_dir/SKILL.md"
test -f "$skill_dir/templates/goal.md"
test -f "$skill_dir/templates/constraint.md"
test -f "$skill_dir/templates/short_goal_message.md"
test -x "$skill_dir/scripts/init_control_files.sh"
test -x "$skill_dir/scripts/send_tmux_message.sh"

grep -F '/home/yguo173/Programs/codex_workflow_tmux/scripts/init_control_files.sh' "$skill_dir/SKILL.md" >/dev/null
grep -F '/home/yguo173/Programs/codex_workflow_tmux/templates/short_goal_message.md' "$skill_dir/SKILL.md" >/dev/null

printf 'test_install_skill PASS\n'

