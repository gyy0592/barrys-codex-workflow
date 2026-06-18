# Minimal Subgoal Workflow

This file is a minimal specific workflow for one class of tasks. It is not a new skill. After the main Codex reads this file, it uses the existing `tmux-codex-supervisor` tooling to control the controlled Codex running inside tmux.

## 1. Whether The Requirement Is Clear Enough

The requirement is clear enough for a minimal version.

The current known facts are:

- The user will provide one overall goal.
- The overall goal will be split into multiple specs.
- A spec is a small goal that can be completed independently. It can also be understood as a subgoal.
- Each spec must have an observable variable.
- An observable variable is evidence that the main Codex can check, such as whether a file exists, whether a test passes, whether command output contains specific text, or whether screen output shows a specific state.
- A full plan does not need to be fixed in advance, because `/goal` lets the controlled Codex generate a plan dynamically.
- Before each spec starts, source discovery is required.
- Source discovery is the information collection stage. Its goal is to collect the files, project knowledge, and internet information needed to complete that spec.
- Source discovery results must be written into the current run directory.
- Each spec needs a short high-level abstract plan.
- A high-level abstract plan is a set of high-level steps. It gives direction without writing fragile details.
- If information is insufficient, the workflow must return to source discovery instead of guessing.
- If a reusable error or misunderstanding is found, it must be written as a bitter lesson.
- A spec can be checked off only after evidence passes. Then the workflow may move to the next spec.
- After each spec is complete, a checkpoint commit is required.
- After each checkpoint commit, the main Codex must start two parallel no-context subagents to review git status, git diff, git commit, spec evidence, goal, and constraint.
- The workflow may move to the next spec only after review passes.

The main Codex must decide these facts dynamically for each run:

- How to name the run id.
- Which specs the overall goal should be split into.
- What observable variable each spec should use.
- Which files, project knowledge, or internet information each spec must collect.
- Which completion check command each spec should use.

## 2. Roles

The main Codex is the supervisor in the current chat. The main Codex reads this workflow file, prepares control files, starts or controls tmux, checks evidence, corrects drift, and decides whether the run may move to the next spec.

The controlled Codex is the executor inside the tmux window. The controlled Codex does the real work required by the current spec.

The main Codex does not directly complete tasks assigned to the controlled Codex. The main Codex only supervises, corrects, and accepts or rejects completion.

## 3. Directory Layout

Each run creates one run directory:

```text
workflow_<run_id>/
  run_goal.md
  spec_001_<task_name>/
    spec.md
    source_discovery.md
    abstract_plan.md
    evidence.md
    status.md
    review.md
  spec_002_<task_name>/
    spec.md
    source_discovery.md
    abstract_plan.md
    evidence.md
    status.md
    review.md
  bitter_lesson/
    lesson_<short_name>.md
```

`workflow_<run_id>/run_goal.md` records the overall goal and spec list for this run.

`spec.md` records the current spec goal, constraints, and observable variable.

`source_discovery.md` records information collected to complete the current spec.

`abstract_plan.md` records the current spec's short high-level plan.

`evidence.md` records the current spec's evidence, check method, and check result.

`status.md` records whether the current spec is complete. It may contain only `pending`, `in_progress`, `blocked_missing_information`, or `done`.

`review.md` records no-context subagent review results for the current spec, git diff, git commit, and evidence.

`bitter_lesson/` records reusable error knowledge found during this run.

## 4. Required Spec Content

Each spec must use this structure:

```text
# Spec

## Subgoal
Write the small goal this spec must complete.

## Observable Variable
Write the observable variable.

## Pass Condition
Write the evidence that counts as passing.

## Fail Condition
Write what counts as failure or drift.

## Required Source Discovery
Write the types of information that must be collected before work starts.

## Completion Check
Write how the main Codex checks completion.
```

A spec must not only say something uncheckable such as "finish a feature." It must answer:

- What must be completed?
- What evidence must be checked?
- What counts as passing?
- What counts as failure?
- Where should the run return when information is missing?

## 5. Stages For Each Spec

### Stage 1: Source Discovery

Goal: collect information required to complete the current spec.

The main Codex must require the controlled Codex to collect information first. The controlled Codex must not start implementation directly.

Information sources include:

- Related files in the current project.
- Existing tests, scripts, configuration, and documentation in the current project.
- Materials explicitly provided by the user.
- Internet information when the task requires current or external facts.

Collected results must be written to:

```text
workflow_<run_id>/spec_<number>_<task_name>/source_discovery.md
```

`source_discovery.md` must state:

- Which files were inspected.
- Which command outputs were inspected.
- Which external sources were inspected.
- What action each finding supports.
- What uncertainty remains.

Conditions for entering the next stage:

- The current spec can proceed without guessing.
- Required files have been inspected.
- Required knowledge has been recorded.
- Required internet information has been collected and recorded when internet information is needed.

If these conditions are not met, the run must not enter the execution stage.

### Stage 2: Abstract Plan

Goal: write a short high-level plan that guides how the current spec will be done.

The plan is written to:

```text
workflow_<run_id>/spec_<number>_<task_name>/abstract_plan.md
```

The plan must be:

- Short.
- High-level.
- Free of fragile details that may become stale.
- Clear about what is evidence and what is not known.
- Focused only on the current spec.

Example:

```text
1. Use source discovery to confirm the smallest required change area.
2. Modify only the files directly required by the current spec.
3. Run the completion check.
4. If the check fails, use failure evidence to return to source discovery or fix the implementation.
```

### Stage 3: Execute

Goal: the controlled Codex does real work based on the current spec and abstract plan.

During execution:

- Every action must serve the current spec.
- The controlled Codex must not do tasks outside the current spec.
- The controlled Codex must not fill missing information by guessing.
- When information is insufficient, the run must return to Stage 1 immediately.
- When a reusable error is found, the controlled Codex must write a bitter lesson.

### Stage 4: Evidence Check

Goal: the main Codex checks whether the current spec is complete.

Evidence is written to:

```text
workflow_<run_id>/spec_<number>_<task_name>/evidence.md
```

`evidence.md` must state:

- What was checked.
- Which command or file was used for the check.
- What result was expected.
- What result actually occurred.
- Whether the conclusion is pass, fail, or insufficient information.

If evidence passes, the main Codex writes this value in the current spec's `status.md`:

```text
done
```

If evidence fails, the main Codex requires the controlled Codex to fix the current spec.

If the failure is caused by insufficient information, the main Codex must require the controlled Codex to return to Stage 1.

### Stage 5: Checkpoint Commit

Goal: save the completed current spec with passing evidence into git history.

A checkpoint commit is a stage-level git commit. It gives long tasks a recoverable and reviewable save point after each stable stage.

A checkpoint commit is allowed only after the current spec's evidence passes.

Before committing, the controlled Codex must:

1. Run `git status --short`.
2. Separate files required by the current spec from unrelated files.
3. Stage only files required by the current workflow.
4. Avoid staging experiment outputs that are still changing.
5. Avoid staging unrelated user changes.
6. Stop and report the exact files if the files cannot be separated safely.

After committing, the controlled Codex must write this evidence to the current spec's `evidence.md`:

```text
git status --short
git log -1 --oneline
git show --stat --oneline --name-status HEAD
```

### Stage 6: Parallel No-Context Review

Goal: have subagents without the current long chat context review whether the current spec is truly complete. This prevents the main Codex and controlled Codex from missing errors because both share the same long context.

A no-context subagent is a fresh review agent. It receives only the files, git evidence, and review instructions required for the current spec. It should not depend on the main Codex's chat context.

After each checkpoint commit, the main Codex must start two no-context subagents in parallel:

1. `implementation_goal_review`: checks whether the current spec was implemented correctly and whether it drifted from `control/goal.md` or the current spec.
2. `constraint_review`: checks whether the current spec violated `control/constraint.md`, global user requirements, git rules, or workflow rules.

Both subagents must review independently. The second subagent must not read the first subagent's conclusion.

The main Codex must give both subagents these materials:

- The current spec's `spec.md`.
- The current spec's `source_discovery.md`.
- The current spec's `abstract_plan.md`.
- The current spec's `evidence.md`.
- The current spec's `status.md`.
- `control/goal.md`.
- `control/constraint.md`.
- Changed files related to the current spec.
- `git status --short`.
- `git diff HEAD^ HEAD`.
- `git show --stat --oneline --name-status HEAD`.
- `git log --oneline -5` when needed so the reviewer can inspect recent checkpoint order.

`implementation_goal_review` must check:

- Whether the current spec was implemented according to `spec.md`.
- Whether source discovery is sufficient to support execution.
- Whether the abstract plan is short and high-level.
- Whether evidence proves the pass condition.
- Whether status is set to `done` only after evidence passes.
- Whether the current spec drifted from `control/goal.md`.
- Whether the current commit contains the files the current spec should produce.

`constraint_review` must check:

- Whether the current spec violated `control/constraint.md`.
- Whether the current spec violated global user requirements.
- Whether the current commit contains only files required by the current workflow.
- Whether the current commit mixed in unrelated user changes.
- Whether the current commit staged experiment outputs that are still changing.
- Whether the current spec skipped checkpoint commit, review, source discovery, evidence, or another workflow rule.

Review results must be written to:

```text
workflow_<run_id>/spec_<number>_<task_name>/review_implementation_goal.md
workflow_<run_id>/spec_<number>_<task_name>/review_constraint.md
workflow_<run_id>/spec_<number>_<task_name>/review.md
```

Each child review file must contain:

```text
# Review

## Review Type
implementation_goal_review or constraint_review

## Result
PASS or FAIL

## Checked
Write which files, commands, and commit were reviewed.

## Findings
Write the findings. If there are no findings, write none.

## Required Fix
If the result is FAIL, write what must be fixed.
```

`review.md` is the summary file written by the main Codex. It must include both child review results, the overall conclusion, and whether the workflow may move to the next spec.

If either child review is `FAIL`, the overall `review.md` must be `FAIL`. The main Codex must require the controlled Codex to fix the current spec, create a new checkpoint commit, and run two new no-context subagent reviews in parallel.

Only when both child reviews are `PASS` may the overall `review.md` be `PASS`, and only then may the main Codex move to the next spec.

## 6. Missing Information Rule

Information is missing when the next action would require guessing a fact, a file purpose, an interface behavior, or an external rule.

When information is missing:

1. Stop the current implementation action.
2. Write the uncertainty in the current spec's `source_discovery.md`.
3. Collect information that can resolve the uncertainty.
4. Update `source_discovery.md`.
5. Update `abstract_plan.md` when needed.
6. Continue execution only after that.

Forbidden actions:

- Guess an implementation first and see what happens.
- Continue only because something looks reasonable.
- Write unsupported inference as fact.

## 7. Bitter Lesson Rule

A bitter lesson must be written when any of these happen:

- The user's requirement is misunderstood.
- Work is done outside the current spec.
- Existing files or existing rules are ignored.
- Missing source discovery causes rework.
- An error is likely to repeat in the future.
- A checkpoint commit includes unrelated files.
- A no-context subagent review fails.

Write it to:

```text
workflow_<run_id>/bitter_lesson/lesson_<short_name>.md
```

Each bitter lesson must contain:

```text
# Lesson

## What Happened
Write what happened.

## Why It Happened
Write why it happened.

## Prevention
Write how to avoid it in the future.
```

## 8. How The Main Codex Supervises

The main Codex uses the existing `tmux-codex-supervisor` as the base.

Minimal supervision flow:

1. The main Codex reads this workflow file.
2. The main Codex splits the overall goal into specs.
3. The main Codex creates `workflow_<run_id>/`.
4. The main Codex writes `spec.md` for the first spec.
5. The main Codex writes the current spec and this workflow's key rules into `control/goal.md` and `control/constraint.md`.
6. The main Codex starts the controlled Codex inside tmux.
7. The main Codex sends the short `/goal`.
8. The main Codex confirms that the controlled Codex received the message.
9. The main Codex checks whether the controlled Codex starts with source discovery.
10. If the controlled Codex starts implementation directly, the main Codex corrects it immediately.
11. The main Codex checks each spec's evidence.
12. After evidence passes, the main Codex requires the controlled Codex to create a checkpoint commit.
13. The main Codex starts two no-context subagents in parallel to review the current spec, goal, constraint, git diff, git commit history, and evidence.
14. After both child reviews pass and the overall `review.md` is `PASS`, the main Codex marks the current spec as `done`.
15. The main Codex moves to the next spec.
16. After all specs are `done`, the main Codex performs final acceptance against the overall goal.

## 9. Minimal Content For Control Files

`control/goal.md` must contain at least:

- The overall goal for this run.
- The current spec.
- The current spec's observable variable.
- The current spec's pass condition.
- The current spec's fail condition.
- The current spec's completion check.
- The current run directory path.
- A checkpoint commit is required after each spec is complete.
- Two parallel no-context subagent reviews are required after each checkpoint commit.
- The workflow may move to the next spec only after both child reviews pass and the overall `review.md` summarizes `PASS`.

`control/constraint.md` must contain at least:

- The controlled Codex must do source discovery first.
- The controlled Codex must write collected information to the current spec's `source_discovery.md`.
- The controlled Codex must write a short `abstract_plan.md` before execution.
- The controlled Codex must return to source discovery when information is missing.
- The controlled Codex must write a bitter lesson when it finds a reusable error.
- The controlled Codex must not do tasks outside the current spec.
- The controlled Codex must not treat guesses as facts.
- The controlled Codex must create a checkpoint commit after completing the current spec.
- Before committing, the controlled Codex must stage only files required by the current workflow.
- The controlled Codex must not stage unrelated user changes.
- The controlled Codex must not stage experiment outputs that are still changing.
- The main Codex must start two no-context subagents in parallel after each checkpoint commit.
- One subagent reviews whether spec implementation is correct and whether it drifted from `control/goal.md`.
- One subagent reviews whether the work violated `control/constraint.md`, global user requirements, git rules, or workflow rules.
- If review fails, the controlled Codex must fix the issue and commit again.

## 10. Minimal Startup Message

The main Codex may understand the following content as part of the user request:

```text
Use tmux-codex-supervisor as the base supervisor.
Also follow specific workflow/minimal_subgoal_workflow.md.

Create a workflow_<run_id>/ directory in the task project.
Split the goal into specs.
For each spec, require source discovery first, then a short high-level abstract plan, then execution, then evidence check.
After each spec passes evidence, require a checkpoint git commit.
After each checkpoint commit, run two parallel no-context subagent reviews.
One reviewer checks correct spec implementation and drift from control/goal.md.
The other reviewer checks violations of control/constraint.md, global user requirements, git rules, and workflow rules.
Both reviewers must inspect spec evidence, git diff, git status, latest commit, and recent commit history when needed.
Only move to the next spec after both no-context reviews pass and review.md summarizes PASS.
If information is missing, return to source discovery.
If a reusable mistake is found, write it to workflow_<run_id>/bitter_lesson/.
Only mark a spec done when its observable variable proves success.
```

## 11. Minimal Completion Standard

One run of this workflow is complete only when all of these are true:

- `workflow_<run_id>/run_goal.md` exists.
- Each spec has its own directory.
- Each spec has `spec.md`.
- Each spec has `source_discovery.md`.
- Each spec has `abstract_plan.md`.
- Each spec has `evidence.md`.
- Each spec has `review_implementation_goal.md`.
- Each spec has `review_constraint.md`.
- Each spec has `review.md`.
- Each spec's `status.md` is `done`.
- Each completed spec has checkpoint commit evidence.
- Each checkpoint commit has two no-context subagent `PASS` reviews.
- Each spec's overall `review.md` summarizes both child reviews and has result `PASS`.
- If a reusable error happened during the run, `bitter_lesson/` contains a record.
- The main Codex's final report cites evidence instead of guesses.
