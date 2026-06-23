# Supervisor Goal

Supervise one controlled Codex executing the speed-detection and frame-update detection workflow for:

`/home/yguo173/Programs/game/fps/fps_mock`

The controlled Codex must obey:

- `/home/yguo173/Programs/codex_workflow_tmux/control/goal.md`
- `/home/yguo173/Programs/codex_workflow_tmux/control/constraint.md`

The controlled Codex must execute:

- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/run_goal.md`
- `/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/specs.md`

The supervisor sends only the short `/goal` message that points to the two control files. The supervisor does not do the controlled implementation.

Completion requires proof in:

`/home/yguo173/Programs/codex_workflow_tmux/workflow_speed_frame_detector/final_analysis.md`

The supervisor must specifically prevent these failures:

- no internet search,
- internet search without local-code validation,
- fewer than 10 methods before saying the approach cannot beat `a2`,
- stopping right after beating `a2`,
- skipped method records,
- missing speed and frame-update diagnostics,
- use of simulator truth inside the algorithm,
- unrelated git changes.
