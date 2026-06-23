# Constraints: Speed Detection And Frame-Update Detection For fps_mock

## Role Boundary

The controlled Codex executes the task. The supervisor monitors and corrects drift. The controlled Codex must use these files as durable instructions and must not rely on supervisor chat memory.

## Hard Algorithm Limits

The new algorithm must not read or depend on simulator truth data.

Forbidden algorithm inputs:

- `x_world`: true enemy world position.
- `cam_angle`: true camera angle.
- true `frame_type`.
- `t_frame`.
- `t_sample`.
- simulator internal time.
- camera phase.
- any simulator-side A/B truth label.

Allowed algorithm inputs:

- current `x_screen`,
- previous `x_screen` values stored by the algorithm,
- commands previously emitted by the algorithm,
- internal counters and internal state owned by the algorithm,
- project configuration only when the existing algorithm interface already allows the same kind of configuration without exposing simulator truth.

Offline evaluation may compare algorithm predictions with simulator truth labels, but that comparison must happen outside the algorithm.

## Forbidden Solution Types

Do not implement PID. PID means a three-part controller that combines proportional, integral, and derivative terms as the main control law.

Do not implement reinforcement learning. Reinforcement learning means a trained policy or model that learns actions from reward feedback.

Do not solve the task by adding a long fixed sleep. A short existing loop delay may remain if already present in the simulator, but the new algorithm's main solution must be speed detection plus frame-update detection.

Do not replace the simulator architecture, rewrite unrelated algorithms, or refactor unrelated files.

Internet search is required. The executor must combine local project evidence with internet search before finalizing method design and before declaring no further improvement remains.

Do not let the executor invent replacement methods during execution. The methods must be the methods listed in the active spec. The executor may make evidence-supported repairs to the current method, but may not skip, reorder, rename, or replace methods.

## Response-Speed Requirement

The algorithm must stay fast enough for the existing simulator budget.

Record compute time through the existing `wall_time_ns` path or an equivalent existing path. The default target is no worse than the existing 5 ms per-iteration budget. If the algorithm exceeds that budget, record the evidence and reduce the implementation before claiming completion.

## Required Checks Before Writing Code

Before implementation, inspect the existing algorithm interface, run entry point, recorder path, and closest existing algorithms.

Required source checks:

- how algorithms are registered,
- what `compute(x_screen)` is allowed to see,
- how scalar metrics are written,
- how frame truth is stored for offline evaluation,
- how existing tests check the observation contract.

Record the checked files and the conclusion in evidence before changing implementation files.

## Diagnostic Evidence Rules

Every experiment report for the new algorithm must include:

- velocity estimates,
- how many observations were considered,
- how many observations were accepted as valid updates,
- how many observations were rejected as unchanged,
- how many unchanged observations were handled without repeating correction,
- how many dropped-frame cases were suspected,
- the final aiming-error metrics,
- whether the run diverged.

Each method must produce one complete result row before the executor starts the next method. The result row must include:

- `method_id`,
- `method_name`,
- `run_path`,
- `median_abs_e`,
- `final_quarter_median`,
- `diverged`,
- `mean_wall_time_ns`,
- `p99_wall_time_ns`,
- `velocity_estimate_mean`,
- `velocity_estimate_p50`,
- `velocity_estimate_p90`,
- `velocity_valid_update_count`,
- `unchanged_frame_count`,
- `handled_unchanged_frame_count`,
- `suspected_dropped_frame_count`,
- `beats_sleep`,
- `beats_a2`,
- `failure_reason`,
- `next_fix_or_stop_reason`.

If the algorithm diverges, fails to converge, or performs worse than `a2`, do not guess. Inspect the recorded diagnostics and answer:

- which file or program produced the run,
- what the algorithm expected to happen,
- what actually happened,
- which diagnostic detected the difference,
- whether the cause was speed-estimation error, frame-update misclassification, dropped-frame handling, or command-response instability,
- what smallest change is supported by the evidence.

If a method beats `a2`, do not stop immediately. Inspect the remaining diagnostics for speed error, unchanged-frame mistakes, dropped-frame mistakes, response delay, unstable final-quarter behavior, and compute-time cost. Continue fixing the winning method until the evidence shows no meaningful remaining improvement inside the speed-detection approach.

The executor may say "this approach cannot beat a2" only after at least 10 completely different listed methods have been implemented, run, diagnosed, and recorded.

## Conservative Option

Conservative option means the reversible, smallest-scope option that follows existing project style, avoids deleting or overwriting user data, avoids extra permissions or cost, and can be tested with the existing project commands.

When multiple implementation choices are possible, choose the conservative option and record the other options considered.

## Required Local And Internet Sources

Use local project files first to understand the simulator, algorithm interface, metrics, and existing results.

Use internet search as a required second source. Search for relevant public material on:

- online velocity estimation,
- repeated-frame or stale-frame detection,
- dropped-frame detection,
- robust filters for noisy motion,
- low-latency tracking control,
- prediction under delayed observations.

For every internet source used, record:

- search query,
- URL,
- source title,
- fact extracted,
- which method, repair, or diagnostic decision the fact supports,
- whether the fact was confirmed against local project behavior.

Internet material must not override local code facts. If internet advice conflicts with this project's simulator or user constraints, follow the local project and user constraints, then record the conflict.

## File Scope

Expected touched files should be limited to:

- a new algorithm file or a small addition near existing algorithm wrappers,
- algorithm registration code,
- minimal recorder or summary code needed for diagnostics,
- minimal tests,
- workflow evidence files.

Do not include unrelated files in commits.

The existing untracked file `report/fast_cfg_report.md` is unrelated unless the user later explicitly makes it part of this task. Do not stage or modify it for this task.

## Git Checkpoint Rule

After each stable completed step, create a checkpoint commit unless the user explicitly forbids commits.

Before committing:

- run `git status --short`,
- separate relevant files from unrelated files,
- stage only task-relevant files,
- do not stage still-changing experiment outputs unless the current evidence requires them.

After committing, record:

- `git status --short`,
- `git log -1 --oneline`,
- `git show --stat --oneline --name-status HEAD`.

## Review Rule

After each checkpoint commit, perform no-context review before moving to the next major step.

Review must check:

- whether the current step is complete,
- whether constraints were violated,
- whether forbidden truth data was used,
- whether unrelated files were included,
- whether diagnostics are sufficient to explain failure,
- whether the result actually supports the next step.

If review finds a real problem, fix the current step, commit again, and run fresh review.

## Stop Conditions

Do not stop because a first attempt fails. A failed run means enter a correction loop:

1. Record what failed.
2. Inspect diagnostics and direct evidence.
3. Identify whether the failure came from speed estimation, frame-update classification, dropped-frame handling, or command instability.
4. Make the smallest evidence-supported fix.
5. Rerun the relevant check.

Stop only when the completion standard in `control/goal.md` is met, or when higher-priority instructions explicitly stop the task.
