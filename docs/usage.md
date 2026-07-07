# Usage

Use this workflow from the project where the real task should run.

## Install

```bash
./install.sh
```

## Clarify The Task

Open Codex in the task project:

```bash
cd /path/to/your/project
codex
```

Send:

```text
Read the tmux-codex-supervisor skill and the run-file-writer skill.

The current directory is the task project.
Do not write run files yet.
Create and maintain workflow_<workflow id>/requirement_dialogue.md.
Every time you ask me whether the task should be one way or another way, append your question, my answer, and the updated conclusion to that file.
Ask me clarification questions until the goal, constraints, task material, output, success checks, and spec list are clear enough to write final run files.
If I have not already said to start writing run files, ask me whether you should start writing the run files now.

My task is: write the real task here.
```

## Write Run Files

After you agree that Codex can start writing run files, send:

```text
Use the run-file-writer skill.

The current directory is the task project.
Use workflow_<workflow id>/requirement_dialogue.md as the source requirement record.
Generate final run files only.
Do not start the run.
Do not start long-running work.
Before writing, reread workflow_<workflow id>/requirement_dialogue.md and confirm there are no unresolved conflicts.
After writing, report which files you created and whether the run can continue after it starts.
```

## Start The Run

Start a supervisor Codex in the task project:

```bash
tmux new -s "<project>-<workflow id>-supervisor" -c "$PWD" 'codex --dangerously-bypass-approvals-and-sandbox'
```

In that Codex:

1. Type `/goal`.
2. Paste the text from `workflow_<workflow id>/prompt_for_supervisor_goal.md`.
3. Press Enter.

After that, the supervisor runs the workflow. You can leave it running in tmux.

## Debugging Scripts

These scripts are for debugging the workflow itself:

```bash
~/Programs/codex_workflow_tmux/scripts/init_control_files.sh "$PWD"
~/Programs/codex_workflow_tmux/scripts/locate_codex.sh
~/Programs/codex_workflow_tmux/scripts/inject_steer.sh send <tmux-pane> ~/Programs/codex_workflow_tmux/templates/short_goal_message.md
```
