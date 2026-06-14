# codex_workflow_tmux

This repository implements a tmux-based supervision workflow for Codex.

The source design is `/home/yguo173/Downloads/tmux_codex_workflow_design.html`.

Core rule:

- The main Codex supervises.
- The controlled Codex executes.
- The task contract uses only `control/goal.md` and `control/constraint.md`.
- Concrete tmux command details live in scripts and tests, not in the high-level design text.

Required repository areas:

- `SKILL.md`: rules the main Codex reads before supervising a controlled Codex.
- `templates/`: reusable files for run preparation, `goal`, `constraint`, and the short `/goal` message.
- `scripts/`: deterministic tmux and evidence-checking commands.
- `tests/`: shell tests that prove the scripts and templates work.
- `docs/experiment_book.md`: chronological record of work and verification.
- `docs/bitter_lessons.md`: repeated mistakes and prevention rules.
- `docs/usage.md`: how to install the skill and use it from any task directory.

## Two-Phase Usage

Use this workflow in two phases:

1. Preparation phase: the main Codex turns the user's task into preparation files and waits for user review.
2. Execution phase: after user approval, the main Codex starts and supervises the controlled Codex in tmux.

Install the skill once:

```bash
~/Programs/codex_workflow_tmux/scripts/install_skill.sh
```

Then open Codex from the project where the real task should happen:

```bash
cd /path/to/your/project
codex
```

For preparation, send this request to Codex:

```text
Use the tmux-codex-supervisor skill.
Use templates/prompt_for_run_prep.md.

The current directory is the task project.
Generate preparation files only.
Do not start the controlled Codex.
Do not start long-running work.

My task is: write the real task here.
```

Review the generated preparation files. Then, for execution, send this request to Codex:

```text
Use the tmux-codex-supervisor skill.
Use templates/prompt_for_supervisor.md.

The current directory is the task project.
Act as the main Codex:
1. Create and fill control/goal.md and control/constraint.md.
2. Start a controlled Codex inside tmux.
3. Send the short /goal message to the controlled Codex.
4. Verify that the message arrived.
5. Supervise, correct drift, and verify completion. Do not directly do the controlled Codex task.

My task is: write the real task here.
```

For execution after preparation review, start from `templates/prompt_for_supervisor.md`. That template is for the main Codex, not the controlled Codex. It exists so the supervisor role, drift rule, checkpoint rule, and control-file update rule are written before the run starts.
