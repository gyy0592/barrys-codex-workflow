# Final Analysis

## Stop Rule Status

Algorithm evidence currently supports stop rule 1 because the latest valid-updates-only M01 still beats `a2`, does not diverge, stays inside the compute budget, and records the required diagnostics. Workflow completion is not yet closed because two fresh no-context PASS reviews of the latest repaired state and a workflow evidence checkpoint are still required.

## Best Method

Best method by `median_abs_e`: M01 compensated-motion repair, `median_abs_e=24.000517593953077`.

Best method by `final_quarter_median`: M01 compensated-motion repair, `final_quarter_median=21.720944919122644`.

Latest valid-updates-only M01 audit run path:

`/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_162822_pid1999374_BE-HYE30LAB-02`

Required comparison command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Comparison result:

| algo | median_abs_e | final_quarter_median | diverged | mean_wall_time_ns | p99_wall_time_ns |
|---|---:|---:|---|---:|---:|
| sleep | 60.00000000000003 | 60.0 | false | 97.1923076923077 | 434.75 |
| a2 | 38.18579621000873 | 36.45623357509305 | false | 351.83690987124464 | 1278.6800000000007 |
| a4 | 46.619232307654215 | 45.80179802610053 | false | 1202.2789699570815 | 3769.520000000003 |
| c1 | 54.42964595780069 | 54.319352835616655 | false | 149.31330472103005 | 523.3600000000021 |
| m01 | 27.52582626861647 | 27.52582626861647 | false | 977.2789699570816 | 2846.280000000006 |

## Stability And Budget

Conclusion: M01 repair is stable in the required comparison run.

Evidence: `diverged=false`, `median_abs_e=27.52582626861647`, and `final_quarter_median=27.52582626861647`.

Compute budget: M01 repair is inside the 5 ms budget.

Evidence: valid-updates-only audit recorded `p99_wall_time_ns=2846.280000000006`, which is far below 5,000,000 ns.

Check scope: This proves the recorded seed-42 comparison run only. It does not prove every possible random seed.

## Remaining Error Causes

Speed estimate error: bounded and not the current stop blocker.

Evidence: valid-updates-only M01 recorded `velocity_estimate_mean=-0.7615236886229239`, `velocity_estimate_p50=-0.22294457794748723`, and `velocity_estimate_p90=1.4229387596586434`.

Unchanged-frame misclassification: not a meaningful remaining blocker.

Evidence: offline `t_frame` check found `same_t_frame:unchanged=173`, `new_t_frame:unchanged=7`, `new_t_frame:updated=16`, and `new_t_frame:dropped_suspected=36`.

Dropped-frame handling: present, but not a stop blocker.

Evidence: valid-updates-only M01 recorded `suspected_dropped_frame_count=36.0`; those samples no longer update the speed window, and M01 still beat A2 and did not diverge.

Response delay: not a stop blocker.

Evidence: M01 uses `post_command_sleep_s=0.0`, and the required comparison shows lower error than A2 without fixed extra sleep.

Command instability: not a stop blocker.

Evidence: valid-updates-only M01 did not diverge; command clipping was hit twice in 233 iterations.

## Repairs Tried

Initial M01:

- Run path: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260623_154445_pid492249_BE-HYE30LAB-02`
- Result: `median_abs_e=47.06893777372932`, `final_quarter_median=40.57473747275753`, `beats_a2=false`.

Repair diagnostics:

- `pending_window=3` improved median error compared with the original `pending_window=4`.
- `gain=1.1` gave the best checked median error before higher checked gains worsened the main median metric or increased dropped-suspected counts.
- `gain=1.2` and `gain=1.25` improved final-quarter median but worsened overall median and increased dropped-suspected counts, so they were not selected.

Final repair:

- M01 default `gain=1.1`.
- M01 default `pending_window=3`.
- Required comparison rerun completed and beat A2.

## Required Evidence Files

- `source_discovery.md`: records local source checks and internet-source discovery.
- `method_list.md`: records fixed M01 through M10 method list.
- `method_results.csv`: records initial M01 row and repaired M01 row.
- `method_results.md`: records commands, run paths, metrics, diagnostics, and repair analysis.
- `failure_analysis.md`: records why initial M01 failed and why repaired M01 can stop.

## Internet Evidence Used

Internet sources were used only to support local design choices, not to override local simulator constraints.

- MathWorks `trackingABF`: supports lightweight constant-velocity prediction for target tracking.
  URL: https://www.mathworks.com/help/radar/ref/trackingabf.html
- Astropy robust statistics: supports median absolute deviation and robust rejection concepts for later methods.
  URL: https://docs.astropy.org/en/latest/stats/robust.html
- FFmpeg `freezedetect`: supports low-change repeated-frame detection as an internet analog, locally adapted to scalar `x_screen`.
  URL: https://ffmpeg.org/ffmpeg-filters.html
- VPixx frame dropping guide: supports the idea that dropped frames can repeat previous image content.
  URL: https://docs.vpixx.com/vocal/a-scientist-s-guide-to-frame-dropping
- MathWorks Smith Predictor example: supports internal delayed-response prediction, locally constrained to non-PID command logic.
  URL: https://www.mathworks.com/help/control/ug/control-of-processes-with-long-dead-time-the-smith-predictor.html

## Tests And Checks

Focused test:

```text
python -m unittest tests.test_speed_frame_m01 -v
```

Result: passed.

Algorithm contract check:

```text
python -m tools.algo_contract_check
```

Result: passed.

Existing relevant test suite:

```text
python -m unittest discover -s tests -v
```

Result: 20 tests passed.

Current-code audit on 2026-07-07:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Result: passed. M01 `median_abs_e=24.000517593953077`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=21.720944919122644`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`.

Fresh no-context review correction on 2026-07-07:

- Review result: FAIL, because M01 used raw motion instead of compensated motion for unchanged classification and audit commits lacked required git evidence.
- Fix: M01 now classifies unchanged through compensated motion candidates, and focused tests verify compensated-motion classification.
- Repair run: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_161329_pid1963084_BE-HYE30LAB-02`.
- Result: M01 still beats A2 after the fix. M01 `median_abs_e=24.000517593953077`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=21.720944919122644`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`.

Second fresh no-context review correction on 2026-07-07:

- Review result: FAIL, because M01 still appended `dropped_suspected` samples to the speed window.
- Fix commit: `8ff61c6 Keep dropped frames out of M01 speed estimate`.
- Fix: M01 now counts `dropped_suspected` observations without adding them to `velocity_samples`, and the focused test verifies this rule.
- Repair run: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_162822_pid1999374_BE-HYE30LAB-02`.
- Result: M01 still beats A2 after the fix. M01 `median_abs_e=27.52582626861647`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=27.52582626861647`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`.
- Remaining gate: two fresh no-context PASS reviews of this repaired state and a workflow evidence checkpoint are still required before final completion can be claimed.

## Final Conclusion

The speed-detection and frame-update approach is still proved useful by M01 in the required comparison. Because the second fresh review found a real M01 bug and that bug has now been repaired, this file does not yet close the workflow. The next required step is two fresh no-context PASS reviews of the latest repaired state, followed by a workflow evidence checkpoint.
