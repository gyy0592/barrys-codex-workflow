---
name: run-file-writer
description: "Create final run files for a supervised Codex tmux workflow before execution. Use when Codex must write or update control/goal.md, control/constraint.md, workflow ID run_goal.md, workflow ID specs.md, per-spec evidence templates, or supervisor prompt files, and then stop before starting the controlled Codex."
---

# Run File Writer

Use this skill only for run-file creation before execution. Do not start tmux, do not send a `/goal` message to a controlled Codex, and do not run the controlled task.

Run files are durable task files read later by the supervisor or executor. The two executor control files are `control/goal.md` and `control/constraint.md`.

## Workflow

1. Read the user's task and task material. For a supervised tmux workflow, read the `tmux-codex-supervisor` skill before designing run files.
2. Create and maintain `workflow_<workflow id>/requirement_dialogue.md` while clarifying the task. Requirement dialogue means the written record of the user's task statements, Codex questions, user answers, and the current resolved requirement. Every time Codex asks the user whether the task should be one way or another way, append the question, the answer, and the updated conclusion to this file.
3. Ask the user direct clarification questions until the goal, constraints, task material, output, success checks, and spec list are clear enough to write final run files. When they are clear enough and the user has not already said to start writing run files, ask whether Codex should start writing the run files now.
4. Before writing run files, reread `workflow_<workflow id>/requirement_dialogue.md` and check for conflicts. A conflict means an earlier requirement says one thing and a later requirement changes it. The latest user answer wins, but Codex must report the conflict and ask the user to confirm the removal or replacement of the older requirement before writing run files.
5. Start writing run files only after the requirement dialogue has no unresolved conflicts and the user has confirmed that run-file writing may begin.
6. Create missing executor templates and rebuild supervisor prompt files with:

```bash
__RUN_FILE_WRITER_ROOT__/scripts/init_run_templates.sh <task-directory> <workflow-id> [spec-name ...]
```

   This script always rebuilds `workflow_<workflow id>/prompt_for_supervisor.md` and `workflow_<workflow id>/prompt_for_supervisor_goal.md` from templates. It leaves existing executor run files and evidence files unchanged.
7. Edit the copied files in place:
   - `control/goal.md`: task goal, input material, required outputs, progress evidence, completion standard.
   - `control/constraint.md`: user constraints, forbidden actions, checkpoint rules, review rules, autonomous execution boundaries, self-check rules.
   - `workflow_<workflow id>/run_goal.md`: stable run description.
   - `workflow_<workflow id>/specs.md`: ordered specs with success evidence and correction triggers.
   - `workflow_<workflow id>/requirement_dialogue.md`: final conflict-free requirement record used to write the run files.
   - per-spec files: `status.md`, `source_discovery.md`, `abstract_plan.md`, `evidence.md`, `review.md`, `bitter_lesson.md`.
   - `workflow_<workflow id>/prompt_for_supervisor.md`: rebuilt supervisor companion prompt for this workflow id.
   - `workflow_<workflow id>/prompt_for_supervisor_goal.md`: rebuilt short supervisor `/goal` prompt for this workflow id.
8. Edit the rebuilt supervisor prompt files for the workflow id. Do not write supervisor prompt files at the task root.
9. Run the autonomy review below. Fix files until it passes.
10. Stop and report the file list. Execution starts when the user manually starts the supervisor Codex in tmux and sets `prompt_for_supervisor_goal.md` as its `/goal`.

## Required Rules

- Do not encode user-review, user-choice, or user-approval gates in durable run files.
- `workflow_<workflow id>/requirement_dialogue.md` must exist before run files are written, and it must record all clarification questions and answers.
- If Codex asked the user whether the task should be one way or another way, the answer must be recorded in `workflow_<workflow id>/requirement_dialogue.md`.
- If the user did not explicitly say to start writing run files, Codex must ask whether it may start writing run files before it writes them.
- All requirement conflicts must be resolved before writing run files. Do not leave conflict repair for the supervisor phase.
- For supervised tmux run-file creation, `workflow_<workflow id>/prompt_for_supervisor.md` and `workflow_<workflow id>/prompt_for_supervisor_goal.md` are required run files. Do not report completion until both exist, are edited for the workflow id, and contain no `<...>` placeholders.
- Do not write `blocked`, `BLOCKED`, or `Current Blocker` into executor run files. Executor failures are correction issues with next actions.
- If the user already specified a method, tool, function, setting, output, metric, or constraint, write it directly into goal/specs. Do not turn it into an undecided choice.
- A spec is not complete if the executor changes, weakens, bypasses, replaces, or reinterprets any user-required method, tool, function, metric, output, or constraint. Difficulty, repeated failed attempts, slower speed, missing adapter code, or implementation complexity does not prove the user requirement is wrong.
- After execution starts, missing information must be resolved through source discovery, local inspection, allowed external sources, or a conservative option within constraints. Do not create a runtime user-response gate.

Allowed external sources means sources permitted by the user, the task, and the available tools. If no specific source is named, use local files first, then official documentation, repository documentation, papers, or public web pages only when the missing fact cannot be found locally and network use is allowed.

Conservative option means the option that is reversible, smallest in scope, least likely to delete or overwrite user data, does not add cost or permissions, and follows existing project defaults when those defaults are visible. Record the options considered and the chosen reason in evidence.

## Autonomy Review

Return `PASS` only when:

- no user-decided requirement is rewritten as undecided,
- `workflow_<workflow id>/requirement_dialogue.md` exists and has no unresolved conflicts,
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
