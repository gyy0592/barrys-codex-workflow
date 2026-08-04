# Spec Status

## Canonical Paths

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder before reporting completion. Any cross-file reference in this status file must use a resolved absolute path from this map.

Status: not_started

Allowed status values:

- not_started
- in_progress
- failed
- needs_correction
- done

## Current Spec

Write the spec id and short name here.

## Last Evidence Check

Write the latest evidence checked and the result.

## Current Executor Correction Issue

Write "none" or the exact missing information, failed command, failed check, unsafe path, or control-file conflict being corrected. This is a local executor issue, not a supervisor stop state and not a request for the user. After final run files are written, the next action must continue the workflow.

## Next Action

Write the next allowed action. It must follow the spec and constraints.
