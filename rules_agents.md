# Subagent Rules

## Purpose

This file defines when a calling Codex should use a subagent.

A subagent is a temporary helper AI called by a Codex. The calling Codex is the Codex that starts the subagent and gives it the bounded task. A subagent can read bounded material and report evidence back to the calling Codex. It is not a new owner of the task. It must not change the calling Codex's role, permission, responsibility, or completion standard.

In this workflow, the supervisor Codex monitors and corrects execution. The executor Codex, also called the controlled Codex, performs the task. A subagent can only do work that belongs to the calling Codex's role. A supervisor Codex's subagent can only do supervisor-allowed read or review work. An executor Codex's subagent can only do executor-allowed read or review work.

Core rule:

```text
Use subagents for read-only evidence work.
Do not use subagents for ownership, final decisions, correction messages, or actions that change state.
```

## Default Bias

Prefer using a subagent when the task is a reading, extraction, comparison, or review task and the answer can be checked with concrete evidence.

There is no fixed minimum such as 20 files or 3000 lines. A task may deserve a subagent even when it reads one long file, a few dense files, a long command output, a tmux screen capture, or a small set of evidence files.

Do not use a subagent only because a task is hard. Use it when the task can be isolated into a read-only question with a short evidence-based answer.

## Use A Subagent

Use a subagent when at least one item below is true and none of the forbidden cases apply:

- The calling Codex must read material that may consume too much attention or context, such as long documents, logs, transcripts, evidence files, status files, review files, command output, or many search results.
- The calling Codex needs a short answer from larger material, such as a list of findings, missing items, changed files, failed commands, unresolved comments, or exact evidence locations.
- The calling Codex needs to check whether another Codex or subagent produced a required output, such as whether a file exists, whether a section was filled, whether evidence was recorded, or whether a required test result appears.
- The calling Codex needs an independent review after creating or changing something, especially a prompt, rule file, design document, code change, or checkpoint result.
- The same material needs more than one independent checking angle, such as user-intent drift, missing evidence, unrelated file changes, undefined words, test coverage, or contradiction between files.
- The task is a no-context review, meaning the reviewer should judge only the supplied files and evidence without relying on chat history.

Good subagent tasks are shaped like this:

```text
Read these files. Report whether X exists. Give exact evidence.
Read this evidence. List missing required outputs.
Read this diff. Identify unrelated files, if any.
Read this status file and this goal file. Report mismatches only.
Review this completed change against this spec. Return findings with evidence.
```

## Supervisor Subagents

The supervisor Codex may use subagents for read-only monitoring and review work that the supervisor Codex itself is allowed to do:

- summarize run files, evidence files, status files, review files, logs, git output, and tmux screen captures;
- compare current evidence against `control/goal.md` and `control/constraint.md`;
- find whether the executor drifted from the current spec;
- check whether expected files, outputs, tests, or evidence exist;
- check whether a checkpoint commit contains unrelated files;
- perform no-context review after a completed spec;
- extract blockers, missing evidence, failed commands, or unresolved reviewer findings.

The supervisor Codex must still make the final supervisory decision. A supervisor Codex subagent may report "the evidence suggests drift" back to the supervisor Codex; it must not send the correction or decide how supervision continues.

## Executor Subagents

The executor Codex may use subagents for read-only support during the current task, limited to work the executor Codex itself is allowed to do:

- search large or dense source areas and report exact relevant files;
- summarize documentation needed for the current spec;
- inspect test failures and list likely causes with evidence;
- compare the implementation against the current spec;
- review a completed local change before checkpoint;
- check whether required outputs and evidence are present.

The executor Codex must still decide the implementation, make the edits, run required checks, and report completion evidence.

## Do Not Use A Subagent

Do not use a subagent for any task below:

- interpreting the latest user instruction;
- deciding the user's intent, task boundary, priority, or forbidden actions;
- deciding whether the whole task is complete;
- deciding whether the supervisor Codex goal is complete or blocked;
- directly sending corrections, commands, tmux input, emails, user messages, commits, or other state-changing instructions instead of returning a report to the calling Codex;
- correcting another Codex or subagent directly;
- starting, stopping, killing, or controlling a running process;
- editing files, deleting files, moving files, changing configuration, or creating commits;
- making final code changes or final document changes;
- choosing the final implementation plan when full project context is needed;
- rewriting a long final document where tone, meaning, and constraints must remain consistent across the whole document;
- making a judgment that depends on hidden chat history or full conversation context not given to the subagent;
- replacing a deterministic command when a command can answer more directly and reliably.

Special forbidden case:

```text
Do not ask a subagent to check whether another Codex or subagent is wrong and then send that Codex or subagent a correction.
The subagent may collect evidence about the possible error.
The calling Codex must inspect the evidence and decide whether it is an error. Any correction must be sent by the calling Codex when its active task permits correction.
```

## Required Subagent Prompt Shape

Every subagent request must include:

- calling Codex role: supervisor Codex, executor Codex, or another current Codex role;
- allowed role boundary from the current task files;
- read-only scope: exact files, command outputs, screenshots, logs, or text to inspect;
- one narrow question;
- required output format;
- evidence requirement, such as file path, line number, command output, or short quote;
- explicit limits saying the subagent must only return a report to the calling Codex and must not edit files, make final decisions, expand the task, or directly send corrections, commands, tmux input, emails, user messages, commits, or other state-changing instructions.

Template:

```text
You are a read-only subagent for the [calling Codex role].
Role boundary: [what the calling Codex is allowed to do under the current task files].
Task: [one narrow reading/checking question].
Read only: [exact material].
Return: [short list/table/summary].
Every finding must cite concrete evidence.
Return your report only to the calling Codex. Do not edit files. Do not decide completion. Do not expand scope. Do not directly send corrections, commands, tmux input, emails, user messages, commits, or other state-changing instructions.
```

## Calling Codex Verification

The calling Codex must verify the subagent result before relying on it.

Verification means checking the cited file path, line, command output, or quoted text when the result affects a decision, correction, commit, completion claim, or next step.

If the subagent gives a conclusion without evidence, the calling Codex must treat it as unproven.

If the subagent reports uncertainty, the calling Codex must inspect the source material or ask a narrower subagent question. Do not turn uncertainty into a final conclusion.

## One-Line Rule

```text
A subagent may reduce reading load, but it must not reduce responsibility.
```
