# 笔记 frontmatter schema

本文件定义四类笔记产物 + MOC 的 frontmatter 全字段，以及配置文件 `~/.help-me-read.json`。让 Obsidian 的 Bases / graph / 搜索能力真正可用。

---

## 一、文献总结笔记（papers/<slug>/HMR-<slug>.md）

```yaml
---
title: "Attention Is All You Need"          # 完整标题（从论文 metadata 取）
aliases:                                     # 按优先级：公认缩写 > 作者+年份(必有) > 中文译名
  - Transformer                              # 公认缩写
  - Vaswani 2017                             # 作者+年份（每篇至少一条）
  - 注意力即你所需                            # 中文译名（若有）
authors:                                     # 名在前姓在后，≤5 人全列，超 5 人列前 3 + et al.
  - Ashish Vaswani
  - Noam Shazeer
  - Niki Parmar
  - et al.                                   # 超过 5 人时用此行替代后续作者
year: 2017
venue: NeurIPS                               # 公认缩写优先；预印本填 arXiv；无法确定留空
area:                                        # 子领域/任务级，1-3 个英文 kebab-case。不取学科大类也不取过细
  - attention
  - sequence-modeling
type: research                               # research / survey / dataset / other
source: "https://arxiv.org/abs/1706.03762"   # 原文链接或本地路径
pdf: ""                                      # 始终空串。用户告知已存 PDF 后由 agent 更新为 [[文件名.pdf]]
status: learning                             # unread / learning / learned / atomized
  # unread=未读, learning=课程学习中, learned=课程学完, atomized=原子笔记已拆
read_date: 2026-06-22
progress: 3                                  # 已学节数（课程逐节学习时回写）
last_section: "02-self-attention"            # 最后学到哪节的 slug（用于断点续传）
sections: 4                                  # 课程总节数
tags:                                        # 标签命名：paper/<关键词>，kebab-case
  - paper/transformer
  - paper/attention
up:                                          # 父节点，指向 MOC
  - "[[HelpMeRead MOC]]"
related: []                                  # 空列表。跨论文联系时追加，不删原有
---
```

**字段指引**（agent 生成时必读）：
| 字段 | 生成规则 | 何时更新 |
|---|---|---|
| `title` | 从论文 metadata 取完整标题 | 不变 |
| `aliases` | 按优先级：公认缩写 > `作者姓氏 年份`（**必须有**）> 中文译名（若有） | 不变 |
| `authors` | 名在前姓在后。≤5 人全列，>5 人列前 3 + `et al.`。从 metadata 提取，不编造 | 不变 |
| `year` | 从 metadata 取发表年份 | 不变 |
| `venue` | 常用缩写优先（NeurIPS/ICLR/CVPR）。仅预印本填 `arXiv`。无法确定留空 `""` | 不变 |
| `area` | **子领域/任务级**，1-3 个英文 kebab-case。不取学科大类，也不取过细。从标题/摘要提取 | 不变 |
| `type` | `research` / `survey` / `dataset` / `other`，按 SKILL.md 类型判定 | 不变 |
| `source` | 原文 URL 或本地路径 | 不变 |
| `pdf` | 始终 `""` | 用户告知存了 PDF 后，agent 更新为 `[[文件名.pdf]]` |
| `status` | 初始 `learning`（课程学习阶段自动） | 学完→`learned`，拆完原子→`atomized` |
| `read_date` | 当日 YYYY-MM-DD | 不变 |
| `progress` | 初始 `0` | 每学完一节回写（agent） |
| `last_section` | 初始 `""` | 每学完一节回写（agent） |
| `sections` | 课程总节数，大纲阶段确定 | 重做单节导致节数变化时更新 |
| `tags` | 格式 `paper/<英文关键词>`，kebab-case | 不变 |
| `up` | 始终 `[[HelpMeRead MOC]]` | 不变 |
| `related` | 初始 `[]` | 跨论文联系时追加，不删原有 |

---

## 二、原子笔记（concepts/<term>.md）

```yaml
---
title: "Self-Attention"
aliases:
  - 自注意力
  - intra-attention
type: concept                                # concept / method / metric / dataset-name
area:
  - attention
defined_in:                                  # 这个概念在哪些论文里被引入/重点解释（去重的关键）
  - "[[HMR-attention-is-all-you-need]]"
  - "[[HMR-bert]]"                             # 跨论文去重时追加
up:
  - "[[Attention]]"                          # 上位概念：agent 从论文上下文判断，能判断则填，不能则留 []
tags:
  - concept/attention
---
```

**去重机制**：
- `defined_in` 是列表，多篇论文标了同一术语时，**追加到此列表**，不新建文件
- agent 检测到已存在时提示用户选：追加出处 / 新建独立文件 / 跳过

**字段指引**（agent 生成时必读）：
| 字段 | 生成规则 |
|---|---|
| `up` | 从论文上下文判断上位概念。如 `self-attention` 的上位是 `attention`。**能判断则填，不能则 `[]`**。不向用户确认 |
| `defined_in` | 初始填当前论文。跨论文去重时按用户选择追加

---

## 三、待学习笔记（to-learn/<concept>.md）

```yaml
---
title: "Positional Encoding"
type: to-learn
from:                                        # 从哪篇论文的哪里冒出来
  - "[[HMR-attention-is-all-you-need]]"
raised_date: 2026-06-22                      # 何时遇到
status: open                                 # open / exploring / resolved
  # open=待学, exploring=已开始查资料, resolved=搞懂了已转成正式原子笔记
resolved_to: []                              # open/exploring 时始终为 []；resolved 时指向转成的原子笔记
tags:
  - to-learn
---
```

**生命周期**：
- `open` → 待学习
- `exploring` → 正在查资料
- `resolved` → 毕业，内容迁到 `concepts/` 成正式原子笔记，原 to-learn 文件保留作为学习轨迹

---

## 四、问答记录（papers/<slug>/qa-<date>.md）

```yaml
---
type: qa-record
paper: "[[HMR-attention-is-all-you-need]]"
date: 2026-06-22
q_count: 5                                   # 问题数（MOC 展示用）
tags:
  - qa
---
```

---

## 五、课程文件（papers/<slug>/course/<序号>-<概念名>.md）

课程文件不在 vault 根管理，而是在 `papers/<slug>/course/` 下。每节课程用最小 frontmatter 标记位置：

```yaml
---
title: "第 2 节：自注意力机制"
course: "[[HMR-attention-is-all-you-need]]"  # 所属论文
section: 2                                   # 节序号
prev: "[[01-why-attention]]"                 # 上一节（双链）
next: "[[03-multi-head-and-position]]"       # 下一节（双链）
---
```

字段轻量——课程是学习路径的重组，完整结构化信息在主笔记（HMR-<slug>.md）里。

---

## 六、MOC（HelpMeRead MOC.md）

```yaml
---
type: moc
tags:
  - moc
---

# HelpMeRead 索引

## 按状态
| 论文 | 类型 | 状态 | 已学 | 领域 |
|---|---|---|---|---|
| [[HMR-attention-is-all-you-need]] | research | learning | 3/4 | attention |
| [[HMR-bert]] | research | unread | 0/5 | nlp |

（用 Obsidian Bases 生成动态表格视图，基于 frontmatter 字段 `status` `type` `progress` `area` `venue` 等）

## 按领域
| 领域 | 论文数 |
|---|---|
| attention | 3 |
| cv | 1 |

（Bases 视图按 `area` 分组）

## 待学习（open）
| 概念 | 出自 | 状态 |
|---|---|---|
| [[positional-encoding]] | [[HMR-attention-is-all-you-need]] | open |
```

---

## 配置文件（~/.help-me-read.json）

SKILL.md 步骤 0 管理。字段：

```json
{
  "obsidian_vault": "D:\\Path\\To\\Vault",
  "qa_record": false,
  "to_learn": true
}
```

| 字段 | 默认 | 说明 |
|---|---|---|
| `obsidian_vault` | 询问（首次） | 用户 Obsidian vault 的绝对路径 |
| `qa_record` | `false` | 是否每次 QA 后询问保存问答记录 |
| `to_learn` | `true` | 是否开启待学习机制 |

> 原 `self_check` 字段已移除（决策 J：砍掉笔记自测模块，只留课程自测）。
