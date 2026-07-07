# codex_workflow_tmux

[中文](README.zh.md) | English

This repository implements a tmux-based supervision workflow for Codex.

The source design is `/home/yguo173/Downloads/tmux_codex_workflow_design.html`.

Core rule:

- The main Codex prepares run files and later supervises.
- The controlled Codex executes.
- The controlled Codex task contract uses only `control/goal.md` and `control/constraint.md`.
- Requirement clarification and conflict repair happen before run files are written.
- Starting the supervisor Codex with `prompt_for_supervisor_goal.md` as `/goal` is approval to run.

Required repository areas:

- `SKILL.md`: the `tmux-codex-supervisor` skill, used only to start or supervise a controlled Codex in tmux.
- `skills/run-file-writer/SKILL.md`: the `run-file-writer` skill, used only to clarify requirements, create final run files, and stop before execution.
- `templates/`: legacy fallback copies of the run templates and supervisor templates.
- `scripts/`: deterministic tmux and evidence-checking commands.
- `tests/`: shell tests that prove the scripts and templates work.
- `docs/experiment_book.md`: chronological record of work and verification.
- `docs/bitter_lessons.md`: repeated mistakes and prevention rules.
- `docs/usage.md`: how to install the skills and use them from any task directory.

## Usage

Use this workflow in three phases. First, use Codex to clarify the task and record every clarification in `workflow_<run_id>/requirement_dialogue.md`. Second, use the `run-file-writer` skill to write final run files from that conflict-free record. Third, the user manually starts the supervisor Codex in tmux and sets `prompt_for_supervisor_goal.md` as `/goal`; that action starts the run and is the approval to execute.

### 1. Install

Install the skills once from a checkout:

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

`install.sh` requires `git` and `tmux`, warns if the Codex CLI is not available, installs the workflow skills into `~/.codex/skills/`, and verifies the required installed files. The installed workflow skills are `tmux-codex-supervisor`, `run-file-writer`, `workflow-error-transition`, and `monitor-codex-goal`.

The lower-level installer is still available:

```bash
~/Programs/codex_workflow_tmux/scripts/install_skill.sh
```

### 2. Clarify The Task And Record The Dialogue

Open Codex from the project where the real task should happen:

```bash
cd /path/to/your/project
codex
```

Ask Codex to read the two workflow skills, clarify the task with you, and record the dialogue:

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

Codex should ask concrete questions when the task is unclear. It should not silently choose between meanings that would change the goal, constraints, required output, success checks, or spec list.

### 3. Check Conflicts Before Writing Run Files

Before writing run files, Codex must reread `workflow_<run_id>/requirement_dialogue.md` and check whether earlier requirements conflict with later answers. The latest user answer wins, but Codex must report the conflict and ask before removing or replacing the older requirement.

The question should be direct, for example:

```text
You previously said to keep X, but later you said to use Y instead. Should I remove X and write the run files using Y?
```

Codex may start writing run files only after the dialogue file has no unresolved conflicts and the user confirms that writing run files may begin.

### 4. Write The Final Run Files

After the user confirms, ask Codex to use the run-file writing skill:

```text
Use the run-file-writer skill.

The current directory is the task project.
Use workflow_<run_id>/requirement_dialogue.md as the source requirement record.
Generate final run files only.
Do not start the controlled Codex.
Do not start long-running work.
Before writing, reread workflow_<run_id>/requirement_dialogue.md and confirm there are no unresolved conflicts.
After writing, report the file list and the autonomy checks.
```

Codex should write files such as `control/goal.md`, `control/constraint.md`, `workflow_<run_id>/run_goal.md`, `workflow_<run_id>/specs.md`, `workflow_<run_id>/requirement_dialogue.md`, `workflow_<run_id>/prompt_for_supervisor.md`, and `workflow_<run_id>/prompt_for_supervisor_goal.md`.

The run files must not contain a later user-approval gate. After the supervisor goal starts, missing information must be handled through source discovery, local inspection, allowed external sources, or a conservative option written into evidence.

### 5. Start The Supervisor Codex Manually

After the run files are ready, the user should briefly inspect `workflow_<run_id>/prompt_for_supervisor_goal.md`, then start a supervisor Codex from the task project:

```bash
cd /path/to/your/project
tmux new -s codex-supervisor -c "$PWD" 'codex --dangerously-bypass-approvals-and-sandbox'
```

In that Codex, type `/goal`, then paste the prompt text from `workflow_<run_id>/prompt_for_supervisor_goal.md`. The file must contain only the goal text after `/goal`; `/goal` itself is typed by the user and must not be included in the prompt template.

Important: do not paste `templates/prompt_for_supervisor.md` or `workflow_<run_id>/prompt_for_supervisor.md` as the active `/goal`. That file is the long companion file. The active supervisor goal should be `prompt_for_supervisor_goal.md`, which tells the supervisor to read the companion file.

If Codex stores a long pasted goal as a pasted text file, that is acceptable only when the active goal points to the pasted file and the pasted file contains the intended supervisor goal text.

### 6. Execution Starts

Once the user submits the supervisor `/goal`, the run has started and no second execution approval is required. The supervisor Codex should read `prompt_for_supervisor.md`, confirm the final run files exist, start one controlled Codex in tmux, send the controlled Codex only the short `/goal` message that points to `control/goal.md` and `control/constraint.md`, and supervise until completion is proved or the user explicitly says to stop.

The controlled Codex still receives a short /goal message from the supervisor. That controlled-Codex message is exactly:

```text
/goal
control/goal.md
control/constraint.md
```
