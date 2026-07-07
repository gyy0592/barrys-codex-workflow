Use the tmux-codex-supervisor skill.
Use /home/barry/Programs/codex_workflow_tmux/templates/prompt_for_run_prep.md.

You are the main Codex for run-file creation only.

Task directory:
/home/barry/github_repo/physics_for_llm

Workflow id:
workflow_20260612_physics_for_llm_scale_training

Run-file creation boundary:
- Create final run files only.
- Do not start a controlled Codex.
- Do not send the short /goal message to a controlled Codex.
- Do not start training.
- Do not generate large datasets.
- Do not submit SLURM jobs.
- Do not start any long-running command.
- These prep-phase bans apply only to this main Codex while creating run files. Do not copy them into controlled execution files as a ban on the future controlled Codex.
- If the final run requires training, jobs, experiments, final outputs, or other task submissions, the future controlled Codex must do them during execution under `control/goal.md` and `control/constraint.md`.
- Stop after the final run files are written and report the file list plus autonomy checks.

First action: preserve Stage 1.
- Inspect the current git status in /home/barry/github_repo/physics_for_llm.
- Create a checkpoint commit that records the completed Stage 1 state before writing new Stage 2 final run files.
- Stage only stable Stage 1 files.
- Treat exp/ and reproduction_results_dashboard.html as possible Stage 1 result files if they are needed to preserve the completed Stage 1 evidence.
- Treat prompt_for_supervisor.md and scaling_ladder_architecture.html as unrelated unless file evidence proves they belong to Stage 1.
- If relevant and unrelated files cannot be separated safely, stop and report exact paths instead of committing.

New user task for the future run:
Expand the Physics of LMs Part 2.1 reproduction from the current minimum runnable baseline toward a paper-scale training run. Use a training scale close to the paper when the paper provides enough information. The cluster has eight GPUs available for the intended run, and the user expects the main training to be feasible in about one day if implemented well. The evaluation set must also be expanded. If the paper states its evaluation question count, use that count. If the paper does not state the count clearly, require at least 5000 evaluation questions after training.

Required future-run constraints:
- Every run, benchmark, data generation job, training job, evaluation job, or probing job must write an ETA before it starts. ETA means estimated time to finish.
- The future controlled Codex must make a serious acceleration effort before long training. It must use source discovery to inspect local code, cluster docs, experiment-run rules, this-cluster rules, and internet sources when needed.
- GPU utilization and MFU must be measured and recorded. MFU means model FLOPs utilization: the fraction of theoretical GPU compute used by model training.
- Hard success gate: either MFU reaches at least 30 percent, or the main training ETA is at most 2 days. At least one of these must be true before continuing a long run.
- If ETA is above the allowed time, MFU is too low, GPU use is clearly bad, or logs show an obvious performance problem, the future controlled Codex must kill the job, read the output files, inspect local code, search internet sources if needed, identify a concrete fix, update the plan, and only then continue under the workflow.
- The future controlled Codex must do checkpoint git commits after stable completed specs and a final commit after final validation. It must not stage unrelated files.

Required final run files:
- control/goal.md
- control/constraint.md
- workflow_20260612_physics_for_llm_scale_training/run_goal.md
- workflow_20260612_physics_for_llm_scale_training/specs.md
- workflow_20260612_physics_for_llm_scale_training/prep/source_discovery.md
- workflow_20260612_physics_for_llm_scale_training/prep/abstract_plan.md

Run-file content requirements:
- control/goal.md must define the future controlled Codex task and completion standard.
- control/constraint.md must include the ETA, acceleration, GPU utilization, MFU, stop-and-fix, no-unrelated-commit, and autonomous execution constraints.
- specs.md must split the future run into checkable specs. Each spec must have required information, expected outputs, observable evidence, ETA requirement, speed/MFU requirement when relevant, checkpoint requirement, and review requirement.
- source_discovery.md must record what was read to design the final run files. It must include paper/code/cluster/experiment-run/this-cluster information sources if available.
- abstract_plan.md must give a short high-level plan for the future run, not detailed commands for a long execution.
- The final run files must be complete enough for autonomous execution and must not encode user-review, user-choice, or user-approval gates.

After writing files:
- Do not start execution.
- Report the Stage 1 commit result.
- Report the final run file list.
- Report autonomy checks.
- Report any missing information that was resolved by source discovery or conservative choices inside constraints.
