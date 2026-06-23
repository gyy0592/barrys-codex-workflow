# Spec 03: One-Method Implementation And Evaluation Loop

## Purpose

Implement, run, diagnose, and repair M01 through M10 one at a time.

## Loop Rule For Each Method

For each method from M01 to M10:

1. Implement only the current method.
2. Register it so it can run through the normal project entry point.
3. Add only the minimal diagnostic recording required by `control/goal.md`.
4. Run required checks.
5. Run required comparison.
6. Append one complete row to `method_results.csv`.
7. Write a method section in `method_results.md`.
8. If the method loses to `a2`, diverges, or has unstable final-quarter behavior, inspect diagnostics and make the smallest evidence-supported repair.
9. Rerun after the repair and append the repaired result as a new row with the same method id and a repair suffix in `method_name`.
10. Move to the next method only when the current method has no remaining evidence-supported repair, or when it beats `a2` and has no meaningful remaining improvement supported by diagnostics.

## Required Comparison

Each method must be compared against:

- `sleep`,
- `a2`,
- `a4`,
- `c1`.

Use the existing project defaults unless source discovery proves the normal comparison command requires a different local default. Do not change metrics to make a method look better.

## Required Diagnostics

For each method run, record:

- speed estimate values,
- number of observations considered,
- number of valid updated observations,
- number of unchanged observations,
- number of unchanged observations handled without repeated correction,
- suspected dropped-frame count,
- predicted frame-update state counts,
- command values,
- compute time,
- `median_abs_e`,
- `final_quarter_median`,
- `diverged`.

## Required Failure Analysis Per Method

If the method fails, write:

- expected behavior,
- actual behavior,
- metric that proved failure,
- whether speed estimate was too high or too low,
- whether too few valid updates were available,
- whether unchanged frames were misclassified,
- whether dropped frames damaged speed estimation,
- whether response speed caused instability,
- exact repair tried or exact reason no repair is supported.

## Required Winning-Method Analysis

If a method beats `a2`, do not stop immediately. Inspect:

- whether `final_quarter_median` is stable,
- whether compute time is within the 5 ms budget,
- whether unchanged frames are handled correctly,
- whether suspected dropped-frame cases are stable,
- whether speed estimates are noisy,
- whether command limits are causing avoidable lag.

Continue repairing the winning method until these checks show no meaningful remaining improvement supported by evidence.

## Fail Conditions

This spec fails if:

- the executor skips a method,
- the executor implements multiple methods at once without recording each separately,
- the executor says the approach cannot beat `a2` before M01 through M10 are complete,
- the executor skips required internet-supported repair checks,
- the executor uses forbidden truth data inside the algorithm,
- any method lacks a complete result row,
- any failure lacks diagnosis.

## Completion Check

Spec 03 is complete only when either:

- a method beats `a2` and the required winning-method analysis proves no meaningful remaining improvement remains, or
- M01 through M10 all have complete result rows, repairs were tried when supported, and every failure has a diagnostic explanation.
