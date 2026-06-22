---
title: "第 4 节：实验结果与影响"
course: "[[HMR-attention-is-all-you-need]]"
section: 4
prev: "[[03-multi-head-and-position]]"
---

# 第 4 节：实验结果*与影响*

> Transformer 不只是理论优美——它在真实翻译任务上碾压了当时所有模型。消融实验揭示了每个设计选择的实际贡献。这篇论文改变了整个 AI 的方向。

> [!objective]+ OBJECTIVES
> 看懂 Transformer 的翻译成绩、理解消融分析揭示了哪些设计最关键、以及为什么这篇论文是 AI 历史上的转折点——从 2017 年到今天，它的影响如何延伸到 NLP 之外。

> [!skip]+ ⏭ 可跳过
> 若你只关心方法不关心实验数据，可跳过本节。但消融分析对理解每个设计选择的价值很有帮助。

---

## 机器翻译结果

WMT 2014 英德翻译和英法翻译，训练数据分别为 4.5M 和 36M 句对。Base 模型在 8 个 P100 GPU 上训练 12 小时（10 万步），Big 模型训练 3.5 天（30 万步）。

| 模型 | 英德 BLEU | 训练 FLOPs |
|---|---|---|
| ConvS2S (2017) | 25.16 | 9.6×10¹⁸ |
| GNMT+RL (2016) | 24.6 | 2.3×10¹⁹ |
| ConvS2S Ensemble | 26.30 | 7.7×10¹⁹ |
| **Transformer (base)** | **27.3** | **3.3×10¹⁸** |
| **Transformer (big)** | **28.4** | **2.3×10¹⁹** |

大模型英德翻译超之前所有模型（含集成模型）2.0+ BLEU。英法翻译 41.0 BLEU，训练成本仅之前最优模型的 1/4。训练用 Adam 优化器（$\beta_1=0.9,\beta_2=0.98,\epsilon=10^{-9}$），学习率先线性 warmup（4000 步）再 $1/\sqrt{step}$ 衰减——这个调度策略后来成为 Transformer 训练的标配。正则化：残差 Dropout（$P_{drop}=0.1$）+ Label Smoothing（$\epsilon_{ls}=0.1$），后者虽然损害困惑度但提升 BLEU。

推理时用 beam search（beam size=4），长度惩罚 $\alpha=0.6$。Base 模型取最后 5 个 checkpoint 平均，Big 取最后 20 个。

*📎 [第 7-8 页 / Sec.5, 6.1, Table 2](https://arxiv.org/html/1706.03762#S5)*

---

## 消融分析

论文通过系统地修改 base 模型的单个组件，在英德开发集 newstest2013 上测量每个设计选择对 BLEU 的贡献：

| 实验 | 改动 | BLEU | 结论 |
|---|---|---|---|
| baseline | 8 头, $d_k=64$ | 25.8 | — |
| (A) 单头 | $h=1$ | 24.9 | 多头显著优于单头 |
| (A) 4头 | $h=4$ | 25.5 | 头太多也降 |
| (B) 降 $d_k$ | $d_k=16$ | 25.1 | Key 维度不能太小 |
| (C) 大模型 | 1024/4096 | 26.0 | 越大越好（但费算力） |
| (D) 无 dropout | $P_{drop}=0$ | 24.6 | Dropout 防过拟合关键 |
| (E) 可学习PE | 代替正弦 | 25.7 | 几乎一样——正弦仅因外推胜出 |

关键发现：(A) 显示固定计算量下 8 头最佳，单头信息瓶颈、太多头冗余；(B) 单独降低 Key 维度显著伤害质量，说明匹配函数的表达能力很重要——点积在低维时不足；(C) 模型越大越好，但需要足够的 Dropout 防过拟合；(D) Dropout 对 translation quality 贡献 1.2 BLEU——是训练稳定性的关键超参。

*📎 [第 9 页 / Sec.6.2, Table 3](https://arxiv.org/html/1706.03762#S6.SS2)*

---

## 泛化与历史影响

**不只在翻译上有效。** 在英文句法解析（WSJ Penn Treebank）上，4 层 Transformer 仅用 4 万句训练就达到 91.3 F1，加半监督数据（17M 句）冲到 92.7，超越当时所有模型——包括 RNN Grammar 等专为解析设计的架构。证明 Transformer 是**通用序列模型**，不是翻译专用。解析任务比翻译更具挑战性：输出更长、受严格结构约束、小数据场景——但 Transformer 依然胜任。

**历史坐标。** 发表于 NIPS 2017，截至 2025 年被引用超过 15 万次。没有这篇论文就没有 BERT（深双向 Transformer 编码器）、GPT 系列（自回归 Transformer 解码器）、Vision Transformer（图像分块 + Transformer）、Stable Diffusion（U-Net 中的交叉注意力）。它的核心主张——"扔掉循环和卷积，只靠注意力"——在 2017 年大胆得近乎疯狂，但数据和工程说服了所有人。代码开源在 tensor2tensor 仓库，后续演化为 HuggingFace Transformers 生态。

**局限与展望。** 自注意力复杂度 $O(n^2)$，处理超长序列仍是瓶颈。解码仍是自回归顺序生成。当时仅验证了文本模态，但作者已预见到图像、音频、视频的扩展。

*📎 [第 10 页 / Sec.6.3, Table 4, Sec.7](https://arxiv.org/html/1706.03762#S6.SS3)*

---

> [!quiz] CHECK YOURSELF
> **问题：** 消融实验中，单头注意力比 8 头差了多少 BLEU？这说明了什么？
>
> > [!answer]- 答案
> > 单头 24.9 vs 8 头 25.8，差了 0.9 BLEU。在机器翻译中这是显著差距。说明多个注意力头各自学习不同子空间的关系（句法、指代、语义），"平均"模式下会丢失这些丰富的结构信息。但头数不是越多越好——16 头和 32 头都开始下降，8 头在固定计算量下是最优平衡点。

---

> [!summary]- SUMMARY —— 默认折叠，点开看要点
> - 机器翻译：28.4 BLEU（英德）、41.0（英法），全面超越 RNN/CNN。训练更快（12h vs 数天），成本更低
> - 消融：8 头 > 单头（+0.9 BLEU），Dropout 关键（+1.2），Key 维度不能太小，正弦 ≈ 可学习 PE
> - 句法解析 92.7 F1（半监督）证明 Transformer 是通用序列架构，非翻译专用
> - 2017-2025：15 万+ 引用。催生了 BERT、GPT 系列、Vision Transformer、Stable Diffusion 等
>
> **🎉 恭喜完成全部 4 节！** 你现在已经理解了 Transformer 的核心动机、自注意力的数学原理、多头与位置编码的设计、以及这篇论文为什么改变了 AI 的历史。

---

← [[03-multi-head-and-position|第 3 节 · 多头注意力与位置编码]] ｜ 课程结束
