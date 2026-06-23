# Run Goal: Speed Detection And Frame-Update Detection For fps_mock

## Controlled Task

The controlled Codex must execute the workflow for:

`/home/yguo173/Programs/game/fps/fps_mock`

The task is to implement and verify speed-detection and frame-update detection methods for the existing FPS aim-assist simulator.

## Required Control Files

Read and obey:

- `/home/yguo173/Programs/codex_workflow_tmux/control/goal.md`
- `/home/yguo173/Programs/codex_workflow_tmux/control/constraint.md`

Then execute:

- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/specs.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_01_source_discovery.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_02_method_list.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_03_method_loop.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/spec_04_final_analysis.md`

## Non-Negotiable Requirements

Use local project files and internet search together. Internet search is mandatory and must be recorded with queries, URLs, facts extracted, and local checks.

Use the fixed M01 through M10 method list. Do not replace, skip, reorder, or rename the methods.

Work one method at a time:

1. Implement the current method.
2. Run the required comparison.
3. Diagnose the current method.
4. Repair it when evidence shows a fixable problem.
5. If it beats `a2`, keep inspecting and improving it until diagnostics show no meaningful remaining improvement inside the speed-detection approach.
6. Move to the next method only after the current method is fully recorded and has no evidence-supported repair left.

Do not say the speed-detection approach cannot beat `a2` before all 10 methods are implemented, evaluated, diagnosed, repaired when evidence supports repair, and recorded.

## Required Evidence Files

Write these files under `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/`:

- `source_discovery.md`
- `method_list.md`
- `method_results.csv`
- `method_results.md`
- `failure_analysis.md`
- `status.md`
- `final_analysis.md`

## Required Comparison

Each method must be compared with:

- `sleep`
- `a2`
- `a4`
- `c1`

Use existing project commands and metrics unless local source discovery proves a different local command is required.

## Required Metrics

For every method run, record:

- `method_id`
- `method_name`
- `run_path`
- `median_abs_e`
- `final_quarter_median`
- `diverged`
- `mean_wall_time_ns`
- `p99_wall_time_ns`
- `velocity_estimate_mean`
- `velocity_estimate_p50`
- `velocity_estimate_p90`
- `velocity_valid_update_count`
- `unchanged_frame_count`
- `handled_unchanged_frame_count`
- `suspected_dropped_frame_count`
- `beats_sleep`
- `beats_a2`
- `failure_reason`
- `next_fix_or_stop_reason`

## Completion Standard

The run is complete only when `final_analysis.md` proves one of these:

1. A method beats `a2`, all remaining visible speed-detection problems have been inspected and repaired when evidence supports repair, and there is no meaningful remaining improvement inside the speed-detection approach.
2. M01 through M10 all fail to beat `a2`, every method has a full result row, every failure has a diagnostic explanation, and every evidence-supported repair was tried.

The second condition is expected to be rare and requires all 10 method records.
