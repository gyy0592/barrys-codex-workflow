# Usage

This workflow can be used from any task directory. Do not change into the workflow repository just to run its scripts.

## One-Time Install

Install the Codex skill package:

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

## Prepare A Run Before Execution

From the directory where the real task should happen, ask the main Codex to use the preparation template:

```text
~/Programs/codex_workflow_tmux/templates/prompt_for_run_prep.md
```

The preparation template makes the main Codex create `control/goal.md`, `control/constraint.md`, `workflow_<workflow id>/run_goal.md`, and `workflow_<workflow id>/specs.md`. It must not start a controlled Codex or long-running work. The user reviews these files before execution.

## Execute After User Approval

After the user approves the preparation files, ask the main Codex to use the supervisor template:

```text
~/Programs/codex_workflow_tmux/templates/prompt_for_supervisor.md
```

From the directory where the real task should happen:

```bash
~/Programs/codex_workflow_tmux/scripts/init_control_files.sh "$PWD"
```

Fill these two files in the current task directory:

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
~/Programs/codex_workflow_tmux/scripts/send_tmux_message.sh \
  mytask:0 \
  ~/Programs/codex_workflow_tmux/templates/short_goal_message.md
```

Read the controlled tmux screen:

```bash
~/Programs/codex_workflow_tmux/scripts/capture_tmux_screen.sh mytask:0
```

The main Codex supervises. The controlled Codex executes the task described in `control/goal.md` while following `control/constraint.md`.
