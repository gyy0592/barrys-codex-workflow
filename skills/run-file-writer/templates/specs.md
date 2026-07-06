# Specs

Each spec is one checkable task step. A spec is complete only when its evidence proves its success standard and its review passes. A spec is not complete if the executor changes, weakens, bypasses, replaces, or reinterprets any user-required method, tool, function, metric, output, or constraint. Difficulty, repeated failed attempts, slower speed, missing adapter code, or implementation complexity does not prove the user requirement is wrong. The executor must keep fixing the implementation until the required result is achieved, unless evidence proves the required thing does not exist or cannot work as stated and the failure is not caused by executor implementation error.

Specs run one at a time, in order. The next spec cannot start until the current spec has evidence, status, fresh no-context Codex subagent review of the current `git diff` using `gpt5.4 high`, checkpoint commit, and required review. Do not combine multiple specs into one checkpoint commit or one review.

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
