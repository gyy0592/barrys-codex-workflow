# Final Closure Reviews

Date: 2026-07-07.

Reviewed project commit: `d061ad1 Do not bootstrap M01 speed window`.

Reviewed workflow commit: `cb757a4 Record no-bootstrap review findings`.

## Review 1

Reviewer: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: PASS.

Blocking findings: none substantive.

Conclusion: the latest code and evidence state satisfy the M01 completion gate. The only remaining action after the review was to record the PASS review and checkpoint it.

Key evidence checked:

- M01 updates speed only from valid updated deltas. First observation, `unchanged`, and `dropped_suspected` do not append to `velocity_samples`; only the `updated` path appends.
- Focused tests cover first-observation exclusion, dropped-frame exclusion, and compensated-motion unchanged classification.
- Latest run artifact shows step 0 `velocity_valid_update_count=0.0`.
- M01 still uses compensated motion for unchanged classification.
- No forbidden truth data, PID, reinforcement learning, or fixed sleep was found.
- Required diagnostics are recorded in raw artifacts and summarized.
- Latest no-bootstrap row shows `median_abs_e=27.680817196046235`, `final_quarter_median=27.5070398240764`, `beats_sleep=true`, `beats_a2=true`, `p99_wall_time_ns=2838.0000000000055`, and `diverged=false`.
- Stopping after M01 is justified under stop rule 1. No further M01 repair or M02 is supported by current evidence.
- Old PASS files are marked historical and superseded.
- Checkpoint commits did not include unrelated files.

Residual risk: the stop proof is based on the required seed-42 comparison, not a broader seed sweep.

## Review 2

Reviewer: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: PASS.

Blocking findings: none.

Conclusion: no substantive blocking issue remains for the latest repaired M01 state. The only remaining action after the review was to record the PASS review and checkpoint it.

Key evidence checked:

- M01 updates speed only from valid updated deltas. There is no bootstrap append on the first observation, and `unchanged` plus `dropped_suspected` observations are excluded.
- Raw no-bootstrap artifact confirms step 0 `velocity_valid_update_count=0.0`.
- M01 still uses compensated motion for unchanged classification.
- M01 consumes only `x_screen` through `compute`, has no truth-data access, has no learned model, and uses `post_command_sleep_s=0.0`.
- Required diagnostics are recorded and summarized sufficiently.
- Latest no-bootstrap `summary.json` shows M01 beats `sleep` and `a2`, stays under 5 ms, and does not diverge.
- Stopping after M01 is justified under stop rule 1. No further M01 repair or M02 is supported by current evidence.
- Workflow evidence is internally consistent; old PASS files are clearly marked historical and superseded.
- Project and workflow checkpoint commits did not include unrelated files.

Residual risks:

- The stop proof is based on the required seed-42 comparison, not a broader seed sweep.
- The workflow repository worktree has unrelated dirty files outside this task; those files were not included in checked checkpoint commits.

## Closure Decision

Both required fresh no-context reviews passed for the latest no-bootstrap repaired state. Their only requested action was to record the PASS reviews and checkpoint this evidence. No substantive blocker remains in M01 code, diagnostics, required comparison, source evidence, or workflow evidence consistency.
