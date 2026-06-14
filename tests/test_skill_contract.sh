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
require 'Only the outer `tmux-codex-supervisor` skill should be implicitly triggered.'
require 'helper names below are internal sections, not independent skills'
require '## Skill Router'
for helper in \
  '## Helper: gen-goal' \
  '## Helper: gen-constraint' \
  '## Helper: gen-specs' \
  '## Helper: gen-supervisor-prompts' \
  '## Helper: review-run-files-for-autonomy' \
  '## Helper: start-supervised-run' \
  '## Helper: monitor-run' \
  '## Helper: persist-user-requirement'
do
  require "$helper"
done
require 'Do not trigger this helper while the controlled Codex is executing a spec'
require 'Do not trigger this helper when the controlled Codex is doing ordinary execution'
require 'Do not trigger this helper while the controlled Codex is executing the current spec'
require 'Do not trigger this helper when the user only asks for status'
require 'definitions for `allowed external sources` and `conservative option`'

# gen-specs must preserve already-decided user content and forbid re-opening it.
require 'If the user already specified a data field, setting, output, or constraint, write it directly into goal/specs. Do not create a spec whose purpose is to decide it again.'
require 'Clarifying questions are allowed only before final run files are written'
require 'After final run files are written, do not ask the user for choices, approvals, or review.'
require 'Allowed external sources means sources permitted by the user, the task, and the available tools.'
require 'Conservative option means the option that is reversible, smallest in scope'
reject 'allowed internet or paper search'
reject 'conservative choice'
reject 'Conservative choice'

# Run-file autonomy review must check real failure modes, not only a heading.
require '## Helper: review-run-files-for-autonomy'
require 'no user-decided requirement is rewritten as undecided'
require 'durable run files contain no `ask the user`, `wait for user review`, or `user approval needed` gates'
require 'controlled files do not depend on supervisor chat memory'
require '`control/goal.md`, `control/constraint.md`, `specs.md`, and `run_goal.md` do not conflict'
require 'runtime terms such as `allowed external sources` and `conservative option` are defined in `control/constraint.md` or in the same durable run file that uses them'
require 'lower-priority files cannot override higher-priority control files'

# Persistence and later-user-requirement handling.
require 'must not mark its own goal complete or blocked because the controlled Codex reports blocked'
require 'a run fails, information is missing, or a review fails'
require 'later user message changes execution permission, stop conditions, required settings, or completion criteria'
require 'Write it into the durable control file before relying on it.'
require 'Do not rely only on chat memory.'
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
require 'After each checkpoint commit, the supervisor must run no-context review'
require 'ordinary spec: at least two no-context reviewers'
require 'high-risk spec: three to five no-context reviewers'
require 'High-risk spec means the completed step touches destructive operations, git history, user data, paid or cloud resources'
require 'If a reviewer finds a real problem, fix the current spec, make a new checkpoint commit, and run fresh no-context review.'

# Actual supervisor start paths must carry the persistence idea or directly point
# to a file that carries it.
persistence_text='Do not mark the supervisor goal complete or blocked'
require "$persistence_text" "$repo_dir/templates/prompt_for_supervisor_goal.md"
require "$persistence_text" "$repo_dir/templates/prompt_for_supervisor.md"
require "$persistence_text" "$repo_dir/stage_supervisor_execution_message.md"
require "$persistence_text" "$repo_dir/stage_supervisor_execution_read_file.md"
require "$persistence_text" "$repo_dir/stage_supervisor_prompt_for_supervisor_goal.md"
require "$persistence_text" "$repo_dir/stage_supervisor_prompt_for_supervisor.md"
require "$persistence_text" "$repo_dir/stage_supervisor_filled_goal.md"

# Script references still exist after the refactor.
require '__WORKFLOW_ROOT__/scripts/init_control_files.sh'
require '__WORKFLOW_ROOT__/scripts/send_tmux_message.sh'
require '__WORKFLOW_ROOT__/scripts/capture_tmux_screen.sh'
require '__WORKFLOW_ROOT__/scripts/verify_delivery.sh'
require '__WORKFLOW_ROOT__/templates/prompt_for_run_prep.md'
require '__WORKFLOW_ROOT__/templates/prompt_for_supervisor.md'
require '__WORKFLOW_ROOT__/templates/short_goal_message.md'

printf 'test_skill_contract PASS\n'
