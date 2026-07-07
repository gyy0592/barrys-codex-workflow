# Fresh Review Results Before Valid-Updates-Only Repair

Date: 2026-07-07.

Purpose: record the two independent fresh no-context reviews run after the compensated-motion repair.

## Review 1

Reviewer: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: FAIL.

Blocking finding: workflow evidence was not closed after the compensated-motion repair. The workflow repository had the repair evidence in history, but `status.md` still said correction was in progress and the repaired state had not passed two fresh no-context PASS reviews.

Non-blocking findings:

- No forbidden truth data was found inside M01.
- No PID, reinforcement learning, fixed-sleep solution, skipped method order, or unrelated project-file edits were found.
- M01 used compensated motion for unchanged classification.
- Diagnostics were sufficient for the current repair analysis.

Decision from review 1: do not claim completion. Close the review gate after the latest repaired state passes two fresh no-context reviews.

## Review 2

Reviewer: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: FAIL.

Blocking finding: M01 still updated its speed estimate from `dropped_suspected` samples. The requirement says speed must be updated only from valid updated observations. Code review found that the `velocity_samples.append(compensated_delta)` call still ran after the `dropped_suspected` branch.

Non-blocking findings:

- M01 used compensated motion for unchanged classification.
- No forbidden truth data was found inside M01.
- No PID, reinforcement learning, fixed-sleep solution, skipped method order, unrelated committed project files, or missing internet/source evidence were found.
- Diagnostics were sufficient; the remaining issue was logic, not missing records.

Decision from review 2: repair M01 before any final completion claim.

## Repair Made Because Of Review 2

Project commit: `8ff61c6 Keep dropped frames out of M01 speed estimate`.

Changed files:

- `/home/yguo173/Programs/game/fps/fps_mock/simulator/algos/speed_frame/m01_fixed_window.py`
- `/home/yguo173/Programs/game/fps/fps_mock/tests/test_speed_frame_m01.py`

Fix: `dropped_suspected` observations are counted but no longer appended to `velocity_samples`.

Focused proof: `test_dropped_suspected_does_not_update_speed_window` verifies that a `dropped_suspected` observation leaves `velocity_valid_update_count=0.0` and `velocity_estimate=0.0`.

Required checks after repair:

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

Result: M01 still beats A2. M01 `median_abs_e=27.52582626861647`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=27.52582626861647`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`.

## Next Required Gate

The first fresh review pair after this file still failed because M01 inserted a bootstrap `0.0` sample on the first observation. That failure is recorded in the section below. The workflow may only close after both reviews pass on the latest repaired state and a workflow evidence checkpoint records both review results and git evidence.

## Fresh Review Results Before No-Bootstrap Repair

Date: 2026-07-07.

Reviewer 1: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: FAIL.

Reviewer 2: fresh Codex subagent using `gpt-5.4` with high reasoning.

Verdict: FAIL.

Shared blocking finding: M01 still inserted a bootstrap `0.0` into the speed window on the first observation. That made `velocity_valid_update_count=1.0` at step 0 before any observation delta could be classified as a valid update.

Other blocking finding from reviewer 2: old PASS review files such as `review_final.md` and `review_current_audit.md` are historical records and must not be read as current completion proof.

Decision: repair M01 again and record that older PASS files are superseded by later FAIL and repair records.

## Repair Made Because Of Bootstrap Review

Project commit: `d061ad1 Do not bootstrap M01 speed window`.

Changed files:

- `/home/yguo173/Programs/game/fps/fps_mock/simulator/algos/speed_frame/m01_fixed_window.py`
- `/home/yguo173/Programs/game/fps/fps_mock/tests/test_speed_frame_m01.py`

Fix: the first observation no longer appends `0.0` to `velocity_samples`.

Focused proof: `test_first_observation_does_not_update_speed_window` verifies that the first observation leaves `velocity_valid_update_count=0.0` and `velocity_estimate=0.0`.

Required checks after repair:

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

Result: M01 still beats A2. M01 `median_abs_e=27.680817196046235`; A2 `median_abs_e=38.18579621000873`; M01 `final_quarter_median=27.5070398240764`; A2 `final_quarter_median=36.45623357509305`; M01 `diverged=false`.

Step-0 diagnostic after repair: `velocity_valid_update_count=0.0`.

## Current Required Gate

Run two fresh no-context reviews on the latest no-bootstrap repaired state. The workflow may only close after both reviews pass and a workflow evidence checkpoint records both review results and git evidence.
