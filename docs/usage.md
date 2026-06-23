# Usage

This workflow can be used from any task directory. Do not change into the workflow repository just to run its scripts.

## One-Time Install

Install the Codex skill package from a checkout:

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

`install.sh` requires `git` and `tmux`, warns if the Codex CLI is not available, installs the skill, and verifies the required installed files.

The lower-level installer is still available:

```bash
~/Programs/codex_workflow_tmux/scripts/install_skill.sh
```

This creates:

```text
~/.codex/skills/tmux-codex-supervisor/SKILL.md
~/.codex/skills/tmux-codex-supervisor/templates/
~/.codex/skills/tmux-codex-supervisor/scripts/
```

Future Codex sessions can discover the skill from `~/.codex/skills/tmux-codex-supervisor`.

## Create Final Run Files Before Execution

From the directory where the real task should happen, ask the main Codex to create final run files only:

```text
Use the tmux-codex-supervisor skill.
Use ~/Programs/codex_workflow_tmux/templates/prompt_for_run_prep.md.

The current directory is the task project.
Generate final run files only.
Do not start the controlled Codex.
Do not start long-running work.

My task is: write the real task here.
```

The run-file template makes the main Codex create `control/goal.md`, `control/constraint.md`, `workflow_<workflow id>/run_goal.md`, and `workflow_<workflow id>/specs.md`. It must not start a controlled Codex or long-running work.

Before stopping, the main Codex must run `review-run-files-for-autonomy`. This means the supervisor checks that the files used during the long run do not tell Codex to ask the user, wait for user review, wait for user choice, follow stale file names, or depend only on chat history.

## Start Execution After Run-File Creation

Start execution with a separate user request after final run files exist. This request enters the execution phase. Before starting the controlled Codex, the supervisor Codex may run the final autonomy check and fix run files if needed. This is not user approval and does not ask the user to read the files.

From the directory where the real task should happen, ask the main Codex to use the supervisor template:

```text
Use the tmux-codex-supervisor skill.
Use ~/Programs/codex_workflow_tmux/templates/prompt_for_supervisor.md.

The current directory is the task project.
Act as the main Codex:
1. Confirm the final run files exist.
2. Confirm review-run-files-for-autonomy passed, or run it and fix the files before execution.
3. Checkpoint the final run files if they must be preserved.
4. Start a controlled Codex inside tmux.
5. Send only the short /goal message from ~/Programs/codex_workflow_tmux/templates/short_goal_message.md to the controlled Codex.
6. Verify that the message arrived.
7. Supervise, correct drift, require checkpoint commits and no-context reviews after completed specs, and verify completion. Do not directly do the controlled Codex task.

My task is: write the real task here.
```

The short `/goal` message sent to the controlled Codex is exactly:

```text
/goal
control/goal.md
control/constraint.md
```

The controlled Codex receives only those two paths in the startup message. It reads the active spec and evidence files through the control files and current spec.

## Manual Script Reference

The supervisor template normally performs these steps, but the scripts can still be used directly when debugging.

Create the two control files in the current task directory:

```bash
~/Programs/codex_workflow_tmux/scripts/init_control_files.sh "$PWD"
```

The two control files are:

```text
control/goal.md
control/constraint.md
```

Start the controlled Codex in tmux:

```bash
tmux new -s mytask -c "$PWD" codex
```

Send the short `/goal` message from any directory:

```bash
~/Programs/codex_workflow_tmux/scripts/inject_steer.sh send \
  mytask:0 \
  ~/Programs/codex_workflow_tmux/templates/short_goal_message.md
```

If the tmux target is uncertain, list candidate Codex panes first:

```bash
~/Programs/codex_workflow_tmux/scripts/locate_codex.sh
```

The main Codex supervises. The controlled Codex executes the task described in `control/goal.md` while following `control/constraint.md`.

After each completed stable spec, the supervisor must require a checkpoint git commit. After each checkpoint commit, the supervisor must run no-context review before moving to the next spec. No-context review means a fresh reviewer receives only the current spec, relevant control-file excerpts, evidence, latest git evidence, relevant diff, and explicit review instructions.
