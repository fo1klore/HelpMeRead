---
name: help-me-read
description: 把学术论文变成可学习的 Markdown 课程和 Obsidian 结构化笔记。
---

# Help Me Read —— 文献阅读辅助

把一篇文献变成两类产物：**可学习的课程**（Markdown）和 **Obsidian 结构化笔记**。两者并行启动，课程一次性全量生成，笔记同步完成。

## 触发与子命令路由

无关键词/"完整"→全流程；"做成课程"→仅课程；"总结/记到 obsidian"→仅笔记；直接提问→仅问答；"重做/深挖第 N 节"→仅课程局部。歧义词（"总结""读一下"）一句话确认："要完整学习还是只要笔记摘要？"

## 全流程

```
0. 首次运行引导（仅问 vault 路径，其余默认）
1. 获取原文 → 类型判定 → 写 _source.md
2. 概念映射(concept-mapper) → 并行: 课程(course-generator) + 笔记(note-writer)
3. 待学习提醒 + 列大纲
4. 代为打开第一节，底部导航自主推进
5. 学完 → 七步纠错引导填写原子笔记定义
```

贯穿全局：学习补充层、待学习机制、跨论文联系、问答。

---

## 步骤 0：首次运行引导

静默执行 `bash scripts/preflight.sh` 检测模式（test/production），读取配置。

配置不存在（首次）→ 仅问两件事：
1. **Obsidian vault 路径**（产物存到 `HelpMeRead/` 子目录）
2. **外部概念目录**（可选，已有原子笔记目录）

其余默认值（`qa_record: false` / `to_learn: true`）直接写入，不必首次询问。

配置已存在且 vault 路径有效 → 静默跳过。路径不可访问 → 提示是否更新。

---

## 步骤 1：获取原文与类型判定

**获取**：本地 PDF→Read；论文 URL→webReader（自动转换 arxiv abs→html/pdf、DOI 解析）；仅有标题→WebSearch→用户确认。

**图片提取**：按 `references/image-extraction.md` 优先级链执行，自动降级不卡流程。

**清理**：URL 下载 PDF 读取后删除。原文写到 `$VAULT/HelpMeRead/papers/$slug/_source.md` 供 subagent 读取。

**类型判定**：

| 类型 | 判定特征 | 模板 |
|---|---|---|
| 研究论文 | 原创方法 + 可复现实验 | 学术标准结构 |
| 综述 | survey/review；分类体系主线 | 领域地图结构 |
| 数据集论文 | 发布数据集 | 数据生命周期结构 |
| 其他 | 不符合上述 | 归入研究论文 |

默认默默判定并告知结果；多类特征时才向用户确认。

### 文献速览

展示 `核心贡献 / 问题-方法-局限 / 核心概念概览`。用户选择：① 完整流程 ② 只要总结 ③ 只做笔记 ④ 停止。

---

## 步骤 2：并行生成（subagent 分发）

先确认 subagent 存在（缺失则提示 `bash scripts/init-agents.sh`）。

### 2A：概念映射（前提）
Agent(subagent_type="concept-mapper", prompt="Paper type|Slug|Vault|Source path")

读取 `_source.md` + 参考文件，输出 JSON 映射表（术语三分 + aliases）。**失败**→重试，仍失败退出 Step 2。映射表冻结，后续步骤严格以此为命名源。

### 2B：课程 + 笔记（并行）
同时启动：Agent(subagent_type="course-generator") + Agent(subagent_type="note-writer")

映射表到手后，同时启动：Agent(subagent_type="course-generator", prompt="...+Mapping JSON") 和 Agent(subagent_type="note-writer", prompt="...+Mapping JSON")。

course-generator 产出：`course/` 课程 + `concepts/` 原子笔记骨架 + 质量检查（2 次检查失败→报告详情）。note-writer 产出：`HMR-<slug>.md` + MOC 更新（失败不影响课程）。

**隔离边界**：`examples/` 禁止复制。图片 Step 1 已提取，subagent 直接引用。

---

## 步骤 3：待学习提醒 + 列大纲

列出大纲（各节标题 + 可跳过条件 + 总节数）。提醒：

> 💡 **待学习机制**：遇到未解释概念 → 一句解释 → 自动存 `to-learn/` → 之后可选深入搜索。

---

## 步骤 4：开始学习

`obsidian://open?vault=<目录名>&file=HelpMeRead/papers/<slug>/course/01-<topic>` 代为打开第一节。

底部导航（`← 上一节 | 下一节 →`）已嵌入课程文件，用户可直接在 Obsidian 内点击推进。

**按需交互**：中途提问→QA（`references/qa-standards.md`）；重做/深挖第 N 节；告知学完→进入 Step 5。

**进度追踪**：学完后回写 `status: learned`，更新 MOC。

---

## 步骤 5：引导填写原子笔记定义

**骨架已就绪**（Step 2 生成），`## 定义` 留空待填充。

**七步纠错流程**（逐个概念，不跳过）：
1. **评价** — 语义对比，用「补充」措辞
2. **反查课程** — 不足则增补，够则重读
3. **拆解问题** — 2-3 子问题一问一答
4. **引导修正** — 用户重组再说
5. **展示参考答案** — `[原文·已验证]`/`[推断]` 锚点
6. **确认填入** — 润色后写 `## 定义`
7. **回写补充层** — 追加主笔记 `## 学习补充`

显示进度"已完成 3/8"，可随时跳过。完成后可选更新 MOC 状态为 `atomized`。

---

## 待学习 / 学习补充 / 跨论文联系 / 问答

**待学习**："不懂""没听过"→一句解释→存 `to-learn/`→可选搜索。毕业 `open→exploring→resolved`。
**学习补充**：只增不改，笔记原文锁定，反馈追加到 `## 学习补充`（`[背景]`/`[推断]` 标签）。
**跨论文**：生成新笔记时扫描已读笔记的 area/aliases/defined_in，发现关联主动提示。
**问答**：一语中的，引用原文+验证标签（见 `qa-standards.md`）。答后问"继续吗"。

---

## 执行约束

**顺序**：严格按流程执行，不跳步不倒序。**简洁**：问答一语中的，总结不注水。**只增不改**：笔记原文锁定，反馈写入补充层。**诚实**：用验证标签让用户自行判断。

## 命名约定

遵循 `references/frontmatter-schema.md`。文献简称确定后会话内路径一致。重名检测 `papers/<简称>/`。
