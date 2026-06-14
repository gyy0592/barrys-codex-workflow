---
name: tmux-codex-supervisor
description: "Use when the main Codex must prepare final run files, start, or supervise one controlled Codex in tmux. Do not use inside the controlled Codex; the startup message to the controlled Codex only points to control/goal.md and control/constraint.md."
---

# tmux Codex Supervisor

Use this skill only when the current Codex is the main Codex acting as supervisor.

Codex is the AI assistant. The main Codex is the supervisor in the current chat. The controlled Codex is the executor in a tmux window. tmux is a terminal tool that keeps sessions running. A control file is a task file read first by the controlled Codex. A run file is a durable file written before execution, such as `control/goal.md`, `control/constraint.md`, `workflow_<workflow id>/run_goal.md`, and `workflow_<workflow id>/specs.md`. The controlled Codex receives only the two control-file paths in its startup message, then reads the spec, source discovery, evidence, or status files named by those control files and the active spec.

Workflow root is `__WORKFLOW_ROOT__`. Use this absolute path even when the current task is in another directory.

## Trigger Strategy

Only the outer `tmux-codex-supervisor` skill should be implicitly triggered.

The helper names below are internal sections, not independent skills. Do not create separate implicitly triggered skills for `gen-goal`, `gen-constraint`, `gen-specs`, `gen-supervisor-prompts`, `review-run-files-for-autonomy`, `start-supervised-run`, `monitor-run`, or `persist-user-requirement` unless a later implementation disables their implicit invocation.

The controlled Codex must not use this skill. It receives only the short `/goal` message that points to `control/goal.md` and `control/constraint.md`.

## Non-Negotiable Design

- Use exactly two active control files for the controlled Codex: `control/goal.md` and `control/constraint.md`.
- `control/goal.md` contains the task goal, input material, output requirement, progress requirement, and completion standard.
- `control/constraint.md` contains limits, forbidden actions, self-check rules, checkpoint rules, review rules, and autonomous execution boundaries.
- The short `/goal` message only points the controlled Codex to the two control files. Those control files may point to the active spec and required evidence files.
- The main Codex supervises; the controlled Codex executes.
- Run-file creation writes final run files and checks that they support autonomous execution. It does not start the controlled Codex or long-running task work.
- Execution starts only after a separate execution request. Do not encode user-review, user-choice, or user-approval gates in durable run files.

## Skill Router

Before acting, classify the latest user request and select one helper path:

- Use `gen-goal`, `gen-constraint`, `gen-specs`, `gen-supervisor-prompts`, then `review-run-files-for-autonomy` when the user asks to create final run files before execution.
- Use `start-supervised-run` when the user explicitly asks to start execution and final run files already exist.
- Use `monitor-run` when a controlled Codex is already running and the user asks to supervise, continue supervising, check progress, correct drift, or verify completion.
- Use `persist-user-requirement` when a later user message changes execution permission, stop conditions, required settings, or completion criteria.

The router must not send internal helper names to the controlled Codex. The controlled Codex startup message should contain only control-file paths.

## Helper: gen-goal

Use this helper only as the main Codex supervisor while creating or updating final run files.

Output for the controlled Codex: `control/goal.md`.

Write:

- the task goal,
- required input material,
- required outputs,
- progress evidence,
- completion standard.

Do not write:

- user-review gates,
- "wait for user confirmation",
- requirements that exist only in supervisor chat memory.

Do not trigger this helper while the controlled Codex is executing a spec, while merely monitoring evidence, or while sending a correction that does not change the goal file.

## Helper: gen-constraint

Use this helper only as the main Codex supervisor while creating or updating final run files.

Output for the controlled Codex: `control/constraint.md`.

Write:

- user constraints,
- forbidden actions,
- checkpoint commit rules,
- no-context review rules,
- autonomous execution boundaries,
- definitions for `allowed external sources` and `conservative option`,
- self-check rules.

Do not put the whole workflow document into `control/constraint.md`. Write only constraints and checks the controlled Codex must obey.

Do not trigger this helper when the controlled Codex is doing ordinary execution or when the supervisor only needs to read evidence or status.

## Helper: gen-specs

Use this helper only as the main Codex supervisor while turning the total goal into checkable specs.

Output for the supervisor and controlled Codex: `workflow_<workflow id>/specs.md` and current spec files.

Each spec must include purpose, required information, expected outputs, observable success evidence, fail conditions, and completion checks.

Hard rule for already-decided user content:

```text
If the user already specified a data field, setting, output, or constraint, write it directly into goal/specs. Do not create a spec whose purpose is to decide it again.
```

Clarifying questions are allowed only before final run files are written, only when missing information prevents writing executable goal/specs, and only for the missing point. Do not ask again about user-decided content.

After final run files are written, do not ask the user for choices, approvals, or review. During execution, missing information must send the controlled Codex back to source discovery, local inspection, allowed external sources, conservative options within constraints, evidence, and continuation.

Allowed external sources means sources permitted by the user, the task, and the available tools. If no specific source is named, use local files first, then official documentation, repository documentation, papers, or public web pages only when the missing fact cannot be found locally and network use is allowed.

Conservative option means the option that is reversible, smallest in scope, least likely to delete or overwrite user data, does not add cost or permissions, and follows existing project defaults when those defaults are visible. Record the options considered and the chosen reason in evidence.

Do not trigger this helper while the controlled Codex is executing the current spec. If a running spec fails, update the current spec or create a fix spec instead of regenerating all specs.

## Helper: gen-supervisor-prompts

Use this helper only as the main Codex supervisor while creating or updating supervisor start files.

Output for the supervisor only: `prompt_for_supervisor.md`, `prompt_for_supervisor_goal.md`, and staged supervisor paste files.

Every supervisor start path must say:

- the supervisor does not do the controlled task,
- the supervisor sends only the short `/goal` to the controlled Codex,
- the supervisor keeps supervising until completion is proved or the user explicitly stops,
- the supervisor must not mark its own goal complete or blocked because the controlled Codex reports blocked, a run fails, information is missing, or a review fails,
- a stop condition means stop the bad path, record evidence, update the current spec or create a fix spec, then continue,
- later user requirements that change permission, stop conditions, settings, or completion criteria must be written into durable control files before relying on them.

Do not send supervisor prompt files to the controlled Codex.

## Helper: review-run-files-for-autonomy

Use this helper only after final run files are written and before execution starts.

Check:

- no user-decided requirement is rewritten as undecided,
- durable run files contain no `ask the user`, `wait for user review`, or `user approval needed` gates,
- durable run files do not ask for user review, choices, or approval,
- file ownership is clear,
- supervisor-only files are not sent to the controlled Codex,
- controlled files do not depend on supervisor chat memory,
- `control/goal.md`, `control/constraint.md`, `specs.md`, and `run_goal.md` do not conflict,
- runtime terms such as `allowed external sources` and `conservative option` are defined in `control/constraint.md` or in the same durable run file that uses them,
- lower-priority files cannot override higher-priority control files.

Return `PASS` only when the files are sufficient for autonomous execution. Return `FAIL` and fix the run files before execution when any check fails.

## Helper: start-supervised-run

Use this helper only after the user explicitly asks to start execution.

Before starting:

- confirm final run files exist,
- confirm `review-run-files-for-autonomy` passed,
- checkpoint final run files when they must be preserved,
- start one controlled Codex in tmux,
- send only the short `/goal` that points to `control/goal.md` and `control/constraint.md`,
- verify delivery.

Do not start execution when the user only asked to create run files, discuss a plan, or review files.

## Helper: monitor-run

Use this helper only when a controlled Codex is already running.

The supervisor may read control files, workflow files, spec files, evidence files, status files, review files, git status/log/diff/show output, tmux captures, transcripts, queue output, logs, metrics, manifests, and other incremental evidence files.

The supervisor must not read full project source code and must not implement task code. If source code understanding is needed, instruct the controlled Codex to inspect the relevant code and report evidence.

If the controlled Codex is stable and working within the current task step, do not interrupt it frequently. Stable means it is reading required sources, writing expected evidence, running an expected command, monitoring an expected job, or waiting on a legitimate long-running step. When stable, monitor at a low frequency, usually once every 2 to 10 minutes.

If the controlled Codex reports blocked, a run fails, information is missing, or a review fails, do not mark the supervisor goal blocked. Force the controlled Codex to continue the correction loop: source discovery, local inspection, allowed external sources, conservative option when an option is unavoidable, concrete fix, test, benchmark when relevant, evidence, checkpoint, no-context review, and next action.

## Helper: persist-user-requirement

Use this helper only when a later user message changes execution permission, stop conditions, required settings, or completion criteria.

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

If relevant and unrelated files cannot be separated safely, stop the commit and report the exact paths.

After each checkpoint commit, require the current spec evidence to record:

```text
git status --short
git log -1 --oneline
git show --stat --oneline --name-status HEAD
```

## No-Context Review Rule

After each checkpoint commit, the supervisor must run no-context review before the workflow can move to the next spec.

Default review count:

- ordinary spec: at least two no-context reviewers,
- high-risk spec: three to five no-context reviewers when correctness, constraints, git scope, tests, or failure risk need separate review.

High-risk spec means the completed step touches destructive operations, git history, user data, paid or cloud resources, security or permissions, broad refactors, long expensive runs, ambiguous requirements, or weak test coverage.

The reviewers must receive only the current spec, relevant goal/constraint excerpts, source discovery, abstract plan, evidence, status, latest git evidence, relevant diff, and explicit review instructions.

The reviewers must check:

- whether the current spec is truly complete,
- drift from `control/goal.md`,
- violations of `control/constraint.md`,
- unrelated files in the commit,
- skipped source discovery, abstract plan, evidence, checkpoint commit, or review,
- unnecessary extra work,
- failure risk.

If a reviewer finds a real problem, fix the current spec, make a new checkpoint commit, and run fresh no-context review. If a reviewer only gives style preference, unsupported nitpicking, or a claim contradicted by file evidence, record why it is ignored and continue.

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

Use these templates for fixed prompt and run-file shapes:

- `__WORKFLOW_ROOT__/templates/prompt_for_run_prep.md` is the main-Codex template for final run-file creation.
- `__WORKFLOW_ROOT__/templates/prompt_for_supervisor.md` is the supervisor's long companion file.
- `__WORKFLOW_ROOT__/templates/prompt_for_supervisor_goal.md` is the supervisor's short `/goal` text.
- `__WORKFLOW_ROOT__/templates/short_goal_message.md` is the only short `/goal` text sent to the controlled Codex.
- `__WORKFLOW_ROOT__/templates/run_goal.md`, `__WORKFLOW_ROOT__/templates/specs.md`, `__WORKFLOW_ROOT__/templates/source_discovery.md`, `__WORKFLOW_ROOT__/templates/abstract_plan.md`, `__WORKFLOW_ROOT__/templates/evidence.md`, `__WORKFLOW_ROOT__/templates/review.md`, and `__WORKFLOW_ROOT__/templates/bitter_lesson.md` define run evidence files.

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
