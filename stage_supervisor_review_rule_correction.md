Run-file correction only.

The specific workflow was updated while you were creating final run files. Update the final run files so every completed spec requires two parallel no-context reviews after each checkpoint commit:

1. `implementation_goal_review`: checks correct spec implementation and drift from `control/goal.md`.
2. `constraint_review`: checks violations of `control/constraint.md`, global user requirements, git rules, and workflow rules.

Both reviewers must inspect the current spec evidence, `git status --short`, `git diff HEAD^ HEAD`, latest commit, and recent commit history when needed.

The expected files for each completed spec must include:

- `review_implementation_goal.md`
- `review_constraint.md`
- `review.md`

`review.md` must summarize both subreviews. The next spec can start only if both subreviews are PASS and the summary `review.md` is PASS.

Update only final run files such as `control/goal.md`, `control/constraint.md`, and `workflow_20260612_physics_for_llm_scale_training/specs.md`. Do not start execution, do not start training, do not submit jobs, and do not start a controlled Codex. Stop after updating and verifying the final run files.
