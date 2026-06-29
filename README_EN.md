# 📚 Help Me Read

> [中文版](README.md)

Turn academic papers into **learnable courses** and a **searchable knowledge base**. An agent skill; output in Markdown files (using Obsidian-compatible syntax: callouts, wikilinks, MathJax), stored in your vault, interoperable with your other notes.

> 💡 **Requires [Obsidian](https://obsidian.md/) ≥ 1.x** (uses callouts, Bases, MathJax, wikilinks). Non-Obsidian editors can read the Markdown content, but callout folding and `[[wikilinks]]` degrade to plain text/blockquotes.
>
> 💡 **Recommended Companion**: Install the [Claudian plugin](https://github.com/YishenTu/claudian) ([中文安装教程](https://developer.aliyun.com/article/1712715)) from the Obsidian community plugins marketplace, and import the Help Me Read skill into its built-in agent. This lets you complete the entire "Generate Course → Learn → Decompose Notes" workflow **within a single Obsidian window** — no more switching between terminal and Obsidian.

## ✨ Features

### 🎓 Courses — papers broken into progressive lessons

- Reorganized by **learning path**, each lesson focuses on 1-2 core concepts with everyday analogies
- Flexible lesson count (1-7+), with on-demand "redo section N" / "deep dive section N"
- Each lesson includes: objectives, core explanation (analogy + formulas + **paper figures** + **embedded examples**), optional code implementation, self-check questions (answers collapsed), curated external resources
- All courses in Markdown with Obsidian-compatible syntax (callouts, wikilinks, MathJax), sharing wikilinks and formula rendering with your notes

### 📝 Notes — structured knowledge base

- Auto-selects template by paper type (research / survey / dataset), with full frontmatter
- Every claim tagged with **【page / section】** source, verified through **page-range check + citation back-check**
- Formulas rendered with MathJax and symbols explained
- Terms tagged as `[[candidate atomic notes]]`
- **Learning supplement layer**: appended after course completion, **physically separated** from the verified original-paper layer
- **To-learn mechanism**: unexplained concepts get a one-liner explanation and auto-saved to `to-learn/`, with optional resource search. Supports "graduation" to formal atomic notes once understood
- **Cross-paper connections**: proactively suggests links to previously read papers

### 📝 Atomic Notes — low-friction decomposition

- Concept filtering first: only concepts defined by the paper and contributing to its contribution are included — no clutter
- Agent pre-builds scaffolding files (frontmatter / provenance / deep insights / related links filled), **you only write "what this thing is in your own words"**
- Scaffolding generated during course creation — start writing definitions right after learning, no waiting
- Cross-paper dedup: same term across papers appends provenance, no duplicate files

### 💬 Q&A — verified, precise answers

- Concise: quote the paper first, supplement only if needed
- **Five-tier source tags**: `[原文·Verified]` / `[原文·Unverified]` / `[Inferred]` / `[Background]` / `[Unknown]`
- Every answer cites sources; out-of-scope questions honestly flagged
- Optional QA record saving

### ⏱️ Status Tracking

- Course completion status written to frontmatter (`unread` → `learning` → `learned` → `atomized`)

---

## 🚀 Usage

Trigger with `/help-me-read` or natural language:

```
/help-me-read https://arxiv.org/abs/1706.03762
Help me read this PDF: D:\papers\transformer.pdf
Summarize Attention Is All You Need
Turn this into a course, I'm a beginner
Redo section 2
Deep dive section 3
```

Sub-commands: "just summarize" for notes only, "make a course" for course only, "redo section N" to regenerate one lesson. Direct questions enter Q&A.

Title-only input → agent searches and confirms with you before proceeding.

**First run only asks for vault path** — everything else uses sensible defaults, so you see output fast. Persisted thereafter.

---

## ⚙️ Configuration (.claude/skills/help-me-read/help-me-read.json)

| Item | Default | Notes |
|---|---|---|
| Obsidian vault path | Asked (first run) | All output stored in vault's `HelpMeRead/` subdirectory |
| QA record saving | Off | Asked after each QA session |
| To-learn | On | Unexplained concepts auto-saved to to-learn |

---

## 📊 Supported Paper Types

| Type | Note Structure | Course Form |
|---|---|---|
| Research paper | Standard academic structure | Learning-path reorganized |
| Survey | Domain-map structure | Panorama + school-by-school (6-8 lessons) |
| Dataset paper | Data-lifecycle structure | Lifecycle lessons |
| Other | Flexible | Learning-path reorganized |

---

## 📁 Output Structure (inside your Obsidian vault)

```
<Vault>/HelpMeRead/
├── papers/                                      # One directory per paper
│   └── attention-is-all-you-need/
│       ├── HMR-attention-is-all-you-need.md       # Main paper note
│       ├── course/                              # Course (Markdown)
│       │   ├── 01-why-attention.md
│       │   ├── 02-self-attention.md
│       │   ├── 03-multi-head-and-position.md
│       │   ├── 04-results-and-impact.md
│       │   └── assets/                          # Paper figures
│       │       └── figure-1.png
│       └── qa-2026-06-22.md                     # QA record
├── concepts/                                    # Cross-paper atomic notes
│   ├── self-attention.md
│   └── multi-head-attention.md
├── to-learn/                                    # To-learn list (with lifecycle)
│   └── positional-encoding.md
└── HelpMeRead MOC.md                            # Index (Bases views)
```

> All output in one `HelpMeRead/` directory — removable as a whole, never mixed with your personal notes.

## 📋 Repository Structure

```
HelpMeRead/
├── SKILL.md                                     # Skill core: triggers, orchestration, full flow
├── test/
│   ├── test-config.json                         # Test configuration
│   └── TESTING.md                               # Modular test framework
├── references/
│   ├── obsidian-note-template.md                # Five note templates
│   ├── course-design-guide.md                   # Three course design guides
│   ├── qa-standards.md                          # Q&A standards
│   ├── frontmatter-schema.md                    # Full field frontmatter schema + MOC
│   ├── failure-modes.md                         # Known failure modes & diagnostic guide
│   └── issue-resolution-workflow.md             # Standard issue resolution workflow
├── examples/                                    # Complete samples
├── README.md
├── README_EN.md
├── LICENSE
└── .gitignore
```

## 📋 Changelog

| Date | Changes | 💭 Dev Notes |
|---|---|---|
| 2026-06-29 | **v2.5.3** · Executable verification system: new test/preflight.sh (mode detection via script, not LLM reading comprehension); new test/check-deps.sh (unified dependency check for image extraction); new test/verify.sh (one-command artifact validation); SKILL.md step 2 parallelism clarified (A. concept list → B. parallel skeleton + course content); issue-resolution-workflow.md Phase 5 bilingual README sync gate | The flesh of mechanics is weak — let intelligence ascend |
| 2026-06-26 | **v2.5.1** · Minimalist review + redundancy cleanup: deleted TESTING.md history & execution log (-62 lines); centralized 3-condition check to SKILL.md (referenced elsewhere); SKILL.md step 5 optional blocks → reference; classification count fix (4→6 types); YAML tab indentation fix; test config path placeholder | Didn't get fat, but got leaner! |
| 2026-06-26 | **v2.5** · 6-issue batch fix + workflow standardization: truncation check (3-condition), to-learn trigger expansion, temp file cleanup, examples isolation, concept "Related" format, test mode detection; new issue resolution SOP + 5 failure modes | I *actually* used it this time! |
| 2026-06-25 | **v2.4** · Self-test constraint; atomic note workflow overhaul (step 2 filtering + scaffolding, step 5 → definition guidance); embedded concept examples (auto-triggered by condition); modular test framework (TESTING.md + test/); directory cleanup |  "WHAT?! He added TESTS!?" |
| 2026-06-23 | **v2.3** · 8-issue batch fix: silent step 0 config check + external concept dirs onboarding; removed progress/last_section, status only; paper slug collision detection & disambiguation; PDF image pipeline overhaul (pdfimages priority, vector fallback, size bounds filtering); notes embed key figures; bottom nav mandatory in courses; external dir dedup scan | Images, please behave yourselves. |
| 2026-06-23 | **v2.2** · Main flow 7→5 steps, steps 5&6 downgraded to cross-cutting modules; all "term" → "core concept"; SUMMARY/external resources callouts now expanded by default; PDF images: banned full-page rasterization + size filtering; final lesson decomposition reminder | How else am I supposed to test it? XD |
| 2026-06-22 | **v2.1** · Full course generation; image extraction optimization; new Concepts blocks; improved note decomposition guidance (evaluate → back-check → supplement → fix); Obsidian URI file opening; course map | Oi! Shipping without testing again, huh?! |
| 2026-06-22 | **v2.0** · Full Markdown migration (removed HTML/flip-cards/self-check); enriched frontmatter + scaffolded decomposition + to-learn graduation; course figures + external resources + arxiv links; verified traceability (page check + citation back-check); cross-paper connections + progress persistence; minimal first-run prompt; ambiguous-word routing; cross-platform PyMuPDF | Reborn. Last life, I was betrayed — tokens burned to ash. This time, I'm taking it all back. Enlightenment hit: when tokens are on the line, looks mean *nothing*. The Seven nodded. Tokens said no. Tokens, watch closely — this cut will be clean. Tokens, go home. Tokens, max level. Tokens, I kept the promise. MAKE WAY FOR TOKENS!! *(inner monologue: wait, they can READ this??)* |
| 2026-06-22 | v1.2 — unified bottom nav + citation superscripts + CSS TOC fix + to-learn setup | You shipped this without testing?! *(inner monologue: there was no testing, at all.)* |
| 2026-06-21 | v1.1 — first-run onboarding + external CSS + flip-card fix + deep-reading upgrade | Just make it *good*, man!! |
| 2026-06-21 | Initial release | When it's time to read papers, suddenly *everything* else is fascinating XD |

## 📄 License

[MIT](LICENSE)
