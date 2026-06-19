# Minimal Subgoal Workflow

这个文件是一个最小 specific workflow（针对某一类任务的具体工作流程说明）。它不是新的 skill。主控 Codex 读取这个文件后，用已经存在的 `tmux-codex-supervisor` 工具去控制 tmux 里的受控 Codex。

## 1. 这个需求是否足够清楚

足够清楚，可以做最小版本。

当前明确的信息是：

- 用户会给一个总目标。
- 总目标会被拆成多个 spec。
- spec 是一个可独立完成的小目标，也可以理解成 subgoal。
- 每个 spec 必须有可观测变量。
- 可观测变量是能被主控 Codex 检查的证据，例如文件是否存在、测试是否通过、命令输出是否包含某段文字、屏幕输出是否显示某个状态。
- 不需要提前写死完整 plan，因为 `/goal` 会让受控 Codex 动态生成计划。
- 每个 spec 开工前必须先做 source discovery。
- source discovery 是信息收集阶段，目标是尽力收集完成该 spec 需要的文件、项目知识和互联网信息。
- source discovery 的结果必须写进本次 run 的目录。
- 每个 spec 需要一个简短 high level abstract plan。
- high level abstract plan 是高层步骤，只写方向，不写容易错的细节。
- 如果发现信息不足，必须回到 source discovery，不能靠猜。
- 如果遇到有复用价值的错误或理解偏差，必须写进 bitter lesson。
- 每个 spec 只有在证据通过后才能打勾，然后进入下一个 spec。
- 每个 spec 完成后，必须做 checkpoint commit。
- 每个 checkpoint commit 后，必须并行开两个无上下文 subagent 审查 git 状态、git diff、git commit、spec 证据、goal 和 constraint。
- 审查通过后才能进入下一个 spec。

当前还需要每次运行时由主控 Codex 动态决定的信息是：

- run id 怎么命名。
- 总目标拆成哪些 spec。
- 每个 spec 的可观测变量是什么。
- 每个 spec 要收集哪些文件、项目知识或互联网信息。
- 每个 spec 的完成检查命令是什么。

## 2. 角色

主控 Codex 是当前聊天里的监督者。主控 Codex 负责读这个 workflow 文件、准备控制文件、启动或控制 tmux、检查证据、纠正偏离、决定是否进入下一个 spec。

受控 Codex 是 tmux 窗口里的执行者。受控 Codex 负责按照当前 spec 做真实工作。

主控 Codex 不直接完成受控 Codex 被分配的任务。主控 Codex 只监督、纠偏和验收。

## 3. 目录结构

每次运行创建一个 run 目录：

```text
workflow_<run_id>/
  run_goal.md
  spec_001_<task_name>/
    spec.md
    source_discovery.md
    abstract_plan.md
    evidence.md
    status.md
    review.md
  spec_002_<task_name>/
    spec.md
    source_discovery.md
    abstract_plan.md
    evidence.md
    status.md
    review.md
  bitter_lesson/
    lesson_<short_name>.md
```

`workflow_<run_id>/run_goal.md` 写本次总目标和 spec 列表。

`spec.md` 写当前 spec 的目标、限制和可观测变量。

`source_discovery.md` 写为了完成当前 spec 收集到的信息。

`abstract_plan.md` 写当前 spec 的简短高层计划。

`evidence.md` 写当前 spec 的证据、检查方法、检查结果。

`status.md` 写当前 spec 是否完成。只能写 `pending`、`in_progress`、`needs_source_discovery`、`needs_correction`、`done`。`needs_source_discovery` 和 `needs_correction` 是执行者局部继续状态，不是 supervisor Codex 停止状态，也不是等待用户回复。

`review.md` 写无上下文 subagent 对当前 spec、git diff、git commit 和证据的审查结果。

`bitter_lesson/` 写本次运行中发现的可复用错误知识。

## 4. Spec 必须包含什么

每个 spec 必须写成下面的结构：

```text
# Spec

## Subgoal
这里写这个 spec 要完成的小目标。

## Observable Variable
这里写可观测变量。

## Pass Condition
这里写什么证据算通过。

## Fail Condition
这里写什么情况算失败或跑偏。

## Required Source Discovery
这里写开工前必须收集的信息类型。

## Completion Check
这里写主控 Codex 如何检查完成。
```

一个 spec 不允许只写“完成某功能”这种无法检查的话。它必须能回答：

- 要完成什么？
- 看什么证据？
- 什么算通过？
- 什么算失败？
- 缺少信息时回到哪里？

## 5. 每个 spec 的运行阶段

### Stage 1: Source Discovery

目标：收集完成当前 spec 必须知道的信息。

主控 Codex 必须要求受控 Codex 先收集信息，不能直接开工。

信息来源包括：

- 当前项目里的相关文件。
- 当前项目里的已有测试、脚本、配置和文档。
- 用户明确给出的材料。
- 如果任务需要最新或外部事实，则收集互联网信息。

收集结果必须写到：

```text
workflow_<run_id>/spec_<number>_<task_name>/source_discovery.md
```

`source_discovery.md` 必须写清楚：

- 查了哪些文件。
- 查了哪些命令输出。
- 查了哪些外部资料。
- 每条信息支持什么行动。
- 还有什么不确定。

进入下一阶段的条件：

- 当前 spec 的行动不需要靠猜。
- 必要文件已经查过。
- 必要知识已经记录。
- 如果需要互联网信息，已经收集并记录。

如果不满足这些条件，不能进入执行阶段。

### Stage 2: Abstract Plan

目标：写一个简短高层计划，指导当前 spec 怎么做。

计划写到：

```text
workflow_<run_id>/spec_<number>_<task_name>/abstract_plan.md
```

计划必须满足：

- 简短。
- 只写高层步骤。
- 不写容易过期的细节。
- 不把猜测写成事实。
- 每一步都服务当前 spec。

示例：

```text
1. 根据 source discovery 确认要改的最小范围。
2. 修改当前 spec 直接要求的文件。
3. 运行 completion check。
4. 如果检查失败，根据失败证据回到 source discovery 或修正实现。
```

### Stage 3: Execute

目标：受控 Codex 根据当前 spec 和 abstract plan 做真实工作。

执行时必须遵守：

- 每个动作都服务当前 spec。
- 不做当前 spec 之外的任务。
- 不靠猜测补全缺失信息。
- 遇到信息不足时立刻回到 Stage 1。
- 遇到可复用错误时写 bitter lesson。

### Stage 4: Evidence Check

目标：主控 Codex 检查当前 spec 是否完成。

证据写到：

```text
workflow_<run_id>/spec_<number>_<task_name>/evidence.md
```

`evidence.md` 必须写清楚：

- 检查了什么。
- 用什么命令或文件检查。
- 期望结果是什么。
- 实际结果是什么。
- 结论是通过、失败，还是信息不足。

如果证据通过，主控 Codex 把当前 spec 的 `status.md` 写成：

```text
done
```

如果证据失败，主控 Codex 让受控 Codex修正。

如果失败原因是信息不足，主控 Codex 必须让受控 Codex 回到 Stage 1。

### Stage 5: Checkpoint Commit

目标：把已经完成并且证据通过的当前 spec 保存成 git 记录。

checkpoint commit 是阶段性 git commit。它的作用是让长任务在每个稳定阶段都有可恢复、可审查的保存点。

只有当前 spec 的 evidence 通过后，才可以做 checkpoint commit。

提交前必须做：

1. 运行 `git status --short`。
2. 区分当前 spec 需要的文件和无关文件。
3. 只暂存当前 workflow 需要的文件。
4. 不暂存还在变化的实验输出。
5. 不暂存用户无关改动。
6. 如果文件无法安全分开，停止并报告具体文件。

提交后必须把这些证据写入当前 spec 的 `evidence.md`：

```text
git status --short
git log -1 --oneline
git show --stat --oneline --name-status HEAD
```

### Stage 6: Parallel No-Context Review

目标：让没有当前长上下文的 subagent 审查当前 spec 是否真的完成，避免主控和受控 Codex 因为长上下文漂移而互相放过错误。

no-context subagent 是一个新开的审查 agent。它只能拿到当前 spec 需要的文件、git 证据和审查要求，不应该依赖主控 Codex 的聊天上下文。

每个 checkpoint commit 后，主控 Codex 必须并行开两个 no-context subagent：

1. `implementation_goal_review`：检查当前 spec 是否正确实现，是否偏离 `control/goal.md` 和当前 spec。
2. `constraint_review`：检查当前 spec 是否违反 `control/constraint.md`、全局用户要求、git 规则和 workflow 规则。

两个 subagent 都必须独立审查。不能让第二个 subagent 读取第一个 subagent 的结论。

主控 Codex 必须给两个 subagent 这些材料：

- 当前 spec 的 `spec.md`。
- 当前 spec 的 `source_discovery.md`。
- 当前 spec 的 `abstract_plan.md`。
- 当前 spec 的 `evidence.md`。
- 当前 spec 的 `status.md`。
- `control/goal.md`。
- `control/constraint.md`。
- 当前 spec 相关的 changed files。
- `git status --short`。
- `git diff HEAD^ HEAD`。
- `git show --stat --oneline --name-status HEAD`。
- 必要时提供 `git log --oneline -5`，让 reviewer 看最近 checkpoint 顺序。

`implementation_goal_review` 必须检查：

- 当前 spec 是否按 `spec.md` 正确实现。
- 当前 spec 的 source discovery 是否足够支持执行。
- 当前 spec 的 abstract plan 是否简短且高层。
- 当前 spec 的 evidence 是否证明 pass condition。
- 当前 spec 的 status 是否只在证据通过后写成 `done`。
- 当前 spec 是否偏离 `control/goal.md`。
- 当前 commit 是否包含当前 spec 应该产生的文件。

`constraint_review` 必须检查：

- 当前 spec 是否违反 `control/constraint.md`。
- 当前 spec 是否违反全局用户要求。
- 当前 commit 是否只包含当前 workflow 需要的文件。
- 当前 commit 是否混入无关用户改动。
- 当前 commit 是否暂存还在变化的实验输出。
- 当前 spec 是否跳过 checkpoint commit、review、source discovery、evidence 或其他 workflow 规则。

审查结果必须写入：

```text
workflow_<run_id>/spec_<number>_<task_name>/review_implementation_goal.md
workflow_<run_id>/spec_<number>_<task_name>/review_constraint.md
workflow_<run_id>/spec_<number>_<task_name>/review.md
```

两个子审查文件必须包含：

```text
# Review

## Review Type
implementation_goal_review 或 constraint_review

## Result
PASS 或 FAIL

## Checked
写审查了哪些文件、命令和 commit。

## Findings
写发现的问题。没有问题就写 none。

## Required Fix
如果 FAIL，写必须修什么。
```

`review.md` 是主控 Codex 写的汇总文件，必须包含两个子审查的结果、结论和是否允许进入下一个 spec。

如果任意一个子审查是 `FAIL`，总 `review.md` 必须是 `FAIL`。主控 Codex 必须让受控 Codex 修正当前 spec，重新提交 checkpoint commit，并重新并行开两个新的无上下文 subagent 审查。

只有两个子审查都是 `PASS`，总 `review.md` 才能是 `PASS`，主控 Codex 才能进入下一个 spec。

## 6. Missing Information Rule

缺少信息的判断标准：

如果下一步行动需要猜测一个事实、猜测一个文件用途、猜测一个接口行为、猜测一个外部规则，当前信息就不足。

信息不足时必须做：

1. 停止执行当前实现动作。
2. 把不确定点写进当前 spec 的 `source_discovery.md`。
3. 重新收集能消除不确定的信息。
4. 更新 `source_discovery.md`。
5. 必要时更新 `abstract_plan.md`。
6. 再继续执行。

禁止做：

- 先猜一个实现试试。
- 因为看起来合理就继续。
- 把没有证据的推断写成事实。

## 7. Bitter Lesson Rule

如果出现以下情况，必须写 bitter lesson：

- 理解错用户要求。
- 做了 spec 外的事情。
- 忽略了已有文件或已有规则。
- 因为没有收集信息导致返工。
- 某个错误以后很可能重复出现。
- checkpoint commit 混入无关文件。
- 无上下文 subagent 审查失败。

写入位置：

```text
workflow_<run_id>/bitter_lesson/lesson_<short_name>.md
```

每条 bitter lesson 必须包含：

```text
# Lesson

## What Happened
写发生了什么。

## Why It Happened
写为什么发生。

## Prevention
写以后怎么避免。
```

## 8. 主控 Codex 怎么监督

主控 Codex 用已有 `tmux-codex-supervisor` 做底座。

最小监督方式：

1. 主控 Codex 读取本 workflow 文件。
2. 主控 Codex 把总目标拆成 spec。
3. 主控 Codex 创建 `workflow_<run_id>/`。
4. 主控 Codex 为第一个 spec 写 `spec.md`。
5. 主控 Codex 把当前 spec 和本 workflow 的关键规则写进 `control/goal.md` 和 `control/constraint.md`。
6. 主控 Codex 启动 tmux 里的受控 Codex。
7. 主控 Codex 发送短 `/goal`。
8. 主控 Codex 确认受控 Codex 收到消息。
9. 主控 Codex 检查受控 Codex 是否先做 source discovery。
10. 如果受控 Codex 直接开工，主控 Codex 立刻纠正。
11. 主控 Codex 检查每个 spec 的 evidence。
12. evidence 通过后，主控 Codex 要求受控 Codex 创建 checkpoint commit。
13. 主控 Codex 并行开两个无上下文 subagent 审查当前 spec、goal、constraint、git diff、git commit history 和 evidence。
14. 两个子 review 都通过，并且总 `review.md` 汇总为 `PASS` 后，主控 Codex 标记当前 spec 为 `done`。
15. 主控 Codex 进入下一个 spec。
16. 所有 spec 都 `done` 后，主控 Codex 按总目标做最终验收。

## 9. 写入 control 文件的最小内容

`control/goal.md` 至少包含：

- 本次总目标。
- 当前 spec。
- 当前 spec 的可观测变量。
- 当前 spec 的通过条件。
- 当前 spec 的失败条件。
- 当前 spec 的完成检查方式。
- 当前 run 目录路径。
- 每个 spec 完成后必须 checkpoint commit。
- 每个 checkpoint commit 后必须并行开两个无上下文 subagent 审查。
- 两个子 review 都通过，并且总 `review.md` 汇总为 `PASS` 后才能进入下一个 spec。

`control/constraint.md` 至少包含：

- 受控 Codex 必须先做 source discovery。
- 受控 Codex 必须把收集结果写入当前 spec 的 `source_discovery.md`。
- 受控 Codex 必须写简短 `abstract_plan.md` 后才能执行。
- 受控 Codex 遇到信息不足必须回到 source discovery。
- 受控 Codex 发现可复用错误必须写 bitter lesson。
- 受控 Codex 不能做当前 spec 之外的任务。
- 受控 Codex 不能把猜测当事实。
- 受控 Codex 完成当前 spec 后必须创建 checkpoint commit。
- 受控 Codex 提交前必须只暂存当前 workflow 需要的文件。
- 受控 Codex 不能暂存无关用户改动。
- 受控 Codex 不能暂存还在变化的实验输出。
- 主控 Codex 必须在 checkpoint commit 后并行开两个无上下文 subagent 审查。
- 一个 subagent 审查 spec 实现是否正确以及是否偏离 `control/goal.md`。
- 一个 subagent 审查是否违反 `control/constraint.md`、全局用户要求、git 规则和 workflow 规则。
- 审查失败时，受控 Codex 必须修正并重新提交。

## 10. 最小启动消息

主控 Codex 可以把下面内容作为用户请求的一部分理解：

```text
Use tmux-codex-supervisor as the base supervisor.
Also follow specific workflow/minimal_subgoal_workflow.md.

Create a workflow_<run_id>/ directory in the task project.
Split the goal into specs.
For each spec, require source discovery first, then a short high-level abstract plan, then execution, then evidence check.
After each spec passes evidence, require a checkpoint git commit.
After each checkpoint commit, run two parallel no-context subagent reviews.
One reviewer checks correct spec implementation and drift from control/goal.md.
The other reviewer checks violations of control/constraint.md, global user requirements, git rules, and workflow rules.
Both reviewers must inspect spec evidence, git diff, git status, latest commit, and recent commit history when needed.
Only move to the next spec after both no-context reviews pass and review.md summarizes PASS.
If information is missing, return to source discovery.
If a reusable mistake is found, write it to workflow_<run_id>/bitter_lesson/.
Only mark a spec done when its observable variable proves success.
```

## 11. 最小完成标准

这个 workflow 的一次运行完成，必须同时满足：

- `workflow_<run_id>/run_goal.md` 存在。
- 每个 spec 都有自己的目录。
- 每个 spec 都有 `spec.md`。
- 每个 spec 都有 `source_discovery.md`。
- 每个 spec 都有 `abstract_plan.md`。
- 每个 spec 都有 `evidence.md`。
- 每个 spec 都有 `review_implementation_goal.md`。
- 每个 spec 都有 `review_constraint.md`。
- 每个 spec 都有 `review.md`。
- 每个 spec 的 `status.md` 是 `done`。
- 每个 spec 完成后都有 checkpoint commit 证据。
- 每个 checkpoint commit 后都有两个无上下文 subagent 的 PASS review。
- 每个 spec 的总 `review.md` 汇总两个子审查，且结果是 `PASS`。
- 如果运行中出现可复用错误，`bitter_lesson/` 里有记录。
- 主控 Codex 的最终汇报引用的是证据，不是猜测。
