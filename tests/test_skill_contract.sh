#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
skill_file="$repo_dir/SKILL.md"

require() {
  local needle=$1
  local file=${2:-$skill_file}
  grep -F "$needle" "$file" >/dev/null
}

reject() {
  local needle=$1
  local file=${2:-$skill_file}
  if grep -F "$needle" "$file" >/dev/null; then
    printf 'unexpected text in %s: %s\n' "$file" "$needle" >&2
    exit 1
  fi
}

test -f "$skill_file"

# Description must front-load the trigger scope and boundary because implicit
# skill matching can use a shortened description.
require 'description: "Use when the main Codex must prepare final run files, start, or supervise one controlled Codex in tmux.'
require 'startup message to the controlled Codex only points to control/goal.md and control/constraint.md'
require 'Do not use inside the controlled Codex'

# The old user-review model must not survive in executable skill/start paths.
for stale in \
  'waits for user review' \
  'files that need user review' \
  'user reviews and approves' \
  'user has reviewed and approved' \
  'approved preparation files' \
  'after the user approves the preparation files'
do
  reject "$stale" "$skill_file"
  for start_file in "$repo_dir"/stage_supervisor_*.md "$repo_dir"/templates/prompt_for_supervisor_goal.md; do
    reject "$stale" "$start_file"
  done
done

# Core controlled-Codex contract: exactly two active control files and no extra
# control-file protocol.
require 'Use exactly two active control files for the controlled Codex'
require 'control/goal.md'
require 'control/constraint.md'
require 'The controlled Codex must not use this skill'
require 'The controlled Codex startup message should contain only control-file paths.'
require 'Those control files may point to the active spec and required evidence files.'
reject 'the controlled Codex only reads control/goal.md and control/constraint.md'
if grep -F -e 'control/self_check.md' -e 'control/progress.md' -e 'control/done.md' "$skill_file" >/dev/null; then
  printf 'SKILL.md references extra control files\n' >&2
  exit 1
fi

# Router and helper boundaries. This protects against accidental independent
# helper-trigger behavior when helper names appear inside controlled files.
require '## Trigger Strategy'
require 'Only the outer `tmux-codex-supervisor` skill should be implicitly triggered for supervision work.'
require 'Run-file creation belongs to the separate `run-file-writer` skill.'
require '## Skill Router'
require 'Use the `run-file-writer` skill when the user asks to create final run files before execution.'
reject '## Helper: gen-goal'
reject '## Helper: gen-constraint'
reject '## Helper: gen-specs'
reject '## Helper: gen-supervisor-prompts'
reject '## Helper: review-run-files-for-autonomy'
require '## Helper: start-supervised-run'
require '## Helper: monitor-run'
require '## Helper: persist-user-requirement'
require 'Do not trigger this helper when the user only asks for status'

# run-file-writer must preserve already-decided user content and forbid user-waiting gates.
run_file_writer_skill="$repo_dir/skills/run-file-writer/SKILL.md"
test -f "$run_file_writer_skill"
require 'If the user already specified a method, tool, function, setting, output, metric, or constraint, write it directly into goal/specs.' "$run_file_writer_skill"
require 'Do not encode user-review, user-choice, or user-approval gates in durable run files.' "$run_file_writer_skill"
require 'workflow_<workflow id>/requirement_dialogue.md' "$run_file_writer_skill"
require 'ask whether Codex should start writing the run files now' "$run_file_writer_skill"
require 'Allowed external sources means sources permitted by the user, the task, and the available tools.' "$run_file_writer_skill"
require 'Conservative option means the option that is reversible, smallest in scope' "$run_file_writer_skill"

# Persistence and later-user-requirement handling.
require 'supervisor Codex is not the user'
require 'A controlled Codex blocked report is an executor-local correction issue, not a supervisor blocked state.'
require 'later user message changes execution permission, correction triggers, required settings, or completion criteria'
require 'Write it into the durable control file before relying on it.'
require 'Do not rely only on chat memory.'
require 'Do not mark the supervisor goal complete or blocked' "$repo_dir/templates/prompt_for_supervisor.md"
require 'source discovery, a short high-level abstract plan, implementation, evidence, status update' "$repo_dir/templates/prompt_for_supervisor.md"
require 'may run or submit jobs when `control/goal.md` and `control/constraint.md` require them' "$repo_dir/templates/prompt_for_supervisor.md"
for persistence_file in \
  "$repo_dir/templates/prompt_for_supervisor.md" \
  "$repo_dir/templates/prompt_for_supervisor_goal.md" \
  "$repo_dir/stage_supervisor_prompt_for_supervisor.md" \
  "$repo_dir/stage_supervisor_prompt_for_supervisor_goal.md" \
  "$repo_dir/stage_supervisor_filled_goal.md"
do
  require 'write it into' "$persistence_file"
  require 'before relying on it' "$persistence_file"
  reject 'update the active control files or send a correction' "$persistence_file"
  reject 'update the active control files or send' "$persistence_file"
done

# Git checkpoint and no-context review rules.
require '## Checkpoint Commit Rule'
require 'After each completed stable task step or spec, require a checkpoint git commit'
require 'git status --short'
require 'git log -1 --oneline'
require 'git show --stat --oneline --name-status HEAD'
require '## No-Context Review Rule'
require 'After each completed task step and before its checkpoint commit, the supervisor must send the current `git diff` to fresh no-context Codex subagent reviewers using `gpt5.4 high`'
require 'The checkpoint commit is allowed only after the required reviewers PASS'
require 'ordinary spec: at least two no-context reviewers'
require 'high-risk spec: three to five no-context reviewers'
require 'High-risk spec means the completed step touches destructive operations, git history, user data, paid or cloud resources'
require 'If a reviewer finds a real problem, fix the current spec, rerun fresh no-context Codex subagent review on the new `git diff`, and commit only after PASS.'

# Controlled Codex startup must explicitly request yolo mode. Do not depend on a
# user-specific shell wrapper because wrapper flags can conflict or be absent.
require 'codex --dangerously-bypass-approvals-and-sandbox'
require 'do not start the controlled Codex with bare `codex` or through a shell wrapper'
require 'confirm the controlled Codex shows the intended permissions mode'
reject 'bash -ic'

# Actual supervisor start paths must carry the persistence idea or directly point
# to a file that carries it.
persistence_text='Do not mark the supervisor goal complete or blocked'
executor_duty_text='may run or submit jobs when `control/goal.md` and `control/constraint.md` require them'
require "$persistence_text" "$repo_dir/templates/prompt_for_supervisor_goal.md"
require "$persistence_text" "$repo_dir/templates/prompt_for_supervisor.md"
require "$persistence_text" "$repo_dir/stage_supervisor_execution_message.md"
require "$persistence_text" "$repo_dir/stage_supervisor_execution_read_file.md"
require "$persistence_text" "$repo_dir/stage_supervisor_prompt_for_supervisor_goal.md"
require "$persistence_text" "$repo_dir/stage_supervisor_prompt_for_supervisor.md"
require "$persistence_text" "$repo_dir/stage_supervisor_filled_goal.md"
require "$executor_duty_text" "$repo_dir/templates/prompt_for_supervisor_goal.md"
require "$executor_duty_text" "$repo_dir/templates/prompt_for_supervisor.md"
require "$executor_duty_text" "$repo_dir/stage_supervisor_execution_message.md"
require "$executor_duty_text" "$repo_dir/stage_supervisor_execution_read_file.md"
require "$executor_duty_text" "$repo_dir/stage_supervisor_prompt_for_supervisor_goal.md"
require "$executor_duty_text" "$repo_dir/stage_supervisor_prompt_for_supervisor.md"
require "$executor_duty_text" "$repo_dir/stage_supervisor_filled_goal.md"
require 'codex --dangerously-bypass-approvals-and-sandbox' "$repo_dir/templates/prompt_for_supervisor.md"
require 'codex --dangerously-bypass-approvals-and-sandbox' "$repo_dir/templates/prompt_for_supervisor_goal.md"
if grep -x '/goal' "$repo_dir/templates/prompt_for_supervisor_goal.md" "$repo_dir/templates/prompt_for_run_prep.md" "$repo_dir"/stage_supervisor_*.md >/dev/null; then
  printf 'supervisor/run-prep paste files must not include /goal; user types it manually\n' >&2
  exit 1
fi

# Script references still exist after the refactor.
require 'run-file-writer'
require 'scripts/init_run_templates.sh'
require 'The `run-file-writer` skill owns `init_control_files.sh` and `init_run_templates.sh`.'
require '__WORKFLOW_ROOT__/scripts/locate_codex.sh'
require '__WORKFLOW_ROOT__/scripts/inject_steer.sh'
require 'required and only allowed tmux input path for controlled Codex messages'
require 'Outside `inject_steer.sh`, do not use any other tmux input path for controlled Codex messages.'
require '__WORKFLOW_ROOT__/templates/prompt_for_supervisor.md'
require '__WORKFLOW_ROOT__/templates/short_goal_message.md'

run_file_writer_skill="$repo_dir/skills/run-file-writer/SKILL.md"
test -f "$run_file_writer_skill"
require 'name: run-file-writer' "$run_file_writer_skill"
require 'Create final run files for a supervised Codex tmux workflow before execution.' "$run_file_writer_skill"
require 'scripts/init_run_templates.sh <task-directory> <workflow-id> [spec-name ...]' "$run_file_writer_skill"
require 'always rebuilds `workflow_<workflow id>/prompt_for_supervisor.md` and `workflow_<workflow id>/prompt_for_supervisor_goal.md` from templates' "$run_file_writer_skill"
require 'Do not write supervisor prompt files at the task root.' "$run_file_writer_skill"
test -x "$repo_dir/skills/run-file-writer/scripts/init_control_files.sh"
test -x "$repo_dir/skills/run-file-writer/scripts/init_run_templates.sh"
test -f "$repo_dir/skills/run-file-writer/templates/prompt_for_run_prep.md"
test -f "$repo_dir/skills/run-file-writer/templates/prompt_for_supervisor.md"
test -f "$repo_dir/skills/run-file-writer/templates/prompt_for_supervisor_goal.md"

printf 'test_skill_contract PASS\n'
