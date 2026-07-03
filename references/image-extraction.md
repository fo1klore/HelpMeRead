# 图片提取指南（按需加载）

> SKILL.md 步骤 1 的图片提取细则是从本文件衍生。agent 在步骤 1 执行图片提取前读取本文件。

---

## 依赖统一检测

执行 `bash scripts/check-deps.sh`，根据输出决定最优提取路径。输出格式为 `KEY=VALUE`，每行一个。

## 提取优先级（自动降级，不卡流程）

1. **arxiv HTML 原图**（优先）：若论文有 arxiv 版本，优先从 HTML 版抓取 `<img>` 原图（作者上传的原始 PNG/PDF，质量最佳）
2. **pdfimages 提取 PDF 内嵌图**（优先于 PyMuPDF）：poppler-utils 的 `pdfimages` 返回的 bbox 通常更准确。先检测 poppler-utils 是否可用：
   - 已安装 → 用 `pdfimages -png` 提取所有内嵌图；**禁用 pdftoppm**
   - 未安装 → 提示安装（macOS: `brew install poppler`，Linux: `apt install poppler-utils`，Windows: 手动下载 poppler）
     - 安装成功 → 继续
     - 安装失败 → 自动降级到路径 3
3. **PyMuPDF 提取 PDF 内嵌图**：检测 PyMuPDF 是否可用：
   - 已安装 → 用 `page.get_images()` 提取。**用图片自身的 bbox 作为 clip 矩形**，**禁用 `page.get_pixmap()` 做整页截图**。若内嵌图原始尺寸 ≤ 200px，**不做 2x 放大**
   - 未安装 → 提示 `pip install PyMuPDF`
     - 安装成功 → 继续
     - 安装失败 → 自动降级到路径 4
4. **矢量图回退**：`get_images()` 返回 0 张有效图时，用 `page.get_drawings()` 检测矢量图形。若有，从原文推断 Figure 所在页码/区域，做**限定 clip 渲染**——clip 矩形严格限定为图/表所在区域，**严禁渲染整页**。矢量图渲染倍率 2x
5. **全部失败**：告知用户「自动提取失败，你可以手动截图保存到 `course/assets/` 目录，然后告诉我"重新嵌入图片"」。课程中标注「📎 参见原文 Figure N」——**严禁用 ASCII art 或文字描述臆造示意图**

## 图片质量控制（提取后、落盘前）

1. **尺寸下限过滤**：丢弃长或宽 < 100px 的图
2. **尺寸上限过滤**：丢弃图宽 > 页面宽度 × 80% **且** 图高 > 页面高度 × 80% 的图
3. **纸张比例过滤**：若图宽高比接近 A4/US Letter 比例（1.25–1.45）且尺寸 > 页面 60%，标记为可疑（可能是跨页大图，不自动丢弃）
4. **文字边缘裁切**：渲染后检查图片左右两侧是否有大块同色像素，若有则向内收缩边界后重新裁切
5. **按需落盘**：只把确定要嵌入课程/笔记的图存入 `papers/<文献简称>/course/assets/`，其余当场丢弃
6. **噪音清理**：课程 + 笔记全部生成完毕后，扫描 `assets/`，删除未被任何 `![[...]]` 引用的残留图

每张成功提取的图标注 Figure 编号 + 页码，存入 `papers/<文献简称>/course/assets/figure-N.png`，课程中用 `![[assets/figure-N.png]]` 嵌入。表格不提取（极其困难），用文字描述 + 标注原文表号。

## 提取策略

- **公式**：arxiv HTML 版中公式可能以 `<svg>` 或 MathJax 呈现。若提取失败，以 MathJax（`$$...$$`）手写重现，标注 `*📎 公式重绘*`
- **页面**：arxiv URL 自动转为 `arxiv.org/html/` 版（优先 HTML 全文），无 HTML 版再转 `arxiv.org/pdf/<id>`。DOI 链接尝试解析到全文页，遇付费墙则提示用户提供可访问的 PDF
- **临时文件**：抓取过程产生的中间文件立即删除。若需保留原始内容，存入 `papers/<简称>/_source.html`（仅一个文件）。URL 下载的 PDF 在提取完成后立即删除（用户提供的本地 PDF 永久保留）

## 边缘情况统一兑底

- 扫描版 PDF（图片型，无文本层）→ 提示用户找原生 PDF 或 HTML 版
- 付费墙 → 提示用户提供 PDF，建议 unpaywall 或作者主页找 OA 版
- 超长论文（50+ 页）→ 分批抓取/分节处理
- JS 渲染页面 → 提示动态渲染页抓取失败，建议提供 PDF

## 检测命令

```bash
# PDF 提取
pip list 2>/dev/null | grep PyMuPDF
which pdfimages 2>/dev/null
identify course/assets/*.png       # 查看实际尺寸

# 内容量
curl -sI "https://arxiv.org/html/XXXX.XXXXX" | grep -i "content-length"

# 残留文件
ls *.html 2>/dev/null
find . -maxdepth 2 -name "*.pdf" -not -path "./references/*" 2>/dev/null
```
