# Bitter Lessons

This file records mistakes that could repeat during the long task.

## Keep The Design Small

Problem:

- Earlier designs drifted into too many control files.

Prevention:

- Keep the control contract to `control/goal.md` and `control/constraint.md` unless the user explicitly changes the design.

## Keep Roles Separate

Problem:

- The main Codex can drift from supervising into doing the controlled Codex task.

Prevention:

- Before each implementation decision, check whether the main Codex is building the workflow or doing a future controlled task. Building workflow components is allowed. Doing a future controlled task is not.

## Keep Details Testable

Problem:

- High-level documents become fragile when they contain exact tmux key sequences and retry rules.

Prevention:

- Put exact tmux commands in scripts and tests.
- Keep README and design text high-level.

## Workdir Creation

Problem:

- A command failed because the working directory was set to a path that did not exist yet.

Prevention:

- Create the target directory from an existing parent directory before running commands inside it.

