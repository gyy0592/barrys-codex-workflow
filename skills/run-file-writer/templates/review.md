# Review

This file records fresh review of one completed spec. It must not review multiple specs at once.

## Canonical Paths

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder before reporting completion. Record resolved absolute paths in reviewer context and findings; bare control, workflow, spec, evidence, review, or status paths are invalid.

## Spec

Write the spec id and short name here.

## Reviewer Context

List exactly what the reviewer received. The reviewer should receive only this spec's requirements, files, checklist, evidence, latest git evidence, and active constraints.

## Checks

- Is `{{CURRENT_SPEC_ROOT}}/review_checklist.md` present, filled, and sourced from the current global/project instructions, `{{CONTROL_ROOT}}/goal.md`, `{{CONTROL_ROOT}}/constraint.md`, `{{WORKFLOW_ROOT}}/run_goal.md`, `{{WORKFLOW_ROOT}}/specs.md`, `{{CURRENT_SPEC_ROOT}}/abstract_plan.md`, and `{{CURRENT_SPEC_ROOT}}/evidence.md` where applicable?
- Does every applicable checklist row have required evidence, observed evidence, and a result?
- Are all applicable checklist rows `PASS` before overall review `PASS`?
- Does the evidence prove the spec success standard?
- Did the spec obey `{{CONTROL_ROOT}}/constraint.md`?
- Did the spec stay within `{{CONTROL_ROOT}}/goal.md` and the current spec under `{{CURRENT_SPEC_ROOT}}`?
- Did the work avoid dependent-spec tasks before this spec's direct release gate passed, while allowing independent ready tasks to run concurrently?
- Is the dependency DAG acyclic, and does this spec record its direct prerequisites, verification command, pass condition, and release condition?
- At each scheduling point, did the workflow launch all ready, non-conflicting, resource-compatible tasks up to actual available capacity, preserve declared order only under capacity pressure, and immediately refill capacity after completion?
- Is every matching resource left unused explained by a concrete dependency, resource mismatch, or gate reason, with no fixed GPU-count branch?
- Are unrelated files excluded from the checkpoint commit?
- Are missing facts or deviations recorded?
- Did the work avoid replacing, weakening, bypassing, or reinterpreting any user-required method, tool, metric, output, original capability, accelerated path, or high-performance implementation without the checklist's required evidence?
- Is it safe to release this spec's direct dependents?

## Findings

List every issue found. Write "none" if there are no issues.

## Result

Write PASS or FAIL.

## Required Fixes Before Next Spec

List required fixes. Write "none" only if the result is PASS. A `FAIL` blocks this spec's direct dependents, not independent ready specs.
