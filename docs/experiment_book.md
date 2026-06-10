# Experiment Book

This file records what was changed, how it was checked, and what remains.

## 2026-06-10 14:11 - Repository bootstrap

Goal:

- Create `/home/yguo173/Programs/codex_workflow_tmux`.
- Initialize git.
- Start the two long-task memory files requested by the user.

Actions:

- Created the repository directory.
- Ran `git init`.
- Added `README.md`, `.gitignore`, this experiment book, and `docs/bitter_lessons.md`.

Verification:

- `git init` reported an empty repository at `/home/yguo173/Programs/codex_workflow_tmux/.git`.
- `git` and `tmux` are installed on this machine.

Next:

- Commit the bootstrap files.
- Ask a clean-context subagent to review the bootstrap commit.
- Implement the skill, templates, scripts, and tests in later commits.

Subagent review:

- Result: FAIL.
- Finding: `README.md` claimed the repository "implements" the workflow before implementation files and tests existed.
- Response: Change README wording to "is being built to implement" until working components and passing tests prove completion.

## 2026-06-10 14:11 - Core components and tests

Goal:

- Add the skill, templates, scripts, and tests named by the design.
- Keep the task contract to `control/goal.md` and `control/constraint.md`.
- Prove tmux scripts work against a real tmux session.

Actions:

- Added `SKILL.md`.
- Added templates for `goal.md`, `constraint.md`, and the short `/goal` message.
- Added scripts for control-file creation, message sending, screen capture, delivery verification, progress checking, completion checking, and output packaging.
- Added shell tests for templates and tmux scripts.
- Changed README wording from "implements" to "is being built to implement" because the bootstrap commit was not a complete implementation.

Verification:

- `tests/run_tests.sh` passed.
- `bash -n scripts/*.sh tests/*.sh` passed.
- The tmux test created a real detached tmux session, sent a command through tmux, captured screen text, and verified the expected marker.
- Search found no extra control files in implementation text. Extra names appear only in tests that assert those files must not exist.

Observed output:

```text
CONTROL_FILES_CREATED /tmp/tmp.Z0J6gGh4nF/task/control
test_templates PASS
test_tmux_scripts PASS
ALL_TESTS_PASS
```

Next:

- Commit this implementation batch.
- Ask a clean-context subagent to review the new commit and test evidence.

## 2026-06-10 14:12 - Skill contract test

Goal:

- Add direct test coverage for `SKILL.md`.

Actions:

- Added `tests/test_skill_contract.sh`.
- Updated `tests/run_tests.sh` to run the skill contract test before template and tmux tests.

Verification:

- `tests/run_tests.sh` passed.
- `bash -n scripts/*.sh tests/*.sh` passed.

Observed output:

```text
test_skill_contract PASS
CONTROL_FILES_CREATED /tmp/tmp.a6jQHcrfYK/task/control
test_templates PASS
test_tmux_scripts PASS
ALL_TESTS_PASS
```

Next:

- Commit the test enhancement.
- Ask a clean-context subagent to review the new commit after the previous implementation review returns.

Subagent reviews:

- Review of `c4aa61b`: FAIL. Finding: `SKILL.md` did not have direct test coverage in that commit.
- Response: `4ba128d` added `tests/test_skill_contract.sh` and included it in `tests/run_tests.sh`.
- Review of `4ba128d`: PASS. Finding: no goal mismatch, but `git diff --check 4ba128d^ 4ba128d` reported a blank line at EOF in `tests/test_skill_contract.sh`.
- Response: remove the blank line at EOF in the next commit.

## 2026-06-10 14:13 - Review fix audit

Goal:

- Verify that the review fixes are complete.

Actions:

- Committed `c88c4dd`, which records review findings, updates bitter lessons, and removes the extra EOF blank line.
- Asked a clean-context subagent to review `c88c4dd`.

Verification:

- Subagent review of `c88c4dd`: PASS.
- `tests/run_tests.sh` passed.
- `bash -n scripts/*.sh tests/*.sh` passed.
- `git diff --check` passed.
- `git diff --check c88c4dd^ c88c4dd` passed.
- Current implementation text uses only `control/goal.md` and `control/constraint.md`. Extra control-file names appear only in tests that assert those files must not exist.

Current completion evidence:

- Git repository exists at `/home/yguo173/Programs/codex_workflow_tmux`.
- Commits exist for bootstrap, core components, skill contract test, and review fixes.
- `SKILL.md`, `templates/`, `scripts/`, and `tests/` exist.
- `docs/experiment_book.md` and `docs/bitter_lessons.md` exist and have been updated during the work.
- A real tmux session was created during `tests/test_tmux_scripts.sh`.

Review boundary:

- A commit can only be reviewed after it exists.
- The final post-commit review result is reported in the conversation instead of being written back into this file, because writing that result would create another commit that would itself need another review.

## 2026-06-10 - Skill installation fix

Goal:

- Make the workflow usable from any task directory.
- Make Codex able to discover the skill from `~/.codex/skills/tmux-codex-supervisor`.

Actions:

- Added `scripts/install_skill.sh`.
- Added `docs/usage.md`.
- Updated `SKILL.md` to use absolute paths under `/home/yguo173/Programs/codex_workflow_tmux`.
- Added `tests/test_install_skill.sh`.

Verification:

- `tests/run_tests.sh` passed.
- `bash -n scripts/*.sh tests/*.sh` passed.
- `git diff --check` passed.
- `scripts/install_skill.sh` installed the skill to `/home/yguo173/.codex/skills/tmux-codex-supervisor`.
- Installed `SKILL.md` contains absolute paths to `/home/yguo173/Programs/codex_workflow_tmux/scripts/init_control_files.sh` and `/home/yguo173/Programs/codex_workflow_tmux/templates/short_goal_message.md`.

Observed output:

```text
test_skill_contract PASS
test_install_skill PASS
CONTROL_FILES_CREATED /tmp/tmp.jXK8BB5UUj/task/control
test_templates PASS
test_tmux_scripts PASS
ALL_TESTS_PASS
SKILL_INSTALLED /home/yguo173/.codex/skills/tmux-codex-supervisor
```

Post-commit finding:

- `git diff --check HEAD^ HEAD` found blank lines at EOF in `docs/usage.md`, `scripts/install_skill.sh`, and `tests/test_install_skill.sh`.
- Response: remove the blank EOF lines and add a bitter lesson for checking committed diffs.

## 2026-06-10 - Source design path fix

Goal:

- Align README with the current goal source file.

Finding:

- A clean-context subagent found that `README.md` still pointed to `/home/yguo173/Downloads/tmux_codex_workflow_design.md`.
- The current goal points to `/home/yguo173/Downloads/tmux_codex_workflow_design.html`.

Action:

- Updated `README.md` to point to the HTML design.

Verification:

- `tests/run_tests.sh` passed.
- `bash -n scripts/*.sh tests/*.sh` passed.
- `git diff --check` passed.
- `README.md` now points to `/home/yguo173/Downloads/tmux_codex_workflow_design.html`.
