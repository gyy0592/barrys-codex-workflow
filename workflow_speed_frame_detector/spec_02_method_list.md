# Spec 02: Fixed Ten-Method List

## Purpose

Create the fixed list of 10 different speed-detection and frame-update methods. The executor must not replace this list during execution.

## Required Methods

Write these methods exactly into `method_list.md`.

### M01: Fixed Window Velocity, Unchanged Skip

Estimate speed from a fixed-size window of accepted updated observations. Classify very small compensated motion as unchanged. Skip command on unchanged observations.

### M02: Median Velocity, Outlier Rejection

Estimate speed as the median of recent compensated deltas. Reject deltas outside a fixed multiple of the median absolute deviation. Use only accepted deltas to update speed.

### M03: Two-Model Frame Match

For each observation, compute two predictions: updated-frame prediction and unchanged-frame prediction. Classify by whichever prediction has smaller error.

### M04: Dropped-Frame Count Search

Assume the current observation may represent 1, 2, or 3 missed update intervals. Pick the count whose speed-consistent prediction has the smallest error. Record the chosen dropped-frame count.

### M05: High-Confidence Learning Only

Use strict confidence rules for updating speed. Low-confidence observations may influence command output but must not update speed.

### M06: Pending-Command Compensation First

Subtract the estimated unobserved effect of recent commands before estimating target speed. Use that corrected signal for update detection.

### M07: Target-Speed First

Estimate target speed first from the raw observation trend, then decide whether command effects are visible. Use the decision to adjust the command.

### M08: Short-Speed And Long-Speed Tracks

Maintain a short-term speed estimate for response and a long-term speed estimate for stability. Use disagreement between them to detect dropped or unchanged frames.

### M09: Uncertain Means No Command

When the updated-vs-unchanged decision is uncertain, emit `0.0` for the command but still record diagnostics. This tests stability-first response without fixed sleep.

### M10: Uncertain Means Predicted Command With Limit

When uncertain, predict forward using speed and command history, but limit command magnitude to prevent runaway behavior.

## Required Method Fields

For every method, `method_list.md` must specify:

- `method_id`,
- `method_name`,
- speed estimate rule,
- frame-update classification rule,
- dropped-frame handling rule,
- command rule,
- response-speed mechanism,
- expected failure cases,
- required diagnostics.

## Required Result Table Columns

Create `method_results.csv` with this exact header before the first method run:

```text
method_id,method_name,run_path,median_abs_e,final_quarter_median,diverged,mean_wall_time_ns,p99_wall_time_ns,velocity_estimate_mean,velocity_estimate_p50,velocity_estimate_p90,velocity_valid_update_count,unchanged_frame_count,handled_unchanged_frame_count,suspected_dropped_frame_count,beats_sleep,beats_a2,failure_reason,next_fix_or_stop_reason
```

## Fail Conditions

This spec fails if:

- fewer than 10 methods are listed,
- any method is vague enough that implementation requires inventing the method later,
- the executor creates internet-only methods that ignore local simulator facts,
- the executor removes or renames required metrics.

## Completion Check

Spec 02 is complete only when:

- `method_list.md` contains M01 through M10 with all required fields,
- `method_results.csv` exists with the exact required header,
- `status.md` records that execution must start with M01.
