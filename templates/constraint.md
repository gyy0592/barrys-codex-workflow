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

- Before any non-trivial run, write an ETA. ETA means estimated time to finish.
- During runs, print or record useful speed information when available, such as throughput, CPU utilization, GPU utilization, memory use, and progress per unit time.
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
- Does this action need an ETA or speed information?
- Is there a reasonable acceleration step that should happen before this run?

After each meaningful action, the controlled Codex checks:

- Was progress evidence updated or made visible?
- Is the task complete under `control/goal.md`?
- Is a correction from the main Codex needed before continuing?
- Is a checkpoint git commit needed now?
- Did the run reveal slow speed, low CPU/GPU use, or another performance issue that requires stopping and fixing before continuing?
