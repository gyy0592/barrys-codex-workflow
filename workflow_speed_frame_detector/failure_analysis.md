# Failure Analysis

## M01 - Initial Run

Program that produced the run: `/home/yguo173/Programs/game/fps/fps_mock/run_demo.py`.

Command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Expected behavior: M01 should skip repeated corrections on unchanged observations while still accepting real updated frames for speed estimation.

Actual behavior: M01 skipped many observations. It recorded `unchanged_frame_count=174.0` out of 233 iterations and lost to `a2`: M01 `median_abs_e=47.06893777372932`; A2 `median_abs_e=38.18579621000873`.

Metric that proved failure: `beats_a2=false` in `method_results.csv`; `median_abs_e` and `final_quarter_median` were both worse than A2.

Speed estimate direction: speed was too weak and noisy for the task. Evidence: `velocity_estimate_mean=-0.861500887842859`, `velocity_estimate_p50=-0.1001186635210047`, and `velocity_estimate_p90=17.821258014155397`, while the simulator target can move tens of pixels between real camera updates under the default 10 Hz camera.

Valid-frame availability: too few valid updated frames were used. Evidence: final `velocity_valid_update_count=5.0`, while 174 observations were classified as unchanged.

Unchanged-frame classification: the first A/B cross-check was insufficient because `frame_type=A` means the sampled frame was after the most recent command known when the frame was generated; it does not prove the loop observed a new `t_frame`. A later `t_frame` cross-check showed `same_t_frame:unchanged=173` and `new_t_frame:unchanged=1` for the initial run, so repeated-frame detection was mostly aligned with repeated `t_frame` observations.

Dropped-frame handling: dropped suspicion was present but not the main proof of failure. Evidence: `suspected_dropped_frame_count=26.0`; offline counts show `A:dropped_suspected=22` and `B:dropped_suspected=4`.

Response speed versus stability: compute time was not the problem. Evidence: M01 `p99_wall_time_ns=2508.88`, far below the 5 ms budget.

Smallest supported repair: tune M01's internal pending-command horizon and gain. Evidence from bounded M01-only diagnostics showed `pending_window=3` improved the initial run, and `gain=1.1` gave the best checked median error before higher gains began to worsen the overall median or increase dropped-suspected counts.

## M01 - Repair Result

Program that produced the repaired run: `/home/yguo173/Programs/game/fps/fps_mock/run_demo.py`.

Command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Run path: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260623_154804_pid495346_BE-HYE30LAB-02`.

Actual repaired behavior: M01 beat A2 and did not diverge. M01 `median_abs_e=24.000517593953077`, A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=21.720944919122644`, A2 `final_quarter_median=36.45623357509305`.

Remaining diagnostics:

- Speed estimate remained bounded: mean `1.6373454801114917`, p50 `0.7758525406833996`, p90 `13.143091844130117`.
- Valid update window was full at the final step: `velocity_valid_update_count=5.0`.
- Unchanged handling was active: `unchanged_frame_count=174.0`, `handled_unchanged_frame_count=174.0`.
- Dropped suspicion remained moderate: `suspected_dropped_frame_count=23.0`.
- Offline `t_frame` cross-check found `new_t_frame:unchanged=1`, `same_t_frame:unchanged=173`, `new_t_frame:updated=35`, and `new_t_frame:dropped_suspected=23`.
- Compute time was inside budget: `p99_wall_time_ns=2424.920000000001`.
- Command clipping did not explain the remaining error: one command hit the limit.

Historical stop reason after the first repair: no meaningful remaining repair was supported inside M01 by the evidence available at that time. Later fresh no-context reviews found two additional M01 repairs: compensated-motion unchanged classification and valid-updates-only speed learning. This older stop reason is therefore superseded.

## M01 - Fresh Review Valid-Updates-Only Failure

Program affected: `/home/yguo173/Programs/game/fps/fps_mock/simulator/algos/speed_frame/m01_fixed_window.py`.

Expected behavior: M01 must update the speed estimate only from observations classified as valid updated frames.

Actual behavior found by fresh no-context review: M01 counted `dropped_suspected` observations but still appended their compensated deltas to `velocity_samples`. That meant suspected dropped-frame samples could change `velocity_estimate`.

Metric or check that proved failure: code review of `m01_fixed_window.py` showed `self.velocity_samples.append(compensated_delta)` ran after the `dropped_suspected` branch instead of only in the `updated` branch.

Cause category: dropped-frame handling corrupted speed estimation. The algorithm treated suspected dropped-frame observations as non-unchanged for command output, but it also used them as speed-learning samples, which violated the valid-updates-only requirement.

Smallest supported repair: move the `velocity_samples.append(compensated_delta)` call into the `updated` branch and add a focused test proving a `dropped_suspected` observation does not increase `velocity_valid_update_count`.

Repair commit: `8ff61c6 Keep dropped frames out of M01 speed estimate`.

Repair checks:

```text
python -m tools.algo_contract_check
```

Result: passed.

```text
python -m unittest tests.test_speed_frame_m01 -v
```

Result: 4 tests passed.

```text
python -m unittest discover -s tests -v
```

Result: 22 tests passed.

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Result: M01 still beats A2 after the valid-updates-only repair. M01 `median_abs_e=27.52582626861647`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=27.52582626861647`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`; M01 `p99_wall_time_ns=2846.280000000006`.

Remaining diagnostics after repair:

- Speed estimate stayed bounded: mean `-0.7615236886229239`, p50 `-0.22294457794748723`, p90 `1.4229387596586434`.
- Valid update window was full at the final step: `velocity_valid_update_count=5.0`.
- Unchanged handling was active: `unchanged_frame_count=180.0`, `handled_unchanged_frame_count=180.0`.
- Dropped suspicion increased to `suspected_dropped_frame_count=36.0`, but those samples no longer update the speed window.
- Offline `t_frame` cross-check found `new_t_frame:dropped_suspected=36`, `new_t_frame:unchanged=7`, `new_t_frame:updated=16`, and `same_t_frame:unchanged=173`.
- Compute time was inside budget: `p99_wall_time_ns=2846.280000000006`.
- Command clipping happened twice, so clipping is not the dominant remaining bottleneck.

Current M01 stop evidence: after the valid-updates-only repair, M01 still beats A2 and stays inside the compute budget. The workflow still requires two fresh no-context PASS reviews and a workflow evidence checkpoint before final completion can be claimed.
