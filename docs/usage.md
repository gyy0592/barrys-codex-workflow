# Usage

This workflow can be used from any task directory. Do not change into the workflow repository just to run its scripts.

## One-Time Install

Install the Codex workflow skills from a checkout:

```bash
./install.sh
```

Install on a new cloud machine after the repository is published:

```bash
git clone <repo-url> ~/codex_workflow_tmux && ~/codex_workflow_tmux/install.sh
```

Install from a downloaded installer script:

```bash
curl -fsSL <raw-install.sh-url> | bash -s -- <repo-url>
```

`install.sh` requires `git` and `tmux`, warns if the Codex CLI is not available, installs the workflow skills, and verifies the required installed files.

Future Codex sessions can discover the workflow skills from `~/.codex/skills/`.

## Clarify Requirements Before Run Files

From the directory where the real task should happen, ask the main Codex to read the supervisor and run-file-writer skills, clarify the task, and maintain `workflow_<workflow id>/requirement_dialogue.md`.

Every clarification question and answer must be recorded in that file. Before run files are written, Codex must reread the file and check whether later answers replace earlier requirements. If there is a conflict, Codex must ask the user to confirm the replacement or removal before writing run files.

If the user has not already said to start writing run files, Codex must ask whether it should start writing the run files now.

## Create Final Run Files

After the user confirms, ask the main Codex to create final run files only:

```text
Use the run-file-writer skill.

The current directory is the task project.
Use workflow_<workflow id>/requirement_dialogue.md as the source requirement record.
Generate final run files only.
Do not start the controlled Codex.
Do not start long-running work.
Before writing, reread workflow_<workflow id>/requirement_dialogue.md and confirm there are no unresolved conflicts.
After writing, report the file list and the autonomy checks.
```

The `run-file-writer` skill makes the main Codex create `control/goal.md`, `control/constraint.md`, `workflow_<workflow id>/run_goal.md`, `workflow_<workflow id>/specs.md`, `workflow_<workflow id>/requirement_dialogue.md`, per-spec evidence files, and workflow-local supervisor prompt files.

The run files must not include user-review, user-choice, or user-approval gates for execution. The user starting the supervisor goal later is the execution approval.

## Start Execution

After final run files exist, the user manually starts the supervisor Codex from the task project:

```bash
tmux new -s codex-supervisor -c "$PWD" 'codex --dangerously-bypass-approvals-and-sandbox'
```

Then the user types `/goal` in Codex and pastes the text from `workflow_<workflow id>/prompt_for_supervisor_goal.md`. The prompt file should contain only the goal body after `/goal`; `/goal` itself is typed by the user and must not be included in the template.

After that goal is submitted, execution is approved and started. There is no second execution approval. The supervisor must not ask for another approval.

The supervisor starts one controlled Codex in tmux, then sends the controlled Codex this short `/goal` message:

```text
/goal
control/goal.md
control/constraint.md
```

The controlled Codex receives only those two paths in the startup message. It reads the active spec and evidence files through the control files and current spec.

## Manual Script Reference

The skills normally perform these steps, but the scripts can still be used directly when debugging.

Create the two control files in the current task directory:

```bash
~/Programs/codex_workflow_tmux/scripts/init_control_files.sh "$PWD"
```

Start the controlled Codex in tmux:

```bash
tmux new -s mytask -c "$PWD" 'codex --dangerously-bypass-approvals-and-sandbox'
```

Send the controlled Codex short goal from any directory:

```bash
~/Programs/codex_workflow_tmux/scripts/inject_steer.sh send \
  mytask:0 \
  ~/Programs/codex_workflow_tmux/templates/short_goal_message.md
```

If the tmux target is uncertain, list candidate Codex panes first:

```bash
~/Programs/codex_workflow_tmux/scripts/locate_codex.sh
```
