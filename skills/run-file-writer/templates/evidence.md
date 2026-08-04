# Evidence

This file records proof that one spec succeeded or failed.

## Canonical Paths

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder before reporting completion. Use resolved absolute paths for every produced file, source file, log, and command working directory; bare control, workflow, spec, evidence, review, or status paths are invalid.

## Spec

Write the spec id and short name here.

## Commands And Results

List commands that prove progress or completion. Include exit codes and important output summaries.

## Files Produced Or Changed

List files produced or changed by this spec using resolved absolute paths.

## Metrics

List measured values required by this spec, such as runtime, ETA, GPU use, MFU, accuracy, pass rate, or loss.

## Git Evidence

Record checkpoint commit evidence when required:

```text
git status --short
git log -1 --oneline
git show --stat --oneline --name-status HEAD
```

## Result

Write PASS, FAIL, or INSUFFICIENT_INFORMATION. Missing information means return to source discovery and continue.

## What This Does Not Prove

State the limits of the evidence.
