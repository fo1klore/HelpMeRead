#!/bin/bash
# scripts/check-deps.sh — Help Me Read 图片提取依赖检测
# 输出可用工具清单，agent 据此查表选择最优提取路径

echo "NETWORK=$(curl -s -o /dev/null -w "%{http_code}" https://arxiv.org 2>/dev/null || echo "FAIL")"
echo "PDFIMAGES=$(which pdfimages 2>/dev/null && echo "YES" || echo "NO")"
echo "PYMUPDF=$(python3 -c 'import fitz; print("YES")' 2>/dev/null || echo "NO")"
echo "PANDOC=$(which pandoc 2>/dev/null && echo "YES" || echo "NO")"
echo "GS=$(which gs 2>/dev/null && echo "YES" || echo "NO")"
