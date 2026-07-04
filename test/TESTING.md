# Help Me Read —— 测试框架

## 设计原则

1. **模块化**：每个测试模块独立，按改动范围选取执行
2. **可执行**：测试步骤用祈使句写成指令，agent 可逐条执行并给出报告
3. **自报告**：每个模块末尾有判定区，agent 执行后填入结果
4. **人工门**：agent 无法独自判定的检查项标记为 `[人工]`，最终裁决由用户做出
5. **隔离性**：测试产物写入独立目录 `test-output/`，不污染用户 vault

---

## 目录结构

```
HelpMeRead/
├── test/
│   ├── test-config.json        # 测试配置文件（指向 test-output/）
│   └── TESTING.md              # 本文件
├── test-output/                # 测试产物（被 .gitignore 忽略）
│   └── HelpMeRead/
│       ├── papers/
│       ├── concepts/
│       ├── to-learn/
│       └── HelpMeRead MOC.md
├── .claude/agents/             # subagent 定义（由 init-agents.sh 生成）
│   ├── concept-mapper.md
│   ├── course-generator.md
│   └── note-writer.md
... └──
```

## 测试配置

`test/test-config.json`（纳入版本控制）：

```json
{
  "obsidian_vault": "<项目绝对路径>/test-output",
  "qa_record": false,
  "to_learn": true,
  "external_concepts_dirs": []
}
```

> 每次运行测试前确认 `test/test-config.json` 中的 vault 路径是绝对路径、指向 `test-output/`、且目录存在。agent 在测试流程开始时自动检查。

## 快速索引：改动 → 必测模块

| 改动范围 | 必测模块 |
|----------|----------|
| 仅改 README/文案 | 无需测试 |
| 改 SKILL.md 流程步骤或顺序 | T9 全流程 + T16-B/C + 对应步骤的子模块 |
| 改课程模板/生成规则 | T4 课程生成 + T4-E |
| 改笔记模板/生成规则 | T5 笔记生成 |
| 改概念筛选标准/概念映射 | T6 概念筛选 + T16-B concept-mapper |
| 改示例嵌入规则 | T7 示例嵌入 |
| 改命名约定/产物目录 | T8 产物结构 |
| 改图片提取管线 | T3 图片提取 |
| 改问答标准 | T11 问答 |
| 改步骤 5 引导逻辑 | T10 步骤 5 引导 |
| 改待学习机制 | T13 待学习功能 |
| 改首次运行引导 | T1 环境检查 + preflight.sh 检查 |
| 改跨论文去重或联系 | T12 跨论文功能 |
| 改 MOC 生命周期/同步机制 | T15 MOC 生命周期 |
| subagent 定义文件（.claude/agents/）变化 | T16-A init-agents |
| concept-mapper 逻辑变化 | T6 + T16-B |
| subagent 容错边界 | T16-C |
| reference 文件之间的交叉引用 | T17 reference 一致性 |
| `_source.md` 格式变化 | T2 + T14 |
| 文献速览环节 | T2 + T9 |
| quality-checks.md 变化 | T4-D + T17 |
| init-agents.sh 变化 | T16-A |
| 多处同时改动 | 各对应模块 + T9 全流程 |
| 新论文类型引入 | T2 + T4 + T5 |

### 一键验证

执行 `bash scripts/verify.sh` 可自动运行所有结构化检查。验证脚本会自动扫描 `test-output/HelpMeRead/` 目录。
可指定目标目录：`bash scripts/verify.sh /path/to/vault/HelpMeRead`

---

## 测试全局设置

- **测试论文 1**：`Attention Is All You Need`（arXiv:1706.03762），以下简称 **Transformer**
  类型：研究论文（research），有原创方法 + 可复现实验
  用途：全模块测试（T1-T17）
- **测试论文 2**：`LLLMs: A Data-Driven Survey of Evolving Research on Limitations of Large Language Models`（arXiv:2505.19240），以下简称 **LLLMs**
  类型：综述论文（survey），数据驱动的文献回顾
  用途：新论文类型引入测试（T2 + T4 + T5）
- **测试前准备**：
  1. 确认 `test/test-config.json` 中 vault 路径为绝对路径、指向 `test-output/`
  2. 删除 `test-output/` 下所有旧产物（清理命令：`rm -rf test-output/HelpMeRead/`）
  3. 执行 `bash scripts/init-agents.sh` 安装 subagent（如尚未安装）
  4. 测试模式由 `bash scripts/preflight.sh` + `test/test-config.json` 共同决定——`test/test-config.json` 存在时自动使用测试配置，产物写入 `test-output/`，无需手动切换生产配置
- **测试执行**：所有产物写入 `test-output/HelpMeRead/`，不碰用户 vault。生产配置（运行时按 preflight.sh 动态确定路径）在测试期间不会被读取或修改

---

## T1：环境检查

**目标**：验证运行环境配置正确，依赖可用。

### 步骤

1. 检查 `test/test-config.json` 存在，`obsidian_vault` 路径存在且可写
2. 检查 `test-output/` 和 `test-output/HelpMeRead/` 目录存在（不存在则创建）
3. 检查 PyMuPDF 是否可用：`pip list 2>/dev/null | grep PyMuPDF`
4. 检查 poppler-utils 是否可用：`which pdfimages 2>/dev/null`
5. 检查网络可达：抓取 `https://arxiv.org/abs/1706.03762` 和 `https://arxiv.org/abs/2505.19240` 确认可返回
6. 检查 Obsidian URI 格式：确认 `obsidian://open?vault=<vault名>&file=<路径>` 中 vault 名提取正确
7. 检查 `bash scripts/preflight.sh` 可执行且输出格式正确：
   ```bash
   bash scripts/preflight.sh | grep -q '^MODE='
   bash scripts/preflight.sh | grep -q '^CONFIG_PATH='
   ```
8. 检查 subagent 安装状态——确认 `.claude/agents/` 存在（若不存在则提示运行 `bash scripts/init-agents.sh`）

### T1-D：测试模式检测（验证 ㉑ 修复）

> **目标**：验证 preflight.sh + test-config.json 的测试模式检测逻辑——`test/test-config.json` 存在时应被读取，而非生产配置文件。

#### 步骤

> **零破坏原则**：T1-D 不修改、不备份、不破坏任何生产配置。所有判定通过观察产物落点 + 配置指纹（mtime + size）实现。

1. 确认 `test/test-config.json` 中 `obsidian_vault` 指向 `test-output/`
2. **确定生产配置路径**（按 preflight.sh 逻辑）：存在 `.claude/` → `.claude/skills/help-me-read/help-me-read.json`，否则 `~/.claude/skills/help-me-read/help-me-read.json`
3. **记录**生产配置文件的当前 mtime + size（如有）：
   ```bash
   export PROD_CONFIG=".claude/skills/help-me-read/help-me-read.json"
   [ ! -f ".claude/skills/help-me-read/help-me-read.json" ] && PROD_CONFIG="$HOME/.claude/skills/help-me-read/help-me-read.json"
   stat -c '%s %Y' "$PROD_CONFIG" > /tmp/prod_config_before 2>/dev/null
   # 或在 PowerShell 下：(Get-Item "$env:USERPROFILE\.claude\skills\help-me-read\help-me-read.json" -ErrorAction SilentlyContinue) | ForEach-Object {"{0} {1}" -f $_.Length,$_.LastWriteTime} > $env:TEMP\prod_config_before.txt
   ```
4. 跑**完整步骤 2**（课程 + 笔记 + 概念三件套全跑），而非最小流程——验证多产物路径下都走 test-config
5. **观察产物落点**：确认全部新文件（课程、笔记、概念、QA 记录）都落在 `test-output/HelpMeRead/`，而非生产 vault
6. **观察生产 vault**：确认生产 vault 目录（生产配置中 `obsidian_vault` 指向的路径）下**没有**新增任何本测试产生的文件
7. **观察配置指纹**：确认生产配置文件的 size + mtime 都未变化（双维度防 touch 误报）：

```bash
# 测试后再次记录
stat -c '%s %Y' "$PROD_CONFIG" > /tmp/prod_config_after
diff /tmp/prod_config_before /tmp/prod_config_after && echo "PASS: config untouched" || echo "FAIL: config was modified"
```

#### 判定

```
T1-D 测试模式检测报告（关联 ㉑ / F0-2）

[通过/失败] 全部产物（课程/笔记/概念/QA）落点在 test-output/HelpMeRead/
[通过/失败] 生产 vault 无本测试产生的任何文件
[通过/失败] 生产配置文件 size + mtime 都未变化（双维度防 touch 误报）
[通过/失败] test/test-config.json 被读取（产物路径匹配其 obsidian_vault）
[通过/失败] 多产物路径无混用：课程/笔记/概念三类都走 test-config

备注：________________________________
```

### 判定

```
T1 环境检查报告

[通过/失败] test/test-config.json 存在且 vault 路径有效
[通过/失败] test-output/ 目录可写
[通过/失败] PyMuPDF 可用（可选，不影响核心功能）
[通过/失败] pdfimages 可用（可选，不影响核心功能）
[通过/失败] 网络可达
[通过/失败] URI 格式正确
[通过/失败] preflight.sh 可执行且输出格式正确
[通过/失败] subagent 安装状态确认（若缺失已提示）

备注：________________________________
```

---

## T2：原文获取与类型判定

**目标**：验证步骤 1 的原文获取链、类型判定、_source.md 写入和文献速览正确。

### 步骤

1. 输入 URL `https://arxiv.org/abs/1706.03762`，确认 URL 被自动转换为 `arxiv.org/html/` 版
2. 确认抓取内容完整（有正文段落，摘要页判定为失败）
3. 确认类型判定为 **研究论文**（判据：有原创方法 + 可复现实验）
4. 确认 arxiv HTML 原图被尝试抓取
5. 确认 `_source.md` 被正确写入：
   ```bash
   SOURCE_FILE="test-output/HelpMeRead/papers/attention-is-all-you-need/_source.md"
   check "文件存在" "test -f '$SOURCE_FILE'"
   check "含 frontmatter" "head -3 '$SOURCE_FILE' | grep -q '^---'"
   check "含 slug 字段" "head -10 '$SOURCE_FILE' | grep -q '^slug:'"
   check "含 type 字段" "head -10 '$SOURCE_FILE' | grep -q '^type:'"
   check "前 3 行含论文标题" "head -30 '$SOURCE_FILE' | grep -qi 'Attention Is All You Need'"
   ```
6. 确认文献速览环节展示：
   - 步骤 1 完成后展示了 `> [!summary]+ 📄 论文速览` callout
   - 包含三段式内容：核心贡献 / 问题-方法-局限 / 核心概念概览
   - 提供了四个选项：① 完整流程 ② 只要总结 ③ 只做笔记 ④ 停止
   - 默认选择①后流程继续到步骤 2

### 判定

```
T2 原文获取与类型判定报告

[通过/失败] URL 转换正确（abs → html）
[通过/失败] 内容完整（非摘要页）
[通过/失败] 类型判定正确（research）
[通过/失败] 图片抓取已触发
[通过/失败] _source.md 已写入且 frontmatter 完整（slug/type/source）
[通过/失败] 文献速览展示（三段式内容 + 四个选项）

备注：________________________________
```

---

## T3：图片提取

**目标**：验证图片提取管线（按 `references/image-extraction.md` 优先级链）正常工作，质量控制有效。

### 步骤

1. 检查 `course/assets/` 目录是否存在，列出所有图片
2. 检查图片文件名格式（`figure-N.png`）
3. 检查图片数量：至少 1 张架构图 + 1 张结果图
4. 检查图片尺寸过滤：没有 < 100px 的噪音图
5. 检查图片引用：在课程和笔记中搜索 `![[assets/` 确认图被正确嵌入
6. 检查课程中图片标注：每张嵌入的图下方有 `*Figure N: <图题>*【第 N 页】` 标注

> **注意**：图片提取依赖运行环境（arxiv HTML 原图需网络、pdfimages 需 poppler-utils、PyMuPDF 需 python 包）。单次提取失败不一定是 bug，但"不尝试提取"就是 bug。提取优先级链详见 `references/image-extraction.md`。
>
> 本模块 agent 只检查"是否有尝试提取"、"提取结果是否符合过滤规则"、"引用是否完整"。图片**内容**是否正确（图对不对、清不清晰）需要 [人工] 查看。

### 判定

```
T3 图片提取报告

[通过/失败] assets/ 目录存在
[通过/失败] 图片命名合规（figure-N.png）
[通过/失败] 无噪音图（< 100px）
[通过/失败] 课程中图片引用完整
[通过/失败] 笔记中图片引用完整
[通过/失败] 图片标注格式正确（Figure 编号 + 页码）

[人工] 图片内容正确性（查看后填写）：
[通过/有缺/失败] 架构图提取正确
[通过/有缺/失败] 结果图提取正确
[通过/有缺/失败] 图片清晰度可接受

备注：________________________________
```

---

## T4：课程生成

**目标**：验证 course-generator subagent 生成的课程遵守所有设计规则。

### 前置条件

- 步骤 2-B 已完成（course-generator subagent 生成），课程文件已生成到 `course/` 目录
- 确认 `.claude/agents/course-generator.md` 存在且 tools 字段包含 `Read/Write/Edit/Bash/WebSearch`
- 获取实际节数 N（从课程文件列表获得）

### 步骤

1. 列出 `course/` 下所有 `*.md` 文件，确认节数 N
2. 逐节检查

---

#### T4-A：通用结构

对每一节（1..N），检查以下项：

**可跳过标注**
- 若存在前置知识则标注 `> [!skip]`，不存在则不标注
- 格式正确（"⏭ 若你已熟悉…"）

**底部导航**
- 导航是文件最后一个结构性元素
- 格式匹配 `← [[上一节]] ｜ [[下一节]] →`
- 首节（N=1）：左侧 `← 无`
- 末节（N=N）：右侧 `课程结束`
- 导航前有 `---` 分隔线

**末节收尾提醒**（仅第 N 节）
- `> [!tip]+ 🎓` callout 存在
- 内容指向"填写原子笔记定义"

---

#### T4-B：核心讲解六模块

对每一节，检查以下模块是否按顺序出现：

1. **学习目标 + 动机**（`> [!objective]+`，默认展开）
2. **核心讲解 + 类比**（`> [!analogy]+`，默认展开，暖色背景）
   - 每个新概念首次出现时加粗并带 `[[双链]]`
   - 公式用 MathJax（`$$...$$`），配套符号说明和直觉解释
   - 关键结论标注原文出处（`📎 第 N 页 / Sec.X`）
   - arxiv 出处标注做成可点击链接（链到 arxiv HTML 对应锚点）
3. **(可选) 代码实现**（有源码引用标注，如仓库名+行号）
4. **自测小问题**（`> [!quiz]`，展开，问题直接可见，答案在 `> [!answer]-` 折叠）
5. **小结 + 预告**（`> [!summary]+`，默认展开，3-5 要点 bullet）
6. **(可选) 延伸资源**（`> [!link]+`，默认展开，1-3 个外部链接）

---

#### T4-C：自测题约束（讲什么考什么）

对每一节的所有自测题，逐题检查：

对每题：
1. 提取问题 Q 和答案 A（从 `> [!answer]-` 中取）
2. 在本节"核心讲解"段落中搜索 A 中的关键信息点
3. 若每个信息点都能找到对应段落 → 通过
4. 若存在信息点找不到对应段落 → 标记为"可能越界"，记录题号

**评分**（混合模式）：
每个问题给出"答案可溯源度"评分（1-5）：
- 5：答案中的每个知识点都能在核心讲解中找到明确对应段落
- 3：大部分可找到，个别知识点需要串联多个段落理解
- 1：答案涉及的内容核心讲解中未出现

---

#### T4-D：课程完整性检查（quality-checks.md 验证）

> **目标**：验证 course-generator subagent 按 `references/quality-checks.md` 的 10 项检查执行了生成后完整性检查。取代旧版"Step 2 step 8 三条件判据"。

##### 步骤

1. 跑完整步骤 2，确认 course-generator subagent 被调用并生成课程
2. 对每个课程文件执行 `references/quality-checks.md` 中的检查（核心 8 项，agent 逐条执行）：

   ```bash
   # 1. 块配对
   for f in test-output/HelpMeRead/papers/*/course/*.md; do
     dollars=$(grep -o '\$' "$f" | wc -l)
     fences=$(grep -o '```' "$f" | wc -l)
     echo "$f: dollars=$dollars fences=$fences"
   done

   # 2-3. 末段完整句 + 末字符检查
   python3 -c "
   import os, glob
   for f in glob.glob('test-output/HelpMeRead/papers/*/course/*.md'):
       with open(f, 'rb') as fh:
           text = fh.read().decode('utf-8', errors='replace')
       tail = text[-200:] if len(text) > 200 else text
       last_char = text[-1] if text else ''
       middle_punct = set(',，:：;；、(（')
       has_complete = any(c in tail for c in ['.', '。', '!', '！', '?', '？', ';', '；', '…'])
       in_middle = last_char in middle_punct
       print(f'{os.path.basename(f)}: complete_sent={has_complete} mid_char={in_middle}')
   "
   ```

3. **检查 quality-checks 第 4 项（原子笔记双链）**：
   ```bash
   for f in test-output/HelpMeRead/concepts/*.md; do
     [ -f "$f" ] || continue
     grep -oP '\[\[([^\]|]+)' "$f" | sed 's/\[\[//' | while read target; do
       [ -f "test-output/HelpMeRead/concepts/$target.md" ] && continue
       echo "断裂双链: $target（在 $(basename "$f") 中）"
     done
   done
   ```

4. **检查 quality-checks 第 7 项（概念解释覆盖）**：
   ```bash
   for f in test-output/HelpMeRead/papers/*/course/*.md; do
     while IFS=':' read -r line_num _; do
       [ -z "$line_num" ] && continue
       context=$(sed -n "${line_num}p" "$f")
       next_line=$(sed -n "$((line_num + 1))p" "$f")
       combined="$context $next_line"
       if ! echo "$combined" | grep -qE '（[^）]{3,}）|是[一一种]|[：:].{5,}|通俗|即[，,]|means|refers to|是一种'; then
         echo "缺少解释: $(basename "$f"):${line_num}"
       fi
     done < <(grep -n '\[\[[^]|]' "$f" 2>/dev/null || true)
   done
   ```

5. **检查 quality-checks 第 8、9 项（来源标注 + 断言标签）**：
   ```bash
   python3 -c "
   import glob
   found_issues = False
   for f in glob.glob('test-output/HelpMeRead/papers/*/course/*.md'):
       with open(f) as fh:
           text = fh.read()
       # 来源标注检查
       if '📖' in text:
           refs = [l for l in text.split('\n') if '📖' in l]
           for r in refs[:3]:  # 采样前 3 条
               has_loc = any(m in r for m in ['Sec', 'Figure', 'Table', '第', '图', '表', 'Appendix'])
               if not has_loc:
                   print(f'无定位标注: {f}')
                   found_issues = True
       # 断言标签检查
       import re
       labels = set(re.findall(r'\[(背景|推断)\]', text))
       if not labels:
           print(f'未检测到语义标签: {f}（可能无不需标注的内容）')
   "
   ```

##### 判定

```
T4-D 课程完整性报告（quality-checks.md 验证）

[通过/失败] 块配对：所有课程文件 $ 个数偶数
[通过/失败] 块配对：所有课程文件 ``` 个数偶数
[通过/失败] 块配对：所有 callout 块成对
[通过/失败] 末段有完整句：所有课程末 200 字符内含完整句子
[通过/失败] 末字符不在句中：所有课程末字符不是中间/起始标点
[通过/失败] 原子笔记双链校验：所有 [[链接]] 目标在 concepts/ 下有对应文件
[通过/失败] 概念解释覆盖：所有 [[概念名]] 首次出现有自然语言解释
[通过/失败] 来源标注检查：📖 引用包含具体定位（Sec/Figure/Table）
[通过/失败] 断言标签检查：[背景]/[推断] 标签按规则标注
[通过/失败] 自动重生成：检查不通过时触发重试（上限 2 次）

备注：________________________________
```

---

#### T4-E：质量检查对接（course-generator 内部）

> **目标**：验证 course-generator subagent 在生成课程后，正确执行了 `references/quality-checks.md` 的质量检查，并处理了失败情况。

##### 步骤

1. 检查 course-generator 的 subagent 定义中引用了 `references/quality-checks.md`：
   ```bash
   grep -q 'quality-checks' .claude/agents/course-generator.md && echo "引用正确"
   ```
2. 检查课程生成过程中是否输出了质量检查报告（`10 项完整性检查` 或类似关键词）
3. 若有检查不通过的课程，确认是否标注了 `> [!WARNING] 本节完整性检查未通过`
4. 确认重试上限为 2 次，第 3 次才保留带标注版本

##### 判定

```
T4-E 质量检查对接报告

[通过/失败] course-generator 引用了 quality-checks.md
[通过/失败] 质量检查报告已生成（10 项检查）
[通过/失败] 检查不通过时触发重试（上限 2 次）
[通过/失败] 重试仍不通过时标注 [!WARNING]（不阻塞管道）

备注：________________________________
```

### 判定

```
T4 课程生成报告

课程节数：N = ____

T4-A 通用结构
[通过/失败] 可跳过标注
[通过/失败] 底部导航
[通过/失败] 末节收尾提醒

T4-B 核心模块
[通过/失败] 六模块顺序合规
[通过/失败] 核心概念首次出现加粗 + 双链
[通过/失败] 公式 MathJax + 符号说明
[通过/失败] 出处标注完整
[通过/失败] 可点击链接（arxiv）

T4-C 自测题约束
[通过/失败] 所有题目答案均可在核心讲解中找到对应段落
[通过/失败] 无跨节考察
低分题（≤3）：[无 / 题号：________]
[人工] 低分题是否需要修正：____

T4-D 课程完整性
[通过/失败] quality-checks.md 10 项检查全部执行
[通过/失败] 无截断/残余问题

T4-E 质量检查对接
[通过/失败] course-generator 正确引用了 quality-checks.md

备注：________________________________
```

---

## T5：笔记生成

**目标**：验证 note-writer subagent 生成的笔记结构、frontmatter、核心概念标注、图片嵌入符合模板要求，且 MOC 同步正确。

### 前置条件

- 确认 `.claude/agents/note-writer.md` 存在
- `HMR-<slug>.md` 已生成（步骤 2-B 完成）

### 步骤

1. 定位笔记文件 `HMR-<slug>.md`
2. 检查 frontmatter 必填字段完整（含首次生成时 `status: learning`）
3. 检查章节结构是否匹配论文类型模板
4. 检查公式格式
5. 检查出处标注规则遵守情况（标注简化规则）
6. 检查 `## 核心概念` 段落中的 `[[双链]]` 标注
7. 检查 `## 学习补充` 段落存在（内容在学后才追加，允许为空骨架）
8. 检查图片嵌入
9. 检查 MOC 同步：`HelpMeRead MOC.md` 的「按状态」表包含 `HMR-<slug>` 行

### 判定

```
T5 笔记生成报告

[通过/失败] frontmatter 字段完整
  检查：title / aliases（含作者年份） / authors（≤5人全列） / year / venue / area / type / source / status（learning） / sections / tags / up / related
[通过/失败] 章节结构匹配论文类型
[通过/失败] 公式 MathJax + 符号说明
[通过/失败] 出处标注遵守简化规则
[通过/失败] 核心概念段落标注了 [[双链]]
[通过/失败] 学习补充骨架存在
[通过/失败] 图片嵌入 + 标注格式正确
[通过/失败] MOC 同步：HelpMeRead MOC.md 按状态表含当前论文行

备注：________________________________
```

---

## T6：概念映射与骨架

**目标**：验证 concept-mapper subagent 的概念映射输出（JSON 术语三分表）和原子笔记骨架生成质量。

### 前置条件

- 确认 `.claude/agents/concept-mapper.md` 存在
- 步骤 2-A 已完成（concept-mapper 输出）
- 步骤 2-B 已生成 `concepts/` 骨架文件

### 步骤

1. 列出 `concepts/` 下所有文件
2. 对照原文，检查每个入选概念是否满足双条件：
   - (a) 原文给出定义或公式推导（不只是一句话带过）
   - (b) 在论文贡献中占有一席之地（解决某个问题、为某个结论铺路）
3. 对照原文，检查是否有"仅顺带提及"的概念被不当入选（如 SGD、Softmax 等标准术语）
4. 检查 concept-mapper 输出的 JSON 映射表质量：
   ```bash
   # 从运行日志或管线输出获取 concept-mapper 的 JSON 输出
   # 验证 JSON 合法
   echo '<映射表 JSON>' | python3 -m json.tool > /dev/null && echo "合法 JSON"
   # 验证必填字段
   echo '<映射表 JSON>' | python3 -c "
   import json, sys
   m = json.load(sys.stdin)
   required = ['slug', 'core_concepts', 'prerequisite_terms', 'background_terms', 'total_core', 'total_prerequisite', 'total_background']
   for r in required:
       assert r in m, f'缺少必填字段: {r}'
   assert m['total_core'] == len(m['core_concepts']), 'total_core 不一致'
   for c in m['core_concepts']:
       assert 'filename_slug' in c and '-' in c['filename_slug'], f'filename_slug 非 kebab-case: {c.get(\"filename_slug\")}'
       assert 'original_name' in c and 'aliases' in c
   print('所有验证通过')
   "
   ```
5. 确认每个 `core_concepts` 在 `concepts/` 下有对应骨架文件（按 `filename_slug` 匹配）
6. 确认 `prerequisite_terms` 和 `background_terms` 未建原子笔记（`concepts/` 下没有它们的 `.md`）
7. 确认"宁少勿多"：通用术语（SGD、softmax、sigmoid 等）未错误进入 `core_concepts`
8. 对每个骨架文件检查必填项

### 判定

```
T6 概念映射与骨架报告

T6-A 概念筛选
[通过/失败] 核心概念全部入选
[通过/失败] 无不满足双条件的"噪音"概念
[通过/失败] 通用术语未进入 core_concepts（宁少勿多）

T6-B 映射表质量
[通过/失败] 输出为合法 JSON
[通过/失败] 必填字段完整（slug/core_concepts/prerequisite_terms/background_terms/total_*）
[通过/失败] filename_slug 为 kebab-case
[通过/失败] total_core = core_concepts 数组长度
[通过/失败] 每个 core_concept 在 concepts/ 下有对应骨架文件
[通过/失败] prerequisite_terms 和 background_terms 未建原子笔记

骨架完整性
[通过/失败] frontmatter 字段完整（title / type:concept / defined_in / area / up / tags）
[通过/失败] ## 定义 已留空（> 你的理解：______）
[通过/失败] ## 出处 已填写（反向链接 + 页码/章节）
[通过/失败] ## 🔍 深入理解 已折叠（> [!help]-）
[通过/失败] ## 相关 已填写
[通过/失败] 可选区块按需填写（公式/结构/分析/延伸探索）

备注：________________________________
```

### T6-D：概念笔记"## 相关"区块格式

> **目标**：验证概念笔记的 `## 相关` 区块满足两个约束：(1) 每个链接附带关系说明；(2) 位置在 `## ⚖️ 分析` 与 `## 🔗 延伸探索` 之间。格式规则定义在 `references/obsidian-note-template.md`。

#### 步骤

1. 列出 `test-output/HelpMeRead/concepts/*.md` 下所有概念笔记
2. 对每个文件提取区块顺序：

```bash
# 提取所有 ## 二级标题及其顺序
for f in test-output/HelpMeRead/concepts/*.md; do
  echo "=== $f ==="
  grep -E "^## " "$f" | head -20
done
```

3. 对每个文件提取 `## 相关` 区块内容：

```bash
awk '/^## 相关/,/^## [^相关]/' test-output/HelpMeRead/concepts/self-attention.md
```

4. 检查每个链接后是否带 `——<一句话关系说明>`

#### 判定

```
T6-D 概念笔记格式报告

[通过/失败] 位置：## 相关 位于 ## ⚖️ 分析 之后
[通过/失败] 位置：## 相关 位于 ## 🔗 延伸探索 之前
[通过/失败] 关系说明：所有 [[xxx]] 后跟 ——<一句话说明>
[通过/失败] 无裸 wikilink 列表（如 [[a]]、[[b]]、[[c]] 这种逗号分隔形式）

备注：________________________________
```

---

## T7：示例嵌入

**目标**：验证示例按触发条件嵌入概念讲解，形式适合。

### 步骤

1. 逐节扫描课程文件，定位每个核心概念讲解段落
2. 对每个概念，判断其是否满足示例触发条件
3. 若满足条件，检查示例是否存在
4. 对存在的示例，检查形式和来源标注

**触发条件与示例形式**：

| 触发条件 | 示例形式 |
|----------|----------|
| 有数学公式 | 代入示例数据逐步演算，写出中间结果 |
| 有算法步骤/流程 | 用具体输入走一遍（状态变化可见） |
| 有架构图/流程图 | 从入口到出口跟踪一条数据路径 |
| 有复杂度分析 | 取具体 n 代入 O() 公式做数值对比 |
| 有对比/权衡 | 同一问题两种方案的输出差异对比 |
| 有抽象概念 | 日常类比 → 映射回技术语境 |

**评分**（混合模式）：
- 对每个示例给出"贴合度"评分（1-5）
  - 5：形式完全匹配触发条件，示例简明聚焦
  - 3：有示例但形式与触发条件匹配一般
  - 1：示例存在但看不出和概念有什么关联

### 判定

```
T7 示例嵌入报告

触发条件满足的概念数：____
实际嵌入示例的概念数：____
覆盖率：___%

[通过/失败] 有公式的概念附带了数值演算
[通过/失败] 有流程/架构的概念附带了跟踪路径
[通过/失败] 示例紧跟在对应概念之后
[通过/失败] 构造示例标注了 *✏️ 构造示例*
[通过/失败] 无硬给示例（构造不了的地方没有强行编）
示例平均贴合度：____ / 5
[人工] 低分示例（≤3）是否需要修正：____

备注：________________________________
```

---

## T8：产物结构

**目标**：验证所有产物的文件路径、命名、frontmatter 符合 `references/frontmatter-schema.md` 规范。

### 步骤

按命名约定检查每条路径：

| 产物类型 | 检查内容 |
|----------|----------|
| 文献简称 | kebab-case 英文小写，≤6 个词 |
| 文献总结笔记 | `papers/<简称>/HMR-<简称>.md` |
| 课程文件 | `papers/<简称>/course/<nn>-<概念英文名>.md` |
| 课程图资源 | `papers/<简称>/course/assets/figure-N.png` |
| 原始来源 | `papers/<简称>/_source.md` |
| 问答记录 | `papers/<简称>/qa-<YYYY-MM-DD>.md` |
| 原子笔记 | `concepts/<概念名>.md` |
| 待学习笔记 | `to-learn/<概念名>.md` |
| MOC | `HelpMeRead MOC.md` |

检查各产物 frontmatter 必填字段（按 `references/frontmatter-schema.md` 定义）：

| 产物类型 | 必填字段 |
|----------|----------|
| 文献总结笔记 | title / aliases / authors / year / venue / area / type / source / status / read_date / sections / tags / up / related |
| 课程文件 | title / course / section / prev / next |
| 原子笔记 | title / aliases / type:concept / area / defined_in / up / tags |
| 待学习笔记 | title / type:to-learn / from / raised_date / status / tags |
| MOC | type:moc / tags |

### 判定

```
T8 产物结构报告

路径约定
[通过/失败] 文献简称合规（kebab-case, ≤6 词）
[通过/失败] 笔记路径合规
[通过/失败] 课程文件路径合规（两位序号 + 概念英文名）
[通过/失败] 原子笔记路径合规
[通过/失败] 待学习笔记路径合规
[通过/失败] _source.md 路径合规（papers/<slug>/_source.md）

frontmatter
[通过/失败] 笔记 frontmatter 字段完整
[通过/失败] 课程 frontmatter 字段完整
[通过/失败] 原子笔记 frontmatter 字段完整

备注：________________________________
```

---

## T9：全流程衔接

**目标**：验证全部步骤 0→5 不断裂，步骤间衔接正确，subagent 管线运行正常，文献速览环节出现。

### 步骤

从头执行一次完整流程，每一步确认能继续下一步：

| 步骤 | 检查点 | 预期 |
|------|--------|------|
| 0 | preflight.sh 检测 + test/test-config.json 读取 | 模式检测正确（preflight.sh 输出 MODE=test），配置加载，零输出静默跳过 |
| 1 | 输入 URL → 获取全文 → 类型判定 → `_source.md` 写入 | 内容完整，类型判定正确（"研究论文"），`_source.md` 含 frontmatter |
| 1b | 文献速览展示 | `> [!summary]+ 📄 论文速览` callout 含三段式内容 + 四个选项，选择①后继续 |
| 2A | concept-mapper subagent 调用 | 调用了 `Agent(subagent_type="concept-mapper")`，输出 JSON 概念映射表，映射表冻结作为后续命名源 |
| 2B | course-generator + note-writer 并行启动 | 两者同时生成，任一先完成不阻塞另一个。课程生成完整（N 节），笔记生成完整（HMR-<slug>.md），MOC 同步完成 |
| 2B | subagent 容错 | course-generator 失败不影响 note-writer（反之亦然）。concept-mapper 失败阻止 Step 2 继续 |
| 3 | 列大纲 + 提醒待学习 | 显示 N 节标题（含可跳过条件）+ 待学习提示 |
| 4 | 打开第一节（Obsidian URI）+ 底部导航可用 | URI 语法正确，导航链接完整，首节左侧 `← 无`、末节右侧 `课程结束` |
| 5 | 概念骨架已就绪 → agent 能开始引导 | 能列出概念列表并开始第一个纠错引导 |

### 判定

```
T9 全流程衔接报告

[通过/失败] 步骤 0 preflight.sh 检测 + 配置加载正常
[通过/失败] 步骤 1 获取成功 + 类型判定正确 + _source.md 写入
[通过/失败] 步骤 1b 文献速览展示（三段式 + 四个选项）
[通过/失败] 步骤 2A concept-mapper 映射表输出（合法 JSON）
[通过/失败] 步骤 2B 并行启动（课程生成 + 笔记生成 + MOC 同步）
[通过/失败] 步骤 2B subagent 容错（一个失败不影响另一个）
[通过/失败] 步骤 3 大纲展示 + 待学习提醒
[通过/失败] 步骤 4 文件 URI 语法 + 导航链接
[通过/失败] 步骤 5 引导启动成功（概念列表可列）

总耗时：____ （可选记录）
卡点记录：________________________________

备注：________________________________
```

---

## T10：步骤 5 引导流程

**目标**：验证步骤 5 的聊天式引导逻辑完整，agent 正确执行纠错流程（分支触发 + 静默反查 + 不标步骤编号）。

### 前置条件

- T6 已通过（概念骨架存在）
- agent 需 **模拟用户角色**：在收到引导提问时，以学习者身份回复，故意包含遗漏和错误，测试分支逻辑

### 注意事项

- agent 不得在对话中输出步骤编号（如"第 1 步：评价"）
- "反查课程"应在后台静默完成，不向用户输出检索过程信号
- 合理回答（接近完整）时 agent 不应执行拆解问题

### 步骤

1. agent 从第一个概念开始引导
2. 当 agent 询问"用你自己的话说说这是什么"时：
   - **场景 A**：模拟用户给出接近完整的回答 → 检查是否跳过反查/拆解，直接展示参考答案
   - **场景 B**：模拟用户给出包含 1 处明显错误或偏离的回答 → 检查 agent 是否：

| 检查项 | 预期行为 | 验证方法 |
|--------|----------|----------|
| 评价 | 先肯定再补充，引用原文，用"补充"而非"纠正" | 检查措辞 |
| 反查课程（静默） | 内部检索，不输出"查课程"信号 | 确认无"查一下课程""让我看看原文"等显式宣布 |
| 拆解问题（仅偏离时触发） | 核心定义拆 2-3 个子问题一问一答，深度≤课程覆盖 | 检查是否拆解、子问题是否涉及一笔带过的边角内容 |
| 引导修正 | 引导用户补全遗漏后重新组织 | 检查是否让用户再说一遍 |
| 展示参考答案 | 基于原文展示标准表述供用户自评 | 检查是否展示「📖 参考答案」且不强制复制 |
| 确认填入 | 用户确认后写入文件 | 检查 `## 定义` 是否更新 |
| 回写补充层 | 纠错点追加到笔记 `## 学习补充` | 检查笔记末尾是否有追加内容 |

### 判定

```
T10 步骤 5 引导流程报告

模拟错误类型：________________
回答完整度场景：[接近完整 / 明显偏离]

[通过/失败] 0. 无步骤编号暴露（不得出现"第 N 步"）
[通过/失败] 1. 评价（肯定+补充，措辞正面）
[通过/失败] 2. 反查静默（无"查课程/看原文"等显式信号）
[通过/失败] 3. 拆解问题仅偏离时触发（接近完整时无拆解）
[通过/失败] 4. 引导修正（让用户重说）
[通过/失败] 5. 展示参考答案（展示「📖 参考答案」，用户自评）
[通过/失败] 6. 确认填入（文件已更新）
[通过/失败] 7. 回写补充层（笔记已追加）
[通过/失败] 进度显示（"已完成 X/N"）

备注：________________________________
```

---

## T11：问答

**目标**：验证问答模块的溯源准确性和回答质量。

### 步骤

1. 提出 3 个问题覆盖不同验证级别：
   - **原文级** 问题："Transformer 用了多少层 encoder？" → 应标注 `[原文]`
   - **推断级** 问题："为什么选择 Adam 而不是 SGD？" → 若原文无直接答案，应标注 `[推断]`
   - **未知级** 问题："这个模型在中文翻译任务上表现如何？" → 应标注 `[未知]` 或如实告知范围外
2. 检查回答中是否标注了来源标签
3. 检查是否附带了 `📎 依据：` 行（页码/章节）
4. 验证标签与实际内容一致

### 判定

```
T11 问答报告

[通过/失败] 原文级问题标注了 [原文·已验证] 或 [原文·未验证]
[通过/失败] 原文级问题附带页码/章节出处
[通过/失败] 推断级问题标注了 [推断]（若原文无直接答案）
[通过/失败] 未知级问题标注了 [未知] 或如实告知范围外
[通过/失败] 回答后询问"还有问题吗 / 继续学习吗"

备注：________________________________
```

---

## T12：跨论文功能

**目标**：验证跨论文去重、跨论文联系功能。

### 前置条件

- 已处理 Transformer 论文，`concepts/` 下有已存在的概念
- 再处理第二篇论文（用户指定）

### 步骤

1. 处理第二篇论文时，若其包含 Transformer 已有的概念，检查去重提示是否触发
2. 检查提示选项是否包含：追加出处 / 新建独立文件 / 跳过
3. 检查新笔记的 `related` 字段是否追加了 Transformer 引用

### 判定

```
T12 跨论文功能报告

第二篇论文：________________

[通过/失败] 概念去重提示触发
[通过/失败] 提示选项完整（追加/新建/跳过）
[通过/失败] 追加出处后 defined_in 正确更新
[通过/失败] 跨论文联系提示
[通过/失败] related 字段更新

备注：________________________________
```

---

## T13：待学习功能

**目标**：验证待学习机制的存入、生命周期和毕业流程。

### 步骤

1. **触发场景 1（显式提问）**：在课程学习中，问一个论文中未解释的概念（如"什么是 Layer Normalization？"）
2. **触发场景 2（被动提及，验证 v2.5 ⑰ 修复）**：用户说"我不懂 Layer Normalization"或"Layer Normalization 这个概念我不熟悉"——agent 应识别信号词并触发
3. **触发场景 3（纯名称提及，验证 v2.6 ㉓ 增强）**：用户只输入概念名"Layer Normalization"（无其他字符，移除标点后 ≤ 30 字符，无完整句子结构）——agent 也应触发
4. 检查 agent 是否首先给了一句话解释
5. 检查 `to-learn/` 下是否自动生成了对应笔记（不需要用户确认）
6. 检查 to-learn 笔记 frontmatter：`status: open`，`from` 指向当前论文
7. 后续选择"搜索资料"，检查 `status → exploring`
8. 后续选择"搞懂了"（毕业），检查 `status → resolved`，`resolved_to` 指向 `concepts/` 下文件

### 判定

```
T13 待学习功能报告

触发场景 1（显式提问"什么是 X"）：[触发 / 未触发]
触发场景 2（被动提及"我不懂 X"）：[触发 / 未触发]
触发场景 3（纯名称"X"）：[触发 / 未触发]

[通过/失败] 触发后先给一句话解释
[通过/失败] to-learn 笔记自动生成（未询问）
[通过/失败] frontmatter 正确（status: open, from 指向论文）
[通过/失败] 搜索后 status → exploring
[通过/失败] 毕业后 status → resolved, resolved_to 有值

备注：________________________________
```

---

## T14：临时文件清理（验证 ⑱ / F1-5 修复）

**目标**：验证步骤 1 新增的临时文件清理约束——抓取后立即清理中间 HTML 文件，不散落工作区根目录。`_source.md` 保留在 `papers/<slug>/` 下。

### 步骤

1. 在跑步骤 1 前，先记录项目根目录和 `test-output/` 的初始 `*.html` 文件清单
2. 跑完整步骤 1（抓取 arxiv HTML 或网页）
3. 跑完后再次扫描：

```bash
# 检查根目录是否有 HTML 残留
ls *.html 2>/dev/null

# 检查 test-output/ 根目录是否有 HTML 残留
ls test-output/*.html 2>/dev/null

# 检查 _source.md（唯一允许保留的原始文件）
find test-output -name "_source.md" 2>/dev/null
```

4. 预期：根目录无 `*.html`，中间 HTML 不在工作区持久保留
5. `_source.md` 仅允许一份，在 `papers/<slug>/_source.md`

### 判定

```
T14 临时文件清理报告（关联 ⑱ / F1-5）

[通过/失败] 项目根目录无 *.html 残留
[通过/失败] test-output/ 根目录无 *.html 残留
[通过/失败] _source.md 在 papers/<slug>/ 下保留（仅一份）
[通过/失败] 临时文件清理在步骤 1 完成后立即执行（不遗留到步骤 2 之后）

备注：________________________________
```

---

## T15：MOC 生命周期验证

**目标**：验证 MOC 在各管线阶段被正确创建、更新、同步。

### 前置条件

- 已处理至少一篇论文（Transformer），产物在 `test-output/HelpMeRead/`
- `test-output/HelpMeRead/HelpMeRead MOC.md` 应已存在（note-writer subagent 在步骤 2 末尾生成）

### 步骤

1. 清空产物后处理第一篇论文（Transformer），完整走到步骤 2 末尾
2. 检查 `HelpMeRead MOC.md` 是否存在，frontmatter 包含 `type: moc` 和 `tags: [moc]`，「按状态」表包含该论文一行
3. 走完步骤 4（模拟用户告知"学完了"），检查 MOC 状态列 `learning` → `learned`
4. 走完步骤 5（模拟原子笔记全部拆完），检查 MOC 状态列 `learned` → `atomized`
5. 触发 to‑learn 机制（说"我不懂 Layer Normalization"），检查 MOC 待学习表追加了对应行
6. 模拟 to‑learn 毕业（用户说"搞懂了"），检查 MOC 待学习状态列 `open` → `resolved`

### 判定

```
T15 MOC 生命周期验证报告

[通过/失败] MOC 被创建（步骤 2 后文件存在且 frontmatter 含 type:moc）
[通过/失败] 论文行已追加（MOC「按状态」表含该论文）
[通过/失败] 状态同步（步骤 4：learned）
[通过/失败] 状态同步（步骤 5：atomized）
[通过/失败] 待学习追加（MOC「待学习」表含该概念行）
[通过/失败] 待学习毕业同步（MOC 待学习状态 → resolved）

备注：________________________________
```

---

## T16：Subagent 管线测试

**目标**：验证 subagent 管线架构的核心三要素——init-agents 安装、concept-mapper 输出质量、subagent 容错。

### 前置条件

- 当前为 git 仓库根目录（确保 `.claude/agents/` 路径正确）

### T16-A：init-agents 安装

#### 步骤

1. 执行 `bash scripts/init-agents.sh`
2. 确认三个文件存在：
   ```bash
   check "concept-mapper.md" "test -f '.claude/agents/concept-mapper.md'"
   check "course-generator.md" "test -f '.claude/agents/course-generator.md'"
   check "note-writer.md" "test -f '.claude/agents/note-writer.md'"
   ```
3. 确认每个文件含 `---` frontmatter（name, description, model, tools）
   ```bash
   for f in .claude/agents/concept-mapper.md .claude/agents/course-generator.md .claude/agents/note-writer.md; do
     check "$f frontmatter" "head -3 '$f' | grep -q '^---'"
     check "$f name" "head -5 '$f' | grep -q '^name:'"
     check "$f description" "head -5 '$f' | grep -q '^description:'"
     check "$f model" "head -10 '$f' | grep -q '^model:'"
     check "$f tools" "head -15 '$f' | grep -q '^tools:'"
   done
   ```
4. 确认幂等性：重复执行 `bash scripts/init-agents.sh` 不报错、不覆盖已有文件
5. 确认 `init-agents.sh` 不修改 `.claude/agents/` 中已有的其他文件（如有）

#### 判定

```
T16-A init-agents 安装报告

[通过/失败] 三个 subagent 文件安装完成（concept-mapper / course-generator / note-writer）
[通过/失败] frontmatter 字段完整（name / description / model / tools）
[通过/失败] 幂等性：重复安装不报错、不覆盖
[通过/失败] 不修改无关文件

备注：________________________________
```

### T16-B：concept-mapper 输出质量

#### 步骤

1. 跑完整步骤 2-A，获取 concept-mapper 的 JSON 输出
2. 验证 JSON 合法性：
   ```bash
   echo '<映射表 JSON>' | python3 -m json.tool > /dev/null && echo "合法 JSON" || echo "非法 JSON"
   ```
3. 验证必填字段完整：`slug`、`core_concepts`、`prerequisite_terms`、`background_terms`、`total_core`、`total_prerequisite`、`total_background`
4. 验证每个 `core_concept` 有：`original_name`、`filename_slug`（kebab-case）、`aliases`
5. 验证 `total_core` = `core_concepts` 数组长度
6. 验证每个 `filename_slug` 在 `concepts/` 下有对应骨架文件
7. 验证 `prerequisite_terms` 和 `background_terms` 不产生原子笔记（`concepts/` 下没有它们的 `.md`）
8. 验证"宁少勿多"：通用术语（SGD、softmax 等）未错误进入 `core_concepts`
9. 验证 Transformer 论文的 core_concepts 至少包含：self-attention（合理预期）

#### 判定

```
T16-B concept-mapper 输出质量报告

[通过/失败] 输出为合法 JSON
[通过/失败] 必填字段完整（slug / core_concepts / prerequisite_terms / background_terms / total_*）
[通过/失败] slug 与论文一致
[通过/失败] filename_slug 为 kebab-case
[通过/失败] each core_concept 有对应骨架文件
[通过/失败] total_core = core_concepts 数组长度
[通过/失败] 通用术语未进入 core_concepts
[通过/失败] prerequisite / background 未建原子笔记

备注：________________________________
```

### T16-C：subagent 容错测试

> **说明**：以下为验证性测试——确认管线在有 subagent 失败时的行为。模拟失败可通过注入非法的 subagent 输入或移除 subagent 实现。

#### 步骤

1. **course-generator 失败时的行为**：
   - 模拟 course-generator 调用失败（如向其传入空的映射表）
   - 验证：course-generator 失败不会影响 note-writer（笔记仍生成）
   - 验证：错误信息被向用户报告，非静默吞掉
   - 验证：course-generator 重试上限 2 次后仍未通过则跳过并报告

2. **note-writer 失败时的行为**：
   - 模拟 note-writer 调用失败
   - 验证：note-writer 失败不影响 course-generator（课程仍生成）
   - 验证：错误信息被向用户报告

3. **concept-mapper 失败时的行为**：
   - 模拟 concept-mapper 调用失败（如向其传入空原文）
   - 验证：concept-mapper 失败会阻止步骤 2 继续（不启动 course-generator + note-writer）
   - 验证：提示用户重试或调试

#### 判定

```
T16-C subagent 容错报告

[通过/失败] course-generator 失败不影响 note-writer
[通过/失败] note-writer 失败不影响 course-generator
[通过/失败] concept-mapper 失败阻止步骤 2 继续
[通过/失败] 错误信息被报告（非静默）
[通过/失败] course-generator 重试次数正确（上限 2 次）

备注：________________________________
```

---

## T17：参考文件交叉引用一致性

**目标**：验证各 reference 文件之间的交叉引用一致性，确保 subagent 引用的 reference 不存在断裂。

### 步骤

1. 扫描 `.claude/agents/*.md`，提取所有引用 `references/xxx.md` 的路径：
   ```bash
   for f in .claude/agents/concept-mapper.md .claude/agents/course-generator.md .claude/agents/note-writer.md; do
     [ -f "$f" ] || continue
     grep -oP 'references/[a-zA-Z0-9_-]+\.md' "$f"
   done | sort -u
   ```
2. 确认每个被引用文件存在（`references/` 下有对应文件）：
   ```bash
   for ref in $(grep -roh 'references/[a-zA-Z0-9_-]\+\.md' .claude/agents/ 2>/dev/null | sort -u); do
     test -f "$ref" && echo "✅ $ref 存在" || echo "❌ $ref 缺失"
   done
   ```
3. 检查 `references/quality-checks.md` 中的标题/检查项是否与 `course-generator.md` 中描述的"10 项检查"一致
4. 检查 `references/image-extraction.md` 中的规则是否被 SKILL.md 步骤 1 正确引用
5. 检查 `references/frontmatter-schema.md` 中的命名约定是否与 `verify.sh` 中使用的路径一致
6. 扫描每个 reference 文件中是否引用其他 reference 文件，引用关系无断裂：
   ```bash
   for ref in references/*.md; do
     echo "=== $ref ==="
     grep -oP 'references/[a-zA-Z0-9_-]+\.md' "$ref" 2>/dev/null
   done
   ```

### 判定

```
T17 参考文件一致性报告

[通过/失败] 所有被引用的 reference 文件存在（subagent → references/）
[通过/失败] quality-checks.md 10 项与 course-generator.md 引用一致
[通过/失败] image-extraction.md 规则被 SKILL.md 正确引用
[通过/失败] frontmatter-schema.md 命名约定与 verify.sh 路径一致
[通过/失败] reference 间交叉引用无断裂

断裂详情：________________________________

备注：________________________________
```

---

## 测试报告格式

测试完成后，agent 输出完整报告。

```markdown
## Help Me Read 测试报告

**日期**：YYYY-MM-DD
**版本/commit**：___________
**执行模块**：T1 T4 T7 T8 ...
**测试配置**：test/test-config.json（vault: test-output/）

### 汇总

| 模块 | 结果 |
|------|------|
| T1 环境检查 | ✅ / ❌ / ⏭ 跳过 |
| T2 原文获取 | ✅ / ❌ / ⏭ 跳过 |
| T3 图片提取 | ⚠️ 部分通过 |
| T4 课程生成 | ✅ |
| ... | ... |

### 失败明细

**T4-C 第 2 节第 1 题 — 失败**：
- 问题：___________
- 分析：答案中"X 概念"未在核心讲解中出现
- 建议：补充讲解或修改题目

### 待人工裁决

- T3 图片内容 → [人工] 查看并填写
- T7 示例贴合度 → [人工] 低分示例需确认

### 结论
[通过 / 有条件通过 / 不通过]
```

---

全流程 0→5 无断裂，所有产物符合命名约定和 frontmatter 规范。
