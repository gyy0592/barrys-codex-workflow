# codex_workflow_tmux

[中文](README.zh.md) | English

This repository installs two Codex skills for a tmux workflow. tmux is a terminal tool that keeps a command running after you leave the window.

- `run-file-writer`: clarifies the task and writes final run files.
- `tmux-codex-supervisor`: runs the prepared workflow in tmux.

## 1. Install

```bash
./install.sh
```

## 2. Clarify The Task

Open Codex in the project where the real task should run:

```bash
cd /path/to/your/project
codex
```

Send this to Codex:

```text
Read the tmux-codex-supervisor skill and the run-file-writer skill.

The current directory is the task project.
Do not write run files yet.
Create and maintain workflow_<run_id>/requirement_dialogue.md.
Every time you ask me whether the task should be one way or another way, append your question, my answer, and the updated conclusion to that file.
Ask me clarification questions until the goal, constraints, task material, output, success checks, and spec list are clear enough to write final run files.
If I have not already said to start writing run files, ask me whether you should start writing the run files now.

My task is: write the real task here.
```

## 3. Write Run Files

After Codex asks whether it can start writing run files and you agree, send:

```text
Use the run-file-writer skill.

The current directory is the task project.
Use workflow_<run_id>/requirement_dialogue.md as the source requirement record.
Generate final run files only.
Do not start the run.
Do not start long-running work.
Before writing, reread workflow_<run_id>/requirement_dialogue.md and confirm there are no unresolved conflicts.
After writing, report which files you created and whether the run can continue after it starts.
```

Codex should create files like:

- `control/goal.md`
- `control/constraint.md`
- `workflow_<run_id>/requirement_dialogue.md`
- `workflow_<run_id>/run_goal.md`
- `workflow_<run_id>/specs.md`
- `workflow_<run_id>/prompt_for_supervisor.md`
- `workflow_<run_id>/prompt_for_supervisor_goal.md`

## 4. Start The Run

Start a new supervisor Codex from the same task project:

```bash
cd /path/to/your/project
tmux new -s codex-supervisor -c "$PWD" 'codex --dangerously-bypass-approvals-and-sandbox'
```

In that Codex:

1. Type `/goal`.
2. Paste the text from `workflow_<run_id>/prompt_for_supervisor_goal.md`.
3. Press Enter.

After that, the supervisor runs the workflow. You can leave it running in tmux.
