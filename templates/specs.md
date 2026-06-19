# Specs

Each spec is one checkable task step. A spec is complete only when its evidence proves its success standard and its review passes.

Specs run one at a time, in order. The next spec cannot start until the current spec has evidence, status, checkpoint commit, and required review. Do not combine multiple specs into one checkpoint commit or one review.

## Spec 001: <short name>

Purpose:
State why this step exists.

Required information:
List what must be read or checked before acting.

Expected outputs:
List files, logs, commits, metrics, or other outputs this step should produce.

Observable success evidence:
List exact evidence that proves this step worked.

Correction triggers:
List conditions that require stopping only the unsafe or wrong executor path, recording evidence, fixing, or returning to source discovery. These are not supervisor stop states and not user-response gates.

Estimated runtime:
Write the expected runtime or "unknown until source discovery".

Review requirement:
State what fresh no-context reviewers must check before the next spec starts.
