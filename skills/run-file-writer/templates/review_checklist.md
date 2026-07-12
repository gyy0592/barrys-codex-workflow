# Review Checklist

This file is the required checklist for one spec. It must be filled before implementation, updated after `abstract_plan.md`, checked before any expensive run, and used by every fresh no-context reviewer.

## Spec

Write the spec id and short name here.

## Requirement Sources

List every source used to build this checklist. Include only sources that apply to the current run.

- Current global and project instruction files available to this task, such as active agent instruction files.
- `control/goal.md`
- `control/constraint.md`
- `workflow_<workflow id>/run_goal.md`
- `workflow_<workflow id>/specs.md`
- Current spec `source_discovery.md`
- Current spec `abstract_plan.md`
- Current spec `evidence.md`
- Current git evidence and run outputs when reviewing observed evidence.

## Extraction Rule

Extract requirements as checklist rows. Do not summarize several independent requirements into one row when separate evidence could pass or fail independently.

Every row must include:

- a stable id;
- the exact requirement in plain language;
- the source path, section, line, or instruction source;
- the evidence required to prove it;
- the observed evidence path or command output;
- `PASS`, `FAIL`, `INSUFFICIENT_INFORMATION`, or `NOT_APPLICABLE`;
- blocker or next action.

## Mandatory Global Rows

Every spec must include rows for these generic gates when applicable:

- latest user requirement and task-boundary compliance;
- zero-assumption evidence for key factual conclusions;
- no replacement, weakening, bypassing, or reinterpretation of user-required methods, tools, metrics, outputs, limits, original repository capabilities, accelerated paths, or high-performance implementations;
- original-path failure handling when a required method or accelerated/high-performance path fails: command, working location, exit result, complete error source, environment/dependency/path/version/compatibility inspection, fix, and rerun evidence;
- no completion claim without observable evidence;
- no skipped tests or skipped required checks hidden as success;
- no unrelated file changes or commit pollution;
- no future-spec work before current-spec gates pass.

## Checklist Table

| id | requirement | source | required evidence | observed evidence | result | blocker or next action |
| --- | --- | --- | --- | --- | --- | --- |
| G-001 | Latest user requirement and task boundary are followed. | Current user/control sources | Response/actions/diff map only to current task. | TODO | INSUFFICIENT_INFORMATION | Fill before review. |

## Expensive-Run Gate

Before any expensive, long-running, paid, GPU, cloud, destructive, or hard-to-reverse action, every applicable checklist row that controls that action must be `PASS`. If any applicable row is `FAIL` or `INSUFFICIENT_INFORMATION`, stop that run path, record the missing evidence, and return to source discovery or correction.

## Review Gate

Fresh no-context reviewers must fill or verify this checklist row by row. A reviewer may not return overall `PASS` while any applicable row is `FAIL` or `INSUFFICIENT_INFORMATION`.
