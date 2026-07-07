# codex_workflow_tmux 中文教程

中文 | [English](README.md)

这个仓库安装两个 Codex skill，用来在 tmux 里运行任务。tmux 是一个终端工具，可以让命令在你离开窗口后继续运行。

- `run-file-writer`：先把任务聊清楚，再写最终运行文件。
- `tmux-codex-supervisor`：在 tmux 里运行已经准备好的工作流。

## 1. 安装

```bash
./install.sh
```

## 2. 先把任务聊清楚

在真正要做任务的项目目录打开 Codex：

```bash
cd /path/to/your/project
codex
```

发给 Codex：

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

## 3. 写运行文件

当 Codex 问是否可以开始写 run files，并且你同意后，发：

```text
Use the run-file-writer skill.

The current directory is the task project.
Use workflow_<run_id>/requirement_dialogue.md as the source requirement record.
Generate final run files only.
Do not start the run.
Do not start long-running work.
Before writing, reread workflow_<run_id>/requirement_dialogue.md and confirm there are no unresolved conflicts.
After writing, report which files you created and whether the run can continue after it starts.
```

Codex 应该生成这些文件：

- `control/goal.md`
- `control/constraint.md`
- `workflow_<run_id>/requirement_dialogue.md`
- `workflow_<run_id>/run_goal.md`
- `workflow_<run_id>/specs.md`
- `workflow_<run_id>/prompt_for_supervisor.md`
- `workflow_<run_id>/prompt_for_supervisor_goal.md`

## 4. 开始运行

在同一个任务项目目录启动新的 supervisor Codex：

```bash
cd /path/to/your/project
tmux new -s "<project>-<run_id>-supervisor" -c "$PWD" 'codex --dangerously-bypass-approvals-and-sandbox'
```

在这个 Codex 里：

1. 输入 `/goal`。
2. 粘贴 `workflow_<run_id>/prompt_for_supervisor_goal.md` 里的正文。
3. 按 Enter。

之后 supervisor 会运行整个工作流。你可以让它留在 tmux 里继续跑。
