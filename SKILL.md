---
name: tmux-codex-supervisor
description: "Use when the main Codex must prepare final run files, start, or supervise one controlled Codex in tmux. Do not use inside the controlled Codex; the startup message to the controlled Codex only points to control/goal.md and control/constraint.md."
---

# tmux Codex Supervisor

Use this skill only when the current Codex is the main Codex acting as supervisor.

Codex is the AI assistant. The main Codex is the supervisor in the current chat; the supervisor Codex is not the user. The controlled Codex is the executor in a tmux window. tmux is a terminal tool that keeps sessions running. A control file is a task file read first by the controlled Codex. A run file is a durable file written before execution, such as `control/goal.md`, `control/constraint.md`, `workflow_<workflow id>/run_goal.md`, and `workflow_<workflow id>/specs.md`. The controlled Codex receives only the two control-file paths in its startup message, then reads the spec, source discovery, evidence, or status files named by those control files and the active spec.

Workflow root is `__WORKFLOW_ROOT__`. Use this absolute path even when the current task is in another directory.

## Trigger Strategy

Only the outer `tmux-codex-supervisor` skill should be implicitly triggered for supervision work. Run-file creation belongs to the separate `run-file-writer` skill.

The controlled Codex must not use this skill. It receives only the short `/goal` message that points to `control/goal.md` and `control/constraint.md`.

## Non-Negotiable Design

- Use exactly two active control files for the controlled Codex: `control/goal.md` and `control/constraint.md`.
- `control/goal.md` contains the task goal, input material, output requirement, progress requirement, and completion standard.
- `control/constraint.md` contains limits, forbidden actions, self-check rules, checkpoint rules, review rules, and autonomous execution boundaries.
- The short `/goal` message only points the controlled Codex to the two control files. Those control files may point to the active spec and required evidence files.
- The main Codex supervises; the controlled Codex executes.
- Run-file creation writes final run files and checks that they support autonomous execution. It does not start the controlled Codex or long-running task work.
- Execution starts when the user starts the supervisor Codex in tmux and sets `prompt_for_supervisor_goal.md` as its `/goal`. That action is the user's approval to run; do not ask for a second execution approval.
- Do not encode user-review, user-choice, or user-approval gates in durable run files.
- A controlled Codex blocked report is an executor-local correction issue, not a supervisor blocked state. Durable run files must avoid `blocked`, `BLOCKED`, and `Current Blocker`; use `needs_correction`, `failed`, or `INSUFFICIENT_INFORMATION` with a next action instead.

## Skill Router

Before acting, classify the latest user request and select one helper path:

- Use the `run-file-writer` skill when the user asks to create final run files before execution.
- Use `start-supervised-run` when the supervisor goal is active or when the user explicitly asks to start execution and final run files already exist.
- Use `monitor-run` when a controlled Codex is already running and the user asks to supervise, continue supervising, check progress, correct drift, or verify completion.
- Use `persist-user-requirement` when a later user message changes execution permission, correction triggers, required settings, or completion criteria.

The router must not send internal helper names to the controlled Codex. The controlled Codex startup message should contain only control-file paths.

## Helper: start-supervised-run

Use this helper only after the user explicitly asks to start execution.

Before starting:

- confirm final run files exist,
- checkpoint final run files when they must be preserved,
- start one controlled Codex in tmux with explicit yolo mode, for example `tmux new-session -d -s <session-name> -c <task-directory> 'codex --dangerously-bypass-approvals-and-sandbox'`,
- do not start the controlled Codex with bare `codex` or through a shell wrapper; the yolo flag must be in the tmux start command itself,
- after startup, inspect the tmux screen and confirm the controlled Codex shows the intended permissions mode before sending the short `/goal`,
- send only the short `/goal` that points to `control/goal.md` and `control/constraint.md`,
- send and verify that message through `__WORKFLOW_ROOT__/scripts/inject_steer.sh`.

Do not start execution when the user only asked to create run files, discuss a plan, or review files. When the user has started this supervisor Codex with `prompt_for_supervisor_goal.md` as `/goal`, treat that as execution approval and continue without asking for another approval.

## Helper: monitor-run

Use this helper only when a controlled Codex is already running.

The supervisor may read control files, workflow files, spec files, evidence files, status files, review files, git status/log/diff/show output, tmux captures, transcripts, queue output, logs, metrics, manifests, and other incremental evidence files.

The supervisor must not read full project source code and must not implement task code. If source code understanding is needed, instruct the controlled Codex to inspect the relevant code and report evidence.

If the controlled Codex is stable and working within the current task step, do not interrupt it frequently. Stable means it is reading required sources, writing expected evidence, running an expected command, monitoring an expected job, or waiting on a legitimate long-running step. When stable, monitor at a low frequency, usually once every 2 to 10 minutes.

If the controlled Codex reports a correction issue, a run fails, information is missing, or a review fails, do not mark the supervisor goal blocked. Force the controlled Codex to continue the correction loop: source discovery, local inspection, allowed external sources, conservative option when an option is unavoidable, concrete fix, test, benchmark when relevant, evidence, checkpoint, no-context review, and next action.

## Helper: persist-user-requirement

Use this helper only when a later user message changes execution permission, correction triggers, required settings, or completion criteria.

Do not trigger this helper when the user only asks for status, asks what a file means, or asks for an explanation without changing a running rule.

When triggered:

1. Decide whether the requirement belongs in `control/goal.md`, `control/constraint.md`, or both.
2. Write it into the durable control file before relying on it.
3. Send a plain correction message to the controlled Codex when needed.
4. Verify delivery.

Do not rely only on chat memory. Do not only send a correction while leaving the durable control files stale.

## Checkpoint Commit Rule

After each completed stable task step or spec, require a checkpoint git commit unless the task explicitly forbids git commits.

Before each checkpoint commit, require:

- `git status --short`,
- separation of relevant and unrelated files,
- staging only files required for the current workflow/spec,
- no unrelated user files,
- no still-changing experiment outputs.
- current `git diff` sent to fresh no-context Codex subagent reviewers using `gpt5.4 high`, with PASS required before commit.

If relevant and unrelated files cannot be separated safely, stop the commit and report the exact paths.

After each checkpoint commit, require the current spec evidence to record:

```text
git status --short
git log -1 --oneline
git show --stat --oneline --name-status HEAD
```

## No-Context Review Rule

After each completed task step and before its checkpoint commit, the supervisor must send the current `git diff` to fresh no-context Codex subagent reviewers using `gpt5.4 high`. The checkpoint commit is allowed only after the required reviewers PASS, and the workflow can move to the next spec only after that checkpoint commit exists.

Default review count:

- ordinary spec: at least two no-context reviewers,
- high-risk spec: three to five no-context reviewers when correctness, constraints, git scope, tests, or failure risk need separate review.

High-risk spec means the completed step touches destructive operations, git history, user data, paid or cloud resources, security or permissions, broad refactors, long expensive runs, ambiguous requirements, or weak test coverage.

The reviewers must receive only the current spec, relevant goal/constraint excerpts, source discovery, abstract plan, evidence, status, latest git evidence, relevant diff, and explicit review instructions.

The reviewers must check:

- whether the current spec is truly complete,
- whether any user-required method, tool, function, metric, output, or constraint was changed, weakened, bypassed, replaced, or reinterpreted without evidence proving the original requirement does not exist or cannot work as stated and the failure is not caused by executor implementation error,
- drift from `control/goal.md`,
- violations of `control/constraint.md`,
- unrelated files in the commit,
- skipped source discovery, abstract plan, evidence, checkpoint commit, or review,
- unnecessary extra work,
- failure risk.

If a reviewer finds a real problem, fix the current spec, rerun fresh no-context Codex subagent review on the new `git diff`, and commit only after PASS. If a reviewer only gives style preference, unsupported nitpicking, or a claim contradicted by file evidence, record why it is ignored and continue.

## File Ownership And Priority

- Supervisor-only files: `prompt_for_supervisor.md`, `prompt_for_supervisor_goal.md`, and staged supervisor paste files.
- Controlled-execution files: `control/goal.md`, `control/constraint.md`, and current spec files.
- Shared evidence files: `run_goal.md`, `specs.md`, `evidence.md`, `status.md`, and review files.

For execution, use this priority:

```text
latest user instruction written into control files > control/constraint.md > control/goal.md > current spec.md > specs.md > run_goal.md
```

If a lower-priority file appears to require stopping but a higher-priority control file authorizes continuation, require the controlled Codex to continue and record the reason in evidence.

## Template Policy

Run-file templates and run-file initialization scripts belong to the `run-file-writer` skill. Use these supervisor templates and legacy fallback paths only when needed:

- `__WORKFLOW_ROOT__/templates/prompt_for_supervisor.md` is the supervisor's long companion file.
- `__WORKFLOW_ROOT__/templates/prompt_for_supervisor_goal.md` is the supervisor's short `/goal` text.
- `__WORKFLOW_ROOT__/templates/short_goal_message.md` is the only short `/goal` text sent to the controlled Codex.

Before writing any templated run file, use the `run-file-writer` skill and its `scripts/init_run_templates.sh <task-directory> <workflow-id> [spec-name ...]`. It copies every missing executor run file, leaves existing executor files unchanged, and always rebuilds `workflow_<workflow id>/prompt_for_supervisor.md` and `workflow_<workflow id>/prompt_for_supervisor_goal.md` from templates. After that, edit the copied or rebuilt files in place. Do not recreate templated run files from memory.

## Script Policy

Use scripts for fixed operations:

- The `run-file-writer` skill owns `init_control_files.sh` and `init_run_templates.sh`.
- `__WORKFLOW_ROOT__/scripts/locate_codex.sh` lists candidate Codex tmux panes so the supervisor can confirm the target pane before sending.
- `__WORKFLOW_ROOT__/scripts/inject_steer.sh` is the required and only allowed tmux input path for controlled Codex messages. It verifies the target pane, pastes text from a file, verifies the text landed in the input box, submits it, verifies it left the input box, and saves evidence under `temp/tmux-codex-supervisor` unless `STEER_EVIDENCE_DIR` overrides it.
- Outside `inject_steer.sh`, do not use any other tmux input path for controlled Codex messages.
- `__WORKFLOW_ROOT__/scripts/check_progress.sh` compares current progress evidence against the last saved check.
- `__WORKFLOW_ROOT__/scripts/check_done.sh` runs the completion check command.
- `__WORKFLOW_ROOT__/scripts/package_outputs.sh` packages output files.

Do not copy exact tmux key sequences into high-level task text. Keep exact terminal behavior in scripts and tests.
