---
title: "Positional Encoding"
type: to-learn
from:
  - "[[HMR-attention-is-all-you-need]]"
raised_date: 2026-06-22
status: open
resolved_to: []
tags:
  - to-learn
---

# 待学习：Positional Encoding

- 出自 [[HMR-attention-is-all-you-need]] 第 6 页 Sec.3.5
- 💡 让 Transformer 知道词序的技术——用正弦和余弦函数给每个位置生成一个独特的向量，然后直接加到词嵌入上。因为自注意力不关心顺序，必须显式注入位置信息。
