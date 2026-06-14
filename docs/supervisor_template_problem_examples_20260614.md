# Supervisor Template Problem Examples

## Purpose

This document records concrete failures found while using the tmux supervisor workflow on the Physics for LLM worktrees.

The goal is to make future template and skill fixes easier to understand. Each problem includes a concrete example, because abstract rules alone were too easy to misread.

## Problem 1: `User Review Points` Looks Like A Runtime Stop Gate

### What Happened

The `run_goal.md` template contains:

```md
## User Review Points

List the parts the user must review before execution starts.
```

The intended meaning was preparation-time review only. The controlled Codex interpreted it as a runtime stop condition.

### Concrete Example

In `/home/barry/github_repo/physics_for_llm_experiments`, Spec 007 stopped with:

```text
status.md: blocked_missing_information
evidence.md: Status: blocked by required user choices.
```

It stopped before formal hidden-state collection because `run_goal.md` listed these user review points:

- formal sample count,
- hidden-state layers,
- whether to save full logits,
- maximum disk space.

The user had already approved the overall run and later explicitly told the system to continue with:

- 4096 samples,
- last hidden-state layer only,
- no full logits,
- 10G disk limit.

### Why This Is Bad

The field turned a preparation-time note into an execution-time stop.

### Fix Direction

Remove `User Review Points` from the run-goal template, or replace it with language that cannot become a runtime gate.

If the field remains, it must say:

```text
These are preparation-phase notes only. After the user approves execution, this section must not create runtime stop conditions.
```

## Problem 2: Shared Files Do Not Define File Ownership

### What Happened

Some files are read by both the supervisor and the controlled Codex, but the workflow does not clearly state who may act on them and how conflicts are resolved.

### Concrete Example

Both the supervisor and controlled Codex read:

- `control/goal.md`
- `control/constraint.md`
- `workflow_.../run_goal.md`
- `workflow_.../specs.md`
- current spec files

The controlled Codex treated `run_goal.md` review notes as a stop condition. The supervisor expected `control/constraint.md` and the approved goal to control execution.

### Why This Is Bad

When a shared file contains ambiguous text, the controlled Codex may invent a stronger rule than the supervisor intended.

### Fix Direction

Add a file ownership section to the workflow and templates:

- Supervisor-only files:
  - `prompt_for_supervisor.md`
  - `prompt_for_supervisor_goal.md`
  - staged paste files such as `stage_supervisor_goal_to_paste.md`
- Controlled-execution files:
  - `control/goal.md`
  - `control/constraint.md`
  - current spec files
- Shared evidence files:
  - `run_goal.md`
  - `specs.md`
  - `evidence.md`
  - `status.md`
  - review files

For shared files, define:

- who reads,
- who writes,
- who checks,
- which file wins when two files conflict.

Recommended priority:

```text
control/constraint.md > control/goal.md > current spec.md > specs.md > run_goal.md
```

Preparation notes must never override runtime constraints.

## Problem 3: The Skill Acts Like One Large Template Instead Of A Router

### What Happened

The main skill gives broad preparation and monitoring rules. It does not route to smaller task-specific helpers.

### Concrete Example

When preparing the hidden-state data workflow, the assistant first proposed a spec called `define_research_data_schema`, even though the user had already specified the data to collect:

- first output token hidden state,
- entropy chain,
- hidden-state trajectory,
- correct and wrong answer labels,
- parser result,
- clustering and variance-ready data.

The user wanted those fields written directly into goal and specs, not rediscovered by a later spec.

### Why This Is Bad

The workflow wasted a spec on rephrasing user intent instead of producing executable work.

### Fix Direction

Split the skill into a router plus sub-skills:

- `gen-goal`
- `gen-constraint`
- `gen-specs`
- `gen-supervisor-prompts`
- `review-prep-files`
- `start-supervised-run`
- `monitor-run`

The router decides which sub-skill applies. The sub-skills enforce sharper rules.

## Problem 4: `gen-specs` Needs A Rule For Already-Decided User Content

### What Happened

The current template does not force the preparer to distinguish decided user requirements from unknown information.

### Concrete Example

The user had already decided that the first data workflow should collect hidden-state generation data. The assistant still suggested a spec to define the schema.

### Why This Is Bad

It lets the controlled Codex reopen decisions that the user already made.

### Fix Direction

Add this rule to the future `gen-specs` helper:

```text
If the user already specified a data field, setting, output, or constraint, write it directly into goal/specs. Do not create a spec whose purpose is to decide it again.
```

Specs should be executable work, not re-discussion.

## Problem 5: Preparation Review Is Not Separated From Runtime Stop Conditions

### What Happened

The workflow says preparation files wait for user review. It does not make a strong enough separation between review before execution and stopping during execution.

### Concrete Example

The hidden-state workflow had preparation review questions about formal collection settings. During Spec 007, the controlled Codex stopped because it treated those questions as unresolved runtime choices.

### Why This Is Bad

The user expects everything to be discussed before execution. After execution starts, the controlled Codex should keep going unless `control/constraint.md` explicitly says to ask the user.

### Fix Direction

Add this rule:

```text
After the user approves execution, only `control/constraint.md` stop-to-ask-user conditions may stop for user input.
Preparation review notes do not create runtime stop conditions.
```

## Problem 6: Supervisor Persistence Must Be Present In Every Actual Start Path

### What Happened

The supervisor prompt templates contain persistence rules, but actual run-start files or project-specific prompts may not always carry the same wording.

### Concrete Example

The desired rule is:

```text
The supervisor must not mark its own goal blocked because the controlled Codex reports blocked, a run fails, information is missing, or a review fails.
```

If the supervisor starts from a shorter prompt that omits this rule, it may stop supervising instead of forcing the controlled Codex to return to source discovery, update the spec, create a fix spec, or continue the allowed correction loop.

### Why This Is Bad

The controlled Codex can get blocked and the supervisor can incorrectly treat that as the supervisor goal being blocked.

### Fix Direction

Require every supervisor start prompt, short prompt, and staged paste file to include the persistence rule.

Tests should check for the exact idea, not only one wording.

## Problem 7: Later User Requirements Must Be Written Into Durable Control Files

### What Happened

Runtime user instructions can fix a blocked state, but if they are not written into `control/goal.md` or `control/constraint.md`, the next restart may lose them.

### Concrete Example

The user later approved the hidden-state formal collection settings:

- 4096 samples,
- last hidden-state layer only,
- no full logits,
- 10G disk limit.

That had to be added to `control/constraint.md` as `Formal Collection Approval Override`; otherwise the controlled Codex could keep stopping for approval.

### Why This Is Bad

Chat memory is not durable. Restarted agents read files.

### Fix Direction

Add this rule:

```text
If a user message changes execution permission, stop conditions, required settings, or completion criteria, write it into the active control files before relying on it.
```

## Problem 8: Template Fields Are Not Reviewed For Misinterpretation Risk

### What Happened

The preparation templates contain fields that are semantically ambiguous.

### Concrete Example

`User Review Points` was intended as preparation review, but it sounded like a required runtime checkpoint.

### Why This Is Bad

Ambiguous labels become hard gates during long autonomous runs.

### Fix Direction

Add a template-review step that checks each heading:

- Can a controlled Codex treat this as a runtime stop condition?
- Can this conflict with `control/constraint.md`?
- Does this ask the user again after execution has already started?

Remove or rewrite any heading that fails.

## Problem 9: There Is No Dedicated Preparation-File Review Step

### What Happened

Preparation files can be syntactically complete but semantically dangerous.

### Concrete Example

The hidden-state preparation files were complete, but the `User Review Points` section caused Spec 007 to stop.

### Why This Is Bad

The workflow checked whether files existed, but not whether they would create unwanted stops.

### Fix Direction

Add a `review-prep-files` helper that checks:

- no user-decided requirement is rewritten as undecided,
- no preparation note becomes a runtime stop,
- file ownership is clear,
- supervisor-only files are not sent to the controlled Codex,
- controlled files do not depend on supervisor chat memory,
- goal, constraint, specs, and run goal do not conflict.

## Problem 10: Shared Files Need Interpretation Priority

### What Happened

The workflow did not clearly say which file wins when shared files conflict.

### Concrete Example

`run_goal.md` suggested formal settings needed user review. `control/constraint.md` later said formal collection was approved and should continue. The controlled Codex needed a clear priority rule.

### Why This Is Bad

Without priority, an older review note can override a newer control-file instruction.

### Fix Direction

Add a priority rule:

```text
For execution, use this priority:
1. Latest user instruction written into control files.
2. control/constraint.md
3. control/goal.md
4. current spec.md
5. specs.md
6. run_goal.md

If a lower-priority file appears to require stopping, but a higher-priority control file authorizes continuation, continue and record the reason in evidence.
```

