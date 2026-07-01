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
for md_file in "$TEST_DIR"/papers/*/notes/*.md "$TEST_DIR"/concepts/*.md; do
  [ -f "$md_file" ] || continue
  fname="$(basename "$md_file")"
  check "$fname 以 --- 开头" "head -1 '$md_file' | grep -q '^---'"
  check "$fname 有 title 字段" "head -10 '$md_file' | grep -q '^title:'"
done
echo ""
echo "--- Callout 格式检查 ---"
for md_file in "$TEST_DIR"/papers/*/notes/*.md "$TEST_DIR"/concepts/*.md "$TEST_DIR"/papers/*/lessons/*.md; do
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
echo "--- 概念热身检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  check "$fname 包含核心概念热身callout" "grep -q '🏋️.*核心概念' '$course_file'"
  check "$fname 包含前置术语热身callout" "grep -q '🧭.*前置术语' '$course_file'"
done
echo ""
echo "--- 概念双链解释检查 ---"
for course_file in "$TEST_DIR"/papers/*/course/*.md; do
  [ -f "$course_file" ] || continue
  fname=$(basename "$course_file")
  first_link=$(grep -n '\\[\\[' "$course_file" 2>/dev/null | head -1 | cut -d: -f1)
  if [ -n "$first_link" ] && [ "$first_link" -gt 1 ]; then
    check "$fname 概念首次出现前有预热解释" "head -\$((first_link - 1)) '$course_file' | grep -q '核心概念\|前置术语\|通俗解释\|一句话'"
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
echo "========================================="
if [ $ERRORS -eq 0 ]; then
  green "  🎉 全部检查通过"
else
  red "  ❌ $ERRORS 项检查失败"
fi
echo "========================================="
exit $ERRORS
