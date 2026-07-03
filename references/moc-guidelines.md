# MOC（Map of Content）生命周期与更新规则

## 定位

MOC（`HelpMeRead MOC.md`）是所有产物的**策展式索引页**。它的角色是：

1. **全集清单**：一眼看到 vault 里有哪些已处理的文献
2. **状态仪表盘**：每篇文献当前处于什么阶段（learning / learned / atomized）
3. **注意信号**：待学习项有哪些、哪些已解决、哪些还在卡着
4. **导航枢纽**：从 MOC 可以跳到任意一篇文献，每篇文献通过 `up` 跳回 MOC

MOC 不是全自动聚合页。管线提供第一轮骨架和增量更新，用户可以根据需要调整表格排版、添加自定义分组节。

聚合类数据（按领域数量、按类型分布等）由 Obsidian Bases 基于 frontmatter 字段动态生成，MOC.md 内不做硬编码计数。

---

## MOC 内容结构

frontmatter 字段按 `references/frontmatter-schema.md`「六、MOC」定义，此处只展示内容结构：

---

## 更新规则

管线在以下时机自动更新 MOC。每次更新是**增量式**的：追加新行或更新已有行的状态列，不覆写用户自行添加的其他内容。

| 触发时机 | 管线步骤 | 更新内容 |
|----------|----------|----------|
| **第一篇论文笔记生成后** | 步骤 2 末尾 | 若 MOC.md 不存在则创建。写入 frontmatter + 结构 + 该论文的按状态行 |
| **第 N 篇论文笔记生成后** | 步骤 2 末尾 | 在「按状态」表追加该论文行 |
| **课程学完 → `status: learned`** | 步骤 4 末尾 | 在「按状态」表中将该论文的状态列改为 `learned` |
| **原子笔记拆完 → `status: atomized`** | 步骤 5 末尾 | 在「按状态」表中将该论文的状态列改为 `atomized` |
| **to‑learn 笔记自动存入** | 待学习机制触发 | 在「待学习」表追加该概念行，填写来源论文和 `open` 状态 |
| **to‑learn 毕业 → `resolved`** | 待学习毕业处理 | 在「待学习」表中将该行的状态列改为 `resolved` |

### 更新操作细则

**追加新论文行**：
- 读取论文笔记 `HMR-<slug>.md` 的 frontmatter，提取 `type`、`area`、`status`、`tags`
- `type` 取 `research` / `survey` / `dataset` / `other`
- `status` 取当前值（首次创建时为 `learning`）
- `area` 取第一个值（主领域），若为列表则取第一个
- 追加格式：`| [[HMR-<slug>]] | <type> | <status> | <area> |`

**更新状态列**：
- 在「按状态」表中，找到 `[[HMR-<slug>]]` 所在行
- 将第三列（状态）替换为新值

**追加待学习行**：
- `to-learn/<concept>.md` 创建后，读取 `from` 字段确定来源论文
- `status` 填 `open`
- 追加格式：`| [[<concept>]] | [[HMR-<slug>]] | open |`

**更新待学习状态**：
- 在「待学习」表中，找到 `[[<concept>]]` 所在行
- 将第三列（状态）改为 `resolved`（同时 `exploring` 也按此规则更新）
- 若表中的 `concept` 行已 `resolved`，保留该行作为学习轨迹（不删除）

---

## 维护原则

1. **增量不覆写**：管线只追加表格行或更新已有行的状态列。不修改用户自行添加的节、注释、排版调整
2. **一致性守则**：
   - `papers/` 下 `HMR-*.md` 的数量 = MOC「按状态」表的行数
   - MOC 中每行的 `status` = 对应笔记 frontmatter 的 `status`
   - MOC「待学习」表的内容 = `to-learn/` 下 `status != resolved` 的笔记
3. **聚合数据归 Bases**：不写硬编码计数行（如 `| attention | 3 |`），由 Obsidian Bases 基于 frontmatter 动态生成
4. **用户可以编辑**：用户可自由修改 MOC 的排版、添加自定义分组、写入注释。管线只在上述 6 个触发时机做最小化更新

---

## 附录：内容示例（2-3 篇论文时）

```markdown
---
type: moc
tags:
  - moc
---

# HelpMeRead 索引

> 📋 这是你所有 Help Me Read 产物的总入口。使用 Obsidian Bases 生成动态视图（基于 frontmatter 字段）。

## 按状态

| 论文 | 类型 | 状态 | 领域 |
|---|---|---|---|
| [[HMR-attention-is-all-you-need]] | research | learned | attention |
| [[HMR-lllms-survey]] | survey | learning | llm |
| [[HMR-bert]] | research | atomized | nlp |

## 待学习

| 概念 | 出自 | 状态 |
|---|---|---|
| [[positional-encoding]] | [[HMR-attention-is-all-you-need]] | resolved |
| [[RLHF]] | [[HMR-lllms-survey]] | exploring |
| [[LoRA]] | [[HMR-lllms-survey]] | open |
```
