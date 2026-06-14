#!/usr/bin/env bash
set -euo pipefail

repo_dir=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
tmp_dir=$(mktemp -d)
cleanup() {
  rm -rf "$tmp_dir"
}
trap cleanup EXIT

"$repo_dir/scripts/init_control_files.sh" "$tmp_dir/task"

test -f "$tmp_dir/task/control/goal.md"
test -f "$tmp_dir/task/control/constraint.md"
test ! -e "$tmp_dir/task/control/self_check.md"
test ! -e "$tmp_dir/task/control/progress.md"
test ! -e "$tmp_dir/task/control/done.md"

grep -F 'control/goal.md' "$repo_dir/templates/short_goal_message.md" >/dev/null
grep -F 'control/constraint.md' "$repo_dir/templates/short_goal_message.md" >/dev/null
grep -F 'This is not the execution phase.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Do not start the controlled Codex.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Do not start long training' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'checks that they do not contain later user-review gates' "$repo_dir/README.md" >/dev/null
grep -F 'Do not write user-review, user-choice, or user-approval gates into durable run files.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Template heading risk check' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Remove or rewrite any heading that can be treated as a runtime stop condition.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Remove or rewrite any heading that conflicts with control/constraint.md.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Remove or rewrite any heading that asks for user review, choices, or approval after durable run files are written.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'latest user instruction written into control files > control/constraint.md > control/goal.md > current spec.md > specs.md > run_goal.md' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Do not paste this whole file as `/goal`' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'control/goal.md' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'control/constraint.md' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'File Conflict Priority Rule' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'If a lower-priority file appears to require stopping' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'send a plain correction message, not a new `/goal`' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'once every 2 to 10 minutes' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'do not interrupt it frequently' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'execute one spec at a time' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'must not batch multiple specs into one checkpoint commit or one review' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'doing future-spec work before the current spec has passed' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'First commit any final run files' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'You are the supervisor only.' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Read `prompt_for_supervisor.md` in the current working directory before acting' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Work and monitor one spec at a time' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'If the executor is stable, monitor once every 2 to 10 minutes' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'They are not permission for the supervisor to stop supervising' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Do not mark the supervisor goal complete or blocked' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'The supervisor must not read full project source code' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Supervisor Persistence Rule' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'Supervisor Evidence Boundary' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'force the executor to continue the fix loop' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
if grep -x '/goal' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null; then
  printf 'prompt_for_supervisor.md must not be the pasted /goal file\n' >&2
  exit 1
fi
grep -F 'write an ETA' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'CPU utilization' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'GPU utilization' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'first inspect whether the code or command can be made faster' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'stop or kill the run' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'Create checkpoint git commits' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'Specs run one at a time, in order' "$repo_dir/templates/specs.md" >/dev/null
grep -F 'must not review multiple specs at once' "$repo_dir/templates/review.md" >/dev/null
grep -F 'Runtime Autonomy' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'After execution starts, complete the run autonomously' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'If a choice is missing during execution, choose a conservative option' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'File Ownership And Priority' "$repo_dir/templates/run_goal.md" >/dev/null
if grep -F 'User Review Points' "$repo_dir/templates/run_goal.md" >/dev/null; then
  printf 'run_goal.md must not contain User Review Points\n' >&2
  exit 1
fi
if grep -F -e 'ask the user' -e 'wait for user review' -e 'user approval needed' "$repo_dir/templates/run_goal.md" "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null; then
  printf 'run files and run-prep prompt must not encode user review or approval gates\n' >&2
  exit 1
fi
for template in run_goal specs spec_status source_discovery abstract_plan evidence review bitter_lesson prompt_for_supervisor_goal; do
  test -f "$repo_dir/templates/$template.md"
done
if grep -F -e 'control/self_check.md' -e 'control/progress.md' -e 'control/done.md' "$repo_dir/templates/short_goal_message.md" >/dev/null; then
  printf 'short_goal_message.md references extra control files\n' >&2
  exit 1
fi

printf 'test_templates PASS\n'
