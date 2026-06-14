# Skill 拆分和剩余问题修复计划

## 目标

把 `docs/supervisor_template_problem_examples_20260614.md` 里还没有完成的问题 3、4、6、7、9 修完。

这次计划的核心判断：

- 问题 1、2、5、8、10 已经在 `v2.1` 里主要通过模板修复。
- 剩下的问题主要是 skill 层问题。
- skill 层必须明确区分哪些内容给监督者用，哪些内容给受控 Codex 用。
- 用户澄清问题只能发生在最终运行文件写出前。最终运行文件写出后，执行阶段不得再向用户索要选择、批准或审查。

## 术语

监督者：当前聊天里的主 Codex。它负责准备运行文件、启动 tmux 里的受控 Codex、检查证据、纠正偏离、决定是否进入下一步。

受控 Codex：tmux 里的执行者。它只读短 `/goal` 指向的 `control/goal.md` 和 `control/constraint.md`，再按当前 spec 和证据文件执行任务。

运行文件：执行前写好的持久文件，例如 `control/goal.md`、`control/constraint.md`、`workflow_<id>/run_goal.md`、`workflow_<id>/specs.md`。

持久文件：写在磁盘上的文件。重启后的 agent 会读它；聊天记忆不算持久文件。

source discovery：执行前的信息收集记录，写清楚查了哪些文件、命令输出或外部资料，以及这些信息支持什么行动。

无上下文 agent：一个新开的检查 agent。它不依赖当前长聊天，只拿到明确给它的文件、git 证据和检查要求，用来降低长上下文互相放过错误的风险。

## Codex skill 触发机制依据

我查了 OpenAI 官方 Codex skill 文档和本地拉取的 Codex manual。结论：

- Codex skill 有两种触发方式：
  - 显式触发：用户在提示里直接写 `$skill-name`，或者在 CLI/IDE 里用 `/skills` 或 `$` 选择 skill。
  - 隐式触发：Codex 发现当前任务匹配某个 skill 的 `description`，就可以选择这个 skill。
- 隐式触发主要依赖 `description`。所以 description 必须写清楚“什么时候用”和“什么时候不用”。
- 如果安装了很多 skill，Codex 初始看到的 skill 列表有上下文预算限制；description 可能被缩短，skill 甚至可能从初始列表里省略。所以关键触发词和边界要写在 description 前面。
- 可以在 `agents/openai.yaml` 里设置 `policy.allow_implicit_invocation: false`，关闭某个 skill 的隐式触发，只允许用户显式 `$skill-name` 调用。
- 官方建议测试不同 prompt 是否会触发正确 skill。

对本项目的影响：

- 不要把所有小帮助器都做成独立可隐式触发 skill；否则可能因为字符匹配误触发。
- 更安全的做法是：保留一个外层 `tmux-codex-supervisor` skill 作为唯一可隐式触发入口，内部用 router 选择小帮助器。
- 小帮助器先写成 `SKILL.md` 内部章节，而不是独立 skill 文件。这样受控 Codex 不会因为看到 `gen-specs`、`monitor-run` 等词就误触发一个独立 skill。
- 如果以后真的拆成多个独立 skill，除外层 router 以外，其余小 skill 应默认关闭隐式触发，只允许 router 或用户显式调用。

## 剩余问题分类

### 问题 3：skill 像一个大模板，而不是分流器

性质：skill 架构问题。

当前风险：`SKILL.md` 只有大段顺序说明，容易让主 Codex 把所有事情混在一起做；也容易把已经决定的用户要求重新变成一个 spec。

修复方向：把 `SKILL.md` 改成“分流器 + 小帮助器”的结构。

### 问题 4：`gen-specs` 需要处理用户已经决定的内容

性质：`gen-specs` 小帮助器规则问题。

当前风险：用户已经明确的数据字段、设置、输出或限制，仍可能被写成“以后再决定”的 spec。

修复方向：在 `gen-specs` 里写硬规则：用户已经指定的内容必须直接写入 goal/specs，不能创建 spec 去再次决定。

### 问题 6：监督者坚持到底规则必须出现在每条实际启动路径里

性质：监督者启动路径一致性问题。

当前风险：某些短启动提示或 staged paste 文件可能缺少坚持到底规则，导致监督者把受控 Codex 的 blocked 当成监督者自己的 blocked。

这句话的意思：

- “监督者坚持到底规则”是指监督者不能因为受控 Codex 卡住、运行失败、缺信息、review 失败，就把监督者自己的任务也标成 blocked。
- 监督者应该把这些情况当成“当前执行路径失败了”，然后要求受控 Codex 回到 source discovery、更新 spec、写修复 spec、重新测试、重新提交、重新审查。
- “每条实际启动路径”是指所有真正可能用来启动监督者的入口文件或短提示，例如 `prompt_for_supervisor.md`、`prompt_for_supervisor_goal.md`、stage paste 文件、项目专用启动文件。
- 如果某个启动入口漏掉这条规则，监督者从那个入口启动时就可能提前停掉。

修复方向：检查并更新所有监督者启动入口；测试检查“坚持到底”的意思，而不是只检查一句固定原文。

### 问题 7：后续用户要求必须写进持久控制文件

性质：监督者运行中修正规则问题。

当前风险：用户运行中新增的设置、权限、停止条件或完成标准只留在聊天里，重启后丢失。

修复方向：监督者收到这类用户消息后，必须先判断是否需要写入 `control/goal.md` 或 `control/constraint.md`，写入后才能依赖它。

### 问题 9：没有专门的运行文件自主性审查步骤

性质：新增小帮助器问题。

当前风险：运行文件语法完整，但语义上仍可能包含“问用户”停止点、文件冲突、已决定内容被改成未决定。

修复方向：增加 `review-run-files-for-autonomy` 小帮助器，专门审查最终运行文件是否足够支持自主执行。

## skill 拆分设计

### 总体触发策略

先不把每个小帮助器做成独立 skill。原因是独立 skill 会有误触发风险，尤其是受控 Codex 看到文件里出现 `gen-specs`、`monitor-run`、`review-run-files-for-autonomy` 这些词时，可能因为 description 匹配而触发错误 skill。

当前推荐：

- 只有外层 `tmux-codex-supervisor` 作为可被用户显式或隐式触发的 skill。
- `gen-goal`、`gen-constraint`、`gen-specs`、`gen-supervisor-prompts`、`review-run-files-for-autonomy`、`start-supervised-run`、`monitor-run`、`persist-user-requirement` 都先做成 `SKILL.md` 内部章节。
- router 只给监督者用。受控 Codex 不读 router，也不读监督者 helper 章节。
- 受控 Codex 只读短 `/goal` 指向的 `control/goal.md` 和 `control/constraint.md`。

如果以后要把小帮助器拆成独立 skill：

- `gen-*` 和 `review-run-files-for-autonomy` 这类只给监督者用的 skill，description 开头必须写“只在主 Codex 作为监督者创建运行文件时使用；受控 Codex 不使用”。
- `start-supervised-run` 和 `monitor-run` 这类只给监督者用的 skill，也必须写“不要在受控 Codex 执行任务时触发”。
- 给内部 helper 设置 `policy.allow_implicit_invocation: false`，除非已经用测试证明不会误触发。
- 为每个 helper 准备触发测试和不触发测试。

### 1. router

给谁用：监督者。

作用：根据当前用户请求选择下一步小帮助器。

分流规则：

- 用户要求准备运行文件：进入 `gen-goal`、`gen-constraint`、`gen-specs`、`gen-supervisor-prompts`，然后进入 `review-run-files-for-autonomy`。
- 用户要求开始执行：进入 `start-supervised-run`。
- 用户要求监督已经运行的任务：进入 `monitor-run`。
- 用户给出运行中新增要求：进入 `persist-user-requirement`。

成功标准：

- router 不直接写具体 spec 内容。
- router 只选择下一步该用哪个小帮助器。
- router 必须说明当前动作是给监督者用，还是最终会写给受控 Codex 用。
- router 不能给受控 Codex 发送内部 helper 名称作为执行要求；受控 Codex 只应该收到控制文件路径。

### 2. gen-goal

给谁用：监督者。

产物给谁读：受控 Codex 读 `control/goal.md`。

触发条件：

- 监督者正在创建或更新最终运行文件。
- 用户目标、必须读取材料、输出要求、进度证据或完成标准需要写入 `control/goal.md`。

不触发条件：

- 受控 Codex 正在执行当前 spec。
- 当前任务只是监督运行、检查证据、或发送纠正消息。

作用：生成或更新 `control/goal.md`。

必须写入：

- 任务目标。
- 必须读取的材料。
- 必须产出的文件、结果或报告。
- 进度证据。
- 完成标准。

禁止写入：

- 用户审查关卡。
- “等用户确认后继续”。
- 只存在于监督者聊天记忆里的要求。

### 3. gen-constraint

给谁用：监督者。

产物给谁读：受控 Codex 读 `control/constraint.md`。

触发条件：

- 监督者正在创建或更新最终运行文件。
- 用户限制、禁止动作、checkpoint commit 规则、review 规则或自主执行边界需要写入 `control/constraint.md`。

不触发条件：

- 受控 Codex 正在普通执行。
- 只需要读 evidence 或 status，不需要改控制文件。

作用：生成或更新 `control/constraint.md`。

必须写入：

- 用户明确给出的限制。
- 禁止动作。
- checkpoint commit 规则。
- review 规则。
- 自主执行边界。

重要边界：

- 暂时不要把完整 workflow 文档塞进 `control/constraint.md`。
- `control/constraint.md` 只写受控 Codex 必须遵守的限制和检查规则。

### 4. gen-specs

给谁用：监督者。

产物给谁读：受控 Codex 和监督者都读 specs。

触发条件：

- 监督者正在把总目标拆成可检查 spec。
- 用户请求还没有变成可执行 spec。

不触发条件：

- 用户已经决定了某个字段、设置、输出或限制，只需要把它写进去，而不是重新讨论。
- 受控 Codex 正在执行当前 spec。
- 当前问题只是运行中修复某个失败 spec；这时应该更新当前 spec 或创建修复 spec，而不是重新生成全部 specs。

作用：把总任务拆成可检查的 spec。

必须写入：

- 每个 spec 的目标。
- 要读什么信息。
- 预期输出。
- 可观察证据。
- 失败条件。
- 完成检查。

必须加的硬规则：

```text
如果用户已经指定了数据字段、设置、输出或限制，就直接写进 goal/specs。
不要创建一个 spec 去再次决定它。
```

什么时候可以问用户：

- 只能在最终运行文件写出前问。
- 只有当缺失信息会导致无法写出可执行 goal/specs 时才问。
- 问题必须具体，不能把已经决定的内容再问一遍。

什么时候不能问用户：

- 最终运行文件写出后不能问。
- 执行开始后不能问。
- 受控 Codex 不能把 spec 写成“等待用户选择”。

### 5. gen-supervisor-prompts

给谁用：监督者。

产物给谁读：监督者读 `prompt_for_supervisor.md` 和 `prompt_for_supervisor_goal.md`。

触发条件：

- 监督者需要创建或更新监督者启动文件。
- 任务要进入执行阶段，需要监督者长提示和短提示。

不触发条件：

- 受控 Codex 执行任务时。
- 只需要更新 `control/goal.md` 或 `control/constraint.md` 时。

作用：生成监督者启动文件。

必须包含：

- 监督者不做受控 Codex 的任务。
- 监督者只启动和监督受控 Codex。
- 监督者坚持到底规则。
- 文件归属规则。
- 文件冲突优先级。
- 纠偏消息和 `/goal` 消息的区别。

禁止：

- 把监督者长提示发给受控 Codex。
- 把受控 Codex 的 blocked 当成监督者 blocked。

### 6. review-run-files-for-autonomy

给谁用：监督者。

作用：在最终运行文件写出后、执行开始前，审查这些文件是否支持自主执行。

触发条件：

- 最终运行文件已经写好。
- 执行还没有开始。
- 需要检查这些文件是否会导致运行中再问用户或冲突。

不触发条件：

- 受控 Codex 已经开始执行当前 spec。
- 只是检查某个 spec 的实现是否正确；那是 spec review，不是运行文件自主性审查。

检查清单：

- 用户已经决定的要求没有被改写成未决定。
- 运行文件没有 `ask the user`、`wait for user review`、`user approval needed` 这类关卡。
- 运行文件没有向用户索要审查、选择或批准。
- 文件归属清楚。
- 只给监督者看的文件没有发给受控 Codex。
- 受控文件不依赖监督者聊天记忆。
- `goal`、`constraint`、`specs`、`run_goal` 不冲突。
- 低优先级文件不会覆盖高优先级控制文件。

输出：

- `PASS`：可以进入后续执行请求。
- `FAIL`：必须修运行文件，不能启动执行。

### 7. start-supervised-run

给谁用：监督者。

作用：开始执行阶段。

触发条件：

- 用户明确要求开始执行。
- 最终运行文件已经通过自主性审查。
- 需要启动 tmux 里的受控 Codex。

不触发条件：

- 用户只是要求准备运行文件。
- 用户只是要求讨论计划。
- 受控 Codex 已经在运行，只需要监督。

必须做：

- 确认运行文件已经写好。
- 确认运行文件已通过自主性审查。
- 提交需要保存的最终运行文件。
- 启动 tmux 里的受控 Codex。
- 只给受控 Codex 发送短 `/goal`。
- 验证消息送达。

禁止：

- 监督者自己做受控 Codex 的任务。
- 把 `prompt_for_supervisor.md` 或 `prompt_for_supervisor_goal.md` 发给受控 Codex。

### 8. monitor-run

给谁用：监督者。

作用：监督执行阶段。

触发条件：

- 受控 Codex 已经启动。
- 用户要求监督、继续监督、检查进度、纠正偏离或判断完成。

不触发条件：

- 还没有启动受控 Codex。
- 只是创建最终运行文件。
- 只是讨论计划。

必须做：

- 读证据文件、状态文件、review 文件、git 证据、tmux 截屏、日志摘要。
- 发现偏离时发送普通纠正消息。
- 如果受控 Codex blocked，要求它回到 source discovery、更新 spec、创建修复 spec 或继续允许的修正循环。
- 完成前不把监督者目标标成 complete。

禁止：

- 监督者直接改任务代码。
- 监督者因为受控 Codex blocked 就停止监督。

### 9. persist-user-requirement

给谁用：监督者。

作用：处理运行中新增用户要求。

触发条件：

- 用户消息改变执行权限。
- 用户消息改变停止条件。
- 用户消息改变必需设置。
- 用户消息改变完成标准。

不触发条件：

- 用户只是问状态。
- 用户只是问某个文件是什么。
- 用户只是要求解释，不改变运行规则。

必须做：

- 判断应该写进 `control/goal.md` 还是 `control/constraint.md`。
- 写入持久控制文件。
- 再发送普通纠正消息给受控 Codex。
- 验证消息送达。

禁止：

- 只靠聊天记忆。
- 只发送纠正消息但不更新控制文件。

## git commit 和无上下文检查规则

这个规则应该进入 skill，因为它是长期运行质量控制的一部分，不只是某一次任务的偏好。

### checkpoint commit

给谁用：监督者负责要求和检查；受控 Codex 负责在自己的任务仓库里执行提交。

规则：

- 每个完成并通过 evidence 的 spec 必须有 checkpoint commit，除非用户明确禁止 git commit。
- 提交前必须运行 `git status --short`。
- 只暂存当前 spec 和当前 workflow 需要的文件。
- 不暂存无关用户改动。
- 不暂存还在变化的实验输出。
- 如果相关文件和无关文件无法安全分开，停止当前提交并报告具体路径。

证据必须写入当前 spec 的 `evidence.md`：

```text
git status --short
git log -1 --oneline
git show --stat --oneline --name-status HEAD
```

### 无上下文 agent 检查

给谁用：监督者。

规则：

- 每个 checkpoint commit 后，监督者必须派出无上下文 agent 检查。
- 检查者只能拿到当前 spec、goal、constraint、evidence、status、最新 git 证据、相关 diff 和明确检查要求。
- 检查者不能依赖监督者聊天记忆。
- 检查者必须检查：
  - 当前 spec 是否真的完成；
  - 是否偏离 `control/goal.md`；
  - 是否违反 `control/constraint.md`；
  - 是否混入无关文件；
  - 是否跳过 source discovery、abstract plan、evidence、checkpoint commit 或 review；
  - 是否有画蛇添足；
  - 是否有失效风险。
- 如果检查者找到真实问题，必须修当前 spec，重新提交，再重新检查。
- 如果检查者只是风格偏好、无证据挑刺或和文件事实冲突，监督者可以忽略，但必须说明忽略理由。

建议默认检查数：

- 普通 spec：至少 2 个无上下文检查者，一个查目标实现，一个查限制和流程。
- 高风险 spec：可以增加到 3 到 5 个检查者，分别检查正确性、约束、git 范围、测试证据、失效风险。

这里不建议硬性要求每次都是 5 个检查者，因为低风险小 spec 会浪费时间和 token。更稳妥的规则是“至少 2 个，高风险最多 5 个”。

## 推荐修复顺序

### 第一步：同步 `SKILL.md` 的阶段语言

目标：先消除 skill 和 `v2.1` 模板之间的冲突。

改动：

- 把 “preparation phase waits for user review” 改成 “run-file creation phase writes final run files and checks autonomy”。
- 把 “after user approval” 改成 “after a separate execution request”。
- 保留“不启动受控 Codex、不启动长任务”的边界。

完成标准：

- `SKILL.md` 不再说运行文件等待用户 review 或 approval。
- 测试不再要求旧说法。

### 第二步：写入 git commit 和无上下文检查总规则

目标：让每个完成的 spec 都有可恢复的 git 保存点和独立检查。

改动：

- 在 `SKILL.md` 写入 checkpoint commit 规则。
- 在 `SKILL.md` 写入无上下文 agent 检查规则。
- 明确普通 spec 至少 2 个检查者，高风险 spec 可以提高到 3 到 5 个。

完成标准：

- skill 明确要求 checkpoint commit。
- skill 明确要求 checkpoint 后无上下文检查。
- 测试能检查这些关键规则。

### 第三步：加入 router 和小帮助器骨架

目标：修问题 3。

改动：

- 在 `SKILL.md` 增加 router。
- 增加每个小帮助器的职责边界。
- 明确每个小帮助器是给监督者用，还是产物给受控 Codex 用。

完成标准：

- 能从 `SKILL.md` 看出准备运行文件、开始执行、监督运行、持久化用户要求分别走哪条路径。

### 第四步：补 `gen-specs` 的已决定内容规则

目标：修问题 4。

改动：

- 在 `gen-specs` 写入“用户已决定内容不能重新开 spec 讨论”。
- 写清楚最终运行文件写出前可以问用户，执行后不能问用户。

完成标准：

- 测试能检查 `SKILL.md` 包含这条规则。

### 第五步：补 `review-run-files-for-autonomy`

目标：修问题 9。

改动：

- 在 `SKILL.md` 写入审查清单。
- 测试检查关键清单项。

完成标准：

- 运行文件自主性审查能挡住用户审查关卡、文件冲突、聊天记忆依赖、已决定内容被改写成未决定。

### 第六步：补监督者启动路径坚持到底规则

目标：修问题 6。

改动：

- 检查 `templates/prompt_for_supervisor_goal.md`、`templates/prompt_for_supervisor.md`、stage 文件。
- 确认每条实际启动路径都有坚持到底规则。
- 测试检查这个意思。

完成标准：

- 任何监督者启动入口都不会允许因为受控 Codex blocked、运行失败、信息缺失或 review fail 就停止监督。

### 第七步：补后续用户要求持久化规则

目标：修问题 7。

改动：

- 在 `SKILL.md` 增加 `persist-user-requirement`。
- 在监督者模板里确保后续用户要求要写进控制文件。
- 测试检查 `control/goal.md`、`control/constraint.md` 持久化规则。

完成标准：

- 用户新增要求不会只留在聊天里。
- 重启后的 agent 能从控制文件读到新要求。

## 不建议现在做的事

- 不建议把完整 workflow 文档塞进 `control/constraint.md`。
- 不建议一次性重写所有模板和 skill。
- 不建议先做复杂脚本生成器。
- 不建议把 `gen-specs` 写成会重新询问所有用户选择的流程。

## 最小验收标准

全部修完后至少要满足：

- `SKILL.md` 明确区分监督者使用的规则和受控 Codex 读取的文件。
- `SKILL.md` 明确每个 helper 什么时候触发、什么时候不触发。
- `SKILL.md` 明确小 helper 默认先做内部章节，不先做独立隐式触发 skill。
- `SKILL.md` 有 router 和小帮助器职责。
- `gen-specs` 明确禁止重新讨论用户已决定内容。
- `review-run-files-for-autonomy` 有完整检查清单。
- 所有监督者启动路径包含坚持到底规则。
- 运行中新增用户要求必须写进持久控制文件。
- 每个完成 spec 后必须 checkpoint commit。
- 每个 checkpoint commit 后必须做无上下文 agent 检查。
- 现有测试通过。
- 新测试覆盖关键文本，不只检查标题。

## 资料来源

- OpenAI Codex Agent Skills 官方文档：`https://developers.openai.com/codex/skills`
- OpenAI Codex Customization 官方文档：`https://developers.openai.com/codex/concepts/customization`
- 本地拉取的 Codex manual：`/tmp/openai-docs-cache/codex-manual.md`
