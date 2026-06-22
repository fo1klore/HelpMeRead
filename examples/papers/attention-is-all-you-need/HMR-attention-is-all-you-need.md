---
title: "Attention Is All You Need"
aliases:
  - Transformer
  - Vaswani 2017
  - 注意力即你所需
authors:
  - Ashish Vaswani
  - Noam Shazeer
  - Niki Parmar
  - et al.
year: 2017
venue: NeurIPS
area:
  - attention
  - sequence-modeling
  - machine-translation
type: research
source: "https://arxiv.org/abs/1706.03762"
pdf: ""
status: learning
read_date: 2026-06-22
progress: 4
last_section: "04-results-and-impact"
sections: 4
tags:
  - paper/transformer
  - paper/attention
up:
  - "[[HelpMeRead MOC]]"
related: []
---

# Attention Is All You Need HMR

## 📌 一句话概述
提出 Transformer——第一个完全基于自注意力机制、不依赖循环和卷积的序列转导模型。在机器翻译任务上达到 28.4 BLEU，训练速度比 SOTA 快一个数量级，彻底改变了 NLP 和 AI 的方向。

## 1. 背景与动机
- 序列建模被 RNN/LSTM/GRU 统治，但 RNN 的串行结构导致无法并行训练，长距离依赖在传播中衰减【第 1 页 / 引言】
- 注意力机制此前只作为 RNN 的辅助组件（如 Bahdanau 2014），从未被当作唯一的建模手段【第 2 页 / Sec.2】

## 2. 问题定义
- 序列转导（sequence transduction）：将输入序列 $x_1...x_n$ 映射为输出序列 $y_1...y_m$【第 3 页 / Sec.3.1】
- 编码器将输入编码为连续表示 $\mathbf{z}$，解码器在 $\mathbf{z}$ 上逐位置生成输出【第 3 页 / Sec.3.1】

## 3. 方法（含公式）
- 核心机制：Scaled Dot-Product Attention
  $$\text{Attention}(Q, K, V) = \text{softmax}\left(\frac{QK^T}{\sqrt{d_k}}\right)V$$
  - 符号说明：$Q$（Query）提问、$K$（Key）打标签、$V$（Value）带内容。三个矩阵来自同一输入经不同线性投影
  - $\sqrt{d_k}$ 缩放防止点积方差过大导致 Softmax 饱和、梯度消失【第 4 页 / Sec.3.2.1, 脚注 4】
- 多头注意力：$h=8$ 个并行头各学不同子空间，每头维度 $d_k=d_v=64$
  $$\text{MultiHead}(Q,K,V) = \text{Concat}(\text{head}_1,...,\text{head}_h) W^O$$
  $$\text{head}_i = \text{Attention}(Q W_i^Q, K W_i^K, V W_i^V)$$
  【第 5 页 / Sec.3.2.2】
- 位置编码用正弦函数注入顺序信息
  $$PE_{(pos, 2i)} = \sin(pos/10000^{2i/d_{model}})$$
  $$PE_{(pos, 2i+1)} = \cos(pos/10000^{2i/d_{model}})$$
  选正弦而非可学习嵌入：支持外推移长序列、任意偏移 $k$ 的 $PE_{pos+k}$ 可表示为 $PE_{pos}$ 的线性函数【第 6 页 / Sec.3.5】
- 架构：编码器-解码器各 $N=6$ 层；每个子层包裹残差连接 + 层归一化；前馈网络 $d_{ff}=2048$【第 3 页 / Sec.3.1】

## 4. 实验
- 数据集：WMT 2014 英德（4.5M 句对）和英法（36M 句对）【第 7 页 / Sec.5】
- 基线方法：ConvS2S、GNMT+RL、MoE 等当时 SOTA【第 7 页 / Sec.5, Table 2】
- 关键结果：Transformer (big) 英德 28.4 BLEU，英法 41.0 BLEU，全面超越所有模型（包括集成模型），训练成本仅为最优模型的 1/4【第 7 页 / Table 2】
- 消融分析（第 9 页 / Table 3）：单头 24.9→8 头 25.8 BLEU；无 Dropout 降 1.2 BLEU；正弦 ≈ 可学习 PE（25.8 vs 25.7）【第 9 页 / Sec.6.2】

## 5. 结论与局限
- 主要贡献：首次完全基于注意力的序列转导模型，训练更快、效果更好、可泛化到解析等任务【第 10 页 / Sec.7】
- 局限性：自注意力 $O(n^2)$ 复杂度限制超长序列；解码仍为自回归；仅验证文本模态【第 10 页 / Sec.7】

## 6. 相关工作
- RNN/LSTM/GRU 序列建模谱系【第 1 页 / Sec.1】
- Bahdanau 等人 2014 提出注意力用于 MT 对齐【第 2 页 / Sec.2】
- 卷积用于序列建模：ByteNet、ConvS2S【第 2 页 / Sec.2】
- 可学习位置嵌入：Gehring 等人 2017【第 6 页 / Sec.3.5】
- 自注意力前期探索：Lin 等人 2017（intra-sentence attention）【第 2 页】

## 🔗 术语
- [[self-attention]]、[[multi-head-attention]]、[[positional-encoding]]、[[scaled-dot-product-attention]]、[[residual-connection]]、[[layer-normalization]]、[[encoder-decoder]]

## 📝 学习补充
<!-- 课程学完后由 agent 追加，只增不改。以下为示例内容 -->

### 💡 深挖与澄清
- 【第 2 节 · 自注意力机制】用户追问 $\sqrt{d_k}$ 的数学推导，展开为详细方差分析 [背景]
- 【第 3 节 · 位置编码】正弦函数的线性关系（$PE_{pos+k} = f(PE_{pos})$）值得单独写一篇证明 [推断]

### ❓ 学习中的疑问
- [[positional-encoding]]（已加入 to-learn，对初始方案有疑问）[背景]

### 🔗 跨论文联系
- 暂无（这是已读的第一篇注意力机制论文）
