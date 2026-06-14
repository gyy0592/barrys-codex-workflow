# Prompt For Run Prep

Use this template as the first message to a main Codex when the user wants preparation files before a long supervised run.

Replace every `<...>` field before use.

```text
/goal
You are preparing a supervised run. This is the preparation phase only.

Task directory:
<absolute task directory>

Workflow id:
<short run id>

User task:
<the user's task request>

Task material:
<absolute paths to task specs, notes, required skills, source files, papers, repos, or docs>

Workflow root:
<absolute path to codex_workflow_tmux>

Preparation rule:
- Create preparation files only.
- Do not start the controlled Codex.
- Do not send the short /goal message to a controlled Codex.
- Do not start long training, benchmark, experiment, data generation, or cloud jobs.
- Do not submit queue jobs.
- Do not make final task deliverables unless they are explicitly preparation files.
- Stop after the preparation files are written and report what the user must review.

Required preparation files:
- control/goal.md
- control/constraint.md
- workflow_<workflow id>/run_goal.md
- workflow_<workflow id>/specs.md

Use these templates from the workflow root:
- templates/goal.md
- templates/constraint.md
- templates/run_goal.md
- templates/specs.md
- templates/spec_status.md
- templates/source_discovery.md
- templates/abstract_plan.md
- templates/evidence.md
- templates/review.md
- templates/bitter_lesson.md

Preparation content rules:
- control/goal.md must tell the future controlled Codex what to do, what materials to read, what outputs to produce, what progress evidence to update, and what proves completion.
- control/constraint.md must contain all active user constraints, forbidden actions, checkpoint rules, review rules, and stop rules.
- workflow_<workflow id>/run_goal.md must preserve the user's task as a stable run description.
- workflow_<workflow id>/specs.md must split the task into checkable steps. Each step must have a purpose, required information, expected outputs, observable success evidence, and stop conditions.
- workflow_<workflow id>/specs.md must state that specs run one at a time, in order, and the next spec cannot start until the current spec has evidence, status, checkpoint commit, and required review.
- If a task step needs a per-step folder during execution, define the expected folder name and expected files in specs.md. Do not create execution evidence before the step actually runs.
- If the user gave a global requirement, put it in control/constraint.md and also mention which specs it affects.
- If source discovery finds missing information, record what is missing and what must be checked later. Do not guess.

Checkpoint rule:
- If there is existing completed work that must be preserved before the next run, inspect git status, stage only relevant stable files, and create a checkpoint commit before writing new run-prep files.
- Do not stage unrelated files.
- If unrelated files cannot be separated safely, stop and report the exact paths.

Review-before-execution rule:
- After writing the preparation files, stop.
- Do not start execution.
- Report the file list and the specific parts the user should review.
- The long run may start only after the user explicitly approves the preparation files.
```
