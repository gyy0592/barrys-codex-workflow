# Goal: Speed Detection And Frame-Update Detection For fps_mock

## Task Goal

Work in `/home/yguo173/Programs/game/fps/fps_mock`.

Implement and verify a new aim-assist algorithm whose main mechanism is speed detection plus frame-update detection.

Use these workflow files:

- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/run_goal.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/specs.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_01_source_discovery.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_02_method_list.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_03_method_loop.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_04_final_analysis.md`

The algorithm must handle this hard case:

- Sometimes the algorithm sees a frame that has not really changed.
- Sometimes one or more camera updates are missed between observations.
- Speed detection needs valid updated frames.
- Frame-update detection needs a speed prediction.
- These two problems affect each other, so the algorithm must track both together.
- The algorithm must respond quickly. It must not solve the problem by adding a long fixed sleep after each command.

The workflow must use a one-method-at-a-time loop:

1. Implement one clearly specified method.
2. Run the required comparison against `a2`.
3. If the method loses to `a2`, inspect the recorded diagnostics and fix that method when the evidence shows a fixable cause.
4. If the method wins against `a2`, inspect remaining problems and continue improving it until the supervisor can prove there is no meaningful remaining improvement inside the speed-detection approach.
5. Move to the next method only after the current method is either fixed as far as evidence supports or has a recorded hard failure reason.

Do not declare that the speed-detection approach cannot beat `a2` until at least 10 completely different specified methods have been fully implemented, evaluated, diagnosed, and recorded.

## Required Algorithm Behavior

The new algorithm must:

1. Estimate target movement speed from observed `x_screen` history after accounting for commands already issued by the algorithm.
2. Decide whether the current observation is a real updated frame, an unchanged frame, or a suspected dropped-frame case.
3. Use only valid updated observations to update the speed estimate.
4. Treat unchanged observations without repeatedly sending the same correction.
5. Keep enough internal evidence to explain every command:
   - current `x_screen`,
   - estimated speed,
   - number of recent observations considered,
   - number of observations accepted as valid updates,
   - number of observations rejected as unchanged,
   - whether dropped frames were suspected,
   - predicted current frame class,
   - command sent this step.

## Required Inputs

Use both local project files and internet search as required source material.

Local project files:

- `original_prompt.md`
- `simulator/algo.py`
- `simulator/simulator.py`
- `simulator/clock.py`
- `run_demo.py`
- `simulator/algos/a/`
- `simulator/algos/c/`
- `tools/aggregate_summaries.py`
- existing tests in `tests/`

Internet search is mandatory. It must be used to look up relevant approaches for velocity estimation, stale-frame or repeated-frame detection, dropped-frame handling, robust filtering, and fast online tracking. Internet findings must be combined with local project facts. Internet findings alone are not enough to justify an implementation change.

## Required Outputs

Produce the smallest useful change set that proves the idea:

1. A sequence of new algorithm methods, handled one at a time.
2. Any minimal recorder or summary additions needed to persist the algorithm's speed and frame-update diagnostics.
3. A focused test or check that proves the algorithm obeys the observation rules and records diagnostics.
4. Experiment output comparing at least:
   - `sleep`,
   - `a2`,
   - `a4`,
   - `c1`,
   - the new algorithm.
5. A written evidence file under the workflow directory recording commands run, result paths, key metrics, failures, fixes, and final conclusion.
6. A written internet-source-discovery section recording search queries, links, facts extracted, and which method or repair each fact supports.

Every method attempt must be recorded before the next method starts.

## Required Metrics

Record and report these metrics for the new algorithm:

- `velocity_estimate`: the algorithm's current speed estimate.
- `velocity_window_size`: how many recent observations were considered for speed estimation.
- `velocity_valid_update_count`: how many observations in that window were accepted as real updates.
- `unchanged_frame_count`: how many observations were classified as unchanged.
- `handled_unchanged_frame_count`: how many unchanged observations were handled without repeating a correction.
- `suspected_dropped_frame_count`: how many times the algorithm suspected one or more missed camera updates.
- `predicted_frame_update_state`: the algorithm's current classification, using clear values such as `updated`, `unchanged`, or `dropped_suspected`.
- `delta_cam`: command sent by the algorithm.
- `wall_time_ns`: compute time per step.
- `median_abs_e`: median absolute aiming error.
- `final_quarter_median`: median absolute aiming error in the last quarter of the run.
- `diverged`: whether the run diverged.

If simulator truth labels are available outside the algorithm, use them only for offline evaluation. Do not feed truth labels into the algorithm.

## Completion Standard

The task is complete only when all of these are true:

1. The new algorithm can be run through the normal project entry point.
2. The algorithm does not use forbidden truth data.
3. The speed and frame-update diagnostic metrics are recorded.
4. The required comparison run has completed.
5. Existing relevant tests pass, or any failure is explained with direct evidence.
6. If a method is worse than `a2`, diverges, or fails to converge, the evidence explains:
   - whether speed was estimated too high or too low,
   - whether too few valid frames were available,
   - whether unchanged frames were misclassified,
   - whether dropped frames corrupted the speed estimate,
   - whether fast response conflicted with stability,
   - the smallest next fix supported by evidence.
7. If any method beats `a2`, remaining problems have been inspected and fixed until evidence shows no meaningful remaining improvement inside the speed-detection approach.
8. If no method beats `a2`, at least 10 completely different specified methods have full result rows and failure analyses.

Do not mark the task complete only because code was written. Completion requires measured evidence.
