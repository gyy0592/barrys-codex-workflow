#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
codex_home=${CODEX_HOME:-"$HOME/.codex"}
skill_dir="$codex_home/skills/tmux-codex-supervisor"
run_file_writer_dir="$codex_home/skills/run-file-writer"
error_skill_dir="$codex_home/skills/workflow-error-transition"
monitor_skill_src="$repo_dir/external_skills/SihaoLiu-skills/monitor-codex-goal"
monitor_skill_dir="$codex_home/skills/monitor-codex-goal"

mkdir -p "$skill_dir/templates" "$skill_dir/scripts"
mkdir -p "$run_file_writer_dir"
mkdir -p "$error_skill_dir"
if [ ! -f "$monitor_skill_src/SKILL.md" ]; then
  printf 'Missing monitor-codex-goal skill source: %s\n' "$monitor_skill_src" >&2
  exit 1
fi
mkdir -p "$monitor_skill_dir"

"$repo_dir/scripts/install_agents_rules.sh"

rm -f \
  "$skill_dir/scripts/capture_tmux_screen.sh" \
  "$skill_dir/scripts/send_tmux_message.sh" \
  "$skill_dir/scripts/verify_delivery.sh"

sed "s#__WORKFLOW_ROOT__#$repo_dir#g" "$repo_dir/SKILL.md" > "$skill_dir/SKILL.md"
cp "$repo_dir/templates/"*.md "$skill_dir/templates/"
cp "$repo_dir/scripts/"*.sh "$skill_dir/scripts/"
chmod +x "$skill_dir/scripts/"*.sh
rm -rf "$run_file_writer_dir"
mkdir -p "$run_file_writer_dir"
cp -R "$repo_dir/skills/run-file-writer/." "$run_file_writer_dir/"
sed "s#__RUN_FILE_WRITER_ROOT__#$run_file_writer_dir#g" \
  "$repo_dir/skills/run-file-writer/SKILL.md" > "$run_file_writer_dir/SKILL.md"
chmod +x "$run_file_writer_dir/scripts/"*.sh
cp "$repo_dir/skills/workflow-error-transition/SKILL.md" "$error_skill_dir/SKILL.md"
rm -rf "$monitor_skill_dir"
mkdir -p "$monitor_skill_dir"
cp -R "$monitor_skill_src/." "$monitor_skill_dir/"
if [ -d "$monitor_skill_dir/scripts" ]; then
  chmod +x "$monitor_skill_dir/scripts/"*.sh
fi

grep -F 'codex --dangerously-bypass-approvals-and-sandbox' "$skill_dir/SKILL.md" >/dev/null
grep -F 'codex --dangerously-bypass-approvals-and-sandbox' "$skill_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'codex --dangerously-bypass-approvals-and-sandbox' "$skill_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F "$run_file_writer_dir/scripts/init_run_templates.sh" "$run_file_writer_dir/SKILL.md" >/dev/null
if grep -F '__RUN_FILE_WRITER_ROOT__' "$run_file_writer_dir/SKILL.md" >/dev/null; then
  printf 'Installed run-file-writer still contains run-file-writer root placeholder\n' >&2
  exit 1
fi
if grep -F 'bash -ic' "$skill_dir/SKILL.md" "$skill_dir/templates/prompt_for_supervisor.md" "$skill_dir/templates/prompt_for_supervisor_goal.md" >/dev/null; then
  printf 'Installed tmux-codex-supervisor still contains bash -ic startup guidance\n' >&2
  exit 1
fi

printf 'SKILL_INSTALLED %s\n' "$skill_dir"
printf 'SKILL_INSTALLED %s\n' "$run_file_writer_dir"
printf 'SKILL_INSTALLED %s\n' "$error_skill_dir"
printf 'SKILL_INSTALLED %s\n' "$monitor_skill_dir"
