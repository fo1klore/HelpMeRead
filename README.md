# 📚 Help Me Read

> [English version](README_EN.md)

把学术论文变成**可学习的课程**和**可检索的知识库**。一个 agent skill，产物以 Markdown 文件（使用 Obsidian 兼容语法：callout、wikilink、MathJax）存入你的 vault，与你的其他笔记互通。

> 💡 **依赖 [Obsidian](https://obsidian.md/) ≥ 1.x**（使用 callout、Bases、MathJax、双链）。非 Obsidian 编辑器能读取 Markdown 内容，但 callout 折叠和 `[[双链]]` 会降级为普通文本/引用块。
>
> 💡 **推荐搭配**：在 Obsidian 社区插件中安装 [Claudian 插件](https://github.com/YishenTu/claudian)（[中文安装教程](https://developer.aliyun.com/article/1712715)），将 Help Me Read skill 导入内置 agent。这样你可以在 **Obsidian 单一窗口内**完成「生成课程 → 学习 → 拆解笔记」全流程，无需在终端和 Obsidian 之间来回切换。

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
- **待学习机制**：遇到文献未解释的概念，agent 给一句话解释后自动存到 `to-learn/`，支持搜索相关资料。搞懂后支持"毕业"转成正式原子笔记
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
	
## ⚙️ 配置（~/.help-me-read.json）

| 项 | 默认 | 说明 |
|---|---|---|
| Obsidian vault 路径 | 询问（首次） | 所有产物集中存到 vault 的 `HelpMeRead/` 子目录 |
| 问答记录保存 | 不保存 | 每轮问答后询问是否保存为独立笔记 |
| 待学习 | 开启 | 遇到文献未解释的概念自动存到 to-learn |

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
├── to-learn/                                    # 待学习清单（含生命周期）
│   └── positional-encoding.md
└── HelpMeRead MOC.md                            # 总索引（Bases 视图）
```

> 所有产物集中在一个 `HelpMeRead/` 目录下，可整体删除来卸载，不与你的其他笔记混淆。

## 📋 项目仓库结构

```
HelpMeRead/
├── SKILL.md                                     # 技能主干：触发、编排、全流程
├── test/
│   ├── test-config.json                         # 测试配置文件
│   └── TESTING.md                               # 模块化测试框架
├── references/
│   ├── obsidian-note-template.md                # 五类笔记模板
│   ├── course-design-guide.md                   # 三类课程设计指南
│   ├── qa-standards.md                          # 问答标准
│   ├── frontmatter-schema.md                    # 全字段 frontmatter schema + MOC
│   ├── failure-modes.md                         # 已知失败模式与排查指南
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
