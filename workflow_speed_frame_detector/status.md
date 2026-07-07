# Status

Current spec: `spec_04_final_analysis.md`.

Status: complete. M01 has been repaired to use compensated motion for unchanged classification, keep suspected dropped-frame samples out of the speed estimate, and avoid bootstrapping the speed window from the first observation. Latest rerun evidence shows M01 beats A2. Two fresh no-context reviews passed for the latest evidence state and found no substantive blocker. Final completion audit passed.

Evidence written:

- `source_discovery.md`
- `method_list.md`
- `method_results.csv`
- `method_results.md`
- `failure_analysis.md`
- `final_analysis.md`

Checkpoint evidence after Spec 01:

```text
git status --short
 M install.sh
 M scripts/install_skill.sh
 M scripts/uninstall_skill.sh
 M tests/test_install_skill.sh
?? external_skills/
?? remote_transcript_skill_report/
?? temp.md
?? temp/

git log -1 --oneline
ef805d0 Add speed-frame source discovery evidence

git show --stat --oneline --name-status HEAD
ef805d0 Add speed-frame source discovery evidence
A	workflow_speed_frame_detector/source_discovery.md
A	workflow_speed_frame_detector/status.md
```

Checkpoint evidence after Spec 02:

```text
git status --short
 M install.sh
 M scripts/install_skill.sh
 M scripts/uninstall_skill.sh
 M tests/test_install_skill.sh
?? external_skills/
?? remote_transcript_skill_report/
?? temp.md
?? temp/

git log -1 --oneline
38f9c33 Add fixed speed-frame method list

git show --stat --oneline --name-status HEAD
38f9c33 Add fixed speed-frame method list
A	workflow_speed_frame_detector/method_list.md
A	workflow_speed_frame_detector/method_results.csv
M	workflow_speed_frame_detector/status.md
```

Spec 03 start requirement:

- Start with M01.
- Implement only M01 before any later method.

Current method:

- M01 initial row recorded.
- M01 repaired row recorded.
- Next action: checkpoint commits and review.

Project checkpoint after M01 implementation:

```text
git status --short
?? prompt_for_supervisor.md
?? prompt_for_supervisor_goal.md
?? report/fast_cfg_report.md

git log -1 --oneline
19f4f5a Add M01 speed-frame detector

git show --stat --oneline --name-status HEAD
19f4f5a Add M01 speed-frame detector
M	run_demo.py
A	simulator/algos/m01.py
A	simulator/algos/speed_frame/__init__.py
A	simulator/algos/speed_frame/m01_fixed_window.py
M	simulator/simulator.py
A	tests/test_speed_frame_m01.py
```

Workflow checkpoint after M01 results:

```text
git status --short
 M install.sh
 M scripts/install_skill.sh
 M scripts/uninstall_skill.sh
 M tests/test_install_skill.sh
?? external_skills/
?? remote_transcript_skill_report/
?? temp.md
?? temp/

git log -1 --oneline
0b9d1bc Record M01 speed-frame results

git show --stat --oneline --name-status HEAD
0b9d1bc Record M01 speed-frame results
A	workflow_speed_frame_detector/failure_analysis.md
A	workflow_speed_frame_detector/final_analysis.md
M	workflow_speed_frame_detector/method_results.csv
A	workflow_speed_frame_detector/method_results.md
M	workflow_speed_frame_detector/status.md
```

Current-code audit on 2026-07-07:

```text
python -m tools.algo_contract_check
```

Result: passed.

```text
python -m unittest tests.test_speed_frame_m01 -v
```

Result: 2 tests passed.

```text
python -m unittest discover -s tests -v
```

Result: 20 tests passed.

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Current run paths:

- `sleep`: `/home/yguo173/Programs/game/fps/fps_mock/exp/sleep_seed42_20260707_160117_pid1940734_BE-HYE30LAB-02`
- `a2`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a2_seed42_20260707_160117_pid1940734_BE-HYE30LAB-02`
- `a4`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a4_seed42_20260707_160117_pid1940734_BE-HYE30LAB-02`
- `c1`: `/home/yguo173/Programs/game/fps/fps_mock/exp/c1_seed42_20260707_160117_pid1940734_BE-HYE30LAB-02`
- `m01`: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_160118_pid1940734_BE-HYE30LAB-02`

Result: M01 still beats A2. M01 `median_abs_e=24.000517593953077`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=21.720944919122644`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`; M01 `p99_wall_time_ns=2404.400000000002`.

Correction after user message on 2026-07-07:

- User correction: do not mark complete; a fresh no-context Codex subagent review using `gpt5.4 high` was required before accepting the step.
- Correction file: `correction_no_context_review.md`.
- Fresh no-context review result: FAIL.
- Real problem 1: M01 used raw motion for unchanged classification even though fixed M01 requires compensated motion.
- Real problem 2: checkpoint git evidence for `9208e6d` and `658249a` was missing from durable workflow evidence.
- Project fix: `simulator/algos/speed_frame/m01_fixed_window.py` now classifies unchanged using compensated-motion candidates; `tests/test_speed_frame_m01.py` covers compensated-motion classification.

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

Repair run paths:

- `sleep`: `/home/yguo173/Programs/game/fps/fps_mock/exp/sleep_seed42_20260707_161328_pid1963084_BE-HYE30LAB-02`
- `a2`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a2_seed42_20260707_161328_pid1963084_BE-HYE30LAB-02`
- `a4`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a4_seed42_20260707_161328_pid1963084_BE-HYE30LAB-02`
- `c1`: `/home/yguo173/Programs/game/fps/fps_mock/exp/c1_seed42_20260707_161328_pid1963084_BE-HYE30LAB-02`
- `m01`: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_161329_pid1963084_BE-HYE30LAB-02`

Result: M01 still beats A2 after the compensated-motion fix. M01 `median_abs_e=24.000517593953077`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=21.720944919122644`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`; M01 `p99_wall_time_ns=3284.960000000006`.

Second fresh no-context review on 2026-07-07:

- Reviewer 1 result: FAIL.
- Real problem: workflow evidence was not closed after the compensated-motion repair. The repair had not passed two fresh no-context PASS reviews and `status.md` still said correction was in progress.
- Reviewer 2 result: FAIL.
- Real problem: M01 still updated speed from `dropped_suspected` samples, violating the valid-updated-observations-only requirement.
- Decision: fix M01 again before any final completion claim.

Project fix after second review:

- Commit: `8ff61c6 Keep dropped frames out of M01 speed estimate`.
- `simulator/algos/speed_frame/m01_fixed_window.py`: `dropped_suspected` observations are counted but are no longer appended to `velocity_samples`.
- `tests/test_speed_frame_m01.py`: added `test_dropped_suspected_does_not_update_speed_window`.

Repair checks after valid-updates-only fix:

```text
python -m tools.algo_contract_check
```

Result: passed.

```text
python -m unittest tests.test_speed_frame_m01 -v
```

Result: 4 tests passed.

```text
python -m unittest discover -s tests -v
```

Result: 22 tests passed.

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Repair run paths:

- `sleep`: `/home/yguo173/Programs/game/fps/fps_mock/exp/sleep_seed42_20260707_162821_pid1999374_BE-HYE30LAB-02`
- `a2`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a2_seed42_20260707_162821_pid1999374_BE-HYE30LAB-02`
- `a4`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a4_seed42_20260707_162822_pid1999374_BE-HYE30LAB-02`
- `c1`: `/home/yguo173/Programs/game/fps/fps_mock/exp/c1_seed42_20260707_162822_pid1999374_BE-HYE30LAB-02`
- `m01`: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_162822_pid1999374_BE-HYE30LAB-02`

Result: M01 still beats A2 after the valid-updates-only fix. M01 `median_abs_e=27.52582626861647`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=27.52582626861647`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`; M01 `p99_wall_time_ns=2846.280000000006`.

Project checkpoint evidence after valid-updates-only fix:

```text
git status --short
?? prompt_for_supervisor.md
?? prompt_for_supervisor_goal.md
?? report/fast_cfg_report.md

git log -1 --oneline
8ff61c6 Keep dropped frames out of M01 speed estimate

git show --stat --oneline --name-status HEAD
8ff61c6 Keep dropped frames out of M01 speed estimate
M	simulator/algos/speed_frame/m01_fixed_window.py
M	tests/test_speed_frame_m01.py
```

Third fresh no-context review on 2026-07-07:

- Reviewer 1 result: FAIL.
- Reviewer 2 result: FAIL.
- Real problem: M01 still added a bootstrap `0.0` sample to `velocity_samples` on the first observation, so `velocity_valid_update_count` was `1.0` at step 0 before any valid updated delta existed.
- Decision: fix M01 again before any final completion claim.

Project fix after third review:

- Commit: `d061ad1 Do not bootstrap M01 speed window`.
- `simulator/algos/speed_frame/m01_fixed_window.py`: the first observation no longer appends `0.0` to `velocity_samples`.
- `tests/test_speed_frame_m01.py`: added `test_first_observation_does_not_update_speed_window`.

Repair checks after no-bootstrap fix:

```text
python -m tools.algo_contract_check
```

Result: passed.

```text
python -m unittest tests.test_speed_frame_m01 -v
```

Result: 5 tests passed.

```text
python -m unittest discover -s tests -v
```

Result: 23 tests passed.

```text
python run_demo.py --algos sleep,a2,a4,c1,m01 --seeds 42 --show 0
```

Repair run paths:

- `sleep`: `/home/yguo173/Programs/game/fps/fps_mock/exp/sleep_seed42_20260707_163651_pid2019353_BE-HYE30LAB-02`
- `a2`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a2_seed42_20260707_163652_pid2019353_BE-HYE30LAB-02`
- `a4`: `/home/yguo173/Programs/game/fps/fps_mock/exp/a4_seed42_20260707_163652_pid2019353_BE-HYE30LAB-02`
- `c1`: `/home/yguo173/Programs/game/fps/fps_mock/exp/c1_seed42_20260707_163652_pid2019353_BE-HYE30LAB-02`
- `m01`: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_163652_pid2019353_BE-HYE30LAB-02`

Result: M01 still beats A2 after the no-bootstrap fix. M01 `median_abs_e=27.680817196046235`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=27.5070398240764`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`; M01 `p99_wall_time_ns=2838.0000000000055`.

Step-0 diagnostic after no-bootstrap fix:

- `velocity_valid_update_count=0.0`.
- `velocity_estimate=0.0`.
- `unchanged_frame_count=0.0`.
- `suspected_dropped_frame_count=0.0`.

Project checkpoint evidence after no-bootstrap fix:

```text
git status --short
?? prompt_for_supervisor.md
?? prompt_for_supervisor_goal.md
?? report/fast_cfg_report.md

git log -1 --oneline
d061ad1 Do not bootstrap M01 speed window

git show --stat --oneline --name-status HEAD
d061ad1 Do not bootstrap M01 speed window
M	simulator/algos/speed_frame/m01_fixed_window.py
M	tests/test_speed_frame_m01.py
```

Fresh review pair after no-bootstrap fix:

- Reviewer 1 result: FAIL as workflow closure, with no new M01 code defect.
- Reviewer 2 result: FAIL as workflow closure, with no new M01 code defect.
- Shared finding: algorithmically, M01 now supports stopping after M01 under stop rule 1.
- Workflow finding: the review results had not yet been recorded, so the review gate was still open.
- Additional reviewer 2 finding: `final_analysis.md` had stale facts about best method, evidence-file row count, and test count.

Workflow evidence fix after no-bootstrap review pair:

- `final_analysis.md`: now names the no-bootstrap M01 repair as the current non-superseded best method.
- `final_analysis.md`: now says `method_results.csv` records all M01 repair rows through the no-bootstrap repair.
- `final_analysis.md`: now says focused test result is 5 tests passed and full suite result is 23 tests passed.
- `review_no_bootstrap_repair.md`: records both fresh review results and the evidence fix.

Next required checkpoint after this evidence fix:

```text
git status --short
git log -1 --oneline
git show --stat --oneline --name-status HEAD
```

Then run two fresh no-context reviews on the resulting workflow evidence state.

Final closure review pair after evidence cleanup:

- Reviewer 1 result: PASS.
- Reviewer 2 result: PASS.
- Blocking findings: none substantive.
- Shared conclusion: M01 now updates speed only from valid updated deltas, still uses compensated motion for unchanged classification, uses no forbidden truth data, records required diagnostics, beats `sleep` and `a2`, stays inside the 5 ms budget, and supports stopping after M01 under stop rule 1.
- Residual risk: the stop proof is based on the required seed-42 comparison, not a broader seed sweep.
- Evidence file: `review_final_closure.md`.

Workflow checkpoint evidence after final closure reviews:

```text
git status --short
 M control/constraint.md
?? remote_transcript_skill_report/
?? temp.md
?? temp/

git log -1 --oneline
79d3d9d Record final M01 closure reviews

git show --stat --oneline --name-status HEAD
79d3d9d Record final M01 closure reviews
M	workflow_speed_frame_detector/final_analysis.md
A	workflow_speed_frame_detector/review_final_closure.md
M	workflow_speed_frame_detector/status.md
```

Unrelated dirty workflow files were not included in the closure evidence checkpoint.

Final completion audit:

- Project HEAD: `d061ad1 Do not bootstrap M01 speed window`.
- Workflow HEAD before this status update: `dc33161 Record final closure checkpoint status`.
- Required evidence files exist: `source_discovery.md`, `method_list.md`, `method_results.csv`, `method_results.md`, `failure_analysis.md`, `status.md`, `final_analysis.md`, `review_final_closure.md`.
- Latest M01 comparison run: `/home/yguo173/Programs/game/fps/fps_mock/exp/m01_seed42_20260707_163652_pid2019353_BE-HYE30LAB-02`.
- Latest M01 result: `median_abs_e=27.680817196046235`, `final_quarter_median=27.5070398240764`, `diverged=false`, `p99_wall_time_ns=2838.0000000000055`.
- A2 result in same comparison: `median_abs_e=38.18579621000873`, `final_quarter_median=36.45623357509305`, `diverged=false`.
- Step-0 no-bootstrap check: `velocity_valid_update_count=0.0`.
- Algorithm contract check: passed.
- Focused M01 tests: 5 tests passed.
- Full test suite: 23 tests passed.
- Final closure reviews: two fresh no-context reviews passed.
- Completion decision: stop rule 1 is satisfied; the workflow is complete after M01 and does not proceed to M02.
