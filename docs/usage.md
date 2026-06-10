# Usage

This workflow can be used from any task directory. Do not change into the workflow repository just to run its scripts.

## One-Time Install

Install the Codex skill package:

```bash
/home/yguo173/Programs/codex_workflow_tmux/scripts/install_skill.sh
```

This creates:

```text
~/.codex/skills/tmux-codex-supervisor/SKILL.md
~/.codex/skills/tmux-codex-supervisor/templates/
~/.codex/skills/tmux-codex-supervisor/scripts/
```

Future Codex sessions can discover the skill from `~/.codex/skills/tmux-codex-supervisor`.

## Use From A Task Directory

From the directory where the real task should happen:

```bash
/home/yguo173/Programs/codex_workflow_tmux/scripts/init_control_files.sh "$PWD"
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
/home/yguo173/Programs/codex_workflow_tmux/scripts/send_tmux_message.sh \
  mytask:0 \
  /home/yguo173/Programs/codex_workflow_tmux/templates/short_goal_message.md
```

Read the controlled tmux screen:

```bash
/home/yguo173/Programs/codex_workflow_tmux/scripts/capture_tmux_screen.sh mytask:0
```

The main Codex supervises. The controlled Codex executes the task described in `control/goal.md` while following `control/constraint.md`.
