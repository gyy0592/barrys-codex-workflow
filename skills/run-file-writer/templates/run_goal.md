# Run Goal

## Workflow Id

Write the workflow id here.

## User Task

Restate the user's task in direct language. Do not add extra goals.

## Required Input Material

List every file, folder, repo, paper, skill, web source, or user message the future controlled Codex must read or inspect.

## Required Output

List the files, reports, code changes, experiment outputs, logs, commits, or summaries the run must produce.

## Success Standard

State what proves the whole run succeeded. Each item must be checkable from files or command output.

## Known Non-Goals

List work that must not be done in this run.

## Runtime Autonomy

After execution starts, complete the run autonomously using the final control files, current specs, source discovery, and evidence.

If a choice is missing during execution, choose a conservative option as defined in `control/constraint.md` and allowed by the active constraints, write the choice and reason into evidence, and continue.

## File Ownership And Priority

This file is a shared run description. The main Codex writes it during run-file creation. The supervisor and controlled Codex may read it. The supervisor checks it for consistency with higher-priority files.

Supervisor-only restrictions in supervisor prompt files do not become executor restrictions here. If higher-priority files require outputs, jobs, experiments, or task submissions, the controlled Codex must do them during execution.

For execution, use this priority:

```text
latest user instruction written into control files > control/constraint.md > control/goal.md > current spec.md > specs.md > run_goal.md
```

If this file appears to require stopping but a higher-priority control file authorizes continuation, continue and record the reason in evidence.
