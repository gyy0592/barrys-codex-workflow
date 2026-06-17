#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

mkdir -p "$tmp_dir/codex"
printf '# Existing AGENTS\n\nKeep this user rule.\n' > "$tmp_dir/codex/AGENTS.md"
CODEX_HOME="$tmp_dir/codex" "$repo_dir/scripts/install_skill.sh" >/dev/null

skill_dir="$tmp_dir/codex/skills/tmux-codex-supervisor"
error_skill_dir="$tmp_dir/codex/skills/workflow-error-transition"
test -f "$skill_dir/SKILL.md"
test -f "$error_skill_dir/SKILL.md"
grep -F 'name: workflow-error-transition' "$error_skill_dir/SKILL.md" >/dev/null
grep -F 'failed command, failed test, bad run' "$error_skill_dir/SKILL.md" >/dev/null
grep -F 'Decision: retry current path | return to source discovery' "$error_skill_dir/SKILL.md" >/dev/null
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
test -f "$skill_dir/templates/agents_subagent_rules.md"
test -x "$skill_dir/scripts/init_control_files.sh"
test -x "$skill_dir/scripts/init_run_templates.sh"
test -x "$skill_dir/scripts/send_tmux_message.sh"
test -x "$skill_dir/scripts/uninstall_skill.sh"
test -x "$skill_dir/scripts/install_agents_rules.sh"
test -x "$skill_dir/scripts/uninstall_agents_rules.sh"
grep -F 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$tmp_dir/codex/AGENTS.md" >/dev/null
grep -F 'Using a subagent does not expand the calling Codex' "$tmp_dir/codex/AGENTS.md" >/dev/null
grep -F 'A subagent can only do work that belongs to the calling Codex' "$tmp_dir/codex/AGENTS.md" >/dev/null
grep -F 'returns its report only to the calling Codex' "$tmp_dir/codex/AGENTS.md" >/dev/null
grep -F 'Keep this user rule.' "$tmp_dir/codex/AGENTS.md" >/dev/null
marker_count=$(grep -c 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$tmp_dir/codex/AGENTS.md")
test "$marker_count" -eq 1

CODEX_HOME="$tmp_dir/codex" "$repo_dir/scripts/install_skill.sh" >/dev/null
marker_count=$(grep -c 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$tmp_dir/codex/AGENTS.md")
test "$marker_count" -eq 1

CODEX_HOME="$tmp_dir/codex" "$repo_dir/scripts/uninstall_agents_rules.sh" >/dev/null
if grep -F 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$tmp_dir/codex/AGENTS.md" >/dev/null; then
  printf 'uninstall_agents_rules.sh did not remove subagent rules from AGENTS.md\n' >&2
  exit 1
fi
grep -F 'Keep this user rule.' "$tmp_dir/codex/AGENTS.md" >/dev/null

CODEX_HOME="$tmp_dir/codex" "$repo_dir/scripts/install_skill.sh" >/dev/null
CODEX_HOME="$tmp_dir/codex" "$repo_dir/uninstall.sh" >/dev/null
test ! -e "$skill_dir"
test ! -e "$error_skill_dir"
if grep -F 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$tmp_dir/codex/AGENTS.md" >/dev/null; then
  printf 'uninstall.sh did not remove subagent rules from AGENTS.md\n' >&2
  exit 1
fi
grep -F 'Keep this user rule.' "$tmp_dir/codex/AGENTS.md" >/dev/null

CODEX_HOME="$tmp_dir/codex" "$repo_dir/scripts/install_skill.sh" >/dev/null

grep -F "$repo_dir/scripts/init_control_files.sh" "$skill_dir/SKILL.md" >/dev/null
grep -F "$repo_dir/scripts/init_run_templates.sh" "$skill_dir/SKILL.md" >/dev/null
grep -F "$repo_dir/templates/short_goal_message.md" "$skill_dir/SKILL.md" >/dev/null
if grep -F '__WORKFLOW_ROOT__' "$skill_dir/SKILL.md" >/dev/null; then
  printf 'Installed SKILL.md still contains workflow root placeholder\n' >&2
  exit 1
fi

one_click_home="$tmp_dir/codex_one_click"
CODEX_HOME="$one_click_home" "$repo_dir/install.sh" >"$tmp_dir/one_click.out"
grep -F 'ONE_CLICK_INSTALL_OK' "$tmp_dir/one_click.out" >/dev/null
one_click_skill_dir="$one_click_home/skills/tmux-codex-supervisor"
one_click_error_skill_dir="$one_click_home/skills/workflow-error-transition"
test -f "$one_click_skill_dir/SKILL.md"
test -f "$one_click_skill_dir/templates/short_goal_message.md"
test -x "$one_click_skill_dir/scripts/send_tmux_message.sh"
test -x "$one_click_skill_dir/scripts/uninstall_skill.sh"
test -f "$one_click_error_skill_dir/SKILL.md"
grep -F 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$one_click_home/AGENTS.md" >/dev/null
CODEX_HOME="$one_click_home" "$one_click_skill_dir/scripts/uninstall_skill.sh" >/dev/null
test ! -e "$one_click_skill_dir"
test ! -e "$one_click_error_skill_dir"
if grep -F 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$one_click_home/AGENTS.md" >/dev/null; then
  printf 'installed uninstall_skill.sh did not remove subagent rules from AGENTS.md\n' >&2
  exit 1
fi

source_repo="$tmp_dir/source_repo"
mkdir -p "$source_repo"
cp "$repo_dir/install.sh" "$repo_dir/uninstall.sh" "$repo_dir/SKILL.md" "$source_repo/"
cp -R "$repo_dir/templates" "$repo_dir/scripts" "$repo_dir/skills" "$source_repo/"
git -C "$source_repo" init -q
git -C "$source_repo" add .
git -C "$source_repo" -c user.name='Test User' -c user.email='test@example.com' commit -q -m init

piped_home="$tmp_dir/codex_piped"
piped_checkout="$tmp_dir/piped_checkout"
CODEX_HOME="$piped_home" CODEX_WORKFLOW_INSTALL_DIR="$piped_checkout" \
  bash -s -- "$source_repo" <"$repo_dir/install.sh" >"$tmp_dir/piped.out"
grep -F 'ONE_CLICK_INSTALL_OK' "$tmp_dir/piped.out" >/dev/null
piped_skill_dir="$piped_home/skills/tmux-codex-supervisor"
piped_error_skill_dir="$piped_home/skills/workflow-error-transition"
test -d "$piped_checkout/.git"
test -f "$piped_skill_dir/SKILL.md"
test -f "$piped_skill_dir/templates/short_goal_message.md"
test -x "$piped_skill_dir/scripts/send_tmux_message.sh"
test -f "$piped_error_skill_dir/SKILL.md"
grep -F 'CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN' "$piped_home/AGENTS.md" >/dev/null

printf 'test_install_skill PASS\n'
