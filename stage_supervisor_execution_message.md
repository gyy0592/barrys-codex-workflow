The user started the supervisor goal for the final run files for:

```text
/home/barry/github_repo/physics_for_llm
workflow_20260612_physics_for_llm_scale_training
```

You are the supervisor only. Start the execution phase now.

Use the tmux-codex-supervisor skill and the final run files:

- `/home/barry/github_repo/physics_for_llm/control/goal.md`
- `/home/barry/github_repo/physics_for_llm/control/constraint.md`
- `/home/barry/github_repo/physics_for_llm/workflow_20260612_physics_for_llm_scale_training/run_goal.md`
- `/home/barry/github_repo/physics_for_llm/workflow_20260612_physics_for_llm_scale_training/specs.md`
- `/home/barry/github_repo/physics_for_llm/workflow_20260612_physics_for_llm_scale_training/prep/source_discovery.md`
- `/home/barry/github_repo/physics_for_llm/workflow_20260612_physics_for_llm_scale_training/prep/abstract_plan.md`

Execution requirements:

1. First checkpoint the final run files.
   - Inspect `git status --short`.
   - Stage only final run files and any needed workflow files.
   - Do not stage unrelated files such as `prompt_for_supervisor.md` or `scaling_ladder_architecture.html`.
   - Create a git commit for the Stage 2 final run files.
2. Start one controlled Codex in tmux from `/home/barry/github_repo/physics_for_llm`.
   - Suggested tmux session name: `workflow_20260612_physics_for_llm_scale_training_controlled`.
   - Use the working Codex command path if needed: `/mnt/nfs/barry/home/.npm-global/bin/codex --dangerously-bypass-approvals-and-sandbox`.
3. Send the controlled Codex only the short `/goal` message that points to `control/goal.md` and `control/constraint.md`.
4. Verify the controlled Codex received the message.
5. Supervise only. Do not personally edit task code, run experiments, submit jobs, or create final task deliverables. The controlled Codex must create required deliverables and may run or submit jobs when `control/goal.md` and `control/constraint.md` require them.
6. Correct only when evidence proves drift, stalling, failed completion, missing required evidence, or a violation of `control/constraint.md`.
7. Do not mark the supervisor goal complete or blocked because the controlled Codex reports blocked, a run fails, information is missing, or a review fails. Keep supervising until completion is proved or the user explicitly stops.

Monitoring cadence requirement:

- If the controlled Codex is stable and working within the current spec, do not interrupt it frequently.
- Stable means it is reading required sources, writing expected evidence, running an expected command, monitoring an expected job, or waiting on a legitimate long-running step under the current spec.
- When stable, monitor at a low frequency, usually once every 2 to 10 minutes.
- Use shorter checks only during startup, after sending corrections, while verifying message delivery, or when there is evidence of drift, stalled progress, failed commands, bad ETA, low MFU, poor GPU/CPU use, or other required stop conditions.
- Do not send a message merely because no new output appeared for a short time.

Specific workflow rule:

- Follow `/home/barry/Programs/codex_workflow_tmux/specific workflow/minimal_subgoal_workflow.md`.
- After each spec checkpoint commit, require two parallel no-context reviews:
  - `implementation_goal_review`
  - `constraint_review`
- The next spec may start only after `review_implementation_goal.md`, `review_constraint.md`, and `review.md` are all `PASS`.

Report status to the user after:

- The final run files are committed.
- The controlled Codex has received the short `/goal`.
- The controlled Codex has started the first spec.
