# Prompt For Run Prep

Use this template as the first message to a main Codex when the user wants final run files before a long supervised run.

Replace every `<...>` and `{{...}}` field before use. The final run files must contain resolved absolute paths, not placeholders.

```text
You are writing final run files for a supervised run. This is not the execution phase.

Task directory:
<absolute task directory>

TASK_ROOT:
<same absolute task directory>

Workflow id:
<short run id>

User task:
<the user's task request>

Task material:
<absolute paths to task specs, notes, required skills, source files, papers, repos, or docs>

Workflow root:
<absolute path to the current workflow directory>

WORKFLOW_ROOT:
<same absolute workflow directory>

CONTROL_ROOT:
<absolute path to the task directory's control directory>

CURRENT_SPEC_ROOT:
<absolute path to the current spec directory; write one concrete value in each per-spec file>

RUN_FILE_WRITER_ROOT:
<absolute path to /home/yguo173/.codex/skills/run-file-writer>

Path rule:
- Every final run file must contain its applicable resolved path map near the beginning.
- Every actionable cross-file reference must use a resolved absolute path from that map.
- Never write bare `control/goal.md`, `control/constraint.md`, `specs.md`, `review.md`, `status.md`, or `workflow_<workflow id>/...` as an executable path.
- A basename may appear only after its canonical absolute path has been written as the same file's label.

Run-file creation rule:
- Create final run files only.
- Do not start the controlled Codex.
- Do not send the short /goal message to a controlled Codex.
- Do not start long training, benchmark, experiment, data generation, or cloud jobs.
- Do not submit queue jobs.
- Do not make final task deliverables unless they are explicitly run files.
- These "do not start" and "do not submit" rules apply only to the main Codex during run-file creation. They must not be copied into executor runtime files as a ban on executor work.
- If the future task requires training, jobs, experiments, final outputs, or other task submissions, write that the controlled Codex must do them during execution under `<absolute CONTROL_ROOT>/goal.md` and `<absolute CONTROL_ROOT>/constraint.md`.
- Stop after the run files are written and report the file list and autonomy checks.

Requirement dialogue rule:
- Before writing run files, create and maintain `<absolute WORKFLOW_ROOT>/requirement_dialogue.md`.
- Every time Codex asks the user whether the task should be one way or another way, append the question, the user's answer, and the updated conclusion to `<absolute WORKFLOW_ROOT>/requirement_dialogue.md`.
- Ask clarification questions until the goal, constraints, task material, output, success checks, and spec list are clear enough to write final run files.
- If the user has not already said to start writing run files, ask whether Codex should start writing the run files now.
- Before writing run files, reread `<absolute WORKFLOW_ROOT>/requirement_dialogue.md` and check for conflicts. A conflict means an earlier requirement says one thing and a later requirement changes it.
- The latest user answer wins, but Codex must report the conflict and ask the user to confirm the removal or replacement of the older requirement before writing run files.
- Do not write run files until `<absolute WORKFLOW_ROOT>/requirement_dialogue.md` has no unresolved conflicts and the user has confirmed that run-file writing may begin.

Required run files:
- <absolute CONTROL_ROOT>/goal.md
- <absolute CONTROL_ROOT>/constraint.md
- <absolute WORKFLOW_ROOT>/run_goal.md
- <absolute WORKFLOW_ROOT>/specs.md
- <absolute WORKFLOW_ROOT>/requirement_dialogue.md
- <absolute WORKFLOW_ROOT>/prompt_for_supervisor.md
- <absolute WORKFLOW_ROOT>/prompt_for_supervisor_goal.md
- <absolute CURRENT_SPEC_ROOT>/review_checklist.md for each spec

Use these template sources from `<absolute RUN_FILE_WRITER_ROOT>`:
- <absolute RUN_FILE_WRITER_ROOT>/templates/goal.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/constraint.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/run_goal.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/specs.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/prompt_for_supervisor.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/prompt_for_supervisor_goal.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/spec_status.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/source_discovery.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/abstract_plan.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/evidence.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/review_checklist.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/review.md
- <absolute RUN_FILE_WRITER_ROOT>/templates/bitter_lesson.md

Before writing any templated run file, run:

```bash
<absolute RUN_FILE_WRITER_ROOT>/scripts/init_run_templates.sh <absolute task directory> <workflow id> [spec-name ...]
```

The script copies every missing executor run file and leaves existing executor files unchanged. It always rebuilds `<absolute WORKFLOW_ROOT>/prompt_for_supervisor.md` and `<absolute WORKFLOW_ROOT>/prompt_for_supervisor_goal.md` from templates. After that, edit the copied or rebuilt files in place. Do not recreate templated run files from memory. Preserve template headings unless a heading conflicts with the task, `<absolute CONTROL_ROOT>/constraint.md`, or the heading risk checks below.

Run-file content rules:
- <absolute CONTROL_ROOT>/goal.md must tell the future controlled Codex what to do, what materials to read, what outputs to produce, what progress evidence to update, and what proves completion.
- <absolute CONTROL_ROOT>/constraint.md must contain all active user constraints, forbidden actions, checkpoint rules, review rules, stop rules, and runtime autonomy definitions.
- <absolute WORKFLOW_ROOT>/run_goal.md must preserve the user's task as a stable run description.
- <absolute WORKFLOW_ROOT>/specs.md must split the task into checkable steps. Each step must have a purpose, required information, expected outputs, observable success evidence, direct prerequisite gates, parallel group, and correction triggers.
- <absolute WORKFLOW_ROOT>/specs.md must state that specs follow declared direct dependencies rather than a global serial queue. Each spec waits only for its own unmet direct prerequisites; all ready, non-conflicting, resource-compatible specs run concurrently up to actual available capacity, and completion immediately refills released capacity. Declared order is preserved when capacity is insufficient, not used to delay independent ready specs.
- <absolute WORKFLOW_ROOT>/requirement_dialogue.md must record the clarified requirement history and must have no unresolved conflicts before the run files are written.
- Each spec must have `<absolute CURRENT_SPEC_ROOT>/review_checklist.md`. The checklist must tell the executor and reviewers to extract rows from the current global/project instruction files, `<absolute CONTROL_ROOT>/goal.md`, `<absolute CONTROL_ROOT>/constraint.md`, the current spec under `<absolute CURRENT_SPEC_ROOT>`, the current abstract plan, and observed evidence. Do not hard-code one user's local instruction text into the template.
- Each checklist must include a hard gate for user-required methods, tools, metrics, outputs, original repository capabilities, accelerated paths, and high-performance implementations. A slower, simpler, ordinary, or unfused substitute cannot pass unless the checklist records user authorization or original-path failure handling with command, location, exit result, complete error source, environment/dependency/path/version/compatibility inspection, fix, and rerun evidence.
- <absolute WORKFLOW_ROOT>/prompt_for_supervisor.md must be the long supervisor companion file for this workflow id.
- <absolute WORKFLOW_ROOT>/prompt_for_supervisor_goal.md must be the short supervisor `/goal` prompt for this workflow id.
- Do not write supervisor prompt files at the task root.
- If a task step needs a per-step folder during execution, define the expected folder name and expected files in `<absolute WORKFLOW_ROOT>/specs.md`. Do not create execution evidence before the step actually runs.
- If the user gave a global requirement, put it in `<absolute CONTROL_ROOT>/constraint.md` and also mention which specs it affects.
- If source discovery finds missing information, record what is missing and the autonomous resolution path for that spec. Do not guess and do not create a runtime user-response gate.
- Do not write `blocked`, `BLOCKED`, `Current Blocker`, or user-response blockers into executor run files. Executor failures must become correction issues with next actions. The supervisor Codex must keep supervising.
- Do not write user-review, user-choice, or user-approval gates into durable run files.
- Final run files must be complete enough for autonomous execution.
- Run-file requirement conflicts must be fixed during run-file creation. Do not leave conflict repair for the supervisor phase.
- After execution starts, the controlled Codex must not ask for choices, approvals, or review. If information is missing, it must return to source discovery, inspect files and outputs, use allowed external sources, choose a conservative option within constraints, record the reason in evidence, and continue.
- Allowed external sources means sources permitted by the user, the task, and the available tools. If no specific source is named, use local files first, then official documentation, repository documentation, papers, or public web pages only when the missing fact cannot be found locally and network use is allowed.
- Conservative option means the option that is reversible, smallest in scope, least likely to delete or overwrite user data, does not add cost or permissions, and follows existing project defaults when those defaults are visible. Record the options considered and the chosen reason in evidence.
- Write those two definitions into `<absolute CONTROL_ROOT>/constraint.md` when generating run files.

File ownership and priority rules:
- Supervisor-only files are `<absolute WORKFLOW_ROOT>/prompt_for_supervisor.md`, `<absolute WORKFLOW_ROOT>/prompt_for_supervisor_goal.md`, and staged paste files.
- Controlled-execution files are `<absolute CONTROL_ROOT>/goal.md`, `<absolute CONTROL_ROOT>/constraint.md`, and current spec files under `<absolute CURRENT_SPEC_ROOT>`.
- Shared evidence files are `<absolute WORKFLOW_ROOT>/run_goal.md`, `<absolute WORKFLOW_ROOT>/specs.md`, and per-spec `evidence.md`, `status.md`, and review files under `<absolute CURRENT_SPEC_ROOT>`.
- For execution, use this priority: latest user instruction written into `<absolute CONTROL_ROOT>/goal.md` or `<absolute CONTROL_ROOT>/constraint.md` > `<absolute CONTROL_ROOT>/constraint.md` > `<absolute CONTROL_ROOT>/goal.md` > current spec under `<absolute CURRENT_SPEC_ROOT>` > `<absolute WORKFLOW_ROOT>/specs.md` > `<absolute WORKFLOW_ROOT>/run_goal.md`.
- Task-preparation notes mean task-internal work such as collecting data, downloading files, checking environment state, or reading sources. They do not mean requesting a user response.

Template heading risk check:
- Check every heading in the generated run files before reporting.
- Remove or rewrite any heading that can be treated as a runtime supervisor stop condition.
- Remove or rewrite any heading that conflicts with `<absolute CONTROL_ROOT>/constraint.md`.
- Remove or rewrite any heading that asks for user review, choices, or approval after durable run files are written.

Checkpoint rule:
- If there is existing completed work that must be preserved before the next run, inspect git status, stage only relevant stable files, and create a checkpoint commit before writing new run-prep files.
- Do not stage unrelated files.
- If unrelated files cannot be separated safely, stop and report the exact paths.

Run-file finalization rule:
- After writing the run files, stop.
- Do not start execution.
- Report the file list and the autonomy checks performed.
- The user starts the long run by manually starting the supervisor Codex in tmux and setting `<absolute WORKFLOW_ROOT>/prompt_for_supervisor_goal.md` as its `/goal`. That action is the user's approval to run. Do not encode a review or approval gate in durable run files.
```
