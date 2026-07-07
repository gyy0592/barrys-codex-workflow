# Correction: Fresh No-Context Review Required

Date: 2026-07-07.

User correction: do not mark complete yet.

Problem recorded: the previous completion path used a local review file instead of the required fresh no-context Codex subagent review. That was workflow drift.

Required next action:

1. Run a fresh no-context Codex subagent review using gpt5.4 high against the current checkpoint evidence and diffs for commits `9208e6d` and `658249a`.
2. If the review finds a real problem, fix it, rerun checks, rerun fresh no-context review, then checkpoint.
3. If the review passes, record the reviewer result, git status, git log -1 --oneline, and git show --stat --oneline --name-status HEAD.
4. Only after that, rerun the final completion audit.

Current relevant commits:

- `9208e6d Record current speed-frame audit`
- `658249a Review current speed-frame audit`

## Fresh No-Context Review Result

Reviewer: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: FAIL.

Real problems found:

1. M01 did not match the fixed M01 method because `method_list.md` says unchanged-frame classification uses compensated motion, while the implementation used raw `x_screen` delta.
2. Durable workflow evidence did not record the required git evidence for audit commits `9208e6d` and `658249a`.

Decision: fix the current M01 method rather than move to M02, because the failure was a concrete implementation mismatch inside M01.

Fix applied in project repository:

- `simulator/algos/speed_frame/m01_fixed_window.py`: M01 now computes compensated motion through local candidates and classifies unchanged by the smallest compensated motion magnitude.
- `tests/test_speed_frame_m01.py`: focused tests now verify unchanged handling and that classification uses compensated motion rather than raw motion alone.

Repair checks:

```text
python -m tools.algo_contract_check
```

Result: passed.

```text
python -m unittest tests.test_speed_frame_m01 -v
```

Result: 3 tests passed.

```text
python -m unittest discover -s tests -v
```

Result: 21 tests passed.

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Result: M01 still beats A2 after the compensated-motion repair. M01 `median_abs_e=24.000517593953077`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=21.720944919122644`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`; M01 `p99_wall_time_ns=3284.960000000006`.

## Retrospective Git Evidence For Audit Commits

The fresh no-context review found that durable workflow evidence did not include the required git outputs for `9208e6d` and `658249a`. This section records that missing evidence.

```text
git -C /home/yguo173/Programs/codex_workflow_tmux show --stat --oneline --name-status 9208e6d
```

Result:

```text
9208e6d Record current speed-frame audit
M	workflow_speed_frame_detector/final_analysis.md
M	workflow_speed_frame_detector/method_results.csv
M	workflow_speed_frame_detector/method_results.md
M	workflow_speed_frame_detector/source_discovery.md
M	workflow_speed_frame_detector/status.md
```

```text
git -C /home/yguo173/Programs/codex_workflow_tmux show --stat --oneline --name-status 658249a
```

Result:

```text
658249a Review current speed-frame audit
A	workflow_speed_frame_detector/review_current_audit.md
```

Workflow repository status before this correction checkpoint:

```text
 M README.md
 M SKILL.md
 M docs/usage.md
 M skills/run-file-writer/SKILL.md
 M skills/run-file-writer/templates/prompt_for_run_prep.md
 M skills/run-file-writer/templates/prompt_for_supervisor.md
 M skills/run-file-writer/templates/prompt_for_supervisor_goal.md
 M templates/prompt_for_run_prep.md
 M templates/prompt_for_supervisor.md
 M templates/prompt_for_supervisor_goal.md
 M workflow_speed_frame_detector/final_analysis.md
 M workflow_speed_frame_detector/method_results.csv
 M workflow_speed_frame_detector/method_results.md
 M workflow_speed_frame_detector/status.md
?? remote_transcript_skill_report/
?? temp.md
?? temp/
?? workflow_speed_frame_detector/correction_no_context_review.md
```

Unrelated modified workflow files are not staged for this correction.
