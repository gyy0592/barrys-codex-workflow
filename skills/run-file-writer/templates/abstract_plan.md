# Abstract Plan

This plan is for one spec. Keep it short and high level so execution can adapt to real evidence.

## Canonical Paths

TASK_ROOT: {{TASK_ROOT}}
WORKFLOW_ROOT: {{WORKFLOW_ROOT}}
CONTROL_ROOT: {{CONTROL_ROOT}}
CURRENT_SPEC_ROOT: {{CURRENT_SPEC_ROOT}}

Replace every path placeholder before reporting completion. Record resolved absolute paths for every referenced file; bare control, workflow, spec, evidence, review, or status paths are invalid.

## Spec

Write the spec id and short name here.

## Goal

State what this spec must accomplish.

## Direct Prerequisites

Write `depends_on`, the concrete prerequisite files/interfaces/tests, the verification command, the pass condition, and the release condition for each direct dependent.

## Steps

1. Write the first high-level step.
2. Write the second high-level step.
3. Write the final verification step.

## Evidence To Produce

List the evidence files, command outputs, logs, metrics, or commits this spec must produce.

## Stop Or Replan Conditions

List conditions that require stopping the bad path, returning to source discovery, or choosing a conservative option defined in `{{CONTROL_ROOT}}/constraint.md` and allowed by the active constraints.
