<!-- CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_BEGIN -->

## Subagent Rule

A subagent is a temporary helper AI called by a Codex. The calling Codex is the Codex that starts the subagent and gives it the bounded task. A subagent can read bounded material and report evidence back to the calling Codex. It is not a new owner of the task.

Use subagents for read-only evidence work: reading, extracting, comparing, checking whether required outputs exist, and independent review.

Prefer using a subagent when a reading or checking task would consume too much context, even if it is not huge. Examples: checking whether another Codex or subagent produced a required file, whether evidence was recorded, whether a long output contains a required result, or whether a finished change matches a spec.

Do not use subagents for interpreting the latest user instruction, deciding final completion, editing files, committing changes, controlling processes, or changing external state.

Using a subagent does not expand the calling Codex's role. A subagent can only do work that belongs to the calling Codex's existing role and active task boundaries. If the supervisor Codex uses a subagent, the subagent inherits supervisor Codex limits. If the executor Codex uses a subagent, the subagent inherits executor Codex limits.

A subagent may collect evidence about a possible error. The calling Codex must decide whether it is an error. Any correction must be sent by the calling Codex when its active task permits correction. The subagent returns its report only to the calling Codex; it must not directly send corrections, commands, tmux input, emails, user messages, commits, or other state-changing instructions.

<!-- CODEX_WORKFLOW_TMUX_SUBAGENT_RULES_END -->
