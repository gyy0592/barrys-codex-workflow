# Specs

## Canonical paths (replace before reporting completion)

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder above before reporting completion. Every actionable cross-file reference in the final file must use the resolved absolute path. Do not write bare `control/goal.md`, `control/constraint.md`, `specs.md`, `review.md`, or `status.md` references.

Each spec is one checkable task step. A spec is complete only when its evidence proves its success standard, `{{CURRENT_SPEC_ROOT}}/review_checklist.md` has every applicable row `PASS`, and its review passes. A spec is not complete if the executor changes, weakens, bypasses, replaces, or reinterprets any user-required method, tool, function, metric, output, original repository capability, accelerated path, high-performance implementation, or constraint. Difficulty, repeated failed attempts, slower speed, missing adapter code, or implementation complexity does not prove the user requirement is wrong. The executor must keep fixing the implementation until the required result is achieved, unless evidence proves the required thing does not exist or cannot work as stated and the failure is not caused by executor implementation error.

Specs are listed in declared direct-dependency order, not as a global serial queue. Before execution, fill a dependency table with `spec`, `depends_on`, concrete prerequisite files/interfaces/tests, verification command, pass condition, release condition, and independent parallel group. A spec waits only for its own unmet direct prerequisites. The review, status, evidence, checkpoint commit, and required fresh no-context review of one spec gate only specs that directly depend on that spec; independent ready specs may run concurrently. At each scheduling point, launch all ready, non-conflicting, resource-compatible specs up to the actual available capacity, preserve the declared order when capacity is insufficient, and immediately recompute and refill capacity when a spec finishes. Do not combine multiple specs into one checkpoint commit or one review.

## Spec 001: <short name>

Purpose:
State why this step exists.

Direct dependency and release gate:
Write `depends_on`, the concrete prerequisite files/interfaces/tests, the verification command, the pass condition, and the condition that releases each direct dependent.

Required information:
List what must be read or checked before acting.

Expected outputs:
List files, logs, commits, metrics, or other outputs this step should produce.

Observable success evidence:
List exact evidence that proves this step worked.

Review checklist sources:
List the global/project instruction files, `{{CONTROL_ROOT}}/goal.md`, `{{CONTROL_ROOT}}/constraint.md`, current spec requirements, plan sections, and evidence sources that must be converted into `{{CURRENT_SPEC_ROOT}}/review_checklist.md` rows for this spec.

Hard gates before expensive work:
List checklist rows or evidence that must be `PASS` before long-running, paid, GPU, cloud, destructive, or hard-to-reverse work starts.

Correction triggers:
List conditions that require stopping only the unsafe or wrong executor path, recording evidence, fixing, or returning to source discovery. These are not supervisor stop states and not user-response gates.

Estimated runtime:
Write the expected runtime or "unknown until source discovery".

Review requirement:
State what fresh no-context reviewers must check before the next spec starts.
