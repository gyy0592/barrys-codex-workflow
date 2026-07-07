# Status

Current spec: `spec_04_final_analysis.md`.

Status: correction in progress after fresh no-context review found real problems. M01 has been repaired to use compensated motion for unchanged classification and rerun evidence shows it still beats A2.

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
