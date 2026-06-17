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

"$repo_dir/scripts/init_run_templates.sh" "$tmp_dir/run_task" demo 001_first spec_002_second >"$tmp_dir/init_run.out"
grep -F "CREATED $tmp_dir/run_task/control/goal.md" "$tmp_dir/init_run.out" >/dev/null
grep -F "CREATED $tmp_dir/run_task/workflow_demo/run_goal.md" "$tmp_dir/init_run.out" >/dev/null
grep -F "CREATED $tmp_dir/run_task/workflow_demo/spec_001_first/status.md" "$tmp_dir/init_run.out" >/dev/null
grep -F "CREATED $tmp_dir/run_task/workflow_demo/spec_002_second/status.md" "$tmp_dir/init_run.out" >/dev/null
test -f "$tmp_dir/run_task/control/goal.md"
test -f "$tmp_dir/run_task/control/constraint.md"
test -f "$tmp_dir/run_task/workflow_demo/run_goal.md"
test -f "$tmp_dir/run_task/workflow_demo/specs.md"
for spec_dir in "$tmp_dir/run_task/workflow_demo/spec_001_first" "$tmp_dir/run_task/workflow_demo/spec_002_second"; do
  test -f "$spec_dir/status.md"
  test -f "$spec_dir/source_discovery.md"
  test -f "$spec_dir/abstract_plan.md"
  test -f "$spec_dir/evidence.md"
  test -f "$spec_dir/review.md"
  test -f "$spec_dir/bitter_lesson.md"
done
printf 'custom status\n' >"$tmp_dir/run_task/workflow_demo/spec_001_first/status.md"
"$repo_dir/scripts/init_run_templates.sh" "$tmp_dir/run_task" workflow_demo 001_first >"$tmp_dir/init_run_again.out"
grep -F "EXISTS $tmp_dir/run_task/workflow_demo/spec_001_first/status.md" "$tmp_dir/init_run_again.out" >/dev/null
grep -F 'custom status' "$tmp_dir/run_task/workflow_demo/spec_001_first/status.md" >/dev/null

expected_short_goal="$tmp_dir/expected_short_goal.md"
printf '/goal\ncontrol/goal.md\ncontrol/constraint.md\n' >"$expected_short_goal"
if ! cmp -s "$expected_short_goal" "$repo_dir/templates/short_goal_message.md"; then
  printf 'short_goal_message.md must contain exactly /goal and the two control-file paths\n' >&2
  exit 1
fi
grep -F 'This is not the execution phase.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Do not start the controlled Codex.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Do not start long training' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'These "do not start" and "do not submit" rules apply only to the main Codex during run-file creation.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'They must not be copied into executor runtime files as a ban on executor work.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'the controlled Codex must do them during execution under `control/goal.md` and `control/constraint.md`' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'checks that they will not make the long run wait for later user review or user choice' "$repo_dir/README.md" >/dev/null
grep -F 'Do not write user-review, user-choice, or user-approval gates into durable run files.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'scripts/init_run_templates.sh <task-directory> <workflow-id> [spec-name ...]' "$repo_dir/SKILL.md" >/dev/null
grep -F 'copies every missing templated run file and leaves existing files unchanged' "$repo_dir/SKILL.md" >/dev/null
grep -F 'Do not recreate templated run files from memory.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Template heading risk check' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Remove or rewrite any heading that can be treated as a runtime stop condition.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Remove or rewrite any heading that conflicts with control/constraint.md.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Remove or rewrite any heading that asks for user review, choices, or approval after durable run files are written.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'latest user instruction written into control files > control/constraint.md > control/goal.md > current spec.md > specs.md > run_goal.md' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Do not paste this whole file as `/goal`' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'This file is for the supervisor, not the executor.' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'the supervisor must not create the controlled task' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'Executor duty: the controlled Codex must produce the required outputs and may run or submit jobs' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
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
grep -F 'Specific Workflow Enforcement Rule' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'must record the files inspected, command outputs inspected, external sources inspected when needed' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'If the next action would require guessing a fact, file purpose, API behavior, data format, user requirement, benchmark meaning, or external rule' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'must record what was checked, which file or command was used, expected result, actual result, and conclusion' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'may be marked `done` only after source discovery, abstract plan, implementation evidence, checkpoint evidence, and required review' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'Enforce the specific workflow stages from `prompt_for_supervisor.md`' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'First commit any final run files' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'You are the supervisor only.' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Read `prompt_for_supervisor.md` in the current working directory before acting' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'The executor does the controlled task. The executor must produce required outputs and may run or submit jobs' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Work and monitor one spec at a time' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'If the executor is stable, monitor once every 2 to 10 minutes' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'They are not permission for the supervisor to stop supervising' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Do not mark the supervisor goal complete or blocked' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'The supervisor must not read full project source code' "$repo_dir/templates/prompt_for_supervisor_goal.md" >/dev/null
grep -F 'Supervisor Persistence Rule' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'Supervisor Evidence Boundary' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'force the executor to continue the fix loop' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'runtime autonomy definitions' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'allowed external sources as defined in `control/constraint.md`' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'Use at least two fresh no-context reviewers for an ordinary completed spec' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
grep -F 'Use three to five fresh no-context reviewers for a high-risk completed spec' "$repo_dir/templates/prompt_for_supervisor.md" >/dev/null
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
grep -F 'Runtime Autonomy Definitions' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'Allowed external sources means sources permitted by the user, the task, and the available tools.' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'Conservative option means the option that is reversible, smallest in scope' "$repo_dir/templates/constraint.md" >/dev/null
grep -F 'Specs run one at a time, in order' "$repo_dir/templates/specs.md" >/dev/null
grep -F 'must not review multiple specs at once' "$repo_dir/templates/review.md" >/dev/null
grep -F 'During execution, do not wait for a user response.' "$repo_dir/templates/source_discovery.md" >/dev/null
grep -F 'allowed external sources as defined in `control/constraint.md`' "$repo_dir/templates/source_discovery.md" >/dev/null
grep -F 'choosing a conservative option defined in `control/constraint.md`' "$repo_dir/templates/abstract_plan.md" >/dev/null
grep -F 'Do not write a user-decision blocker after final run files are written.' "$repo_dir/templates/spec_status.md" >/dev/null
grep -F 'Runtime Autonomy' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'After execution starts, complete the run autonomously' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'If a choice is missing during execution, choose a conservative option as defined in `control/constraint.md`' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'File Ownership And Priority' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'Supervisor-only restrictions in supervisor prompt files do not become executor restrictions here.' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'the controlled Codex must do them during execution.' "$repo_dir/templates/run_goal.md" >/dev/null
grep -F 'autonomous resolution path for that spec' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Allowed external sources means sources permitted by the user, the task, and the available tools.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Conservative option means the option that is reversible, smallest in scope' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
grep -F 'Write those two definitions into control/constraint.md when generating run files.' "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null
if grep -F 'User Review Points' "$repo_dir/templates/run_goal.md" >/dev/null; then
  printf 'run_goal.md must not contain User Review Points\n' >&2
  exit 1
fi
if grep -F -e 'ask the user' -e 'wait for user review' -e 'user approval needed' "$repo_dir/templates/run_goal.md" "$repo_dir/templates/prompt_for_run_prep.md" >/dev/null; then
  printf 'run files and run-prep prompt must not encode user review or approval gates\n' >&2
  exit 1
fi
semantic_gate_templates=("$repo_dir"/templates/*.md)
for semantic_gate_template in "${semantic_gate_templates[@]}"; do
  if grep -F -e 'user approves' \
             -e 'asking the user' \
             -e 'ask the user' \
             -e 'wait for user review' \
             -e 'user approval needed' \
             -e 'user decision needed' \
             -e 'do not execute until' \
             -e 'what must be checked later' \
             -e 'internet or paper search when needed' \
             -e 'conservative choice' \
             -e 'Conservative choice' \
             "$semantic_gate_template" >/dev/null; then
    printf 'template has a user-waiting or undefined-search gate: %s\n' "$semantic_gate_template" >&2
    exit 1
  fi
done
for template in run_goal specs spec_status source_discovery abstract_plan evidence review bitter_lesson prompt_for_supervisor_goal; do
  test -f "$repo_dir/templates/$template.md"
done
if grep -F -e 'control/self_check.md' -e 'control/progress.md' -e 'control/done.md' "$repo_dir/templates/short_goal_message.md" >/dev/null; then
  printf 'short_goal_message.md references extra control files\n' >&2
  exit 1
fi

grep -F 'These prep-phase bans apply only to this main Codex while creating run files.' "$repo_dir/stage_supervisor_prep_message.md" >/dev/null
grep -F 'This is not a ban on the future controlled Codex' "$repo_dir/stage_supervisor_read_file_message.md" >/dev/null
grep -F 'For this correction message only: do not start execution' "$repo_dir/stage_supervisor_review_rule_correction.md" >/dev/null
grep -F 'This is not a ban on the future controlled Codex' "$repo_dir/stage_supervisor_review_rule_correction.md" >/dev/null

printf 'test_templates PASS\n'
