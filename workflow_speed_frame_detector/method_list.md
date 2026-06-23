# Fixed Ten-Method List

Spec: `spec_02_method_list.md`.

Execution rule: implement and evaluate these methods in order, one method at a time. Do not skip, reorder, rename, or replace them.

## M01

- `method_id`: M01
- `method_name`: Fixed Window Velocity, Unchanged Skip
- Speed estimate rule: keep a fixed-size window of compensated `x_screen` deltas from observations classified as real updates; estimate speed as the arithmetic mean of accepted compensated deltas per internal observation step.
- Frame-update classification rule: classify the current observation as `unchanged` when the compensated motion magnitude is below a fixed small threshold; otherwise classify it as `updated`.
- Dropped-frame handling rule: if compensated motion is much larger than the current speed estimate predicts for one internal step, record `dropped_suspected` but do not change the update interval yet.
- Command rule: on `updated`, command proportional correction after subtracting pending command effect; on `unchanged`, emit `0.0` to avoid repeated correction.
- Response-speed mechanism: no fixed post-command sleep; use internal state on every loop.
- Expected failure cases: fixed threshold may reject slow valid motion, accept unchanged noisy motion, or underestimate speed after missed updates.
- Required diagnostics: all required velocity, window, unchanged, dropped-suspected, predicted state, command, wall-time, and error metrics.

## M02

- `method_id`: M02
- `method_name`: Median Velocity, Outlier Rejection
- Speed estimate rule: compute compensated deltas, use the median as the speed estimate, and reject deltas outside a fixed multiple of median absolute deviation.
- Frame-update classification rule: classify observations with rejected near-zero compensated deltas as `unchanged`; accepted nonzero deltas are `updated`.
- Dropped-frame handling rule: classify very large accepted deltas as `dropped_suspected` and exclude them from the median until enough supporting samples appear.
- Command rule: command from the current error corrected by pending commands and the median speed estimate; emit `0.0` for unchanged observations.
- Response-speed mechanism: use a short bounded sample list and median calculation; no fixed sleep.
- Expected failure cases: median may lag during target direction flips; MAD can be zero early; too much rejection can leave too few valid updates.
- Required diagnostics: accepted and rejected delta counts, MAD threshold behavior, required velocity and frame-state metrics.

## M03

- `method_id`: M03
- `method_name`: Two-Model Frame Match
- Speed estimate rule: maintain speed from accepted updated observations after pending-command compensation.
- Frame-update classification rule: compute an updated-frame prediction and an unchanged-frame prediction; choose the state whose predicted `x_screen` is closer to the observation.
- Dropped-frame handling rule: if both predictions are poor but the updated-frame error improves when multiple update intervals are assumed, record `dropped_suspected`.
- Command rule: use the winning model state to avoid repeating already-sent correction; command a bounded proportional correction from the model-corrected error.
- Response-speed mechanism: evaluate two small scalar predictions per step; no fixed sleep.
- Expected failure cases: wrong speed estimate can make the wrong model win; close model errors can cause unstable classification.
- Required diagnostics: model errors, selected state, accepted update count, unchanged count, dropped-suspected count, command, wall-time.

## M04

- `method_id`: M04
- `method_name`: Dropped-Frame Count Search
- Speed estimate rule: estimate speed from accepted updated observations, corrected for commands already issued.
- Frame-update classification rule: first classify unchanged by near-zero compensated motion; otherwise classify as updated or dropped-suspected by count search.
- Dropped-frame handling rule: test 1, 2, and 3 missed update intervals and pick the count whose speed-consistent prediction has the smallest error; record the chosen count.
- Command rule: correct the current error using the chosen count's predicted position and pending-command compensation.
- Response-speed mechanism: bounded search over three scalar counts; no fixed sleep.
- Expected failure cases: count search can overfit noisy observations; wrong count can corrupt speed estimate.
- Required diagnostics: chosen dropped count, prediction errors per count, required velocity and frame-state metrics.

## M05

- `method_id`: M05
- `method_name`: High-Confidence Learning Only
- Speed estimate rule: update speed only when frame-update classification confidence is above a fixed threshold.
- Frame-update classification rule: classify by compensated motion and model residual margin; low margin means uncertain.
- Dropped-frame handling rule: record dropped suspicion only when multi-step prediction beats one-step prediction by a clear margin.
- Command rule: low-confidence observations may influence immediate command, but must not update speed; unchanged observations emit `0.0`.
- Response-speed mechanism: no sleep; confidence gates protect learning instead of delaying the loop.
- Expected failure cases: strict confidence may starve speed learning; immediate command may still be unstable under uncertainty.
- Required diagnostics: confidence value, learning accepted count, rejected count, required velocity and frame-state metrics.

## M06

- `method_id`: M06
- `method_name`: Pending-Command Compensation First
- Speed estimate rule: subtract estimated unobserved effect of recent commands before computing movement deltas; estimate speed on that corrected signal.
- Frame-update classification rule: classify update state after pending-command compensation, not on raw `x_screen`.
- Dropped-frame handling rule: large corrected residuals after compensation become `dropped_suspected`.
- Command rule: command from compensated error and predicted target movement, with repeated correction suppressed for unchanged observations.
- Response-speed mechanism: use a bounded recent-command ring; no fixed sleep.
- Expected failure cases: wrong command horizon can over-subtract or under-subtract, causing false unchanged or false dropped-suspected classifications.
- Required diagnostics: pending compensation amount, velocity estimate, valid update count, unchanged count, dropped-suspected count.

## M07

- `method_id`: M07
- `method_name`: Target-Speed First
- Speed estimate rule: estimate target speed first from raw observation trend, then adjust it using command-effect visibility decisions.
- Frame-update classification rule: compare raw trend prediction against command-compensated prediction to decide whether command effect is visible.
- Dropped-frame handling rule: if raw trend implies multiple update intervals, classify as `dropped_suspected`.
- Command rule: command from the error adjusted by the target-speed-first prediction and visible command effect.
- Response-speed mechanism: immediate prediction from raw trend; no fixed sleep.
- Expected failure cases: raw trend mixes target motion and camera command effects, so early speed can be biased.
- Required diagnostics: raw speed, adjusted speed, command visibility decision, required frame-state metrics.

## M08

- `method_id`: M08
- `method_name`: Short-Speed And Long-Speed Tracks
- Speed estimate rule: maintain short-term and long-term speed estimates from accepted updates; use short speed for response and long speed for stability checks.
- Frame-update classification rule: disagreement between short and long predictions helps classify unchanged or dropped-suspected observations.
- Dropped-frame handling rule: classify as `dropped_suspected` when short-speed prediction explains a large residual better than long-speed one-step prediction.
- Command rule: use short speed for immediate command, but limit command when short and long tracks disagree strongly.
- Response-speed mechanism: two small running estimates; no fixed sleep.
- Expected failure cases: long speed may lag after direction flips; short speed may chase noise.
- Required diagnostics: short speed, long speed, disagreement, required velocity and frame-state metrics.

## M09

- `method_id`: M09
- `method_name`: Uncertain Means No Command
- Speed estimate rule: update speed only from observations classified as valid updates with enough confidence.
- Frame-update classification rule: classify as updated, unchanged, dropped-suspected, or uncertain using prediction residual margins.
- Dropped-frame handling rule: record dropped suspicion when multi-step prediction is plausible, but classify low-margin cases as uncertain.
- Command rule: emit `0.0` when uncertain; updated observations use corrected proportional command; unchanged observations also emit `0.0`.
- Response-speed mechanism: no fixed sleep; uncertainty is handled by skipping only that command.
- Expected failure cases: too many uncertain frames may cause lag; stability may improve while tracking error grows.
- Required diagnostics: uncertain count, skipped command count, required velocity and frame-state metrics.

## M10

- `method_id`: M10
- `method_name`: Uncertain Means Predicted Command With Limit
- Speed estimate rule: update speed from high-confidence valid updates; keep current speed during uncertainty.
- Frame-update classification rule: use the same residual-margin classification as M09.
- Dropped-frame handling rule: during dropped-suspected or uncertain observations, predict forward with current speed but do not learn from the sample unless confidence improves.
- Command rule: when uncertain, emit a predicted correction with a fixed magnitude limit to prevent runaway behavior; unchanged still suppresses repeated correction.
- Response-speed mechanism: no fixed sleep; bounded predicted command preserves response under uncertainty.
- Expected failure cases: prediction can be wrong after target flips; command limit can cause lag or still allow oscillation if too high.
- Required diagnostics: limited-command count, limit hits, required velocity and frame-state metrics.
