---
title: "Self-Attention"
aliases:
  - 自注意力
  - intra-attention
  - Scaled Dot-Product Attention
type: concept
area:
  - attention
defined_in:
  - "[[HMR-attention-is-all-you-need]]"
up:
  - "[[Attention]]"
tags:
  - concept/attention
---

# Self-Attention

## 定义
> 你的理解：______（用自己的话说）

> 💡 **提示：** 用一两句自己的话讲清楚 self-attention 在做什么。不需要复述公式——说说你理解的"直觉"：Q、K、V 各扮演什么角色？整个计算流程在解决什么问题？

## 出处
- [[HMR-attention-is-all-you-need]] 第 4 页 Sec.3.2.1

## 相关
- [[multi-head-attention]]——Self-attention 的多头扩展，将 Q/K/V 投影到多个子空间并行计算
- [[scaled-dot-product-attention]]——Self-attention 的核心运算，点积 + 缩放 + softmax
- [[positional-encoding]]——为 self-attention 补充序列位置信息，使其能区分 token 顺序
