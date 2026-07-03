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
8. [步骤 6：MOC 生命周期](#步骤-6moc-生命周期)
9. [附录：检测命令速查](#附录检测命令速查)

---

## 1. 按阶段快速定位

| 症状 | 可能阶段 | 优先排查 |
|------|---------|---------|
| 配置检查反复弹出 | 步骤 0 | 配置文件格式 |
| 测试产物写入生产 vault | 步骤 0 | F0-2 测试模式 |
| PDF 图片缺失 / 全是文字截图 | 步骤 1 | 图片提取管线 |
| 抓取内容只到摘要 | 步骤 1 | URL 转换、网络 |
| 根目录散落 HTML 临时文件 | 步骤 1 | F1-5 清理 |
| 文献速览未展示 / 用户无选择机会 | 步骤 1 | F1-7 文献速览 |
| 课程缺少导航链接 | 步骤 2 | 课程设计指南遵守 |
| 自测题答案无法从课程中找到 | 步骤 2 | 内容范围约束 |
| 笔记缺少核心图 | 步骤 2 | 笔记模板图嵌入 |
| 概念列表有噪音概念 | 步骤 2 | 筛选条件 | 
| 概念/课程含其他论文的完整产物 | 步骤 2 | 🔴 跨论文污染 F2-7 |
| 课程内容截断（话说到一半） | 步骤 2 | F2-8 完整性检查 |
| 课程使用未解释的专业概念 | 步骤 2 | F2-9 概念解释覆盖 |
| 概念解释句含未解释的嵌套术语 | 步骤 2 | F2-10 嵌套术语 |
| 可跳过标注未位于课程节顶部 | 步骤 2 | F2-11 skip 位置 |
| Obsidian URI 打不开（无自动回退） | 步骤 4 | F3-1 vault 路径/编码 |
| to-learn 未触发（被动提及概念） | 步骤 3-4 | F3-3 触发条件 |
| 引导流程跳跃 / 未展示参考答案 | 步骤 5 | F4-1 / F4-3 |
| 概念自测步骤编号暴露 + 反查/拆解未静默 | 步骤 5 | F4-4 |
| 产物路径和预期不一致 | 产物后 | 命名约定、重名处理 |
| 概念笔记"相关"区块无关系说明 | 产物后 | F5-3 模板格式 |
| MOC 不存在 / 论文条目不同步 | 步骤 6 | F6-* |
| MOC 状态列与笔记 frontmatter 不一致 | 步骤 6 | F6-* |
| MOC 待学习表与 to-learn/ 目录不同步 | 步骤 6 | F6-* |

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

### F1-6：URL 下载的 PDF 未清理

**现象**：步骤 1 完成后，根源 URL 下载的 PDF 文件仍残留在磁盘上（用户提供的本地 PDF 不受影响）。

**原因**（按概率排序）：
1. SKILL.md 步骤 1 的"输入文件分类与清理"规则未被 agent 执行——agent 未识别输入来源，未触发清理
2. 步骤 1 内子步骤失败，PDF 被保留（预期行为，非 bug）
3. 清理权限不足（文件被占用/只读）

**修复**：
1. 确认步骤 1 末尾已包含"输入文件分类与清理"指令
2. 检查 PDF 是否为 URL 下载（非用户提供的本地路径）
3. 手动删除或确认文件状态

**检测命令**：
```bash
# 检查项目根目录及 papers/ 下是否有残留 PDF（排除用户提供的本地路径）
find . -maxdepth 2 -name "*.pdf" -not -path "./references/*" 2>/dev/null
```

### F1-7：文献速览未展示/用户无选择机会

**现象**：步骤 1 类型判定后，agent 直接进入步骤 2 并行生成，未展示文献速览 callout，用户无机会判断"这篇是否值得学"就进入了完整流程。

**原因**：
1. agent 省略了「文献速览」环节（SKILL.md 未强调其为必经步骤）
2. agent 默认用户选择"继续完整流程"，跳过选择环节

**修复**：
1. 确认 SKILL.md 步骤 1 末尾包含「文献速览」段落
2. 确认速览包含三项：核心贡献、问题-方法-局限、核心概念概览
3. 确认用户有四个选项可选（继续/只要总结/只笔记/停止）

**检测命令**：
```bash
# 检查 SKILL.md 中是否存在文献速览段落
grep -q "📄 论文速览" ../SKILL.md && echo "✅ 已包含" || echo "❌ 缺失"
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

### F2-3：（已修复 ✅ 模板已包含图嵌入）

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

**原因**：agent 未遵守流程重构——概念骨架应在步骤 2 与课程笔记并行生成，步骤 5 只做引导填写。

**修复**：
1. 确认 SKILL.md 步骤 2 包含"概念生成"子步骤
2. 步骤 5 检查 `concepts/` 下骨架是否已存在

### F2-7：跨论文污染（✅ 已验证修复——v2.7+ 步骤 2 已硬边界隔离）

**历史背景**：人工迁移目录时误将 Attention Is All You Need 全套产物与 Logic Reward 产物一起移动，非 agent 生成行为。但暴露了示例设计的风险敞口。

**旧现象**：处理论文 A 时，agent 为论文 B（`examples/` 中的示例论文）生成全套产物（课程 + 笔记 + 概念）。触发条件：当前论文与示例论文有术语重叠（如都涉及 "attention"）。

**旧原因**：
1. **上下文污染**：repo 中 `examples/` 目录的完整示例可能被 agent 误认为应一并生成的产物
2. **缺少硬边界**：步骤 2 没有约束"只为当前这篇论文生成"
3. **术语关联**：论文中的术语与示例论文的术语重叠时，可能触发联想扩展

**已应用的修复**（v2.7+）：
- SKILL.md 步骤 2 已加入 `examples/ 目录中的文件是示例，严禁在生成新论文产物时将其作为候选或模板复制`
- 每个产物要求引用当前论文原文的段落作为"存在证明"

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

### F2-9：课程使用未解释的专业概念

**现象**：课程中 `[[概念名]]` 双链出现，但没有对应的自然语言解释（或在首次出现时才解释，但"解释句"本身仍是术语堆砌，零背景读者无法理解）。

**原因**（按概率排序）：
1. 课程生成时 agent 默认读者已了解该领域，或认为概念名称自解释
2. "首次出现+一句话解释"规则执行不严——解释句包含嵌套术语

**修复**：
1. 确认课程生成前执行了读者画像声明（零背景默认）
2. 确认课程生成遵循了"首次出现即解释"规则——每个 `[[概念名]]` 在正文首次出现时附带一句话自然语言解释
3. 确认完整性检查中的"概念解释覆盖"条件通过

**检测命令**：
```bash
# 检查每节课程文件中 [[概念名]] 首次出现时是否有前置解释段落
for f in test-output/HelpMeRead/papers/*/course/*.md; do
  echo "=== $f ==="
  # 提取所有 [[概念名]]
  grep -oP '\[\[\K[^\]|]+' "$f" | sort -u
done
```

> 关联 issue：④

### F2-10：概念解释句中包含未解释的嵌套术语

**现象**：对概念 A 的解释句本身包含概念 B 的术语，而 B 在前文和首次出现解释中均未解释。例如"Transformer 使用 self-attention 机制"——self-attention 是另一个需要解释的概念。

**原因**：agent 在写解释句时使用了论文语言而非日常语言，混淆了"领域内公认术语"和"通用常识"。

**修复**：
1. 检查每个 `[[概念名]]` 首次出现时的解释句是否包含另一个 `[[...]]` 标记或候选概念名
2. 如果包含 → 拆分：要么在被嵌套概念首次出现处先解释，要么改写解释句用日常语言绕过

**检测命令**：
```bash
# 扫描课程文件中每个 `[[概念名]]` 的解释句是否嵌套其他 `[[概念名]]`
# 若一个概念出现在另一个概念的解释句中，检查前者是否在更早前解释过
```

> 关联 issue：④

### F2-11：可跳过标注未位于课程节顶部

**现象**：`> [!skip] ⏭` 标注出现在课程节正文的中后段，而非该节顶部（地图之后、学习目标之前）的固定位置。

**原因**：course-design-guide.md 中的位置规则以自然语言描述，未嵌入模板示例或生成 prompt 的结构约束，agent 按内容逻辑而非格式规则放置。

**修复**：
1. 检查每节课文件中 `[!skip]` 的位置是否在文件前 20% 行以内
2. 如果不在 → 将该标注移动到该节顶部（课程地图之后、学习目标之前）
3. 调整后确认 skip 标注与上下节内容之间的语义连贯性（移动后不应产生歧义）

**检测命令**：
```bash
# 检查每节课文件中 [!skip] 是否位于文件前 20% 行范围内
for f in vault/path/论文名/*.md; do
  total=$(wc -l < "$f")
  skip_line=$(grep -n '\[!skip\]' "$f" | head -1 | cut -d: -f1)
  [ -n "$skip_line" ] && [ "$skip_line" -gt $((total / 5)) ] && \
    echo "⚠️  $f: [!skip] 位于第 $skip_line/${total} 行（应在前 20%）"
done
```

> 关联 issue：⑪

---

## 步骤 3-4：学习阶段

### F3-1：Obsidian URI 无法打开

**现象**：agent 执行的 `obsidian://open?` 链接无效或 Obsidian 未响应。

**原因**（按概率排序）：
1. vault 路径中的目录名与实际 Obsidian vault 名称不匹配
2. 文件路径包含空格/中文未正确编码
3. 用户未在 Obsidian 中设置 vault 路径对应的 vault

**修复**：
1. 确认 `obsidian_vault` 路径的**最末一级目录名**作为 vault 名（如 `D:\Path\To\MyVault` → `MyVault`）
2. 确认 URI 编码正确（空格 → `%20`，中文 → 百分比编码）
3. 当前策略**不自动回退**到平台命令——由用户反馈"没打开"后手动执行（避免双重打开）

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

### F4-3：概念自测后未展示参考答案

**现象**：用户用自己的话回答了概念定义后，agent 只做口头点评（"你漏了 X"），未将原文定义的核心要点提炼为完整标准表述展示给用户供自我对照。

**原因**（按概率排序）：
1. 纠错流程中「评价」步骤仅要求 agent 做语义对比并输出点评，缺少"展示标准答案供用户自评"的独立环节
2. agent 认为口头点评已覆盖对比需求，低估了用户直接对照原文锚点的学习价值

**修复**：
1. 确认 SKILL.md 步骤 5 的纠错流程包含「展示参考答案」步骤（当前步骤 5）
2. 展示内容应基于 `## 出处` 的原文引用或原子笔记的 `## 🔍 深入理解`，标注 `[原文·已验证]` 或 `[推断]`
3. 与步骤 1「评价」的边界：步骤 1 是 agent 口头诊断，参考答案步骤是用户自主对照

**检测命令**：
```bash
# 检查 SKILL.md 步骤 5 是否包含「展示参考答案」步骤
grep -q "展示参考答案" ../SKILL.md && echo "✅ 已包含" || echo "❌ 缺失"
```

### F4-4：概念自测纠错步骤编号暴露给用户 + 反查/拆解未静默条件触发

**现象**（三个同源问题）：
1. agent 在交互中输出"第 1 步：评价""第 2 步：反查课程"等步骤标签
2. "反查课程"作为显式步骤宣布，暴露内部检索过程
3. "拆解问题"每个概念都固定执行（无论回答是否正确），且子问题深度超出课程讲解范围

**原因**：
- SKILL.md 步骤 5 以编号列表形式（1./2./3.）描述流程，agent 倾向原样照搬
- 反查课程和拆解问题是 agent 的心智过程，但被列为用户可见的独立步骤
- 流程为线性无分支，缺乏条件跳转逻辑
- 拆解问题的深度缺少"不超过课程讲解深度"的约束

**修复**：
1. 在 SKILL.md 步骤 5 头部追加 `（步骤编号仅作为 agent 内部执行参考，不得在对话中输出给用户）`
2. 将"反查课程"从用户可见步骤中移除，改为 agent 在评价后的内部检索动作
3. 将"拆解问题"改为条件触发——仅在"用户回答明显偏离核心定义"时执行，且限定子问题深度≤课程对该内容的覆盖深度
4. 重构为分支流程：评价 → 条件分支（完整/少量遗漏/明显偏离）→ 展示参考答案 → 确认填入 → 回写补充

**检测命令**：
```bash
# 检查步骤 5 是否已限制步骤编号输出
grep -q "不得在对话中输出" ../SKILL.md && echo "✅ 已限制" || echo "❌ 未限制"
# 检查分支流程中是否移除了用户可见的步骤编号
grep -A10 "纠错流程" ../SKILL.md | grep -E "^\d+\.\s+\*\*" && echo "⚠️ 仍有编号列表" || echo "✅ 已移除编号列表"
```

> 关联 issue：⑫


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

### F5-4：原子笔记双链命名与文件名不一致

**现象**：原子笔记 `## 相关` 或正文中的 `[[wikilink]]` 双链文本与实际目标文件不匹配，Obsidian 将其视为新笔记创建，产生重复条目。

**原因**（按概率排序）：
1. 概念映射表未在步骤 2 构建——agent 用自由文本命名（大小写/空格/别名），与 kebab-case 文件名不匹配
2. 映射表已构建但 agent 未从中取值——步骤指令约束不足
3. `## 相关` 模板未指定管语法（`[[filename_slug|显示文本]]`）——agent 沿用旧格式

**修复**：
1. 确认 SKILL.md 步骤 2 包含"构建概念映射表"指令
2. 确认 `references/obsidian-note-template.md` 的 `## 相关` 模板已更新为管语法
3. 所有 `concepts/*.md` 扫描一遍，修正不匹配的双链

**检测命令**：
```bash
# 扫描 concepts/ 中所有 [[wikilink]]，检查是否有对应文件（处理 `[[X|Y]]` 管语法）
python3 -c "
import glob, re
for f in glob.glob('test-output/HelpMeRead/concepts/*.md'):
    with open(f) as fh:
        content = fh.read()
    # 提取所有 [[...]]，去除 |Y 显示文本
    links = re.findall(r'\[\[([^\]|]+)(?:\|[^\]]+)?\]\]', content)
    for link in links:
        target = f'test-output/HelpMeRead/concepts/{link}.md'
        if not glob.glob(target):
            with open('/dev/stderr', 'w') as err:
                err.write(f'MISSING: {link}.md (referenced in {f})\n')
"
```

---

## 步骤 6：MOC 生命周期

### F6-1：MOC 文件不存在

**现象**：`HelpMeRead MOC.md` 在 vault 的 `HelpMeRead/` 目录下不存在，或 `type: moc` frontmatter 缺失。

**原因**：步骤 2（首篇论文生成）时 MOC 创建逻辑未执行，或用户手动删除了文件。

**修复**：
1. 执行 `bash scripts/verify.sh` 检查 MOC 存在性
2. 若缺失，按 `references/moc-guidelines.md` 中的内容结构重新创建并填入已有论文

**检测命令**：
```bash
# 检查 MOC 文件存在且 frontmatter 正确
head -5 test-output/HelpMeRead/HelpMeRead\ MOC.md 2>/dev/null | grep -c "type: moc"
```

> 关联 issue：⑫

### F6-2：MOC 论文条数与实际不匹配

**现象**：MOC「按状态」表的行数 ≠ `papers/` 下 `HMR-*.md` 的数量（多出或缺少）。

**原因**（按概率排序）：
1. 新论文笔记生成后 MOC 未同步（SKILL.md 补丁① 未执行）
2. 用户手动删除了论文目录但未同步 MOC
3. MOC 中有用户添加的非论文行

**修复**：
1. 确认 SKILL.md 步骤 2 末尾的 MOC 同步指令已执行
2. 扫描 MOC 中所有 `[[HMR-` 链接，逐一验证对应的笔记文件存在
3. 缺少的行手动补上，多余的行标记为可疑

**检测命令**：
```bash
# 比较 MOC 论文引用数与 papers/ 下的实际论文数
python3 -c "
import os, re
moc = open('test-output/HelpMeRead/HelpMeRead MOC.md').read()
moc_papers = set(re.findall(r'\[\[(HMR-[^\]|]+)', moc))
actual_papers = set()
for f in os.listdir('test-output/HelpMeRead/papers/'):
    if os.path.isdir(f'test-output/HelpMeRead/papers/{f}'):
        actual_papers.add(f'HMR-{f}')
missing = actual_papers - moc_papers
extra = moc_papers - actual_papers
print(f'MOC 中论文数: {len(moc_papers)}')
print(f'实际论文数: {len(actual_papers)}')
if missing: print(f'MOC 缺少: {missing}')
if extra: print(f'MOC 多余: {extra}')
"
```

### F6-3：MOC 状态列与笔记 frontmatter 不同步

**现象**：MOC「按状态」表中某论文的 `status` 列与其笔记 frontmatter 中的 `status` 字段不一致。

**原因**：步骤 4（学习完成）或步骤 5（原子笔记拆完）更新笔记 frontmatter 后，未同步更新 MOC 状态列。

**修复**：
1. 确认 SKILL.md 步骤 4/5 末尾的 MOC 同步指令已执行
2. 逐行检查 MOC 状态列与对应笔记的 frontmatter

**检测命令**：
```bash
# 逐篇对比 MOC 状态与笔记 frontmatter
python3 -c "
import os, re
moc = open('test-output/HelpMeRead/HelpMeRead MOC.md').read()
table = re.search(r'## 按状态\n\|.*?\n(\|.*\n)+', moc)
if not table: exit()
papers_dir = 'test-output/HelpMeRead/papers'
for line in table.group().split('\n'):
    m = re.match(r'\|\s*\[\[(HMR-[^\]]+)\]\].*?\|.*?\| (\w+) \|', line)
    if m:
        slug = m.group(1).replace('HMR-', '')
        expected = m.group(2)
        note_path = f'{papers_dir}/{slug}/HMR-{slug}.md'
        if os.path.exists(note_path):
            note = open(note_path).read()
            actual = re.search(r'status: (\w+)', note)
            if actual and actual.group(1) != expected:
                print(f'MISMATCH: {slug} MOC={expected} frontmatter={actual.group(1)}')
"
```

### F6-4：MOC 待学习表与 to-learn/ 目录不同步

**现象**：MOC「待学习」表中的条目与 `to-learn/` 目录下的文件不匹配（缺少行、多余行、状态不一致）。

**原因**（按概率排序）：
1. to‑learn 笔记自动存入后 MOC 同步未执行（SKILL.md 补丁④ 未执行）
2. to‑learn 笔记毕业后 MOC 状态未同步
3. 用户手动清除了 `to-learn/` 目录但未更新 MOC

**修复**：
1. 确认待学习机制中 MOC 同步指令已执行
2. 扫描 `to-learn/` 目录，将 open/exploring 的条目逐一与 MOC 待学习表对比

**检测命令**：
```bash
# 对比 MOC 待学习表与 to-learn/ 目录
python3 -c "
import os, re
moc = open('test-output/HelpMeRead/HelpMeRead MOC.md').read()
table = re.search(r'## 待学习\n\|.*?\n(\|.*\n)+', moc)
moc_items = set()
if table:
    for line in table.group().split('\n'):
        m = re.match(r'\|\s*\[\[([^\]]+)\]\]', line)
        if m:
            moc_items.add(m.group(1))
to_learn_dir = 'test-output/HelpMeRead/to-learn'
actual_items = set()
if os.path.isdir(to_learn_dir):
    for f in os.listdir(to_learn_dir):
        if f.endswith('.md'):
            actual_items.add(f.replace('.md', ''))
missing = actual_items - moc_items
extra = moc_items - actual_items
if missing: print(f'MOC 待学习表缺少: {missing}')
if extra: print(f'MOC 待学习表多余: {extra}')
if not missing and not extra: print('MOC 待学习表与 to-learn/ 目录一致')
"
```

---

## 附录：检测命令速查

已拆出到 `references/diagnostics-cheatsheet.md`（按需读取）。