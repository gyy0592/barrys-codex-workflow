---
name: run-file-writer
description: "Create final run files for a supervised Codex tmux workflow before execution. Use when Codex must write or update control/goal.md, control/constraint.md, workflow_<id>/run_goal.md, workflow_<id>/specs.md, per-spec evidence templates, or supervisor prompt files, and then stop before starting the controlled Codex."
---

# Run File Writer

Use this skill only for run-file creation before execution. Do not start tmux, do not send a `/goal` message to a controlled Codex, and do not run the controlled task.

Run files are durable task files read later by the supervisor or executor. The two executor control files are `control/goal.md` and `control/constraint.md`.

## Workflow

1. Read the user's task and task material.
2. Create missing executor templates and rebuild supervisor prompt files with:

```bash
__RUN_FILE_WRITER_ROOT__/scripts/init_run_templates.sh <task-directory> <workflow-id> [spec-name ...]
```

   This script always rebuilds `workflow_<workflow id>/prompt_for_supervisor.md` and `workflow_<workflow id>/prompt_for_supervisor_goal.md` from templates. It leaves existing executor run files and evidence files unchanged.
3. Edit the copied files in place:
   - `control/goal.md`: task goal, input material, required outputs, progress evidence, completion standard.
   - `control/constraint.md`: user constraints, forbidden actions, checkpoint rules, review rules, autonomous execution boundaries, self-check rules.
   - `workflow_<workflow id>/run_goal.md`: stable run description.
   - `workflow_<workflow id>/specs.md`: ordered specs with success evidence and correction triggers.
   - per-spec files: `status.md`, `source_discovery.md`, `abstract_plan.md`, `evidence.md`, `review.md`, `bitter_lesson.md`.
   - `workflow_<workflow id>/prompt_for_supervisor.md`: rebuilt supervisor companion prompt for this workflow id.
   - `workflow_<workflow id>/prompt_for_supervisor_goal.md`: rebuilt short supervisor `/goal` prompt for this workflow id.
4. Edit the rebuilt supervisor prompt files for the workflow id. Do not write supervisor prompt files at the task root.
5. Run the autonomy review below. Fix files until it passes.
6. Stop and report the file list. Execution starts only after a separate user request.

## Required Rules

- Do not encode user-review, user-choice, or user-approval gates in durable run files.
- Do not write `blocked`, `BLOCKED`, or `Current Blocker` into executor run files. Executor failures are correction issues with next actions.
- If the user already specified a method, tool, function, setting, output, metric, or constraint, write it directly into goal/specs. Do not turn it into an undecided choice.
- A spec is not complete if the executor changes, weakens, bypasses, replaces, or reinterprets any user-required method, tool, function, metric, output, or constraint. Difficulty, repeated failed attempts, slower speed, missing adapter code, or implementation complexity does not prove the user requirement is wrong.
- After execution starts, missing information must be resolved through source discovery, local inspection, allowed external sources, or a conservative option within constraints. Do not create a runtime user-response gate.

Allowed external sources means sources permitted by the user, the task, and the available tools. If no specific source is named, use local files first, then official documentation, repository documentation, papers, or public web pages only when the missing fact cannot be found locally and network use is allowed.

Conservative option means the option that is reversible, smallest in scope, least likely to delete or overwrite user data, does not add cost or permissions, and follows existing project defaults when those defaults are visible. Record the options considered and the chosen reason in evidence.

## Autonomy Review

Return `PASS` only when:

- no user-decided requirement is rewritten as undecided,
- no run file asks for user review, choices, or approval after execution starts,
- controlled-execution files do not depend on supervisor chat memory,
- `control/goal.md`, `control/constraint.md`, `specs.md`, and `run_goal.md` do not conflict,
- runtime terms such as `allowed external sources` and `conservative option` are defined where used,
- lower-priority files cannot override higher-priority control files.

Return `FAIL` and fix the run files before execution when any check fails.

## Bundled Resources

- `templates/`: run-file templates.
- `scripts/init_run_templates.sh`: creates missing executor run files, leaves existing executor files unchanged, and rebuilds workflow-local supervisor prompt files.
- `scripts/init_control_files.sh`: creates only `control/goal.md` and `control/constraint.md` when needed.
