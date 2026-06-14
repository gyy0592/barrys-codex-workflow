# Physics For LLM Supervision Error Report

## Scope

This report records supervision problems observed during the cloud run for:

```text
/home/barry/github_repo/physics_for_llm
workflow_20260611_physics_for_llm_initial
```

The inspected Codex transcript files were:

```text
/home/barry/.codex/sessions/2026/06/11/rollout-2026-06-11T21-05-30-019eb881-20c3-7491-bc98-50abe4b2df8f.jsonl
/home/barry/.codex/sessions/2026/06/11/rollout-2026-06-11T21-38-48-019eb89f-9df4-7873-86a1-98f84b41c01b.jsonl
```

The first file is the supervisor Codex. The second file is the controlled Codex.

## Current Run State

Final repository state on the cloud project after the controlled Codex finished:

```text
repo: /home/barry/github_repo/physics_for_llm
latest commit: 581114a complete final validation results
previous checkpoint commits:
  767c1c1 complete spec007 nece probing
  7eb4850 complete spec006 gpt2 training
  38957ca complete spec005 igsm data eval smoke
  5adafb0 checkpoint physics llm workflow specs 1-5 setup
```

Observed final spec state:

```text
Spec 001: done
Spec 002: done
Spec 003: done
Spec 004: done
Spec 005: done
Spec 006: done
Spec 007: done
Spec 008: done
```

The controlled Codex marked the goal complete after checking the five required docs, eight spec status files, four kept run validation files, active path rules, and final Git evidence.

Remaining untracked files in the task repository were:

```text
?? exp/
?? prompt_for_supervisor.md
?? reproduction_results_dashboard.html
?? scaling_ladder_architecture.html
```

These remaining paths were not committed by the controlled Codex. `exp/` contains run outputs that were referenced by committed evidence. The prompt and HTML files were not treated as required workflow files.

## Correct Drift Rule

Drift means the controlled Codex violates either:

- The current spec.
- A global requirement added by the user.
- A workflow rule that applies to every spec.

The current spec is the local boundary. A later user requirement can become a global constraint. If that global constraint does not conflict with the current spec, the controlled Codex must follow it immediately.

Therefore, missing checkpoint commits after stable completed work is drift after the user says git commits must be handled well.

## Error 1: Checkpoint Commit Rule Was Missing

Conclusion:

The initial workflow did not require checkpoint commits after completed specs or stable work chunks.

Evidence:

- `/home/barry/Programs/codex_workflow_tmux/specific workflow/minimal_subgoal_workflow.md` describes spec directories, source discovery, abstract plans, evidence, status, and bitter lessons. It does not define git checkpoint commits.
- `/home/barry/.codex/skills/tmux-codex-supervisor/SKILL.md` defines supervision, tmux messages, delivery checks, progress checks, and completion checks. It does not define git checkpoint commits.
- `/home/barry/github_repo/physics_for_llm/workflow_20260611_physics_for_llm_initial/run_goal.md` originally mentioned commit hash only as part of final `docs/05_results.md`, not as an action requirement.
- The initial `prompt_for_supervisor.md` did not say checkpoint commits were required after completed specs.

Cause:

The workflow treated git as final evidence instead of a repeated safety mechanism. It did not say when a controlled Codex must create a commit during a long task.

Impact:

The controlled Codex completed meaningful stable work for Specs 001-004 and started Spec 005 without creating a checkpoint commit.

## Error 2: User's Git Requirement Was First Interpreted Too Narrowly

Conclusion:

After the user said git commits must be handled well, the supervisor first encoded it as a final-only commit rule. That was wrong.

Evidence from supervisor transcript:

The user said:

```text
对了 你要让他做好git commit 这也是一个要求 我没写到workflow吗 没有的话你自己让他做好
```

The supervisor answered:

```text
新增要求是最终验证通过后创建一个 git commit。
```

The supervisor then wrote a final-only rule into the control files.

Evidence from current control files:

```text
control/constraint.md: After all eight specs are done and final validation has passed, create one git commit for this workflow.
control/goal.md: A git commit has been created after final validation.
```

Cause:

The supervisor converted a broad user requirement, "做好 git commit", into a narrow final-step requirement. It did not ask what "做好" means, and it did not infer the obvious long-task need: commit stable completed chunks.

Impact:

The controlled Codex was told not to commit early. This directly caused the later state where Specs 001-004 were done but no checkpoint commit existed.

## Error 3: Prompt And Control Files Became Inconsistent

Conclusion:

The current `prompt_for_supervisor.md` has the correct checkpoint rule, but `control/goal.md` and `control/constraint.md` still mostly say final commit only.

Evidence:

Current `prompt_for_supervisor.md` says:

```text
If the controlled Codex has completed meaningful work without a git commit, treat that as drift and correct it.
Require checkpoint commits after completed specs or stable work chunks, and a final commit after validation.
```

Current `control/constraint.md` says:

```text
After all eight specs are done and final validation has passed, create one git commit for this workflow.
```

Cause:

The supervisor corrected its own prompt and sent a correction message to the controlled Codex, but did not fully propagate the checkpoint rule into the durable control files.

Impact:

The controlled Codex did create a checkpoint commit after receiving the correction message, but future continuation may reread the control files and see weaker final-only git instructions.

## Error 4: Supervisor Needed User Correction Before Treating Missing Commit As Drift

Conclusion:

The supervisor did not independently classify the missing checkpoint commit as drift until the user pointed it out.

Evidence from transcript:

The user said:

```text
而且我说了要好好做git 他为啥到现在一次commit都没有 这不是错误？ 你不用给他纠正？？？？
```

After that, the supervisor said:

```text
到现在没有任何 commit，是我监督不到位。
前面我把它写成“最终再 commit”，这和你说的“做好 git commit”不一致。
```

Then the supervisor sent a correction to the controlled Codex:

```text
Missing git commits are drift.
Do not wait until the final workflow before the first commit.
At the next safe point, create a checkpoint git commit for completed and stable workflow work.
```

Cause:

The supervisor was checking task scope and current spec behavior, but did not consistently include later user global requirements in the drift definition.

Impact:

The correction came late. The controlled Codex had already completed several specs and started submitting Spec 005 jobs before the first checkpoint commit.

## What Worked After Correction

The controlled Codex responded correctly after the checkpoint correction.

Evidence:

The controlled Codex created:

```text
5adafb0 checkpoint physics llm workflow specs 1-5 setup
```

It staged completed Specs 001-004 and stable Spec 005 setup files. It did not stage actively changing `exp/` output, unrelated HTML, or unrelated official iGSM example files.

This behavior matches the corrected checkpoint rule.

The same rule also worked later after another correction:

```text
38957ca complete spec005 igsm data eval smoke
7eb4850 complete spec006 gpt2 training
767c1c1 complete spec007 nece probing
581114a complete final validation results
```

However, the Spec 006 checkpoint happened only after the supervisor corrected another checkpoint miss. That repeat failure is recorded below.

## Post-Completion Classification

This section classifies the problems after reading the completed supervisor and controlled Codex transcripts.

Already written or already attempted to fix:

- Checkpoint commits were missing from the original workflow.
- The user's broad git requirement was first narrowed into a final-only commit rule.
- The supervisor prompt and durable control files became inconsistent.
- The supervisor needed user correction before treating missing checkpoint commits as drift.
- The drift rule was clarified: drift includes current-spec violations and active global user requirements.
- The unrelated Codex session in the same project directory was classified as not an error unless it interferes with the supervised workflow.

Not written before this post-completion audit:

- The checkpoint rule failed again after Spec 006. The controlled Codex marked Spec 006 done and started Spec 007 before creating the Spec 006 checkpoint commit.
- The no-context review rule was not part of the executor control files for this run. The final controlled Codex audit noticed that the source workflow mentioned review files, but the active control files did not require per-spec no-context review evidence.
- The tmux correction path had avoidable interaction errors. One correction was accidentally sent in a way that triggered goal-replacement handling, then had to be cancelled and resent as a normal message.
- The run found cluster/environment lessons. Those lessons were written in the physics workflow's own `bitter_lesson/` files, not in this supervision report.

## Error 5: Checkpoint Rule Failed Again After Spec 006

Conclusion:

The checkpoint rule was fixed in principle, but the controlled Codex did not fully internalize it. After completing Spec 006, it moved into Spec 007 before committing Spec 006.

Evidence from supervisor transcript:

```text
发现偏离：它已经把 Spec 006 标成 done，并且开始 Spec 007 source discovery，但还没有为 Spec 006 做 checkpoint commit。
```

Evidence from controlled Codex transcript:

```text
Spec 006 is now marked done ... I’m moving to Spec 007 source discovery next
```

Then the supervisor sent this correction:

```text
You drifted from the checkpoint commit rule. Spec 006 is now marked done and has completed evidence, but you moved into Spec 007 before making a checkpoint commit.
```

The controlled Codex then created:

```text
7eb4850 complete spec006 gpt2 training
```

Cause:

The checkpoint rule was delivered as a correction during the run, but it was not yet embedded strongly enough into the per-spec transition rule. The controlled Codex still treated "status done" as enough to move to the next spec.

Impact:

The supervisor had to interrupt Spec 007 and force a delayed Spec 006 checkpoint commit. After that correction, Spec 007 did checkpoint before moving to Spec 008.

Required fix:

The workflow transition rule must say:

```text
A spec is not complete enough to leave until evidence passes, status is done, required files are stable, the checkpoint commit is created, and git evidence is recorded.
```

## Error 6: No-Context Review Was Not In The Active Executor Contract

Conclusion:

The workflow now says each spec should pass a no-context review before moving on, but that rule was not present in the control files used by this completed physics run.

Evidence from controlled Codex final audit:

```text
The source workflow mentions review files and no-context reviews for the supervising process, while the current executor control files require five files per spec and the final Git evidence commands.
```

Cause:

The no-context review rule was added to the general workflow after this run was already underway. It was synced into the workflow document, but not propagated into this run's concrete `control/goal.md` and `control/constraint.md`.

Impact:

The run can still be considered complete under its active control files, but it did not produce per-spec `review.md` files or fresh no-context reviewer evidence.

Required fix:

Future run setup must generate control files from the latest workflow rules. The control files should require, for every spec:

```text
review.md exists, a clean no-context reviewer checked the spec evidence and latest commit, and the review result is PASS before moving to the next spec.
```

## Error 7: tmux Correction Delivery Had Avoidable Interaction Mistakes

Conclusion:

The supervisor corrected the controlled Codex successfully, but the correction path was not always clean. At least one correction was sent in a way that triggered goal-replacement handling, then had to be cancelled and resent.

Evidence from supervisor transcript:

```text
目标替换已经取消，原总目标保留。现在我用普通消息发送纠正，不再用 /goal。
```

Cause:

The supervisor did not consistently separate two message types:

- `/goal` messages, which create or replace an active goal.
- Plain correction messages, which should guide the current active goal without replacing it.

Impact:

This did not corrupt the final result, but it wasted time and created risk that the active goal could be replaced accidentally.

Required fix:

The tmux skill should require this before every correction:

```text
If the controlled Codex already has the correct active goal, send a plain correction message, not /goal.
After sending, capture the tmux pane and confirm the message appeared in the intended place.
If the input was sent to the wrong mode or as goal replacement, cancel immediately and resend as plain text.
```

## Run-Local Technical Lessons Written Elsewhere

The controlled Codex also found cluster/runtime problems. These were task execution lessons, not supervisor workflow errors, and they were written in the physics run's own `bitter_lesson/` files:

```text
workflow_20260611_physics_for_llm_initial/bitter_lesson/lesson_tmp_repo_not_shared.md
workflow_20260611_physics_for_llm_initial/bitter_lesson/lesson_user_site_not_compute_env.md
workflow_20260611_physics_for_llm_initial/bitter_lesson/lesson_compute_cache_paths.md
```

They record:

- `/tmp` is not a safe dependency path for compute jobs.
- Login-node user-site Python packages are not reliable on compute nodes.
- Compute jobs need shared cache and home paths for model and plotting caches.

## Required Fix To The Workflow

The workflow should define git handling as a global rule:

```text
After each completed spec, or after a stable multi-step chunk that would be expensive to reconstruct, create a checkpoint commit.
Before committing, inspect git status, separate unrelated files, stage only files required for the workflow, and record commit evidence.
Do not stage active experiment outputs until they are complete and validated.
After all specs and final validation pass, create a final commit if new completed work remains.
```

This rule should be present in:

- `prompt_for_supervisor.md`
- `control/goal.md`
- `control/constraint.md`
- the specific workflow document used to generate future runs

## Required Fix To Drift Detection

The supervisor should classify drift by this rule:

```text
Current action is valid only if it satisfies the current spec and every active global user requirement.
If a later user requirement applies globally, it becomes part of every later spec unless it conflicts with a higher-priority instruction.
Violating that global requirement is drift.
```

This avoids the wrong distinction between "current spec drift" and "global workflow discipline drift." Both are drift when they apply to the running spec.

## Note On Unrelated Codex Sessions

Another Codex transcript exists in the same project directory for a separate user task. That is not a supervision problem by itself. The user can open multiple Codex sessions. Future audits should not list a separate user-started Codex session as an error unless its files or actions interfere with the supervised workflow.
