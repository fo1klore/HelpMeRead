# 检测命令速查（按需加载）

> 从 `references/failure-modes.md` 附录拆出。仅在排查问题时读取。

---

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
