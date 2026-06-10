# codex_workflow_tmux

This repository implements a tmux-based supervision workflow for Codex.

The source design is `/home/yguo173/Downloads/tmux_codex_workflow_design.md`.

Core rule:

- The main Codex supervises.
- The controlled Codex executes.
- The task contract uses only `control/goal.md` and `control/constraint.md`.
- Concrete tmux command details live in scripts and tests, not in the high-level design text.

Required repository areas:

- `SKILL.md`: rules the main Codex reads before supervising a controlled Codex.
- `templates/`: reusable files for `goal`, `constraint`, and the short `/goal` message.
- `scripts/`: deterministic tmux and evidence-checking commands.
- `tests/`: shell tests that prove the scripts and templates work.
- `docs/experiment_book.md`: chronological record of work and verification.
- `docs/bitter_lessons.md`: repeated mistakes and prevention rules.

