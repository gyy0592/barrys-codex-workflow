# Method Results

## M01 - Fixed Window Velocity, Unchanged Skip

Run path: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260623_154445_pid492249_BE-HYE30LAB-02`

Comparison command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Comparison metrics from `summary.json`:

| algo | median_abs_e | final_quarter_median | diverged | mean_wall_time_ns | p99_wall_time_ns |
|---|---:|---:|---|---:|---:|
| sleep | 60.00000000000003 | 60.0 | false | 105.84615384615384 | 543.75 |
| a2 | 38.18579621000873 | 36.45623357509305 | false | 329.12017167381975 | 1123.76 |
| a4 | 46.619232307654215 | 45.80179802610053 | false | 1119.7381974248926 | 3187.520000000003 |
| c1 | 54.42964595780069 | 54.319352835616655 | false | 160.98283261802575 | 918.5200000000027 |
| m01 | 47.06893777372932 | 40.57473747275753 | false | 854.5836909871244 | 2508.88 |

M01 diagnostic metrics:

| metric | value |
|---|---:|
| velocity_estimate_mean | -0.861500887842859 |
| velocity_estimate_p50 | -0.1001186635210047 |
| velocity_estimate_p90 | 17.821258014155397 |
| velocity_valid_update_count | 5.0 |
| unchanged_frame_count | 174.0 |
| handled_unchanged_frame_count | 174.0 |
| suspected_dropped_frame_count | 26.0 |

Offline frame-state cross-check:

| truth frame_type | predicted_frame_update_state | count |
|---|---|---:|
| A | dropped_suspected | 22 |
| A | unchanged | 138 |
| A | updated | 25 |
| B | dropped_suspected | 4 |
| B | unchanged | 36 |
| B | updated | 8 |

Conclusion: M01 beats `sleep` but loses to `a2`. It does not diverge and stays under the 5 ms compute budget.

Next fix recorded before repair: tune only M01 pending-command compensation and gain. Direct evidence showed weak speed estimates and worse error than A2. Later `t_frame` audit showed the `A:unchanged` count was not itself proof of a bad unchanged rule because repeated use of the same `t_frame` can still carry truth label `A`.

### M01 repair - gain 1.1 pending window 3

Run path: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260623_154804_pid495346_BE-HYE30LAB-02`

Comparison command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Comparison metrics from `summary.json`:

| algo | median_abs_e | final_quarter_median | diverged | mean_wall_time_ns | p99_wall_time_ns |
|---|---:|---:|---|---:|---:|
| sleep | 60.00000000000003 | 60.0 | false | 104.0 | 519.5 |
| a2 | 38.18579621000873 | 36.45623357509305 | false | 354.83690987124464 | 1409.6800000000003 |
| a4 | 46.619232307654215 | 45.80179802610053 | false | 1199.901287553648 | 3479.7200000000025 |
| c1 | 54.42964595780069 | 54.319352835616655 | false | 167.27467811158797 | 566.1200000000023 |
| m01 | 24.000517593953077 | 21.720944919122644 | false | 886.7768240343347 | 2424.920000000001 |

M01 repair diagnostic metrics:

| metric | value |
|---|---:|
| velocity_estimate_mean | 1.6373454801114917 |
| velocity_estimate_p50 | 0.7758525406833996 |
| velocity_estimate_p90 | 13.143091844130117 |
| velocity_valid_update_count | 5.0 |
| unchanged_frame_count | 174.0 |
| handled_unchanged_frame_count | 174.0 |
| suspected_dropped_frame_count | 23.0 |

Offline `t_frame` update cross-check:

| `t_frame` relation | predicted_frame_update_state | count |
|---|---|---:|
| new_t_frame | dropped_suspected | 23 |
| new_t_frame | unchanged | 1 |
| new_t_frame | updated | 35 |
| same_t_frame | unchanged | 173 |
| same_t_frame | updated | 1 |

Repair evidence:

- `gain=1.1`, `pending_window=3`, and `unchanged_threshold=2.0` produced the best checked median error before the tested gain range began to worsen.
- `gain=1.2` and `gain=1.25` improved final-quarter median but worsened overall median and increased dropped-suspected counts.
- M01 repair beats A2 on both `median_abs_e` and `final_quarter_median`.
- Compute time remains far below the 5 ms budget.
- New-frame unchanged mistakes are low: 1 case in the offline `t_frame` check.
- Command limit was hit once, so command clipping is not the remaining bottleneck.

Historical conclusion at that time: no meaningful remaining M01 repair was supported by the then-available evidence. Later fresh no-context reviews found additional M01 defects, so this older conclusion is superseded by the later compensated-motion and valid-updates-only repairs below.

### M01 repair - current-code audit on 2026-07-07

Run path: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_160118_pid1940734_BE-HYE30LAB-02`

Comparison command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Comparison metrics from `summary.json`:

| algo | median_abs_e | final_quarter_median | diverged | mean_wall_time_ns | p99_wall_time_ns |
|---|---:|---:|---|---:|---:|
| sleep | 60.00000000000003 | 60.0 | false | 111.23076923076923 | 422.5 |
| a2 | 38.18579621000873 | 36.45623357509305 | false | 365.0386266094421 | 1883.8800000000042 |
| a4 | 46.619232307654215 | 45.80179802610053 | false | 1173.1330472103004 | 5050.400000000021 |
| c1 | 54.42964595780069 | 54.319352835616655 | false | 145.76394849785407 | 554.6800000000019 |
| m01 | 24.000517593953077 | 21.720944919122644 | false | 858.4849785407725 | 2404.400000000002 |

M01 current-code diagnostic metrics:

| metric | value |
|---|---:|
| velocity_estimate_mean | 1.6373454801114917 |
| velocity_estimate_p50 | 0.7758525406833996 |
| velocity_estimate_p90 | 13.143091844130117 |
| velocity_valid_update_count | 5.0 |
| unchanged_frame_count | 174.0 |
| handled_unchanged_frame_count | 174.0 |
| suspected_dropped_frame_count | 23.0 |

Offline `t_frame` update cross-check:

| `t_frame` relation | predicted_frame_update_state | count |
|---|---|---:|
| first | updated | 1 |
| new_t_frame | dropped_suspected | 23 |
| new_t_frame | unchanged | 1 |
| new_t_frame | updated | 35 |
| same_t_frame | unchanged | 173 |

Historical conclusion at that time: the then-current worktree proved M01 beat A2, stayed under the 5 ms compute budget, and recorded speed and frame-update diagnostics. Later fresh no-context review found an evidence-supported M01 repair, so this older stop conclusion is superseded.

### M01 repair - compensated-motion fix after fresh review on 2026-07-07

Fresh no-context review found that M01 used raw motion for unchanged classification, while `method_list.md` requires compensated motion. The implementation was repaired so unchanged classification uses the smallest local compensated-motion candidate.

Run path: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_161329_pid1963084_BE-HYE30LAB-02`

Comparison command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Comparison metrics from `summary.json`:

| algo | median_abs_e | final_quarter_median | diverged | mean_wall_time_ns | p99_wall_time_ns |
|---|---:|---:|---|---:|---:|
| sleep | 60.00000000000003 | 60.0 | false | 102.34615384615384 | 490.25 |
| a2 | 38.18579621000873 | 36.45623357509305 | false | 332.53648068669526 | 1323.8800000000012 |
| a4 | 46.619232307654215 | 45.80179802610053 | false | 1168.8068669527897 | 2782.720000000004 |
| c1 | 54.42964595780069 | 54.319352835616655 | false | 158.30042918454936 | 655.6000000000031 |
| m01 | 24.000517593953077 | 21.720944919122644 | false | 1076.3562231759656 | 3284.960000000006 |

M01 compensated-motion diagnostic metrics:

| metric | value |
|---|---:|
| velocity_estimate_mean | 1.6373454801114917 |
| velocity_estimate_p50 | 0.7758525406833996 |
| velocity_estimate_p90 | 13.143091844130117 |
| velocity_valid_update_count | 5.0 |
| unchanged_frame_count | 174.0 |
| handled_unchanged_frame_count | 174.0 |
| suspected_dropped_frame_count | 23.0 |

Offline `t_frame` update cross-check:

| `t_frame` relation | predicted_frame_update_state | count |
|---|---|---:|
| first | updated | 1 |
| new_t_frame | dropped_suspected | 23 |
| new_t_frame | unchanged | 1 |
| new_t_frame | updated | 35 |
| same_t_frame | unchanged | 173 |

Additional diagnostic: command clipping happened once, so command limit is not the remaining bottleneck.

Historical conclusion at that time: after the compensated-motion fix, M01 still beat A2, stayed inside the 5 ms budget, and recorded required diagnostics. Later fresh no-context review found that `dropped_suspected` samples still polluted the speed estimate, so this older stop conclusion is superseded by the valid-updates-only repair below.

### M01 repair - valid-updates-only speed learning after fresh review on 2026-07-07

Fresh no-context review found that M01 still appended `dropped_suspected` compensated deltas into the speed window. That violated the requirement that speed be updated only from valid updated observations. The implementation was repaired so `dropped_suspected` observations are counted but not inserted into `velocity_samples`.

Project repair commit: `8ff61c6 Keep dropped frames out of M01 speed estimate`.

Run path: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_162822_pid1999374_BE-HYE30LAB-02`

Comparison command:

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Comparison metrics from `summary.json`:

| algo | median_abs_e | final_quarter_median | diverged | mean_wall_time_ns | p99_wall_time_ns |
|---|---:|---:|---|---:|---:|
| sleep | 60.00000000000003 | 60.0 | false | 97.1923076923077 | 434.75 |
| a2 | 38.18579621000873 | 36.45623357509305 | false | 351.83690987124464 | 1278.6800000000007 |
| a4 | 46.619232307654215 | 45.80179802610053 | false | 1202.2789699570815 | 3769.520000000003 |
| c1 | 54.42964595780069 | 54.319352835616655 | false | 149.31330472103005 | 523.3600000000021 |
| m01 | 27.52582626861647 | 27.52582626861647 | false | 977.2789699570816 | 2846.280000000006 |

M01 valid-updates-only diagnostic metrics:

| metric | value |
|---|---:|
| velocity_estimate_mean | -0.7615236886229239 |
| velocity_estimate_p50 | -0.22294457794748723 |
| velocity_estimate_p90 | 1.4229387596586434 |
| velocity_valid_update_count | 5.0 |
| unchanged_frame_count | 180.0 |
| handled_unchanged_frame_count | 180.0 |
| suspected_dropped_frame_count | 36.0 |

Offline `t_frame` update cross-check:

| `t_frame` relation | predicted_frame_update_state | count |
|---|---|---:|
| first | updated | 1 |
| new_t_frame | dropped_suspected | 36 |
| new_t_frame | unchanged | 7 |
| new_t_frame | updated | 16 |
| same_t_frame | unchanged | 173 |

Additional diagnostic: command clipping happened twice. Compute time remained inside the 5 ms budget. M01 still beat A2 after enforcing the valid-updates-only speed-learning rule.
