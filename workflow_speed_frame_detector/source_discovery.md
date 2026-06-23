# Source Discovery Evidence

## Scope

Spec: `spec_01_source_discovery.md`.

Project root checked: `/home/yguo173/Programs/game/fps/fps_mock`.

Workflow evidence root: `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector`.

This file records only source discovery. No implementation file was changed during this step.

## Local Source Checks

| Checked path | Fact found | Direct relevance | Implementation conclusion |
|---|---|---|---|
| `original_prompt.md` | The simulator exists to reproduce delayed screenshots, independent game and camera clocks, command latency, A/B frame timing, repeated stale frames, and oscillation caused by repeated correction on old frames. | The new algorithm must solve stale and dropped frame handling without fixed extra sleep. | The method must combine movement speed estimation, pending command compensation, and frame-update classification. |
| `simulator/algo.py` | `BaseAlgo.compute` accepts only `x_screen: float`; the file states algorithms must not receive `t`, `cam_angle`, `x_world`, or other ground truth. `post_command_sleep_s` defaults to `0.0`. | This defines the allowed algorithm input contract. | The new method may store prior `x_screen`, prior commands, counters, and internal estimates, but must not read simulator truth or time. |
| `simulator/clock.py` | `GameClock` owns true `x_world`; `CameraClock` stores `CameraFrame(t_sample, x_screen, frame_type)`. | It separates simulator truth from algorithm input. | Frame truth can be used only by recorder or offline analysis, not inside `compute`. |
| `simulator/simulator.py` | `run_algo` passes only `x_screen_input` to `algo.compute`; it records `t_frame`, `frame_type`, `t_cmd`, `t_cmd_effective`, `delta_cam`, `cam_angle_at_cmd`, `wall_time_ns`, and optional `predicted_frame_type`. Divergence is simulator-side. | This proves what the algorithm sees and what offline evidence can use. | Add new algorithm diagnostics by exposing attributes after `compute` and minimally extending recorder output; offline truth comparison can read `events.jsonl`. |
| `simulator/recorder.py` | `ScalarWriter` writes long-form rows: `timestamp,step,phase,field,value`; `EventWriter` writes JSON events. | Required speed and frame-state diagnostics need persistent per-step scalar fields. | New scalar diagnostics should be written through the existing scalar path, not a separate ad hoc file. |
| `run_demo.py` | `_build_algo` lazily imports named algorithms from `simulator.algos.{key}` and requires `ALGO_CLASS` for A/C shim modules. `_write_records` emits scalar fields and events. `_build_summary` computes `median_abs_e`, `final_quarter_median`, `diverged`, and wall-time statistics from run data. | This is the normal entry point and summary source. | Register the new algorithm by adding a shim module with `ALGO_CLASS` and extending `_build_algo` only as much as needed. |
| `simulator/algos/a/a2_dual_rate.py` | A2 compensates a fixed window of recent commands and uses no simulator truth or wall clock. | A2 is the required comparison target. | New methods must be compared against A2 using normal `run_demo.py` output. |
| `simulator/algos/a/a4_dual_model.py` | A4 maintains two internal pending-command horizons and residuals from observed `x_screen` deltas. | This is a close local pattern for internal multi-model prediction. | New methods can follow this style: internal rings, residuals, no truth data, no sleep. |
| `simulator/algos/c/c1_threshold.py` | C1 predicts A/B from `abs(x_screen - last_x)` and sets `last_predicted_frame_type`, which the simulator records as `c_frame_type_pred`. | This shows the existing prediction-reporting soft contract. | The new method should expose a similar prediction attribute, extended if needed for `updated`, `unchanged`, and `dropped_suspected`. |
| `tools/algo_contract_check.py` | The checker scans `compute` and helpers for forbidden simulator state, forbidden time APIs, and unresolved unsafe external calls. It forbids `cam_angle`, `x_world`, `frame_type`, `t_frame`, simulator handles, and wall-clock time. | This enforces the observation contract. | Run this check after implementation and keep new algorithm code inside its allowed patterns. |
| `tools/aggregate_summaries.py` | Aggregation reads run summaries and comparison artifacts from `exp/`. It is broader than the per-method comparison needed here. | It can help compare existing algorithms, but per-method metrics require the exact columns in this workflow. | Use `summary.json` and scalar diagnostics for the new method table; avoid depending only on the aggregate table. |
| `tests/test_algo_contract_check.py` | Tests prove direct simulator access, aliased simulator access, forbidden external calls, and forbidden helper paths fail. | These tests cover the observation contract. | Run the contract test or checker after algorithm implementation. |
| `tests/test_aggregate_artifacts.py` | Tests verify aggregate artifact structure and error-curve files. | This is relevant to existing result generation, not the new method contract itself. | Do not use this as the only verification for the new speed diagnostics. |
| `tests/test_fps_env_contract.py` | Tests simulator and environment step behavior against each other for `x_screen_input` and `delta_cam`. | It protects simulator timing semantics. | If simulator loop or recording behavior changes, this test is relevant. |
| `tests/test_strict_json.py` | Tests JSON output sanitization for NaN and infinity. | Summary files should remain strict JSON. | Any new JSON evidence should avoid non-finite values or sanitize them. |
| `git status --short` in project root | Existing unrelated untracked files: `prompt_for_supervisor.md`, `prompt_for_supervisor_goal.md`, `report/fast_cfg_report.md`. | Constraint file says `report/fast_cfg_report.md` is unrelated unless explicitly requested. | Do not modify, stage, or include these unrelated files. |

## Required Questions

1. Where should the new method code live?

Conclusion: Put implementation code under `simulator/algos/`, preferably in a new method-specific submodule with a shim `simulator/algos/<key>.py` exporting `ALGO_CLASS`.

Evidence: `run_demo.py` imports `simulator.algos.{key}` and reads `ALGO_CLASS` for A/C style algorithms. Existing shims `simulator/algos/a2.py` and `simulator/algos/c1.py` re-export classes from deeper files.

Check scope: I checked `run_demo.py`, `simulator/algos/a2.py`, `simulator/algos/c1.py`, and existing `simulator/algos/a/` and `simulator/algos/c/` files.

Cannot prove: This does not prove the final new algorithm name; `spec_02_method_list.md` must define method names before implementation.

2. How is a new algorithm registered so `run_demo.py` can run it?

Conclusion: Add the new key to `_build_algo` and make `simulator.algos.<key>` importable with `ALGO_CLASS`.

Evidence: `_build_algo` accepts explicit keys such as `a1` through `a5` and `c1` through `c5`, imports `simulator.algos.{key}`, then instantiates `ALGO_CLASS`.

Check scope: I checked `run_demo.py` and shim modules.

Cannot prove: This does not prove whether a single key or several method keys will be best; that belongs to Spec 02 and Spec 03.

3. What can `compute(x_screen)` legally observe?

Conclusion: `compute` may observe only the current `x_screen`, its own stored prior `x_screen` values, prior commands it emitted, counters, and internal state. It must not observe `x_world`, `cam_angle`, true `frame_type`, `t_frame`, `t_sample`, simulator time, camera phase, or simulator truth labels.

Evidence: `simulator/algo.py` states the allowed input is only `x_screen`; `simulator/simulator.py` calls `algo.compute(x_screen_input)` with a single float; `tools/algo_contract_check.py` flags forbidden simulator truth and wall-clock reads.

Check scope: I checked the base class, simulator loop, and contract checker.

Cannot prove: Static checks cannot prove every possible runtime information leak if later code adds an unscanned path, so the checker must be rerun after implementation.

4. How can method diagnostics be recorded without giving the algorithm simulator truth?

Conclusion: The algorithm should store diagnostic attributes after each `compute`; `run_demo.py` or a minimal recorder adapter can read those attributes after `compute` returns and write them to `scalars.csv`.

Evidence: `simulator/simulator.py` already reads `last_predicted_frame_type` after `compute` and records it without feeding truth into the algorithm. `ScalarWriter` already persists scalar fields.

Check scope: I checked `simulator/simulator.py`, `run_demo.py`, `simulator/recorder.py`, and C1.

Cannot prove: The exact field names still need implementation and tests in Spec 03.

5. How are `median_abs_e`, `final_quarter_median`, `diverged`, and `wall_time_ns` produced?

Conclusion: `wall_time_ns` is measured around `algo.compute`; `median_abs_e` is the median of absolute `x_screen_input`; `final_quarter_median` is the median absolute `x_screen_input` in the last quarter of iterations; `diverged` is set by simulator-side divergence detection and copied to `summary.json`.

Evidence: `simulator/simulator.py` measures `time.perf_counter_ns()` immediately around `compute`; `_build_summary` in `run_demo.py` computes the error medians and wall-time statistics from `result.iterations`; divergence is set in `FPSSimulator._check_divergence`.

Check scope: I checked `simulator/simulator.py` and `run_demo.py`.

Cannot prove: This does not prove any future run result; it only proves where the metrics come from.

6. How can offline evaluation compare predicted frame state with truth without feeding truth to the algorithm?

Conclusion: Write predicted state from algorithm attributes to scalar records, then compare it offline with `frame_type` in `events.jsonl` or simulator result events.

Evidence: `run_demo.py` already computes C-group metrics by reading `c_frame_type_pred` from `scalars.csv` and true `frame_type` from `events.jsonl`.

Check scope: I checked `_compute_c_group_metrics` and `_write_records` in `run_demo.py`.

Cannot prove: Existing C-group metrics support A/B only; new `updated`, `unchanged`, and `dropped_suspected` states need a minimal extension.

7. What existing tests or checks must be run after implementation?

Conclusion: At minimum run the algorithm contract checker, focused tests for new diagnostics, and a normal `run_demo.py` comparison including `sleep,a2,a4,c1,<new_algo>`.

Evidence: `tools/algo_contract_check.py` is the project tool for enforcing the algorithm information boundary. `run_demo.py` is the normal entry point that produces `summary.json`, `scalars.csv`, `events.jsonl`, and plots.

Check scope: I checked the checker, tests, and run entry point.

Cannot prove: The exact focused test file cannot be named until the new diagnostic recording code exists.

8. Which existing file currently has unrelated untracked or modified state that must not be included?

Conclusion: In `/home/yguo173/Programs/game/fps/fps_mock`, unrelated untracked files are `prompt_for_supervisor.md`, `prompt_for_supervisor_goal.md`, and `report/fast_cfg_report.md`; the constraint file explicitly names `report/fast_cfg_report.md` as unrelated.

Evidence: `git status --short` in the project root lists those files.

Check scope: I checked only the project root status for this workflow.

Cannot prove: This does not classify unrelated changes in other repositories.

9. Which internet sources give useful facts for this task?

Conclusion: Useful sources are MathWorks `trackingABF` documentation for lightweight constant-velocity prediction, Astropy robust statistics documentation for median absolute deviation, FFmpeg `freezedetect` documentation for repeated/frozen-frame detection by low frame difference over a duration, and MathWorks Smith Predictor documentation for delayed-response compensation with an internal prediction model.

Evidence: The internet-source-discovery table below records the queries, URLs, titles, facts, local checks, and supported methods.

Check scope: I searched public web sources on 2026-06-23.

Cannot prove: These sources do not prove the new algorithm will beat `a2`; they only support method design choices that must be tested locally.

10. Which internet facts are usable after checking them against the local simulator constraints?

Conclusion: Usable facts are constant-velocity state prediction, robust median/MAD outlier rejection, low-change repeated-frame detection, and internal delayed-response prediction. They are usable only when implemented with `x_screen`, prior commands, and internal state, not simulator truth or wall-clock time.

Evidence: Local files allow internal state and prior commands, while forbidding truth data and wall-clock time.

Check scope: I checked the internet sources against `simulator/algo.py`, `simulator/simulator.py`, and `tools/algo_contract_check.py`.

Cannot prove: Internet facts that require timestamps or true frame labels are not directly usable inside `compute`.

## Internet Source Discovery

| Search query | URL | Source title | Fact extracted | Local project check | Method or repair supported |
|---|---|---|---|---|---|
| `online velocity estimation alpha beta filter target tracking source` | https://www.mathworks.com/help/radar/ref/trackingabf.html | MathWorks `trackingABF` | Alpha-beta filters are for object tracking under linear motion models, including constant velocity, and provide predict and correct steps. | The simulator enemy is locally modeled as mostly constant velocity between flips, but `compute` has no timestamps, so implementation must use an internal step count or inferred update count rather than simulator time. | Supports M01, M03, M07, M08, and M10 speed prediction. |
| `median absolute deviation outlier rejection robust velocity estimation` | https://docs.astropy.org/en/latest/stats/robust.html | Astropy Robust Statistical Estimators | Median absolute deviation is `median(abs(a - median(a)))`; Astropy documents using MAD with sigma clipping for outlier rejection. | Recent compensated `x_screen` deltas can be stored by the algorithm; no simulator truth is needed. | Supports M02 outlier rejection and repair analysis for corrupted speed samples. |
| `FFmpeg freezedetect filter documentation freeze duplicate frames` | https://ffmpeg.org/ffmpeg-filters.html | FFmpeg Filters Documentation, `freezedetect` | Frozen video detection compares mean absolute frame difference against a noise threshold over a duration. | The algorithm sees only scalar `x_screen`, not pixels, so the usable local analog is small compensated `x_screen` change across observations, not image comparison. | Supports unchanged-frame classification in M01, M03, M05, M09. |
| `dropped frame detection duplicate frame detection video timestamp method` | https://docs.vpixx.com/vocal/a-scientist-s-guide-to-frame-dropping | VPixx Scientist's Guide to Frame Dropping | A dropped frame can cause previous image content to repeat when new content is not ready for the next video frame. | The simulator can return an unchanged or stale `x_screen` observation while commands are pending; `compute` cannot read the frame truth. | Supports recording unchanged frames and suspected dropped-frame cases separately. |
| `Smith predictor delayed feedback control tracking latency source` | https://www.mathworks.com/help/control/ug/control-of-processes-with-long-dead-time-the-smith-predictor.html | MathWorks Smith Predictor Example | A Smith Predictor uses an internal model to estimate delay-free response and compares delayed actual output against delayed prediction to avoid overreacting to delayed feedback. | A2 and A4 already use local internal pending-command models without simulator truth. PID is forbidden, so only the internal prediction and delayed-output comparison idea is usable, not PI/PID control. | Supports M03, M04, M06, M08, and M10 delayed-command compensation. |

## Spec 01 Completion Check

- `source_discovery.md` exists: yes.
- Required local files inspected: yes, including the higher-priority `control/goal.md` addition `simulator/clock.py`.
- Internet search completed and recorded: yes.
- Required questions answered: yes, questions 1 through 10.
- Forbidden truth-data proposal avoided: yes.
- Implementation started before source discovery: no.
