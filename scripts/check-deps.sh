#!/bin/bash
# scripts/check-deps.sh — Help Me Read 图片提取依赖检测
# 输出可用工具清单，agent 据此查表选择最优提取路径
#
# 输出契约：一行一个 KEY=VALUE，VALUE 为 YES / NO / 数字 / 路径。
# 禁止出现跨行的值（旧版 `$(which X && echo YES)` 会把路径和 YES 打成两行）。

have() { command -v "$1" >/dev/null 2>&1; }

# yesno <cmd> [args...] → YES / NO
yesno() {
    if "$@" >/dev/null 2>&1; then echo YES; else echo NO; fi
}

# python 解释器：Windows 上通常只有 python / py，没有 python3
PY=""
if have python3; then
    PY="$(command -v python3)"
elif have python; then
    PY="$(command -v python)"
fi

# 网络探测：curl 缺失或超时都要给出确定值，不能挂住 agent
NET="FAIL"
if have curl; then
    code="$(curl -s -o /dev/null --max-time 5 -w '%{http_code}' https://arxiv.org 2>/dev/null)" || code=""
    case "$code" in
        [0-9][0-9][0-9]) NET="$code" ;;
        *)                NET="FAIL" ;;
    esac
fi

echo "NETWORK=$NET"
echo "PDFIMAGES=$(yesno have pdfimages)"
if [ -n "$PY" ]; then
    echo "PYMUPDF=$(yesno "$PY" -c 'import fitz')"
else
    echo "PYMUPDF=NO"
fi
echo "PYTHON=${PY:-NO}"
