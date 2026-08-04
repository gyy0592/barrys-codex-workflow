# Constraint

## Role Boundary

The controlled Codex executes the assigned task. The main Codex supervises and verifies.

## Forbidden Actions

List actions the controlled Codex must not take. Write "none" if there are no task-specific forbidden actions.

## Runtime Autonomy Definitions

Allowed external sources means sources permitted by the user, the task, and the available tools. If no specific source is named, use local files first, then official documentation, repository documentation, papers, or public web pages only when the missing fact cannot be found locally and network use is allowed.

Conservative option means the option that is reversible, smallest in scope, least likely to delete or overwrite user data, does not add cost or permissions, and follows existing project defaults when those defaults are visible. Record the options considered and the chosen reason in evidence.

## Default Runtime Rules

These rules apply to every task unless the user explicitly removes them.

- Maintain the current spec's `review_checklist.md`. Extract checklist rows from the current global/project instruction files, `control/goal.md`, `control/constraint.md`, `run_goal.md`, `specs.md`, current `abstract_plan.md`, and observed evidence where applicable.
- Before implementation, before any expensive or hard-to-reverse run, and before review, update `review_checklist.md` and make every applicable controlling row `PASS`. If a row is `FAIL` or `INSUFFICIENT_INFORMATION`, stop that path and return to source discovery or correction.
- If the task uses a user-required method, tool, metric, output, original repository capability, accelerated path, or high-performance implementation, do not substitute a slower, simpler, ordinary, unfused, or different path unless the checklist records user authorization or original-path failure handling evidence.
- Original-path failure handling evidence means the command, working location, exit result, complete error source, environment/dependency/path/version/compatibility inspection, fix, and rerun result.
- Before any non-trivial run, write an ETA. ETA means estimated time to finish.
- During runs, print or record useful speed information when available, such as throughput, CPU utilization, GPU utilization, memory use, and progress per unit time.
- When the executor monitors a running program and the program reports an ETA, set the next monitoring interval to `max(ETA/5, 5 minutes)`, using the latest remaining ETA and the same interval policy at every subsequent check.
- When no ETA is available but the run is stable—no observed drift, expected progress or wait state, and a low likelihood of near-term error—use a 2–5 minute monitoring interval, normally 5 minutes.
- After a failure, correction, unexpected output, drift, stalled progress, bad ETA, or other elevated-risk signal, use active shorter monitoring until the run is stable again; do not apply the stable-run interval during that correction window.
- Before starting expensive or long-running work, first inspect whether the code or command can be made faster in a reasonable way.
- Prefer a faster correct implementation over a slower correct implementation when the speedup matters for the task.
- If a run is much slower than expected, GPU or CPU use is clearly low, or logs show an obvious performance problem, and there is likely room to optimize, stop or kill the run, inspect the output and logs, fix or accelerate the cause, then rerun.
- Do not keep a bad long-running job alive merely because it is still making some progress.

## Git Commit Rules

- Create checkpoint git commits after stable completed work.
- Before each commit, run `git status --short`.
- Stage only files required for the current task.
- Do not stage unrelated user files.
- If relevant and unrelated files cannot be separated safely, stop and report the exact paths instead of committing.

## Self-Check Rules

Before each meaningful action, the controlled Codex checks:

- Does the action serve `control/goal.md`?
- Does the action violate this constraint file?
- Will the action produce or improve observable evidence?
- Is the current `review_checklist.md` updated for this action?
- Does this action need an ETA or speed information?
- Is there a reasonable acceleration step that should happen before this run?

After each meaningful action, the controlled Codex checks:

- Was progress evidence updated or made visible?
- Is the task complete under `control/goal.md`?
- Is a correction from the main Codex needed before continuing?
- Is a checkpoint git commit needed now?
- Did any checklist row become `FAIL` or `INSUFFICIENT_INFORMATION` because of this action?
- Did the run reveal slow speed, low CPU/GPU use, or another performance issue that requires stopping and fixing before continuing?
