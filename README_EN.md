# 📚 Help Me Read

> [中文版](README.md)

Turn academic papers into **interactive courses** and a **searchable knowledge base**.

Reading papers has two pain points: you forget what you read (didn't truly learn it), and nothing sticks (doesn't become your own knowledge). Help Me Read tackles both — it first builds a step-by-step HTML course to help you truly understand the paper, then produces structured notes with term-based atomic notes, a to-learn list, and source-traceable Q&A, so the paper genuinely enters your knowledge network.

> 💡 **Best paired with [Obsidian](https://obsidian.md/)** for the full knowledge-base experience (structured notes, atomic notes, bidirectional links). Without Obsidian, the course feature works standalone and still helps you learn the paper.

## ✨ Features

### 🎓 Course — Turn papers into learnable lessons

- Reorganizes the paper by **learning path** into several sequential lessons, each focusing on 1–2 core concepts
- Beginner-friendly, with each lesson labeled with **skip conditions** — skip ahead if you already know it
- Each lesson includes: learning objectives, core explanations (with everyday analogies), optional code implementations (only when trusted source code exists), self-check questions (with answers), and a lesson summary
- Courses are delivered as standalone HTML files — open in any browser, no special software required

### 📝 Notes — Write into a structured knowledge base

- Automatically selects the right summary structure based on paper type:
  - **Research papers** → Background & Motivation / Problem Definition / Method (with formulas) / Experiments / Conclusions & Limitations / Related Work
  - **Surveys** → Domain Overview / Classification System / Method Comparison / Trends / Open Problems
  - **Dataset papers** → Construction Motivation / Data Composition / Annotation Pipeline / Statistics / Benchmarks / Limitations & Ethics
- Every point is annotated with its source location **[page / section]**, fully traceable
- Key formulas are reproduced with symbol-by-symbol explanations
- Terms are automatically tagged as candidate atomic notes; after learning, you're guided to split them yourself (hands-on splitting is how knowledge internalizes)
- **To-learn mechanism**: when a concept isn't explained in the paper, the agent gives a one-sentence explanation and auto-saves it to the to-learn directory — no extra confirmation needed. It can then help find related resources
- **Self-check module** (off by default): Q&A-style questions appended to your notes; answer them and get a strict review

### 💬 Q&A — Precise, source-backed answers

- Aim for concise, to-the-point answers — answer exactly what was asked, nothing more
- Quote the original text first whenever possible, then add minimal necessary explanation
- Every statement is labeled with its source type
- Questions outside the paper's scope are honestly flagged as "not covered by the paper" — never fabricate

## 🚀 Usage

Trigger via the `/help-me-read` command or plain natural language:

```
/help-me-read https://arxiv.org/abs/1706.03762
Help me read this paper: Attention Is All You Need
Summarize this PDF: D:\papers\transformer.pdf
Turn this into a course, I'm a beginner
What does this survey say?
```

You can also use sub-commands to run only part of the flow — say "summarize only" for notes alone, "make a course" for the course alone, or ask a question directly to enter Q&A mode.

If you only have a paper title (no URL or PDF), the agent will search the web and confirm with you before proceeding.

On first use, the agent will guide you through initial setup (vault path, course theme, self-check module, Q&A record preference), then remember your choices.

### 📂 Obsidian vault path

On first use, you'll be prompted for the vault path. It's then persisted to `~/.help-me-read.json` for future sessions. You can also edit this file directly to change it:

```json
{
  "obsidian_vault": "D:\\Path\\To\\Vault",
  "theme": "light",
  "self_check": false,
  "qa_record": false,
  "to_learn": true
}
```

## ⚙️ Configuration

| Item | Default | Description |
|---|---|---|
| Obsidian vault path | Ask once | Persisted to `~/.help-me-read.json` after first input |
| Self-check module | Off | When on, Q&A questions are appended to notes for a strict review — correct answers pass, incorrect ones get feedback to retry, direct answers are only given on explicit request |
| Q&A record saving | Off | After each Q&A round, you'll be asked whether to save the record as a standalone note |
| Lesson count | 3–5 | Automatically determined by paper length; hard cap at 5 |
| Code implementation | Auto | When the paper involves algorithms/models with trusted source code, corresponding code snippets with line-by-line annotations are appended |
| Course theme | Light | Default light. Say "use dark" to switch. Preference persisted to `~/.help-me-read.json` |

## 📊 Supported Paper Types

| Type | Summary Structure | Course Shape |
|---|---|---|
| Research paper | Academic standard structure | Learning-path reorganization |
| Survey | Domain map structure | Overview + school-by-school walkthrough |
| Dataset paper | Data lifecycle structure | Lifecycle-stage walkthrough |
| Others (case study, tech report, position paper, etc.) | Fall back to research template, flexibly adjust section titles | Learning-path reorganization |

## 📁 Directory Structure

```
HelpMeRead/
├── SKILL.md                          # Core: triggers, type routing, full workflow
├── references/
│   ├── obsidian-note-template.md     # Three note templates + atomic notes + self-check + to-learn
│   ├── course-design-guide.md        # Three course design guides + code module spec
│   ├── course-template.html          # Light theme HTML template
│   ├── course-template-dark.html     # Dark theme HTML template
│   └── qa-standards.md               # Q&A standards (four source labels + mandatory citation)
├── README.md
├── README_EN.md
└── .gitignore
```

## 📋 Changelog

| Date | Change |
|---|---|
| 2026-06-22 | **v1.2** · Unified bottom nav, citation superscripts + reference lists, CSS fix for floating TOC, to-learn setting in onboarding |
| 2026-06-21 | **v1.1** · First-run onboarding, external CSS + parallel generation, flip-card fix, close-reading depth upgrade |
| 2026-06-21 | Initial release |

## 📄 License

[MIT](LICENSE)
