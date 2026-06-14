# Prompt For Run Prep

Use this template as the first message to a main Codex when the user wants final run files before a long supervised run.

Replace every `<...>` field before use.

```text
/goal
You are writing final run files for a supervised run. This is not the execution phase.

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

Run-file creation rule:
- Create final run files only.
- Do not start the controlled Codex.
- Do not send the short /goal message to a controlled Codex.
- Do not start long training, benchmark, experiment, data generation, or cloud jobs.
- Do not submit queue jobs.
- Do not make final task deliverables unless they are explicitly run files.
- Stop after the run files are written and report the file list and autonomy checks.

Required run files:
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

Run-file content rules:
- control/goal.md must tell the future controlled Codex what to do, what materials to read, what outputs to produce, what progress evidence to update, and what proves completion.
- control/constraint.md must contain all active user constraints, forbidden actions, checkpoint rules, review rules, and stop rules.
- workflow_<workflow id>/run_goal.md must preserve the user's task as a stable run description.
- workflow_<workflow id>/specs.md must split the task into checkable steps. Each step must have a purpose, required information, expected outputs, observable success evidence, and stop conditions.
- workflow_<workflow id>/specs.md must state that specs run one at a time, in order, and the next spec cannot start until the current spec has evidence, status, checkpoint commit, and required review.
- If a task step needs a per-step folder during execution, define the expected folder name and expected files in specs.md. Do not create execution evidence before the step actually runs.
- If the user gave a global requirement, put it in control/constraint.md and also mention which specs it affects.
- If source discovery finds missing information, record what is missing and what must be checked later. Do not guess.
- Do not write user-review, user-choice, or user-approval gates into durable run files.
- Final run files must be complete enough for autonomous execution.
- After execution starts, the controlled Codex must not ask for choices, approvals, or review. If information is missing, it must return to source discovery, inspect files and outputs, use allowed external sources, choose a conservative option within constraints, record the reason in evidence, and continue.

File ownership and priority rules:
- Supervisor-only files are `prompt_for_supervisor.md`, `prompt_for_supervisor_goal.md`, and staged paste files.
- Controlled-execution files are `control/goal.md`, `control/constraint.md`, and current spec files.
- Shared evidence files are `run_goal.md`, `specs.md`, `evidence.md`, `status.md`, and review files.
- For execution, use this priority: latest user instruction written into control files > control/constraint.md > control/goal.md > current spec.md > specs.md > run_goal.md.
- Task-preparation notes mean task-internal work such as collecting data, downloading files, checking environment state, or reading sources. They do not mean asking the user.

Template heading risk check:
- Check every heading in the generated run files before reporting.
- Remove or rewrite any heading that can be treated as a runtime stop condition.
- Remove or rewrite any heading that conflicts with control/constraint.md.
- Remove or rewrite any heading that asks for user review, choices, or approval after durable run files are written.

Checkpoint rule:
- If there is existing completed work that must be preserved before the next run, inspect git status, stage only relevant stable files, and create a checkpoint commit before writing new run-prep files.
- Do not stage unrelated files.
- If unrelated files cannot be separated safely, stop and report the exact paths.

Run-file finalization rule:
- After writing the run files, stop.
- Do not start execution.
- Report the file list and the autonomy checks performed.
- A later execution request starts the long run. Do not encode a review or approval gate in durable run files.
```
