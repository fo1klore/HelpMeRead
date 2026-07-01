# 📚 Help Me Read

> [中文版（完整版）](README.md)
>
> **English version is a simplified overview. See the Chinese README for full details.**

Turn academic papers into **learnable courses** and a **searchable knowledge base** in your Obsidian vault.

> 💡 **Requires [Obsidian](https://obsidian.md/) ≥ 1.x** (uses callouts, Bases, MathJax, wikilinks).
>
> 💡 **Recommended**: Install the [Claudian plugin](https://github.com/YishenTu/claudian) to run the full workflow inside Obsidian.

## Features

- **🎓 Courses** — papers reorganized by progressive learning path (1-7+ lessons), with analogies, formulas, paper figures, embedded examples, and self-check questions. Each lesson opens with a **Core Concepts** warmup and a **Prerequisite Terms** block. Non-source claims are tagged `[Background]` or `[Inferred]`.
- **📝 Notes** — structured knowledge base with source-verified tags (`[原文·Verified]` / `[Inferred]` / ...)
- **📝 Atomic Notes** — agent pre-builds scaffolding; you write definitions in your own words; cross-paper dedup
- **💬 Q&A** — concise, source-cited answers with five-tier verification tags

## Quick Usage

```
/help-me-read https://arxiv.org/abs/1706.03762
Help me read this PDF: D:\papers\transformer.pdf
Turn this into a course, I'm a beginner
```

First run only asks for your Obsidian vault path. Everything else uses sensible defaults.

## Output Structure

```
<Vault>/HelpMeRead/
├── papers/<paper slug>/
│   ├── HMR-<paper slug>.md       # Main note
│   ├── course/                    # Course files
│   │   ├── 01-*.md
│   │   ├── 02-*.md
│   │   └── assets/
│   └── qa-<date>.md
├── concepts/                      # Cross-paper atomic notes
├── to-learn/                      # Auto-saved concepts to learn later
└── HelpMeRead MOC.md              # Index
```

## License

[MIT](LICENSE)
