---
name: academic-journal-latex-workflow
description: >-
  Use this skill when drafting, structuring, writing, formatting, or debugging academic journal papers, conference articles, or thesis chapters in LaTeX (IEEE, ACM, Elsevier, Springer, SINTA, Scopus standards). Covers the complete 0% to 100% paper lifecycle, mathematical formulas, algorithms, booktabs tables, and BibTeX citations.
---

# Academic Journal & Paper Writing in LaTeX (0% to 100% Complete Workflow)

This skill guides the creation of high-impact, publication-ready academic journal articles in LaTeX following the standard **IMRaD** (Introduction, Methodology, Results, and Discussion) format.

---

## 1. The 6-Phase Paper Writing Lifecycle

```text
[0%] Outline & Research Gap ──> [25%] Methodology & Formulations ──> [50%] Experimental Setup & Tables ──> [75%] Discussion & Abstract ──> [100%] Compilation & Proofreading
```

### Phase 1: Problem Definition & Novelty (0% - 25%)
- Formulate the primary research question and identify the specific **Research Gap**.
- Define 3-4 bulleted concrete **Contributions** in the Introduction section.
- Construct the Related Work comparative analysis table (`\begin{table*}`).

### Phase 2: Mathematical Formulation & Algorithm (25% - 50%)
- Write all variables and parameters in standard LaTeX mathematical notation (`\begin{equation}`).
- Use `algorithm` and `algpseudocode` for clean, formal step-by-step procedural pseudocode.
- Ensure all symbols are defined immediately before or after their first equation.

### Phase 3: Experimental Tables & Plots (50% - 75%)
- Design professional tables using `booktabs` (`\toprule`, `\midrule`, `\bottomrule`). Never use vertical table lines (`|`).
- Report multi-dimensional metrics: Precision, Recall, Macro/Weighted F1-score, and AUC.
- Bold the top-performing values in comparison tables.

### Phase 4: Discussion, Abstract & Conclusion (75% - 100%)
- Write the Abstract last: Background (1-2 sentences), Problem & Method (2 sentences), Key Quantitative Results (1-2 sentences), Impact (1 sentence).
- Address **Threats to Validity** and limitations honestly in the Discussion section.
- Manage all citations via BibTeX (`references.bib`) using official DOI entries.

---

## 2. Starter Kit & Template Location
A complete, pre-configured LaTeX journal project is available in:
`D:\agent-skills\references\latex-journal-starter-kit\`
- `main.tex`: Full working academic paper with sections, equations, algorithms, and tables.
- `references.bib`: Standard BibTeX entries.

---

## 3. Compilation Commands (Terminal / CLI)

### Automated Single-Command Build:
```bash
latexmk -pdf main.tex
```

### Standard 4-Pass Compilation Sequence:
```bash
pdflatex main.tex
bibtex main
pdflatex main.tex
pdflatex main.tex
```

---

## 4. Common LaTeX Error Recovery Cheatsheet

| Error | Root Cause | Solution |
| :--- | :--- | :--- |
| `Undefined control sequence` | Package missing or typo in command. | Add `\usepackage{...}` (e.g. `amsmath`, `booktabs`, `algorithm`). |
| `Citation ... undefined` | BibTeX not compiled or citation key typo. | Run `bibtex main` then `pdflatex main.tex` twice. |
| `Overfull \hbox` | Equation or table wider than column width. | Wrap table in `\resizebox{\columnwidth}{!}{...}` or use `\begin{table*}` for two-column spans. |
| `Package inputenc Error` | Special non-ASCII unicode character. | Use standard LaTeX escape sequences (e.g. `\&`, `\%`, `\_`). |
