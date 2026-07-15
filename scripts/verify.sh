#!/bin/bash
# scripts/verify.sh — Help Me Read 一键产物验证
ERRORS=0
TEST_DIR="test-output/HelpMeRead"
if [ -n "$1" ]; then
  TEST_DIR="$1"
fi
red() { printf '\033[31m%s\033[0m\n' "$1"; }
green() { printf '\033[32m%s\033[0m\n' "$1"; }
check() {
  local desc="$1"; shift
  if eval "$@" 2>/dev/null; then
    green "  ✅ $desc"
  else
    red "  ❌ $desc"
    ERRORS=$((ERRORS + 1))
  fi
}
echo "========================================="
echo " Help Me Read —— 产物验证"
echo " 目标目录: $TEST_DIR"
echo "========================================="
echo ""
echo "--- 结构检查 ---"
check "产物根目录存在" "test -d '$TEST_DIR'"
check "papers/ 目录存在" "test -d '$TEST_DIR/papers'"
check "concepts/ 目录存在" "test -d '$TEST_DIR/concepts'"
echo ""
echo "--- Frontmatter 检查 ---"
for md_file in "$TEST_DIR"/papers/*/HMR-*.md "$TEST_DIR"/concepts/*.md; do
  [ -f "$md_file" ] || continue
  fname="$(basename "$md_file")"
  check "$fname 以 --- 开头" "head -1 '$md_file' | grep -q '^---'"
  check "$fname 有 title 字段" "head -10 '$md_file' | grep -q '^title:'"
done
echo ""
echo "--- Callout 格式检查 ---"
for md_file in "$TEST_DIR"/papers/*/HMR-*.md "$TEST_DIR"/concepts/*.md "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$md_file" ] || continue
  fname="$(basename "$md_file")"
  opens=$(grep -c '^>[[:space:]]*\[!' "$md_file" 2>/dev/null || echo 0)
  total_block=$(grep -c '^>' "$md_file" 2>/dev/null || echo 0)
  if [ "$opens" -gt 0 ] && [ "$total_block" -gt 0 ]; then
    green "  ✅ $fname: $opens 个 callout"
  elif [ "$opens" -gt 0 ]; then
    red "  ❌ $fname: 有 callout 标记但无内容"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""
echo "--- 图片检查 ---"
for img in "$TEST_DIR"/papers/*/course/assets/*.png "$TEST_DIR"/papers/*/course/assets/*.jpg "$TEST_DIR"/papers/*/course/assets/*.jpeg; do
  [ -f "$img" ] || continue
  iname="$(basename "$img")"
  dims=$(file --mime-type "$img" 2>/dev/null)
  if echo "$dims" | grep -q 'image/'; then
    green "  ✅ $iname (有效图片)"
  else
    red "  ❌ $iname (非图片文件)"
    ERRORS=$((ERRORS + 1))
  fi
done
echo ""
echo "--- 概念首次出现解释检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  # 每个 [[概念名]] 所在行或其相邻行应有解释内容（括号、判断句等）
  while IFS=':' read -r line_num _; do
    [ -z "$line_num" ] && continue
    context=$(sed -n "${line_num}p" "$course_file")
    next_line=$(sed -n "$((line_num + 1))p" "$course_file")
    combined="$context $next_line"
    if echo "$combined" | grep -qE '（[^）]{3,}）|是[一一种]|[：:].{5,}|通俗|即[，,]|means|refers to|是一种'; then
      :  # 有解释内容
    else
      red "  ❌ $fname:${line_num} [[概念]] 附近缺少解释"
      ERRORS=$((ERRORS + 1))
    fi
  done < <(grep -n '\\[\\[[^]|]' "$course_file" 2>/dev/null || true)
done
echo ""
echo "--- 可跳过标注位置检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  skip_line=$(grep -n '\[!skip\]' "$course_file" 2>/dev/null | head -1 | cut -d: -f1)
  if [ -n "$skip_line" ]; then
    total=$(wc -l < "$course_file")
    if [ "$skip_line" -gt $((total / 5)) ]; then
      red "  ❌ $fname: [!skip] 位于第 $skip_line/${total} 行（应在前 20%）"
      ERRORS=$((ERRORS + 1))
    else
      green "  ✅ $fname: [!skip] 位于第 $skip_line/${total} 行 ✅"
    fi
  else
    echo "  ℹ️ $fname 无 [!skip] 标注（此项非强制）"
  fi
done
echo ""
echo "--- 表格竖杠一致性检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  awk -v fname="$fname" '
    BEGIN { in_table=0; ref_count=0; errors=0; }
    /^\|/ {
      in_table++;
      count=gsub(/\|/, "|");
      if (in_table == 2) ref_count=count;
      if (in_table >= 3 && count != ref_count) {
        printf "  ❌ %s:%d 竖杠数 %d ≠ 预期 %d（可能含未转义字面 |）\n", fname, NR, count, ref_count > "/dev/stderr"
        errors++;
      }
      next;
    }
    { in_table=0; }
    END { exit errors ? 1 : 0; }
  ' "$course_file" 2>&1 1>/dev/null && green "  ✅ $fname 表格竖杠数一致" || red "  ❌ $fname 表格中有未转义竖杠"
done
echo ""
echo "--- 公式 MathJax 覆盖检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  issues=$(awk '
    BEGIN { in_code=0; }
    /^```/ { in_code=!in_code; next; }
    in_code { next; }
    /^\$/ { next; }
    {
      line=$0;
      gsub(/\$[^$]*\$/, "", line);
      if (line ~ /[μσ∑αβγθλπ∈∉⊂⊆∩∪∀∃⊥∇∂≈∼≠≡≤≥∞]/) {
        printf "%s:%d: %s\n", FILENAME, NR, $0 > "/dev/stderr"
      }
    }
  ' "$course_file" 2>&1 >/dev/null || true)
  if [ -n "$issues" ]; then
    count=$(echo "$issues" | wc -l)
    red "  ❌ $fname: $count 处数学符号未被 \$ 包裹"
    ERRORS=$((ERRORS + 1))
  else
    green "  ✅ $fname 数学符号均已 MathJax 包裹"
  fi
done

echo ""
echo "--- 代码块内公式检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  issues=$(awk '
    BEGIN { in_backtick=0; }
    /^```/ { in_backtick=!in_backtick; next; }
    in_backtick && /[μσ∑αβγθλπ∈∉⊂⊆∩∪∀∃⊥∇∂≈∼≠≡≤≥∞]/ {
      printf "%s:%d: %s\n", FILENAME, NR, $0 > "/dev/stderr"
    }
  ' "$course_file" 2>&1 >/dev/null || true)
  if [ -n "$issues" ]; then
    count=$(echo "$issues" | wc -l)
    red "  ❌ $fname: $count 处代码块中包含数学符号"
    ERRORS=$((ERRORS + 1))
  else
    green "  ✅ $fname 代码块中无数学符号"
  fi
done

echo ""
echo "--- Heading 公式缺失检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  issues=$(awk '
    /^#/ {
      line=$0;
      if (line ~ /[μσ∑αβγθλπ∈∉⊂⊆∩∪∀∃⊥∇∂≈∼≠≡≤≥∞]/ && line !~ /\$/) {
        printf "%s:%d: %s\n", FILENAME, NR, $0 > "/dev/stderr"
      }
    }
  ' "$course_file" 2>&1 >/dev/null || true)
  if [ -n "$issues" ]; then
    count=$(echo "$issues" | wc -l)
    red "  ❌ $fname: $count 处 heading 含数学符号但无 \$ 包裹"
    ERRORS=$((ERRORS + 1))
  else
    green "  ✅ $fname heading 公式均已 \$ 包裹"
  fi
done
echo ""
echo "--- 来源标注检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  # 检查 📖 引用是否包含具体定位信息
  has_ref=$(grep '📖' "$course_file" 2>/dev/null || true)
  if [ -n "$has_ref" ]; then
    check "$fname 📖 引用有具体定位(章节/图号)" "echo '$has_ref' | head -5 | grep -qE '(Sec|Figure|Table|第.*页|图|表|章节|Appendix|Section)'"
  else
    echo "  ℹ️ $fname 无 📖 引用（此项非强制）"
  fi
done
echo ""
echo "--- 语义标签检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  tags=$(grep -E '\[背景\]|\[推断\]' "$course_file" 2>/dev/null || true)
  if [ -n "$tags" ]; then
    tag_count=$(echo "$tags" | wc -l)
    green "  ✅ $fname: $tag_count 处带语义标签"
  else
    echo "  ⚠️ $fname 未检测到[背景]/[推断]标签（此项非强制，若课程无不需标注的内容可忽略）"
  fi
done
echo ""
echo "--- MOC 一致性检查 ---"
MOC_FILE="$TEST_DIR/HelpMeRead MOC.md"
check "MOC 文件存在" "test -f '$MOC_FILE'"
check "MOC frontmatter 含 type:moc" "head -5 '$MOC_FILE' 2>/dev/null | grep -q 'type: moc'"
if [ -f "$MOC_FILE" ]; then
  python3 -c "
import os, re, sys
moc = open('$MOC_FILE').read()
moc_refs = set(re.findall(r'\\[\\[(HMR-[^\\]|]+)', moc))
actual_dirs = set()
papers_dir = '$TEST_DIR/papers'
if os.path.isdir(papers_dir):
    for d in os.listdir(papers_dir):
        if os.path.isdir(os.path.join(papers_dir, d)):
            actual_dirs.add(f'HMR-{d}')
missing = actual_dirs - moc_refs
extra = moc_refs - actual_dirs
if missing:
    print(f'MOC 缺少论文行: {missing}')
    sys.exit(1)
if extra:
    print(f'MOC 有多余引用 (可能是用户自定义行): {extra}')
" && green "  ✅ MOC 论文引用与 papers/ 目录一致" || red "  ❌ MOC 论文引用与 papers/ 目录不一致"
fi
echo ""
echo "--- Subagent 检查 ---"
check "concept-mapper agent 存在" "test -f '.claude/agents/concept-mapper.md'"
check "course-generator agent 存在" "test -f '.claude/agents/course-generator.md'"
check "note-writer agent 存在" "test -f '.claude/agents/note-writer.md'"
echo ""
echo "--- 原始来源检查 ---"
for source in "$TEST_DIR"/papers/*/_source.md; do
  [ -f "$source" ] || continue
  sname=$(basename "$(dirname "$source")")
  check "$sname _source.md 存在" "test -f '$source'"
  check "$sname _source.md 含 frontmatter" "head -5 '$source' | grep -q '^---'"
  check "$sname _source.md 含 slug 字段" "head -10 '$source' | grep -q '^slug:'"
done
echo ""
echo "========================================="
if [ $ERRORS -eq 0 ]; then
  green "  🎉 全部检查通过"
else
  red "  ❌ $ERRORS 项检查失败"
fi
echo "========================================="
exit $ERRORS
