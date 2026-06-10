---
name: tmux-codex-supervisor
description: "Use when supervising a Codex instance running inside tmux, with the main Codex preparing two control files, sending a short /goal message, checking evidence, and avoiding direct task execution."
---

# tmux Codex Supervisor

Use this skill when the main Codex must supervise a controlled Codex running in tmux.

Codex is the AI assistant. The main Codex is the supervisor in the current chat. The controlled Codex is the executor in a tmux window. tmux is a terminal tool that keeps sessions running. A control file is a task file read by the controlled Codex.

## Non-Negotiable Design

- Use exactly two control files: `control/goal.md` and `control/constraint.md`.
- `control/goal.md` contains the task goal, input material, output requirement, progress requirement, and completion standard.
- `control/constraint.md` contains limits, forbidden actions, and self-check rules.
- The short `/goal` message only points the controlled Codex to the two control files.
- The main Codex supervises; the controlled Codex executes.

## Required Order

1. Read the user's task and decide what belongs in `control/goal.md` and `control/constraint.md`.
2. Create the two control files from `templates/goal.md` and `templates/constraint.md`.
3. Send `templates/short_goal_message.md` to the controlled tmux target.
4. Verify that the message reached the controlled tmux target.
5. Monitor progress using the evidence named in `control/goal.md`.
6. Correct only when evidence proves drift, stalling, or failed completion.
7. Verify completion with the completion standard in `control/goal.md`.
8. Report to the user using evidence, not guesses.

## Role Boundary

The main Codex may prepare control files, run supervision scripts, read evidence, send correction text, and report. The main Codex must not do the future task output that the controlled Codex was assigned to do.

## Script Policy

Use scripts for fixed operations:

- `scripts/send_tmux_message.sh` sends a file's text to tmux.
- `scripts/capture_tmux_screen.sh` reads recent tmux screen text.
- `scripts/verify_delivery.sh` checks that expected text appears on screen.
- `scripts/check_progress.sh` compares current progress evidence against the last saved check.
- `scripts/check_done.sh` runs the completion check command.
- `scripts/package_outputs.sh` packages output files.

Do not copy exact tmux key sequences into high-level task text. Keep exact terminal behavior in scripts and tests.

