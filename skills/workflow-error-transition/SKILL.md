---
name: workflow-error-transition
description: Use when Codex hits an error, failed command, failed test, bad run, unexpected result, blocked state, bug, crash, timeout, low performance, wrong output, repeated failure, or uncertainty after trying an implementation. Also use when Codex is deciding whether to retry the current fix, inspect logs, return to source discovery, search the repository, search official or external sources, change the plan, or abandon the current idea. Do not use for ordinary planning before any error or failed result happened.
---

# Workflow Error Transition

Use this skill immediately after an error or failed result.

Source discovery means collecting facts from local files, logs, command output, documentation, or allowed external sources before choosing or changing an implementation idea.

## Preserve Role

Keep the role you already have. This skill only decides the next workflow state. It does not expand permissions.

- If you are the supervisor Codex, inspect evidence and send corrections. Do not do the executor's task.
- If you are the executor Codex, fix the assigned task within the current goal and constraints.

## Decision Rule

Stay on the current path when the idea is still supported by evidence and the failure looks like an implementation mistake, command mistake, small bug, missing dependency, flaky test, fixable environment issue, or known performance problem.

Return to source discovery when the failure suggests the idea may be wrong, the cause is unknown, the same fix failed repeatedly, or the next action would require guessing.

## Current Path Fix

Do this when staying on the current path:

1. Record what failed.
2. Inspect direct evidence: logs, command output, changed files, tests, metrics, or screenshots.
3. Make the smallest fix that matches the current idea.
4. Rerun the relevant check.
5. Update evidence.

## Return To Discovery

Do this when returning to source discovery:

1. Stop changing implementation.
2. Write the unknown fact clearly.
3. Search the repository and existing files first.
4. Search allowed external sources when local files cannot answer it.
5. Update source discovery notes.
6. Update the plan only after new evidence is recorded.
7. Continue from the corrected plan.

## Must Return To Discovery

- The cause of the failure is unknown.
- The fix would require guessing an API behavior, file purpose, data format, benchmark meaning, user requirement, or external rule.
- The same fix failed repeatedly.
- The result suggests the chosen approach may not work.
- The task needs a new assumption before continuing.
- You want to replace the idea instead of fixing a known bug.

## Must Not Return To Discovery

- The error message directly identifies a simple fix.
- A test failure points to a specific expected behavior.
- The code path is understood and only the implementation is wrong.
- The command was malformed or missing a known dependency.
- A run is slow and logs already show the bottleneck.
- The current plan remains valid and only needs a local correction.

## Required Output Before Continuing

Write this short decision before the next action:

```text
Decision: retry current path | return to source discovery
Evidence: <what failed and what proves this decision>
Next action: <the exact next check or fix>
```
