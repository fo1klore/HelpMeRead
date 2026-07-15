# 📚 Help Me Read v3.1.2

> [English version](README_EN.md)

把学术论文变成**可学习的课程**和**可检索的知识库**。基于 **Claude Code** 的 agent-skill 架构，通过 subagent 管线将产出以 Markdown 文件（callout、wikilink、MathJax）存入你的 vault。

> 💡 **最佳适配平台：Claude Code**（`claude.ai/code` 或 CLI）。核心流程（concept-mapper → course-generator + note-writer）使用 Claude Code 独有的 `Agent(subagent_type=...)` API 调度，无法在其他平台上等价执行。详见「架构与平台适配」节。

---

### 产出预览（Obsidian）

所有产物以 Obsidian 兼容的 Markdown 呈现：callout 折叠、MathJax 公式、`[[双链]]`。非 Obsidian 编辑器可读，但折叠和双链会降级。

> 💡 **推荐搭配**：在 Obsidian 社区插件中安装 [Claudian 插件](https://github.com/YishenTu/claudian)（[中文安装教程](https://developer.aliyun.com/article/1712715)），将 Help Me Read skill 导入内置 agent。这样你可以在 **Obsidian 单一窗口内**完成「生成课程 → 学习 → 拆解笔记」全流程。

## ✨ 功能

### 🎓 课程 —— 把文献拆成循序渐进的若干节课

- 按**学习路径**重组文献，每节聚焦 1-2 个核心概念，用日常类比建立直觉
- 节数弹性（1-7+ 节），深挖/重做单节按需触发
- 每节内置：学习目标、核心讲解（含类比 + 公式推导 + **论文原图** + **概念示例嵌入**）、可选的代码实现、自测小问题（答案折叠，先思考再看）、精选延伸资源链接
- 所有课程以 Markdown（Obsidian 兼容：callout/MathJax/双链）呈现，与笔记共享双链和公式渲染

### 📝 笔记 —— 结构化知识库

- 按文献类型自动选用对应结构（研究论文 / 综述 / 数据集论文），含完整 frontmatter
- 每条总结标注原文出处 **【页码 / 章节】**，经过**页码范围校验 + 引用回查**，标记验证状态
- 关键公式用 MathJax 重现并解释符号
- 核心概念自动标注为 `[[候选原子笔记]]`
- **学习补充层**：课程学完后追加学习过程中的反馈，与原文层**物理分离**，保护溯源可靠性
- **跨论文联系**：读新论文时主动提示与已读论文的关联

### 📝 原子笔记 —— 低摩擦拆分

- 概念筛选先行：只收录原文给出定义且在论文贡献中占一席之地的核心概念，不冗余
- agent 自动建骨架文件（frontmatter / 出处 / 深入理解 / 相关都填好），**你只写"用自己的话说这东西是什么"**一句
- 筛选和骨架生成在课程阶段完成，学完即可开始填写定义，无需等待

### 💬 问答 —— 带验证标签的精确答疑

- 力求一语中的，能引用原文的尽量先引用，再补少量必要解释
- **五级来源标签**：`[原文·已验证]` / `[原文·未验证]` / `[推断]` / `[背景]` / `[未知]`
- 每条回答标明出处，文献范围外的问题如实告知
- 可选保存问答记录

### ⏱️ 进度持久化

- 课程进度和最后学到哪节写入 frontmatter，会话中断后重开能续传

---

## 🚀 使用

通过 `/help-me-read` 指令或自然语言均可触发：

```
/help-me-read https://arxiv.org/abs/1706.03762
帮我读一下 https://arxiv.org/abs/1706.03762
总结这篇 PDF：D:\papers\transformer.pdf
帮我读一下 Attention Is All You Need
把这篇做成课程，我是新手
重做第 2 节
深挖第 3 节
```

也可用子命令指定执行范围——说"只总结"仅生成笔记，"做成课程"仅生成课程，"重做第 N 节"只再生那一节。直接提问进入问答。

如果只给出论文标题（没有 URL 或 PDF），agent 会联网搜索并找你确认。

**首次使用时只问 vault 路径**，其余配置用合理默认值，让你尽快看到第一份产物。此后自动记住。

---
	
## ⚙️ 配置（.claude/skills/help-me-read/help-me-read.json）

| 项 | 默认 | 说明 |
|---|---|---|
| Obsidian vault 路径 | 询问（首次） | 所有产物集中存到 vault 的 `HelpMeRead/` 子目录 |
| 问答记录保存 | 不保存 | 每轮问答后询问是否保存为独立笔记 |

---

## 📊 支持的文献类型

| 类型 | 笔记结构 | 课程形态 |
|---|---|---|
| 研究论文 | 学术标准结构 | 学习路径重组 |
| 综述 | 领域地图结构 | 全景 + 流派逐节（6-8 节） |
| 数据集论文 | 数据生命周期结构 | 数据生命周期逐节 |
| 其他 | 灵活调整 | 学习路径重组 |

---

## 📁 产物目录结构（在你的 Obsidian vault 中）

```
<Vault>/HelpMeRead/
├── papers/                                      # 每篇论文一个目录
│   └── attention-is-all-you-need/
│       ├── HMR-attention-is-all-you-need.md       # 文献总结笔记
│       ├── course/                              # 课程（Markdown）
│       │   ├── 01-why-attention.md
│       │   ├── 02-self-attention.md
│       │   ├── 03-multi-head-and-position.md
│       │   ├── 04-results-and-impact.md
│       │   └── assets/                          # 论文原图
│       │       └── figure-1.png
│       └── qa-2026-06-22.md                     # 问答记录
├── concepts/                                    # 跨论文共享原子笔记
│   ├── self-attention.md
│   └── multi-head-attention.md
└── HelpMeRead MOC.md                            # 总索引（Bases 视图）
```

> 所有产物集中在一个 `HelpMeRead/` 目录下，可整体删除来卸载，不与你的其他笔记混淆。

## 📋 项目仓库结构

```
HelpMeRead/
├── SKILL.md                                     # 技能主干：触发、编排、全流程
├── .claude/agents/                              # subagent 定义（init-agents.sh 本地生成，不纳入版本控制）
│   ├── concept-mapper.md                        #   概念映射（术语三分 → JSON 映射表）
│   ├── course-generator.md                      #   课程生成 + 原子笔记骨架 + 质量检查
│   └── note-writer.md                           #   Obsidian 笔记 + MOC 同步
├── test/
│   ├── test-config.json                         # 测试配置文件
│   └── TESTING.md                               # 模块化测试框架（T1-T17）
├── scripts/
│   ├── preflight.sh                             # 模式检测（test/production）
│   ├── init-agents.sh                           # subagent 安装脚本
│   ├── check-deps.sh                            # 图片提取依赖检测
│   └── verify.sh                                # 一键产物验证
├── references/
│   ├── obsidian-note-template.md                # 五类笔记模板
│   ├── course-design-guide.md                   # 三类课程设计指南
│   ├── frontmatter-schema.md                    # 全字段 frontmatter schema + 命名约定
│   ├── image-extraction.md                      # 图片提取优先级链
│   ├── quality-checks.md                        # 生成后完整性检查 10 项
│   ├── moc-guidelines.md                        # MOC 生命周期与更新规则
│   ├── qa-standards.md                          # 问答标准与验证标签
│   ├── failure-modes.md                         # 已知失败模式与排查指南
│   ├── diagnostics-cheatsheet.md                # 诊断命令速查
│   └── issue-resolution-workflow.md             # 问题解决标准操作流程
├── examples/                                    # 完整样例
├── README.md
├── README_EN.md
├── LICENSE
└── .gitignore
```

## 📋 更新记录

| 日期 | 变更 | 📝 开发者寄语 |
|---|---|---|
| 2026-07-15 | **v3.2** · 4 issue 集中修复：subagent 参考文件路径改为 skill 目录绝对路径（消除 CWD 依赖）；全局 MathJax 约束重构（正面规则+三条禁令+质量检查全覆盖）；课程集中术语表回归拦截；待学习功能整体移除 | 我们总是不把话说清楚 |
| 2026-07-15 | **v3.1.3** · 配置路径统一为 preflight.sh 绝对路径驱动（防嵌套 CWD 误判）；步骤 4 取消自动打开，改输出文件路径；步骤 5 参考答案解耦为独立展示步骤 + MOC 自动更新 | 虫子怎么老是杀不掉 |
| 2026-07-04 | **v3.1.2** · 自然语言触发路由显式化（triggers 字段 + 触发短语列表）；步骤 4 自动打开（去"代为"歧义）；表格竖杠转义约束 + verify.sh 检测；全课程 MathJax 统一约束 + verify.sh 检测；反引号包裹 wikilink 修复（init-agents.sh + course-design-guide 4 处）；步骤 5 参考答案自动填入 + 自动推进 | 增肌 |
| 2026-07-04 | **v3.1.1** · 删除课程地图+概念索引；模块模板化（5 填空模板）；init-agents.sh 部署化（目标目录参数 + flag 自动更新）；SKILL.md agent 更新门禁；清理项目内 subagent 生成物 | 加点骨架和新陈代谢 |
| 2026-07-03 | **v3.1** · 可跳过标注位置约束强化（course-design-guide 模板 + verify.sh 检测）；概念自测纠错流程 UX 大修——线性七步改为分支流程、去步骤编号、反查课程静默完成、拆解问题条件触发；course-design-guide 单课模块顺序修正（地图/可跳过纳入完整 0-10 顺序）；逐概念教学循环替代批处理模块 4 | 一些被脂肪淹没的小毛病 |
| 2026-07-03 | **v3.0** · 全面 subagent 管线重构：步骤 2 由单块内联流程拆分为 concept-mapper → course-generator + note-writer 三级 subagent 调度；SKILL.md 精简 70%（514→140 行），详细逻辑提取到 references/ 独立文件；新增 init-agents.sh 安装脚本；图片提取/质量检查/MOC 管理各自独立 reference；集中热身模块彻底移除，改正文首次出现即解释；文献速览环节；verify.sh + TESTING.md（T1-T17）全面适配 subagent 架构。**最佳适配平台：Claude Code** | 减脂成功了...吗？ |
| 2026-07-03 | **v2.7.2** · 概念/术语首次出现解释替代独立热身：三类术语不再设独立热身模块，改在正文首次出现处即附解释（核心概念 `[[]]` + 解释 / 前置术语加粗 + 解释 / 背景术语一句话解释）；新增文献速览环节（步骤 1 类型判定后展示核心贡献/问题-方法-局限/核心概念概览，用户选择继续/总结/只笔记/停止）；course-design-guide.md 同步移除热身模块定义；verify.sh 检查同步；failure-modes.md 新增 F1-7 | 有些事情，我希望你提前知道 |
| 2026-07-02 | **v2.7.1** · 概念自测新增参考答案展示步骤（④引导修正→⑤展示参考答案→⑥确认填入→⑦回写补充层）；TESTING.md T10 同步更新；failure-modes.md 新增 F4-3 | 我需要知道什么是对的。 |
| 2026-07-02 | **v2.7** · 课程生成质量大修：术语三分（核心概念/前置术语/背景术语）替代单一块热身；生成时来源标注要求；断言降级制度（[背景]/[推断]）；完整性检查新增来源标注/断言标签/缩写解释检查；verify.sh 和 course-design-guide.md 同步适配 | 他好像不太聪明的样子 |：course-design-guide.md 新增 Core/Supporting 节角色定义（Core ≥ max(ceil(总节数 × 50%), 1））和教学深度最低结构（问题动机→变量准备→分步推导→直觉解释→数值例子→错误直觉）；SKILL.md step 2.6 新增节角色检查和 Core 节深度检查（推导分步/前置桥接/数值示例/错误直觉 4 条验证） | 你怎么这样？ |
| 2026-07-01 | **v2.5.6** · 课程原文出处格式修正：course-design-guide.md 中原文位置从行内斜体改为独立成行 +  空行 + `📖` 前缀 | 即使这样也改变不了什么... |
| 2026-06-30 | **v2.5.5** · 可执行脚本从 test/ 迁移到 scripts/（解除 ZIP 下载的 export-ignore 限制）；SKILL.md 和 TESTING.md 引用路径同步更新；Issue ④ 课程 0 基础约束（读者画像声明 + 概念热身模块 + 边界场景/豁免规则/重试降级 + 完整性检查概念覆盖 + F2-9/F2-10）；verify.sh 新增概念热身/双链解释检查段 | 你疑似有点傲慢了 |
| 2026-06-29 | **v2.5.4** · PDF 清理 + 原子笔记双链一致性修复：URL 下载的 PDF 在生成后自动删除；步骤 2 新增概念映射表避免双链命名不一致；obsidian-note-template.md 模板 `## 相关` 改为管语法；failure-modes.md 新增 F1-6 + F5-4 条目 | 我真得控制你了 |
| 2026-06-29 | **v2.5.3** · 可执行验证体系建设：新增 test/preflight.sh（模式检测脚本化，不再靠 LLM 阅读理解）；新增 test/check-deps.sh（图片提取依赖统一检测）；新增 test/verify.sh（一键产物验证）；SKILL.md 步骤 2 并行约束明确化（A.先确定概念列表 → B.并行生成骨架+课程）；issue-resolution-workflow.md Phase 5 新增双语 README 同步门禁 | 机械苦弱，智能飞升 |
| 2026-06-26 | **v2.5.1** · minimalist 精简审查 + 冗余清理：删除 TESTING.md 历史报告与执行日志（-62 行）；三条件判据集中到 SKILL.md，另两处改引用；SKILL.md 步骤 5 可选区块列表改引用；修正分类数量 表述（四类→六类）；YAML 缩进 tab 修复；测试配置路径占位符化 | 没胖真比以前瘦嘞！ |
| 2026-06-26 | **v2.5** · 6 项问题集中修复 + 流程标准化：截断检测（三条件判据）、待学习触发扩展、临时文件清理、examples 隔离边界、概念"相关"格式、测试模式检测；新增问题解决 SOP + 5 个 failure mode | 这次我真用了！ |
| 2026-06-25 | **v2.4** · 自测题"讲什么考什么"约束；原子笔记流程重构（步骤 2 筛选+生成骨架，步骤 5 缩为引导写定义）；新增概念示例嵌入（按触发条件自动匹配）；新增模块化测试框架（TESTING.md + test/ 目录）；目录优化重组 |  "什！么！他加了测！试！？" |
| 2026-06-23 | **v2.3** · 8 项问题集中修复：步骤 0 静默配置检查 + 外部概念目录引导；删除 progress/last_section，只留 status；论文简称重名检测消歧；PDF 图片提取管线重构（pdfimages 优先、矢量图回退、尺寸上下限过滤）；笔记嵌入关键图片；课程底部导航列为必选模块；外部目录去重扫描 | 图片，我希望你乘乘的。 |
| 2026-06-23 | **v2.2** · 主线 7→5 步，步骤5/6降级为独立模块；全文「术语」→「核心概念」；SUMMARY/延伸资源默认展开；PDF 图片禁用整页栅格化+尺寸过滤；末节拆解提醒 | 不端上来怎么测XD |
| 2026-06-22 | **v2.1** · 课程全量生成；图片提取优化；新增Concepts 区块；优化笔记拆解引导（评价→反查→增补→修正）；改为 Obsidian URI 打开文件；添加课程地图 | Oi！又不测试就端上来是吧！ |
| 2026-06-22 | **v2.0** · 全面 Markdown 化（砍 HTML/翻转卡/自测）；笔记 frontmatter 加厚 + 脚手架拆分 + 待学毕业；课程原图 + 延伸资源 + arxiv 跳转；带验证标签的溯源（页码校验+引用回查）；跨论文联系 + 进度持久化；只问 vault 首次引导；歧义词路由确认；跨平台 PyMuPDF | 我重生了，上一世我被奸人陷害，token狂烧，这一世，我要拿回属于我的一切！我悟了，在token面前，长得怎么样一点都不重要。七神默许，token反对。token看好了，这一刀会很帅。token，老实回家做宅男。token，100级，海神！token，三年之约我如约而至。token驾到，通通闪开！！os：他们居然能看到我的os？？ |
| 2026-06-22 | v1.2 — 底部导航统一 + 引用角标 + CSS 修复 TOC + 待学习初始设置 | 没测试够你端上来干嘛！！os：其实根本没测试 |
| 2026-06-21 | v1.1 — 首次运行引导 + CSS 外置并行生成 + 翻转卡修复 + 精读升级 | 做东西给我做好的呀！！ |
| 2026-06-21 | 初始发布 | 到了要读论文的时候，干什么都比读论文有意思XD |

## 📄 License

[MIT](LICENSE)
