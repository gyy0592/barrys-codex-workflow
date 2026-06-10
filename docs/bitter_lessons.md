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

## Do Not Claim Completion Early

Problem:

- The bootstrap README said the repository "implements" the workflow before scripts, templates, and tests were committed.

Prevention:

- Use "is being built to implement" until the repository has working components and passing tests.
- Only claim that the repository implements the workflow after current evidence proves it.

## Keep Tests Isolated

Problem:

- A draft test wrote expected-failure output to fixed `/tmp` paths.

Prevention:

- Put test byproducts under the test's own temporary directory so concurrent runs do not collide.

## Test Every Required Component

Problem:

- The first implementation commit tested templates and tmux scripts, but did not directly test `SKILL.md`.

Prevention:

- Keep a dedicated skill contract test.
- Treat "all tests pass" as incomplete when a required component has no direct test or inspection gate.

## Run Diff Formatting Checks

Problem:

- A reviewed commit passed functional tests but had a blank line at EOF reported by `git diff --check`.

Prevention:

- Run `git diff --check` before each commit.
