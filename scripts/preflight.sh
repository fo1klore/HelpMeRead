#!/bin/bash
# scripts/preflight.sh — Help Me Read 模式检测
# 输出 MODE 和 CONFIG_PATH，agent 据此决定走测试还是生产路径
#
# 优先级（先命中先走）：
#   1. HELP_ME_READ_MODE 环境变量（test | production，非法值报错退出）
#   2. .test-mode 文件存在（gitignored，本地持久开关）
#   3. 默认生产模式

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
TEST_CONFIG="$PROJECT_ROOT/test/test-config.json"

# ── 生产配置路径 ──
# 检测是否以 skill 方式安装（在 .claude/skills/ 目录内）。
# 开发时 PROJECT_ROOT 为用户工程目录，路径为 PROJECT_ROOT/.claude/skills/...；
# 安装时 PROJECT_ROOT 本身就在 .claude/skills/help-me-read/ 下，再嵌一层导致嵌套重复。
if [[ "$PROJECT_ROOT" == *".claude/skills/"* ]]; then
  PROD_CONFIG="$PROJECT_ROOT/help-me-read.json"
else
  PROD_CONFIG="$PROJECT_ROOT/.claude/skills/help-me-read/help-me-read.json"
fi

# 第 1 层：环境变量（最高优先级，显式会话级覆盖）
if [ -n "$HELP_ME_READ_MODE" ]; then
  case "$HELP_ME_READ_MODE" in
    test)
      echo "MODE=test"
      echo "CONFIG_PATH=$TEST_CONFIG"
      exit 0
      ;;
    production)
      echo "MODE=production"
      echo "CONFIG_PATH=$PROD_CONFIG"
      exit 0
      ;;
    *)
      echo "ERROR: HELP_ME_READ_MODE must be 'test' or 'production', got '$HELP_ME_READ_MODE'" >&2
      exit 1
      ;;
  esac
fi

# 第 2 层：.test-mode 标记文件（gitignored，开发者本地持久开关）
if [ -f "$PROJECT_ROOT/.test-mode" ]; then
  echo "MODE=test"
  echo "CONFIG_PATH=$TEST_CONFIG"
  exit 0
fi

# 第 3 层：默认生产模式
echo "MODE=production"
echo "CONFIG_PATH=$PROD_CONFIG"
