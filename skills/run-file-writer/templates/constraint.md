# Constraint

## Canonical Paths

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder before reporting completion. Every cross-file reference in this constraint file must use a resolved absolute path from this map; bare control, workflow, spec, evidence, review, or status paths are invalid.

## Role Boundary

The controlled Codex executes the assigned task. The main Codex supervises and verifies.

## Forbidden Actions

List actions the controlled Codex must not take. Write "none" if there are no task-specific forbidden actions.

## Runtime Autonomy Definitions

Allowed external sources means sources permitted by the user, the task, and the available tools. If no specific source is named, use local files first, then official documentation, repository documentation, papers, or public web pages only when the missing fact cannot be found locally and network use is allowed.

Conservative option means the option that is reversible, smallest in scope, least likely to delete or overwrite user data, does not add cost or permissions, and follows existing project defaults when those defaults are visible. Record the options considered and the chosen reason in evidence.

## Default Runtime Rules

These rules apply to every task unless the user explicitly removes them.

- Maintain `{{CURRENT_SPEC_ROOT}}/review_checklist.md`. Extract checklist rows from the current global/project instruction files, `{{CONTROL_ROOT}}/goal.md`, `{{CONTROL_ROOT}}/constraint.md`, `{{WORKFLOW_ROOT}}/run_goal.md`, `{{WORKFLOW_ROOT}}/specs.md`, `{{CURRENT_SPEC_ROOT}}/abstract_plan.md`, and observed evidence under `{{CURRENT_SPEC_ROOT}}` where applicable.
- Before implementation, before any expensive or hard-to-reverse run, and before review, update `{{CURRENT_SPEC_ROOT}}/review_checklist.md` and make every applicable controlling row `PASS`. If a row is `FAIL` or `INSUFFICIENT_INFORMATION`, stop that path and return to source discovery or correction.
- If the task uses a user-required method, tool, metric, output, original repository capability, accelerated path, or high-performance implementation, do not substitute a slower, simpler, ordinary, unfused, or different path unless the checklist records user authorization or original-path failure handling evidence.
- Original-path failure handling evidence means the command, working location, exit result, complete error source, environment/dependency/path/version/compatibility inspection, fix, and rerun result.
- Before any non-trivial run, write an ETA. ETA means estimated time to finish.
- During runs, print or record useful speed information when available, such as throughput, CPU utilization, GPU utilization, memory use, and progress per unit time.
- Before starting expensive or long-running work, first inspect whether the code or command can be made faster in a reasonable way.
- Prefer a faster correct implementation over a slower correct implementation when the speedup matters for the task.
- If a run is much slower than expected, GPU or CPU use is clearly low, or logs show an obvious performance problem, and there is likely room to optimize, stop or kill the run, inspect the output and logs, fix or accelerate the cause, then rerun.
- Do not keep a bad long-running job alive merely because it is still making some progress.

## Dependency-Aware Scheduling

- Before execution, record a dependency DAG or equivalent table for every spec and runnable task. Each entry must identify `depends_on`, concrete prerequisite files/interfaces/tests, the verification command, the pass condition, and the release condition.
- A task waits only for its own unmet direct prerequisites. A review, checkpoint, or failure gate blocks only the task or dependency wave that directly depends on it; it must not block an independent ready task.
- At every scheduling point, compute the ready set and launch all ready, non-conflicting, resource-compatible tasks concurrently up to the actual available capacity. Preserve declared order only when capacity is insufficient to choose among ready tasks.
- When a task finishes, immediately recompute the ready set and fill released capacity. Do not wait for unrelated tasks or an entire wave, and do not encode a fixed GPU-count branch. Record a concrete reason for every matching resource left unused.

## Git Commit Rules

- Create checkpoint git commits after stable completed work.
- Before each commit, run `git status --short`.
- Stage only files required for the current task.
- Do not stage unrelated user files.
- If relevant and unrelated files cannot be separated safely, stop and report the exact paths instead of committing.

## Self-Check Rules

Before each meaningful action, the controlled Codex checks:

  - Does the action serve `{{CONTROL_ROOT}}/goal.md`?
- Does the action violate this constraint file?
- Will the action produce or improve observable evidence?
  - Is the current `{{CURRENT_SPEC_ROOT}}/review_checklist.md` updated for this action?
- Does this action need an ETA or speed information?
- Is there a reasonable acceleration step that should happen before this run?

After each meaningful action, the controlled Codex checks:

- Was progress evidence updated or made visible?
- Is the task complete under `{{CONTROL_ROOT}}/goal.md`?
- Is a correction from the main Codex needed before continuing?
- Is a checkpoint git commit needed now?
- Did any checklist row become `FAIL` or `INSUFFICIENT_INFORMATION` because of this action?
- Did the run reveal slow speed, low CPU/GPU use, or another performance issue that requires stopping and fixing before continuing?
