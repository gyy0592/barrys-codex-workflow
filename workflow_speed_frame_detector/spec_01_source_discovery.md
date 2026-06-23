# Spec 01: Source Discovery

## Purpose

Read local source files and perform internet search before writing implementation code. Record exactly how the new methods must fit into the existing project and which internet facts support velocity detection, frame-update detection, and dropped-frame handling.

## Required Local Files To Inspect

Inspect these files:

- `/home/yguo173/Programs/game/fps/fps_mock/original_prompt.md`
- `/home/yguo173/Programs/game/fps/fps_mock/simulator/algo.py`
- `/home/yguo173/Programs/game/fps/fps_mock/simulator/simulator.py`
- `/home/yguo173/Programs/game/fps/fps_mock/simulator/recorder.py`
- `/home/yguo173/Programs/game/fps/fps_mock/run_demo.py`
- `/home/yguo173/Programs/game/fps/fps_mock/simulator/algos/a/a2_dual_rate.py`
- `/home/yguo173/Programs/game/fps/fps_mock/simulator/algos/a/a4_dual_model.py`
- `/home/yguo173/Programs/game/fps/fps_mock/simulator/algos/c/c1_threshold.py`
- `/home/yguo173/Programs/game/fps/fps_mock/tools/algo_contract_check.py`
- `/home/yguo173/Programs/game/fps/fps_mock/tests/`

Internet search is required after local file inspection. Use it to find relevant facts about online velocity estimation, stale-frame detection, repeated-frame detection, dropped-frame handling, robust filtering, and low-latency tracking.

## Required Questions To Answer

Write answers to:

1. Where should the new method code live?
2. How is a new algorithm registered so `run_demo.py` can run it?
3. What can `compute(x_screen)` legally observe?
4. How can method diagnostics be recorded without giving the algorithm simulator truth?
5. How are `median_abs_e`, `final_quarter_median`, `diverged`, and `wall_time_ns` produced?
6. How can offline evaluation compare predicted frame state with truth without feeding truth to the algorithm?
7. What existing tests or checks must be run after implementation?
8. Which existing file currently has unrelated untracked or modified state that must not be included?
9. Which internet sources give useful facts for this task?
10. Which internet facts are usable after checking them against the local simulator constraints?

## Required Output

Write `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/source_discovery.md`.

The file must include:

- checked path,
- fact found,
- direct relevance to the new speed-detection methods,
- implementation conclusion.

The file must also include an internet-source-discovery section with:

- search query,
- URL,
- source title,
- fact extracted,
- local project check,
- method or repair supported.

## Fail Conditions

This spec fails if:

- implementation starts before source discovery is recorded,
- the executor skips internet search,
- internet sources are listed without extracted facts or local project checks,
- the executor leaves any required question unanswered,
- the executor proposes using forbidden truth data.

## Completion Check

Spec 01 is complete only when `source_discovery.md` exists and answers all required questions using local file evidence.
