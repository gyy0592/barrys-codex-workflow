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
test -f "$skill_dir/templates/prompt_for_run_prep.md"
test -f "$skill_dir/templates/prompt_for_supervisor.md"
test -f "$skill_dir/templates/run_goal.md"
test -f "$skill_dir/templates/specs.md"
test -f "$skill_dir/templates/spec_status.md"
test -f "$skill_dir/templates/source_discovery.md"
test -f "$skill_dir/templates/abstract_plan.md"
test -f "$skill_dir/templates/evidence.md"
test -f "$skill_dir/templates/review.md"
test -f "$skill_dir/templates/bitter_lesson.md"
test -f "$skill_dir/templates/short_goal_message.md"
test -x "$skill_dir/scripts/init_control_files.sh"
test -x "$skill_dir/scripts/send_tmux_message.sh"

grep -F "$repo_dir/scripts/init_control_files.sh" "$skill_dir/SKILL.md" >/dev/null
grep -F "$repo_dir/templates/short_goal_message.md" "$skill_dir/SKILL.md" >/dev/null
if grep -F '__WORKFLOW_ROOT__' "$skill_dir/SKILL.md" >/dev/null; then
  printf 'Installed SKILL.md still contains workflow root placeholder\n' >&2
  exit 1
fi

printf 'test_install_skill PASS\n'
