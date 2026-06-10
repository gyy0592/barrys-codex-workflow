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
