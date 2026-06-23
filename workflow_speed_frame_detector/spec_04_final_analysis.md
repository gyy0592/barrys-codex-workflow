# Spec 04: Final Analysis

## Purpose

Write the final evidence summary and decide whether the workflow is complete.

## Required Output

Write `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/final_analysis.md`.

## Required Content

The final analysis must include:

1. Best method by `median_abs_e`.
2. Best method by `final_quarter_median`.
3. Whether any method beats `a2`.
4. Whether the best method is stable.
5. Whether the best method stays inside the 5 ms compute budget.
6. Whether remaining errors come from:
   - speed estimate error,
   - unchanged-frame misclassification,
   - dropped-frame handling,
   - response delay,
   - command instability.
7. What repairs were tried.
8. Why the workflow can stop.

## Stop Rule

The workflow may stop only if one of these is true:

1. A method beats `a2`, and diagnostics show no meaningful remaining improvement inside the speed-detection approach.
2. M01 through M10 all failed to beat `a2`, each failure is fully diagnosed, and every evidence-supported repair was tried.

The second case is expected to be rare and must be proved with all 10 method rows.

## Required Local Evidence

Final analysis must cite both local evidence files and internet-source-discovery evidence:

- `source_discovery.md`,
- `method_list.md`,
- `method_results.csv`,
- `method_results.md`,
- `failure_analysis.md`,
- project run output paths,
- recorded internet search queries,
- recorded internet URLs,
- extracted internet facts that were checked against local project behavior.

## Completion Check

Spec 04 is complete only when `final_analysis.md` directly proves the stop rule.
