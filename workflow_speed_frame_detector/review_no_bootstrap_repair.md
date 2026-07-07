# Fresh Review Results After No-Bootstrap Repair

Date: 2026-07-07.

Reviewed project commit: `d061ad1 Do not bootstrap M01 speed window`.

Reviewed workflow commit: `677b4c9 Record M01 no-bootstrap repair evidence`.

## Review 1

Reviewer: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: FAIL as a workflow-closure verdict, with no new M01 code defect found.

Blocking finding: the review results had not yet been recorded in workflow evidence, so the review gate was still open.

Code and algorithm findings:

- M01 updates speed only from valid updated deltas.
- First observation does not update the speed window.
- `unchanged` observations do not update the speed window.
- `dropped_suspected` observations do not update the speed window.
- M01 still uses compensated motion for unchanged classification.
- No forbidden truth data, PID, reinforcement learning, or fixed sleep was found.
- Required diagnostics are recorded.
- Latest evidence shows M01 beats `sleep` and `a2` and stays inside the 5 ms budget.
- Algorithmically, stopping after M01 is justified under stop rule 1; another M01 repair or M02 is not supported by current evidence.

Residual risk: the stop evidence is based on the required seed-42 comparison, not a broader seed sweep.

## Review 2

Reviewer: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: FAIL as a workflow-closure verdict.

Blocking finding 1: the review-and-checkpoint gate was still open.

Blocking finding 2: `final_analysis.md` still contained stale pre-repair facts:

- It named the compensated-motion repair as the best method even though later reviews found that state had blocking bugs.
- It said `method_results.csv` had only initial and repaired rows even though it now has multiple M01 repair rows.
- It still reported 20 tests passed even though the latest run has 23 tests passed.

Code and algorithm findings:

- M01 updates speed only from valid updated deltas.
- First observation, `unchanged`, and `dropped_suspected` observations are excluded from speed updates.
- M01 still uses compensated motion for unchanged classification.
- No forbidden truth data, PID, reinforcement learning, or fixed sleep was found.
- Latest evidence shows M01 beats `sleep` and `a2` and stays inside the 5 ms budget.
- On algorithm behavior, stopping after M01 is justified under stop rule 1.
- No unrelated files were included in the checked checkpoint commits.

Residual risk: final evidence should summarize current raw predicted-frame-state diagnostics more completely.

## Repair Made Because Of Review 2

Changed workflow file:

- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/final_analysis.md`

Fix:

- `final_analysis.md` now names the latest no-bootstrap M01 repair as the current non-superseded best method.
- Evidence-file description now says `method_results.csv` records all M01 repair rows through the no-bootstrap repair.
- Test result now says 5 focused tests and 23 full tests passed.
- Current audit result now uses the no-bootstrap run metrics.

## Current Required Gate

Run two fresh no-context reviews on the latest workflow evidence after this file is committed. The workflow may only close after both reviews pass and a workflow evidence checkpoint records both review results and git evidence.
