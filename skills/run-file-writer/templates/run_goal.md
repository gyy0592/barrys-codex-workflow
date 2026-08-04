# Run Goal

## Canonical Paths

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder before reporting completion. Every actionable cross-file reference in the final file must use a resolved absolute path; do not use bare control, workflow, spec, evidence, review, or status paths.

## Workflow Id

Write the workflow id here.

## User Task

Restate the user's task in direct language. Do not add extra goals.

## Required Input Material

List every file, folder, repo, paper, skill, web source, or user message the future controlled Codex must read or inspect.

## Required Output

List the files, reports, code changes, experiment outputs, logs, commits, or summaries the run must produce.

## Success Standard

State what proves the whole run succeeded. Each item must be checkable from files or command output.

## Known Non-Goals

List work that must not be done in this run.

## Runtime Autonomy

After execution starts, complete the run autonomously using the final files at `{{CONTROL_ROOT}}/goal.md`, `{{CONTROL_ROOT}}/constraint.md`, `{{WORKFLOW_ROOT}}/specs.md`, the current spec files under `{{CURRENT_SPEC_ROOT}}`, source discovery, and evidence.

If a choice is missing during execution, choose a conservative option as defined in `{{CONTROL_ROOT}}/constraint.md` and allowed by the active constraints, write the choice and reason into `{{CURRENT_SPEC_ROOT}}/evidence.md`, and continue.

## Dependency-Aware Scheduling

The run follows the declared dependency DAG, not a global serial queue. Each spec waits only for its own unmet direct prerequisites. At every scheduling point, launch all ready, non-conflicting, resource-compatible specs concurrently up to actual available capacity; preserve declared order only when capacity is insufficient. When a spec finishes, recompute readiness and immediately fill released capacity. Do not wait for unrelated specs or an entire wave, and do not encode a fixed GPU-count branch.

## File Ownership And Priority

This file is a shared run description. The main Codex writes it during run-file creation. The supervisor and controlled Codex may read it. The supervisor checks it for consistency with higher-priority files.

Supervisor-only restrictions in supervisor prompt files do not become executor restrictions here. If higher-priority files require outputs, jobs, experiments, or task submissions, the controlled Codex must do them during execution.

For execution, use this priority:

```text
latest user instruction written into `{{CONTROL_ROOT}}/goal.md` or `{{CONTROL_ROOT}}/constraint.md` > `{{CONTROL_ROOT}}/constraint.md` > `{{CONTROL_ROOT}}/goal.md` > current spec under `{{CURRENT_SPEC_ROOT}}` > `{{WORKFLOW_ROOT}}/specs.md` > `{{WORKFLOW_ROOT}}/run_goal.md`
```

If this file appears to require stopping but a higher-priority file at `{{CONTROL_ROOT}}/goal.md` or `{{CONTROL_ROOT}}/constraint.md` authorizes continuation, continue and record the reason in `{{CURRENT_SPEC_ROOT}}/evidence.md`.
