# Help Me Read —— 已知失败模式与排查指南

> 遇到异常时按阶段定位问题，不要从头排查。解决流程参见 [问题解决标准操作流程](issue-resolution-workflow.md)。

---

## 目录

1. [使用流程](#1-按阶段快速定位)
2. [步骤 0：配置文件](#步骤-0-配置文件)
3. [步骤 1：原文获取与图片提取](#步骤-1-原文获取与图片提取)
4. [步骤 2：课程/笔记/概念生成](#步骤-2-课程笔记概念生成)
5. [步骤 3-4：学习阶段](#步骤-3-4-学习阶段)
6. [步骤 5：原子笔记拆分](#步骤-5-原子笔记拆分)
7. [产物后检查](#产物后检查)
8. [附录：检测命令速查](#附录检测命令速查)

---

## 1. 按阶段快速定位

| 症状 | 可能阶段 | 优先排查 |
|------|---------|---------|
| 配置检查反复弹出 | 步骤 0 | 配置文件格式 |
| 测试产物写入生产 vault | 步骤 0 | F0-2 测试模式 |
| PDF 图片缺失 / 全是文字截图 | 步骤 1 | 图片提取管线 |
| 抓取内容只到摘要 | 步骤 1 | URL 转换、网络 |
| 根目录散落 HTML 临时文件 | 步骤 1 | F1-5 清理 |
| 课程缺少导航链接 | 步骤 2 | 课程设计指南遵守 |
| 自测题答案无法从课程中找到 | 步骤 2 | 内容范围约束 |
| 笔记缺少核心图 | 步骤 2 | 笔记模板图嵌入 |
| 概念列表有噪音概念 | 步骤 2 | 筛选条件 | 
| 概念/课程含其他论文的完整产物 | 步骤 2 | 🔴 跨论文污染 F2-7 |
| 课程内容截断（话说到一半） | 步骤 2 | F2-8 完整性检查 |
| Obsidian URI 打不开 | 步骤 4 | 平台命令、vault 路径 |
| to-learn 未触发（被动提及概念） | 步骤 3-4 | F3-3 触发条件 |
| 产物路径和预期不一致 | 产物后 | 命名约定、重名处理 |
| 概念笔记"相关"区块无关系说明 | 产物后 | F5-3 模板格式 |

---

## 步骤 0：配置文件

### F0-1：配置检查持续输出（无论是否已配置）

**现象**：每次执行都输出"检查中""已找到配置文件"等信号。

**原因**：步骤 0 未静默——agent 把内部检查结果输出了。

**修复**：
1. 确认 SKILL.md 步骤 0 包含 `（内部完成，不向用户输出开始检查信号、检查过程或结果）` 的指令
2. 检查点：配置存在且指向有效 vault → 0 输出直接进入步骤 1

**检测命令**：
```bash
# 生产配置路径按 SKILL.md 步骤 0 动态确定（优先项目 .claude/，否则 ~/.claude/）
cat .claude/skills/help-me-read/help-me-read.json 2>/dev/null || cat ~/.claude/skills/help-me-read/help-me-read.json
jq -r '.obsidian_vault' .claude/skills/help-me-read/help-me-read.json 2>/dev/null | xargs ls -d || \
  jq -r '.obsidian_vault' ~/.claude/skills/help-me-read/help-me-read.json | xargs ls -d
```

### F0-2：测试配置不可见——agent 始终读写生产配置

**现象**：测试时产物写入生产 vault 而非 `test-output/`；生产配置被测试参数覆盖。

**原因**：SKILL.md 步骤 0 未检测 `test/test-config.json` 的存在，agent 始终操作生产配置。

**修复**：
1. 确认 SKILL.md 步骤 0 包含"测试模式检测"段落——先检查 `test/test-config.json`，存在则使用测试配置
2. 测试配置中 vault 指向 `test-output/`，与生产 vault 物理隔离
3. TESTING.md 测试前准备中确认 agent 读取了测试配置

**检测命令**：
```bash
# 确认测试配置文件存在
cat test/test-config.json
# 产物应写入 test-output/ 而非生产 vault
ls test-output/HelpMeRead/

---

## 步骤 1：原文获取与图片提取

### F1-1：抓取内容过短（仅摘要页）

**现象**：抓取到 ~48KB 的摘要页而非 ~100KB+ 的全文。

**原因**：agent 抓取了 `arxiv.org/abs/XXXX` 页面而非 `arxiv.org/html/XXXX`。

**修复**：
1. 确认 URL 被自动转换为 `arxiv.org/html/` 版本（SKILL.md 步骤 1 第一条）
2. 检查 HTTP 响应大小（全文通常 > 100KB）
3. 若摘要页面确定，重新请求 HTML 版

**检测命令**：
```bash
# 检查内容量
curl -sI "https://arxiv.org/html/XXXX.XXXXX" | grep -i "content-length"
# 通常在 100KB-500KB 之间
```

### F1-2：PDF 图片提取失败

**现象**：`course/assets/` 目录不存在、图片数量不足、或全是噪音小图。

**原因**（按概率排序）：
1. **extraction order wrong**：agent 未按 `pdfimages → PyMuPDF → (禁用 pdftoppm)` 的优先级提取
2. **整页栅格化**：agent 用了 `pdftoppm` 或 `page.get_pixmap()` 截取整页而非内嵌图
3. **尺寸过滤误杀**：图片尺寸确实 < 100px（噪音）或 > 页面 80%（全页截图）
4. **PyMuPDF 未安装**：跳过了唯一可行的提取路径

**修复**：
1. 确认提取优先级正确：`pdfimages`（bbox 最准）→ PyMuPDF `page.get_images()`（矢量图回退）
2. 确认禁用：`pdftoppm` 和 `page.get_pixmap()`（整页渲染）
3. 检查尺寸过滤参数：
   - 下限：`width < 100px` 或 `height < 100px` → 丢弃
   - 上限：`width > page_width * 0.8` 且 `height > page_height * 0.8` → 丢弃（全页文字截图）
4. 小图不放大（保持原始分辨率，不插值）

**检测命令**：
```bash
# 检查 PyMuPDF 可用性
pip list 2>/dev/null | grep PyMuPDF

# 检查 poppler-utils
which pdfimages 2>/dev/null

# 检查提取结果
ls course/assets/
identify course/assets/*.png   # ImageMagick，查看实际尺寸
```

### F1-3：矢量图 / 公式渲染缺失

**现象**：论文中的矢量图或数学公式渲染为图片的部分提取失败。

**原因**：arxiv HTML 版中公式/矢量图可能以 `<svg>` 或 MathJax 呈现，非嵌入图片。

**修复**：
1. 回退路径：确认 agent 尝试了 PyMuPDF `get_drawings()` + 限定 clip 渲染
2. 若仍失败，将公式以 MathJax（`$$...$$`）手写重现，标注 `*📎 公式重绘*`

### F1-4：URL 类型判定失败

**现象**：agent 无法确定给定 URL 是 arxiv、OpenReview、PDF 直链还是其他。

**原因**：SKILL.md 步骤 1 的 URL 转换规则未覆盖该域名。

**修复**：
1. arxiv URL 统一转为 `arxiv.org/html/` 版
2. PDF URL → 保存到本地，走 PDF 提取管线
3. 其他 → 尝试通用 HTML 抓取

### F1-5：临时 HTML 文件散落根目录未清理

**现象**：`ls *.html` 在项目根目录能看到 arxiv 抓取的临时 HTML 文件。

**原因**（按概率排序）：
1. SKILL.md 步骤 1 未要求清理临时文件
2. agent 抓取后忘记删除中间文件

**修复**：
1. 确认 SKILL.md 步骤 1 包含"临时文件清理"约束
2. 若需保留原始抓取内容 → 存入 `papers/<简称>/_source.html`（仅一个文件）
3. 其余中间副本立即删除

**检测命令**：
```bash
# 检查根目录是否有残留 HTML
ls *.html 2>/dev/null
```

---

## 步骤 2：课程/笔记/概念生成

### F2-1：课程文件缺少底部导航

**现象**：课程文件末尾没有 `← 上一节 | 下一节 →` 导航链接。

**原因**：导航未列入「单课模块」必选项，agent 自觉遗漏。

**修复**：
1. 确认 `references/course-design-guide.md` 中底部导航结构存在且标注为"必须包含"
2. 检查末节是否有 `> [!tip]+ 🎓 课程结束` callout
3. 检查首节 `prev: 无`，末节 `next: 无`

### F2-2：自测题内容越界

**现象**：自测题答案中的关键信息点在本节核心讲解中找不到对应段落。

**原因**：agent 生成自测题时引用了其他节或原文未在课程中讲解的内容。

**修复**：
1. 确认 `references/course-design-guide.md` 包含"讲什么考什么"约束
2. 逐题检查：每个信息点是否在核心讲解中有对应段落
3. 若越界，调整题目内容或补充讲解段落

### F2-3：笔记中缺少核心图片

**现象**：笔记纯文本，没有图嵌入。

**原因**：笔记模板未要求图嵌入，agent 认为笔记不需要图。

**修复**：
1. 确认 `references/obsidian-note-template.md` 中「方法」和「实验」章节有 `![[assets/figure-N.png]]` 占位
2. 检查图片嵌入规则：只嵌核心 1-3 张（架构图 + 关键结果图）

### F2-4：概念筛选含噪音

**现象**：`concepts/` 中有仅顺带提及、非论文核心贡献的概念。

**原因**：筛选条件未严格执行双条件。

**修复**：
1. 逐概念检查双条件：
   - (a) 原文给出定义或公式推导
   - (b) 在论文贡献中占有一席之地
2. 不满足任一条件 → 从 `concepts/` 中移除

### F2-5：论文简称重名冲突

**现象**：两篇不同论文的 kebab-case 缩写相同。

**原因**：生成的简称被已有目录占用。

**修复**：
1. 检查 `papers/<简称>/` 目录是否已存在
2. 同论文（同 title）→ 提示覆盖或取消
3. 不同论文 → 自动追加消歧后缀：`<简称>-<年份>` → `<简称>-<年份>-<作者姓>`
4. 全部失败 → 请用户手动指定

### F2-6：概念拆分时机混乱

**现象**：步骤 5 才生成概念文件，而非步骤 2 并行产出。

**原因**：agent 未遵守 v2.4 的流程重构——概念骨架应在步骤 2 与课程笔记并行生成，步骤 5 只做引导填写。

**修复**：
1. 确认 SKILL.md 步骤 2 包含"概念生成"子步骤
2. 步骤 5 检查 `concepts/` 下骨架是否已存在

### F2-7：🟡 全管线跨论文污染（潜在风险）

**严重级别**：🟡 潜在风险（尚未被 agent 实际触发，但示例设计存在诱发条件）。

**实际案例**：人工迁移目录时误将 Attention Is All You Need 全套产物与 Logic Reward 产物一起移动，非 agent 生成行为。但暴露了示例设计的风险敞口。

**潜在现象**：处理论文 A 时，agent 为论文 B（`examples/` 中的示例论文）生成全套产物（课程 + 笔记 + 概念）。触发条件：当前论文与示例论文有术语重叠（如都涉及 "attention"）。

**原因**：
1. **上下文污染**：repo 中 `examples/` 目录的完整示例可能被 agent 误认为应一并生成的产物
2. **缺少硬边界**：步骤 2 没有约束"只为当前这篇论文生成"
3. **术语关联**：论文中的术语与示例论文的术语重叠时，可能触发联想扩展

**修复**：
1. **前置隔离**：步骤 2 启动时明确告知 agent "`examples/` 是历史示例，勿参考勿扩展；只处理论文 X"
2. 或更轻量：SKILL.md 步骤 2 加一句 `examples/ 目录中的文件是示例，严禁在生成新论文产物时将其作为候选或模板复制`
3. **原文归属硬约束**（长线）：每个产物必须引用当前论文原文的具体段落作为"存在证明"

**检测命令**：
```bash
# 检查 papers/ 下是否有非预期的论文目录
ls test-output/HelpMeRead/papers/

# 检查 concepts/ 中每个概念的 defined_in 是否指向预期论文
for f in test-output/HelpMeRead/concepts/*.md; do
  echo "$f → $(grep 'defined_in' "$f" | head -1)"
done
```

### F2-8：课程文件内容截断（话说到一半就断了）

**现象**：课程某节末尾不满足 SKILL.md 步骤 2 的三条件判据（块配对、末段完整句、末字符不在句中）

**原因**（按概率排序）：
1. LLM 生成时达到输出长度限制，提前截断
2. agent 一次性生成多节时未逐节检查完整性
3. 块结构（callout/代码块/公式）配对未对齐

**修复**：
1. 确认 SKILL.md 步骤 2 包含"生成后完整性检查"（第 8 步）
2. 逐节执行三条件 AND 判据，任一不通过则立即重新生成该节
3. emoji 收尾（4 字节 UTF-8）不视为截断；只在 block pairing + 末段完整句都不通过时才判为截断

**检测命令**：
```bash
# 块配对
for f in test-output/HelpMeRead/papers/*/course/*.md; do
  dollars=$(grep -o '\$' "$f" | wc -l)
  fences=$(grep -o '\`\`\`' "$f" | wc -l)
  echo "$f: dollars=$dollars fences=$fences"
done

# 末字符检查（多字节安全，用 Python 避免 UTF-8 切片错位）
python3 -c "
import os, glob
for f in glob.glob('test-output/HelpMeRead/papers/*/course/*.md'):
    with open(f, 'rb') as fh:
        text = fh.read().decode('utf-8', errors='replace')
    # 取最后 200 字符（按字符，不是字节）
    tail = text[-200:] if len(text) > 200 else text
    last_char = text[-1] if text else ''
    has_complete = any(c in tail for c in ['.', '。', '!', '！', '?', '？', ';', '；', '…', '……'])
    in_middle = last_char in [',', '，', ':', '：', ';', '；', '、', '(', '（']
    print(f'{f}: last={last_char!r} complete_sent={has_complete} mid_char={in_middle}')
"
```

---

## 步骤 3-4：学习阶段

### F3-1：Obsidian URI 无法打开

**现象**：agent 生成的 `obsidian://open?` 链接点击后无反应。

**原因**（按概率排序）：
1. vault 路径中的目录名与实际 Obsidian vault 名称不匹配
2. 文件路径包含空格/中文未正确编码
3. 平台命令回退失败（Windows `start` / macOS `open` / Linux `xdg-open`）

**修复**：
1. 确认 `obsidian_vault` 路径的**最末一级目录名**作为 vault 名（如 `D:\Path\To\MyVault` → `MyVault`）
2. 确认 URI 编码正确（空格 → `%20`，中文 → 百分比编码）
3. URI 失败时回退到平台命令

**检测命令**：
```bash
# Windows 测试 URI
start obsidian://open?vault=MyVault&file=HelpMeRead/papers/xxx/HMR-xxx.md
```

### F3-2：底部导航断裂

**现象**：课程文件中 `[[wikilink]]` 指向的文件路径不存在。

**原因**：前后节文件命名不一致。

**修复**：
1. 检查 `prev`/`next` 字段中的文件名是否与 `title` + 实际文件名匹配
2. 导航中的 `[[链接]]` 是否对应实际存在的 `.md` 文件

### F3-3：待学习机制未在用户被动提及陌生概念时触发

**现象**：用户说"我不懂 X""这里有个 Y 我不熟悉"，agent 解释了概念但没有自动存入 `to-learn/`。

**原因**（按概率排序）：
1. 触发条件过窄——agent 只在显式提问"X 是什么？"时触发
2. 被动提及的信号词（"不懂""不熟悉""没听过""没解释"等）未被识别
3. agent 主动解释概念后未执行后续步骤（存入 to-learn + 提供协助）

**修复**：
1. 确认 SKILL.md 待学习机制段落包含扩展触发条件——覆盖主动提问和被动提及两种场景
2. 主动解释概念后必须按流程执行：解释 → 自动存入 → 提供搜索协助

**检测命令**：
```bash
# 检查 to-learn/ 目录是否有对应概念的笔记
ls test-output/HelpMeRead/to-learn/
```

---

## 步骤 5：原子笔记拆分

### F4-1：引导流程跳跃

**现象**：agent 跳过引导直接写入定义，或一次性完成全部概念。

**原因**：agent 未遵守"脚手架 + 聊天逐个引导"的约束。

**修复**：
1. 确认 SKILL.md 步骤 5 指令明确写有"逐个引导"
2. 检查 `## 定义` 是否为 `> 你的理解：______` 的留空状态
3. 每次最多处理一个概念，引导用户用自己的话填写后再写文件

### F4-2：学习补充层未回写

**现象**：纠错/补充内容未追加到笔记的 `## 学习补充`。

**原因**：agent 直接在笔记原文层修改，或完全忘记补充层机制。

**修复**：
1. 检查笔记末尾 `## 学习补充` 是否存在
2. 确认修改添加到补充层而非原文层

---

## 产物后检查

### F5-1：产物路径不符合命名约定

**现象**：文件位置或名称与 [SKILL.md 命名约定](../SKILL.md#命名约定全文统一遵循) 不匹配。

**原因**：agent 未从头参照命名约定表。

**快速检查**：

```bash
# 检查所有产物路径
find test-output/HelpMeRead/ -type f -name "*.md" | sort

# 期望结构：
# HelpMeRead/
# ├── HelpMeRead MOC.md
# ├── concepts/<概念名>.md
# ├── papers/<简称>/
# │   ├── HMR-<简称>.md
# │   ├── course/
# │   │   ├── <nn>-<英文名>.md
# │   │   └── assets/
# │   │       └── figure-N.png
# │   └── qa-<YYYY-MM-DD>.md
# └── to-learn/<概念名>.md
```

### F5-2：frontmatter 字段缺失

**现象**：Markdown 文件的 `---` 间的元数据字段不完整。

**快速检查**：对照 `references/frontmatter-schema.md` 逐产物类型核对。

### F5-3：概念笔记"相关"区块格式异常

**现象**：概念笔记的 `## 相关` 区块只有裸 wikilink（无关系说明），或位置在 `## 🔗 延伸探索` 之后。

**原因**：模板中 `## 相关` 未要求关系说明，且位置语义不当。

**修复**：
1. 确认 `references/obsidian-note-template.md` 模板中 `## 相关` 位于 `## ⚖️ 分析` 和 `## 🔗 延伸探索` 之间
2. 每个链接附带 `——<一句话关系说明>`

**检测命令**：
```bash
# 检查概念笔记相关区块格式
grep -A 5 "^## 相关" test-output/HelpMeRead/concepts/*.md
```

---

## 附录：检测命令速查

```bash
# === 环境 ===
# 配置文件存在？路径按 SKILL.md 步骤 0 动态确定
cat .claude/skills/help-me-read/help-me-read.json 2>/dev/null || cat ~/.claude/skills/help-me-read/help-me-read.json

# PyMuPDF 可用？
pip list 2>/dev/null | grep PyMuPDF

# poppler-utils 可用？
which pdfimages 2>/dev/null

# 网络可达？
curl -sI "https://arxiv.org/abs/XXXX.XXXXX" | head -5

# === 产物 ===
# 图片提取结果
ls -la outputs/HelpMeRead/papers/*/course/assets/

# 图片是否有噪音（< 100px）
identify outputs/HelpMeRead/papers/*/course/assets/*.png | awk '{print $3}' | grep -E '^[0-9]+x'

# 课程文件结构
ls outputs/HelpMeRead/papers/*/course/*.md

# 导航完整性
grep -l "←.*→" outputs/HelpMeRead/papers/*/course/*.md | wc -l

# 概念筛选（检查噪音）
cat outputs/HelpMeRead/concepts/*.md | grep "^title:" | sort

# frontmatter 完整性
head -15 outputs/HelpMeRead/papers/*/HMR-*.md | grep -E "^(title|type|status|tags):" | sort
```
