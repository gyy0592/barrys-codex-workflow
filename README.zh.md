# codex_workflow_tmux 中文教程

中文 | [English](README.md)

这个仓库提供一套基于 tmux 的 Codex 监督流程。

核心规则：

- 主 Codex 先准备运行文件，之后作为监督者。
- 受控 Codex 负责真正执行任务。
- 受控 Codex 只用 `control/goal.md` 和 `control/constraint.md` 作为任务合同。
- 需求澄清和前后冲突检查必须在写运行文件前完成。
- 用户在 supervisor Codex 里输入 `/goal` 并粘贴 `prompt_for_supervisor_goal.md` 正文后，就等于批准开始运行；之后不需要第二次批准。

## 1. 安装

在本仓库执行：

```bash
./install.sh
```

安装脚本会把 workflow skills 安装到 `~/.codex/skills/`。

## 2. 先聊清楚任务，并记录聊天

在真正任务所在的项目目录打开 Codex：

```bash
cd /path/to/your/project
codex
```

让 Codex 先读两个 skill，然后和你澄清任务：

```text
Read the tmux-codex-supervisor skill and the run-file-writer skill.

The current directory is the task project.
Do not write run files yet.
Create and maintain workflow_<run_id>/requirement_dialogue.md.
Every time you ask me whether the task should be one way or another way, append your question, my answer, and the updated conclusion to that file.
Ask me clarification questions until the goal, constraints, task material, output, success checks, and spec list are clear enough to write final run files.
If I have not already said to start writing run files, ask me whether you should start writing the run files now.

My task is: 在这里写真实任务。
```

`requirement_dialogue.md` 是需求聊天记录文件。每次 Codex 问“是不是要这样做”“这个选项还是那个选项”，都必须把问题、你的回答、更新后的结论写进去。

## 3. 写 run files 前检查前后冲突

写运行文件前，Codex 必须重读 `workflow_<run_id>/requirement_dialogue.md`，检查有没有前面说 A、后面改成 B 的情况。最新回答优先，但 Codex 必须先问清楚旧要求是否删除或替换。

例子：

```text
You previously said to keep X, but later you said to use Y instead. Should I remove X and write the run files using Y?
```

只有当 `requirement_dialogue.md` 没有未解决冲突，并且用户确认可以开始写 run files 后，Codex 才能写运行文件。

## 4. 写最终 run files

用户确认后，让 Codex 使用 run-file-writer：

```text
Use the run-file-writer skill.

The current directory is the task project.
Use workflow_<run_id>/requirement_dialogue.md as the source requirement record.
Generate final run files only.
Do not start the controlled Codex.
Do not start long-running work.
Before writing, reread workflow_<run_id>/requirement_dialogue.md and confirm there are no unresolved conflicts.
After writing, report the file list and the autonomy checks.
```

Codex 应该写出：

- `control/goal.md`
- `control/constraint.md`
- `workflow_<run_id>/run_goal.md`
- `workflow_<run_id>/specs.md`
- `workflow_<run_id>/requirement_dialogue.md`
- `workflow_<run_id>/prompt_for_supervisor.md`
- `workflow_<run_id>/prompt_for_supervisor_goal.md`

这些运行文件不能包含“执行时再等用户批准、选择、审查”的关卡。

## 5. 用户手动启动 supervisor

run files 写完后，用户可以大概看一眼 `workflow_<run_id>/prompt_for_supervisor_goal.md`。然后在任务项目目录启动 supervisor Codex：

```bash
cd /path/to/your/project
tmux new -s codex-supervisor -c "$PWD" 'codex --dangerously-bypass-approvals-and-sandbox'
```

在这个 Codex 里，用户先手动输入：

```text
/goal
```

然后粘贴 `workflow_<run_id>/prompt_for_supervisor_goal.md` 里的正文。

重要：`prompt_for_supervisor_goal.md` 模板里不能包含 `/goal`。模板只写 `/goal` 后面的正文。这样可以避免用户整块复制时把 Codex 的长文本粘贴机制搞乱。

不要把 `prompt_for_supervisor.md` 当成 `/goal` 粘贴。`prompt_for_supervisor.md` 是长的 companion file，也就是 supervisor goal 里要求 Codex 去读的详细说明文件。

## 6. 提交 supervisor goal 后就开始运行

用户提交 supervisor `/goal` 后，运行已经开始，不需要第二次批准。Supervisor Codex 应该读取 `prompt_for_supervisor.md`，确认运行文件存在，启动一个受控 Codex，把短 goal 发给受控 Codex，然后持续监督直到完成，除非用户明确要求停止。

Supervisor 发给受控 Codex 的短 goal 是：

```text
/goal
control/goal.md
control/constraint.md
```
