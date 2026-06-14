# 监督模板问题示例

## 目的

这个文档记录在 Physics for LLM 工作区使用 tmux 监督流程时发现的具体失败。

目标是让以后修改模板和 skill 时更容易看懂问题。每个问题都包含具体例子，因为只写抽象规则太容易被误读。

## 问题 1：`User Review Points` 制造了错误的“问用户”关卡

### 发生了什么

`run_goal.md` 模板包含：

```md
## User Review Points

List the parts the user must review before execution starts.
```

原来的意思是让用户在执行前审查一些选择。这个意思对这个流程来说是错的。用户问题应该在 skill 写出最终运行文件之前问清楚。一旦开始执行，受控 Codex 必须在最终控制文件范围内自主行动。

受控 Codex 把这个字段理解成了运行时停止条件。

### 具体例子

在 `/home/barry/github_repo/physics_for_llm_experiments` 里，Spec 007 停在：

```text
status.md: blocked_missing_information
evidence.md: Status: blocked by required user choices.
```

它在正式收集 hidden-state 之前停止，因为 `run_goal.md` 列了这些用户审查点：

- 正式样本数；
- hidden-state 层；
- 是否保存完整 logits；
- 最大磁盘空间。

用户已经给了足够方向让运行继续，并且后来明确告诉系统继续使用：

- 4096 个样本；
- 只用最后一层 hidden state；
- 不保存完整 logits；
- 10G 磁盘限制。

### 为什么不好

这个字段把“问用户”的行为放进了持久运行文件。结果是运行依赖再次询问用户，而不是自主执行。

### 修复方向

从 run-goal 模板里删除 `User Review Points`。不要换成另一个用户审查章节。

给 skill 和运行文件模板加这条规则：

```text
skill 可以在写出最终运行文件之前向用户提澄清问题。
持久运行文件不得包含 "ask the user"、"wait for user review" 或 "user approval needed" 这类关卡。
执行开始后，受控 Codex 必须依靠 control/goal.md、control/constraint.md、当前 specs、source discovery 和 evidence 自主完成。
如果执行期间缺少某个选择，受控 Codex 必须在 control/constraint.md 允许的范围内选择保守方案，把选择和理由写进 evidence，然后继续。
```

## 问题 2：共享文件没有定义文件归属

### 发生了什么

有些文件会被监督者和受控 Codex 同时读取，但流程没有清楚说明谁可以根据这些文件行动，以及冲突时怎么处理。

### 具体例子

监督者和受控 Codex 都会读：

- `control/goal.md`
- `control/constraint.md`
- `workflow_.../run_goal.md`
- `workflow_.../specs.md`
- 当前 spec 文件

受控 Codex 把 `run_goal.md` 里的审查说明当成停止条件。监督者预期由 `control/constraint.md` 和最终 goal 控制执行。

### 为什么不好

共享文件里有模糊文字时，受控 Codex 可能发明出比监督者本意更强的规则。

### 修复方向

在流程和模板里增加文件归属章节：

- 只给监督者用的文件：
  - `prompt_for_supervisor.md`
  - `prompt_for_supervisor_goal.md`
  - 类似 `stage_supervisor_goal_to_paste.md` 的待粘贴文件
- 给受控执行用的文件：
  - `control/goal.md`
  - `control/constraint.md`
  - 当前 spec 文件
- 共享证据文件：
  - `run_goal.md`
  - `specs.md`
  - `evidence.md`
  - `status.md`
  - review 文件

对共享文件，定义清楚：

- 谁读；
- 谁写；
- 谁检查；
- 两个文件冲突时哪个文件优先。

建议优先级：

```text
control/constraint.md > control/goal.md > current spec.md > specs.md > run_goal.md
```

任务准备说明不能覆盖运行时限制。这里的“任务准备”指任务内部工作，例如收集数据、下载文件、检查环境状态、阅读资料。它不指询问用户。

## 问题 3：skill 像一个大模板，而不是分流器

### 发生了什么

主 skill 给了宽泛的准备和监督规则。它没有把工作分流给更小、更针对具体任务的帮助器。

### 具体例子

准备 hidden-state 数据流程时，assistant 先提出一个叫 `define_research_data_schema` 的 spec，虽然用户已经指定了要收集的数据：

- 第一个输出 token 的 hidden state；
- entropy chain；
- hidden-state trajectory；
- 正确答案和错误答案标签；
- parser 结果；
- 可用于 clustering 和 variance 的数据。

用户要的是把这些字段直接写进 goal 和 specs，而不是让后面的 spec 重新发现它们。

### 为什么不好

流程浪费了一个 spec 去重述用户意图，而不是产出可执行工作。

### 修复方向

把 skill 拆成一个分流器加多个小帮助器：

- `gen-goal`
- `gen-constraint`
- `gen-specs`
- `gen-supervisor-prompts`
- `review-run-files-for-autonomy`
- `start-supervised-run`
- `monitor-run`

分流器决定该用哪个小帮助器。小帮助器执行更明确的规则。

## 问题 4：`gen-specs` 需要一条规则处理用户已经决定的内容

### 发生了什么

当前模板没有强制准备者区分“用户已经决定的要求”和“未知信息”。

### 具体例子

用户已经决定第一个数据流程要收集 hidden-state generation 数据。assistant 仍然建议创建一个 spec 去定义 schema。

### 为什么不好

这会让受控 Codex 重新打开用户已经决定的事项。

### 修复方向

给未来的 `gen-specs` 帮助器加这条规则：

```text
如果用户已经指定了数据字段、设置、输出或限制，就直接写进 goal/specs。不要创建一个 spec 去再次决定它。
```

Specs 应该是可执行工作，不是重新讨论。

## 问题 5：用户审查被当成了有效运行阶段

### 发生了什么

流程说 preparation files 等用户审查。这是错误模型。skill 可以在最终运行文件创建前问澄清问题，但运行文件本身不能定义用户审查阶段。

### 具体例子

hidden-state 流程里有关于正式收集设置的用户审查问题。Spec 007 执行期间，受控 Codex 停止了，因为它把这些问题当成未解决的运行时选择。

### 为什么不好

流程不能依赖后续用户讨论。一旦开始执行，受控 Codex 应该继续，除非用户明确停止运行。

### 修复方向

加这条规则：

```text
最终运行文件写出前，skill 如果确实需要，可以向用户提澄清问题。
最终运行文件必须足够支持自主执行。
执行开始后，不要向用户索要选择、批准或审查。
如果缺少信息，就回到 source discovery，检查文件，检查输出，使用允许的外部资料，在限制范围内选择保守方案，把理由写进 evidence，然后继续。
只有用户明确发消息停止或改变运行，才可以打断自主执行。
```

## 问题 6：监督者坚持到底的规则必须出现在每条实际启动路径里

### 发生了什么

监督者提示模板里有坚持到底的规则，但实际启动文件或特定项目提示里不一定总是带着同样意思。

### 具体例子

需要的规则是：

```text
监督者不能因为受控 Codex 报告 blocked、运行失败、信息缺失或审查失败，就把监督者自己的 goal 标成 blocked。
```

如果监督者从一个省略这条规则的短提示开始，它可能停止监督，而不是强制受控 Codex 回到 source discovery、更新 spec、创建修复 spec，或者继续允许的修正循环。

### 为什么不好

受控 Codex 可能被卡住，而监督者会错误地把这当成监督者 goal 被卡住。

### 修复方向

要求每个监督者启动提示、短提示和待粘贴文件都包含坚持到底的规则。

测试应该检查这个意思本身，而不是只检查某一种固定措辞。

## 问题 7：后续用户要求必须写入持久控制文件

### 发生了什么

运行中的用户指令可以修复卡住状态，但如果它没有写进 `control/goal.md` 或 `control/constraint.md`，下次重启可能会丢失。

### 具体例子

用户后来指定 hidden-state 正式收集设置：

- 4096 个样本；
- 只用最后一层 hidden state；
- 不保存完整 logits；
- 10G 磁盘限制。

这些必须作为 `Formal Collection Settings` 加入 `control/constraint.md`；否则受控 Codex 可能继续停下来等待用户决定。

### 为什么不好

聊天记忆不是持久文件。重启后的 agent 会读文件。

### 修复方向

加这条规则：

```text
如果用户消息改变了执行权限、停止条件、必需设置或完成标准，就先把它写进当前控制文件，再依赖它。
```

## 问题 8：模板字段没有检查误读风险

### 发生了什么

运行文件模板包含语义模糊的字段。在这个文档里，“preparation” 必须表示任务内部准备工作，不是询问用户。

### 具体例子

`User Review Points` 听起来像必需的运行时检查点。它还编码了一个错误想法：持久运行文件可以等待用户审查。

### 为什么不好

模糊标题会在长时间自主运行中变成硬停止点。

### 修复方向

增加一个模板审查步骤，检查每个标题：

- 受控 Codex 能不能把它当成运行时停止条件？
- 它能不能和 `control/constraint.md` 冲突？
- 它是否在持久运行文件写出后向用户索要审查、选择或批准？

删除或重写任何检查失败的标题。

## 问题 9：没有专门的运行文件自主性审查步骤

### 发生了什么

运行文件可以语法完整，但语义危险。

### 具体例子

hidden-state 运行文件已经完整到可以存在，但 `User Review Points` 章节导致 Spec 007 停止。

### 为什么不好

流程检查了文件是否存在，但没有检查它们是否会制造不该有的“问用户”停止。

### 修复方向

增加一个 `review-run-files-for-autonomy` 帮助器，检查：

- 用户已经决定的要求没有被改写成未决定；
- 任务准备说明没有变成运行时“问用户”停止；
- 持久运行文件没有向用户索要审查、选择或批准；
- 文件归属清楚；
- 只给监督者看的文件没有发送给受控 Codex；
- 受控文件不依赖监督者聊天记忆；
- goal、constraint、specs 和 run goal 不冲突。

## 问题 10：共享文件需要解释优先级

### 发生了什么

流程没有清楚说明共享文件冲突时哪个文件优先。

### 具体例子

`run_goal.md` 暗示正式设置需要用户审查。`control/constraint.md` 后来说明正式收集设置已经指定，运行应该继续。受控 Codex 需要明确的优先级规则。

### 为什么不好

没有优先级时，旧的审查说明可能覆盖新的控制文件指令。

### 修复方向

增加一条优先级规则：

```text
执行时使用这个优先级：
1. 已写入控制文件的最新用户指令。
2. control/constraint.md。
3. control/goal.md。
4. current spec.md。
5. specs.md。
6. run_goal.md。

如果低优先级文件看起来要求停止，但高优先级控制文件允许继续，就继续，并把理由记录到 evidence。
```
