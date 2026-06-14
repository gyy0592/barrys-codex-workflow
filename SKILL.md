---
name: tmux-codex-supervisor
description: "Use when preparing or supervising a Codex instance running inside tmux, with the main Codex creating run-prep files, preparing two control files, sending a short /goal message only during execution, checking evidence, and avoiding direct task execution."
---

# tmux Codex Supervisor

Use this skill when the main Codex must prepare a supervised run or supervise a controlled Codex running in tmux.

Codex is the AI assistant. The main Codex is the supervisor in the current chat. The controlled Codex is the executor in a tmux window. tmux is a terminal tool that keeps sessions running. A control file is a task file read by the controlled Codex. A preparation file is a file that describes the future run before execution starts.

Workflow root is `__WORKFLOW_ROOT__`. Use this absolute path even when the current task is in another directory.

## Non-Negotiable Design

- Use exactly two control files: `control/goal.md` and `control/constraint.md`.
- `control/goal.md` contains the task goal, input material, output requirement, progress requirement, and completion standard.
- `control/constraint.md` contains limits, forbidden actions, and self-check rules.
- The short `/goal` message only points the controlled Codex to the two control files.
- The main Codex supervises; the controlled Codex executes.
- The preparation phase writes files and waits for user review. It does not start the controlled Codex or long-running task work.
- The execution phase starts the controlled Codex only after the user approves the preparation files.

## Preparation Phase Order

Use this order when the user asks to turn a task request into preparation files before execution:

1. Use `__WORKFLOW_ROOT__/templates/prompt_for_run_prep.md` as the main-Codex template.
2. Create or update `control/goal.md` and `control/constraint.md` in the task directory.
3. Create `workflow_<workflow id>/run_goal.md` and `workflow_<workflow id>/specs.md`.
4. Use the prep templates when a spec folder or evidence file format must be defined.
5. Do not start the controlled Codex.
6. Do not send the short `/goal` message.
7. Do not start training, experiments, jobs, or other long-running execution.
8. Stop and report the files that need user review.

## Execution Phase Order

Use this order only after the user approves the preparation files:

1. Read the user's task and decide what belongs in `control/goal.md` and `control/constraint.md`.
2. Create the two control files with `__WORKFLOW_ROOT__/scripts/init_control_files.sh <task-directory>`.
3. Send `__WORKFLOW_ROOT__/templates/short_goal_message.md` to the controlled tmux target.
4. Verify that the message reached the controlled tmux target.
5. Monitor progress using the evidence named in `control/goal.md`.
6. Correct only when evidence proves drift, stalling, or failed completion.
7. Verify completion with the completion standard in `control/goal.md`.
8. Report to the user using evidence, not guesses.

## Supervisor Prompt Templates

Use `__WORKFLOW_ROOT__/templates/prompt_for_supervisor.md` as the long companion file for a main Codex supervisor. It defines the task details, supervisor role, drift rule, checkpoint rule, review rule, correction rule, and the rule that later global user requirements must be propagated into the active control files.

Use `__WORKFLOW_ROOT__/templates/prompt_for_supervisor_goal.md` as the short direct `/goal` text to paste into the main Codex supervisor. Keep this short because the active goal may be reread when the main Codex stops.

Do not paste the long companion file as `/goal`. Do not send either supervisor template to the controlled Codex. The controlled Codex should receive only `__WORKFLOW_ROOT__/templates/short_goal_message.md` after `control/goal.md` and `control/constraint.md` are ready.

## Run-Prep Templates

Use these templates when preparing a run:

- `__WORKFLOW_ROOT__/templates/prompt_for_run_prep.md`: message for the main Codex during preparation.
- `__WORKFLOW_ROOT__/templates/run_goal.md`: stable run goal.
- `__WORKFLOW_ROOT__/templates/specs.md`: checkable task steps.
- `__WORKFLOW_ROOT__/templates/spec_status.md`: per-spec status.
- `__WORKFLOW_ROOT__/templates/source_discovery.md`: sources and missing information.
- `__WORKFLOW_ROOT__/templates/abstract_plan.md`: short per-spec plan.
- `__WORKFLOW_ROOT__/templates/evidence.md`: per-spec proof.
- `__WORKFLOW_ROOT__/templates/review.md`: fresh no-context review result.
- `__WORKFLOW_ROOT__/templates/bitter_lesson.md`: reusable failure lesson.

## Role Boundary

The main Codex may prepare run-prep files, prepare control files, run supervision scripts, read evidence, send correction text, and report. The main Codex must not do the future task output that the controlled Codex was assigned to do.

## Script Policy

Use scripts for fixed operations:

- `__WORKFLOW_ROOT__/scripts/init_control_files.sh` creates the two control files in the task directory.
- `__WORKFLOW_ROOT__/scripts/send_tmux_message.sh` sends a file's text to tmux.
- `__WORKFLOW_ROOT__/scripts/capture_tmux_screen.sh` reads recent tmux screen text.
- `__WORKFLOW_ROOT__/scripts/verify_delivery.sh` checks that expected text appears on screen.
- `__WORKFLOW_ROOT__/scripts/check_progress.sh` compares current progress evidence against the last saved check.
- `__WORKFLOW_ROOT__/scripts/check_done.sh` runs the completion check command.
- `__WORKFLOW_ROOT__/scripts/package_outputs.sh` packages output files.

Do not copy exact tmux key sequences into high-level task text. Keep exact terminal behavior in scripts and tests.
