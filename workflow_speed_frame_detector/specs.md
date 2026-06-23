# Specs: Speed Detection And Frame-Update Detection For fps_mock

## Workflow Rule

Execute these specs in order. Do not skip a spec. Use local project files and internet search together. Do not replace the listed methods with executor-invented methods.

The implementation workflow is one method at a time:

1. Implement the current method.
2. Run the required comparison.
3. Diagnose the current method.
4. Repair the current method if evidence shows a fixable issue.
5. If it beats `a2`, keep improving it until there is no meaningful remaining improvement supported by diagnostics.
6. Only then move to the next method.

Do not claim the speed-detection direction cannot beat `a2` unless M01 through M10 are all complete, recorded, and diagnosed.

## Spec List

1. `spec_01_source_discovery.md`: read local project files and record how to implement, register, record, run, and test a new method.
2. `spec_02_method_list.md`: write the fixed list of 10 methods and the exact metrics table format.
3. `spec_03_method_loop.md`: implement and evaluate M01 through M10 one at a time, with repair loops.
4. `spec_04_final_analysis.md`: select the best method, prove remaining issues are fixed or not worth further work, and write final evidence.

## Required Shared Evidence Files

Write these files under `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/`:

- `source_discovery.md`
- `method_list.md`
- `method_results.csv`
- `method_results.md`
- `failure_analysis.md`
- `status.md`
- `final_analysis.md`

## Completion Gate

The workflow is complete only when `final_analysis.md` proves one of these:

- A method beats `a2`, all remaining visible problems have been inspected, and further improvement inside the speed-detection approach is not supported by evidence.
- M01 through M10 all fail to beat `a2`, every failure has a diagnostic reason, and every evidence-supported repair was tried before moving on.
