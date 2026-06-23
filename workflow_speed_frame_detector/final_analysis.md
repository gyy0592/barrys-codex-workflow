# Final Analysis

## Stop Rule Result

The workflow can stop under stop rule 1: M01 beats `a2`, remaining visible speed-detection problems were inspected, repairs supported by evidence were tried, and no meaningful remaining M01 repair is supported by the recorded diagnostics.

## Best Method

Best method by `median_abs_e`: M01 repair, `median_abs_e=24.000517593953077`.

Best method by `final_quarter_median`: M01 repair, `final_quarter_median=21.720944919122644`.

M01 repair run path:

`/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260623_154804_pid495346_BE-HYE30LAB-02`

Required comparison command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Comparison result:

| algo | median_abs_e | final_quarter_median | diverged | mean_wall_time_ns | p99_wall_time_ns |
|---|---:|---:|---|---:|---:|
| sleep | 60.00000000000003 | 60.0 | false | 104.0 | 519.5 |
| a2 | 38.18579621000873 | 36.45623357509305 | false | 354.83690987124464 | 1409.6800000000003 |
| a4 | 46.619232307654215 | 45.80179802610053 | false | 1199.901287553648 | 3479.7200000000025 |
| c1 | 54.42964595780069 | 54.319352835616655 | false | 167.27467811158797 | 566.1200000000023 |
| m01 | 24.000517593953077 | 21.720944919122644 | false | 886.7768240343347 | 2424.920000000001 |

## Stability And Budget

Conclusion: M01 repair is stable in the required comparison run.

Evidence: `diverged=false`, `median_abs_e=24.000517593953077`, and `final_quarter_median=21.720944919122644`.

Compute budget: M01 repair is inside the 5 ms budget.

Evidence: `p99_wall_time_ns=2424.920000000001`, which is far below 5,000,000 ns.

Check scope: This proves the recorded seed-42 comparison run only. It does not prove every possible random seed.

## Remaining Error Causes

Speed estimate error: bounded and not the current stop blocker.

Evidence: M01 repair recorded `velocity_estimate_mean=1.6373454801114917`, `velocity_estimate_p50=0.7758525406833996`, and `velocity_estimate_p90=13.143091844130117`.

Unchanged-frame misclassification: not a meaningful remaining blocker.

Evidence: offline `t_frame` check found `same_t_frame:unchanged=173`, `same_t_frame:updated=1`, `new_t_frame:unchanged=1`, `new_t_frame:updated=35`, and `new_t_frame:dropped_suspected=23`.

Dropped-frame handling: present, but not a stop blocker.

Evidence: M01 repair recorded `suspected_dropped_frame_count=23.0`; despite those cases, M01 beat A2 and did not diverge.

Response delay: not a stop blocker.

Evidence: M01 uses `post_command_sleep_s=0.0`, and the required comparison shows lower error than A2 without fixed extra sleep.

Command instability: not a stop blocker.

Evidence: M01 repair did not diverge; command clipping was hit once in 233 iterations.

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

## Final Conclusion

The speed-detection and frame-update approach is proved useful by M01 repair in the required comparison. Because M01 already beats A2 and the remaining diagnostics do not support a meaningful same-method repair, the workflow stops after M01 instead of continuing to M02.
