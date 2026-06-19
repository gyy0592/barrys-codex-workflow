# Evidence

This file records proof that one spec succeeded or failed.

## Spec

Write the spec id and short name here.

## Commands And Results

List commands that prove progress or completion. Include exit codes and important output summaries.

## Files Produced Or Changed

List files produced or changed by this spec.

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
