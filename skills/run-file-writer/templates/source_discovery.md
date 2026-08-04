# Source Discovery

This file records the information collected before acting on a spec.

## Canonical Paths

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder before reporting completion. Record resolved absolute paths for every source; bare control, workflow, spec, evidence, review, or status paths are invalid.

## Spec

Write the spec id and short name here.

## Files Read

List local files and folders that were read. Include paths.

## Commands Run

List read-only or discovery commands that were run. Include the useful result.

## External Sources Read

List web pages, papers, docs, or repos read for this spec. Include URLs when used.

## Facts Learned

List facts that are directly supported by the sources above.

## Missing Information

List missing information that would require guessing. During execution, do not wait for a user response. Resolve each missing item through more local inspection, allowed external sources as defined in `{{CONTROL_ROOT}}/constraint.md`, or a conservative option as defined in `{{CONTROL_ROOT}}/constraint.md` and allowed by the active constraints, then record the resolution.

## Decision For This Spec

State whether the current information is enough to proceed, and name the next allowed action.
