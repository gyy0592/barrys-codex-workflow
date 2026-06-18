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

## Usage

Use this workflow in two phases. First, ask Codex to write and review the run files with you. Second, start a separate Codex inside tmux and give it the short `/goal` message. During run-file creation, the main Codex turns the user's task into final run files, checks that they will not make the long run wait for later user review or user choice, and stops before execution.

### 1. Install

Install the skill once from a checkout:

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

`install.sh` requires `git` and `tmux`, warns if the Codex CLI is not available, installs the skill into `~/.codex/skills/tmux-codex-supervisor`, and verifies the required installed files.

The lower-level installer is still available:

```bash
~/Programs/codex_workflow_tmux/scripts/install_skill.sh
```

### 2. Ask Codex To Prepare The Run Files

Then open Codex from the project where the real task should happen:

```bash
cd /path/to/your/project
codex
```

Describe your task normally first. Then ask Codex to use the skill and write the run files. A short request can look like this:

```text
Use the tmux-codex-supervisor skill.
Use templates/prompt_for_run_prep.md.

The current directory is the task project.
Generate final run files only.
Do not start the controlled Codex.
Do not start long-running work.
Stop and ask me when a missing choice would change the goal, constraints, or spec list.
After each run file is written, report:
- which file was written,
- a short summary of what it contains,
- which files still need to be written,
- what you plan to write next.
Then ask whether the file is correct before continuing.

My task is: write the real task here.
```

Codex should write files such as `control/goal.md`, `control/constraint.md`, `workflow_<run_id>/run_goal.md`, and `workflow_<run_id>/specs.md`. It should stop after the run files are ready and tell you what was written. Review the short summaries and confirm whether they match your task.

### 3. Start The Controlled Codex In tmux

After the run files are ready, start tmux from the task project:

```bash
tmux new -s codex-run
codex
```

In the new Codex, paste the contents of:

```text
templates/short_goal_message.md
```

That short message points the controlled Codex to `control/goal.md` and `control/constraint.md`. It is the only startup message the controlled Codex needs.

### 4. Supervise The tmux Run

In the original Codex chat, send a separate execution request. This request enters the execution phase. Before starting the controlled Codex, the supervisor Codex may run the final autonomy check and fix run files if needed. This is not user approval and does not ask the user to read the files.

```text
Use the tmux-codex-supervisor skill.
Use templates/prompt_for_supervisor.md.

The current directory is the task project.
Act as the main Codex:
1. Confirm the final run files exist.
2. Confirm review-run-files-for-autonomy passed, or run it and fix the files before execution.
3. Checkpoint the final run files if they must be preserved.
4. If the controlled Codex is already open in tmux, send only the short /goal message from templates/short_goal_message.md to it. If it is not open, tell me to open tmux and start Codex first.
5. Verify that the message arrived.
6. Supervise, correct drift, require checkpoint commits and no-context reviews after completed specs, and verify completion. Do not directly do the controlled Codex task.

My task is: write the real task here.
```

For execution after run-file creation, start from `templates/prompt_for_supervisor.md`. That template is for the main Codex, not the controlled Codex. It exists so the supervisor role, drift rule, checkpoint rule, file-priority rule, and control-file update rule are written before the run starts.
