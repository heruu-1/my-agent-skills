---
name: subagent-orchestration-and-delegation
description: Use when delegating focused responsibilities like research, security audit, code review, ML data audit, or LaTeX drafting to specialized subagents.
---

# Subagent Orchestration & Delegation Protocol

When tackling complex software engineering, machine learning, or academic writing tasks, dividing work across specialized subagents prevents context pollution and enables parallel problem-solving.

## Available Specialized Subagents

| Subagent Persona | Specialization | Best For |
| :--- | :--- | :--- |
| **`research`** | Codebase & Web Exploration | Broad file reading, finding symbols, searching web documentation. |
| **`code-reviewer`** | Staff Code Review | Evaluating correctness, readability, architecture, and performance before merge. |
| **`security-auditor`** | Security Hardening | Finding vulnerabilities, injection risks, authentication flaws, and credential leaks. |
| **`test-engineer`** | Test Suite Creation | Writing edge-case unit tests, integration tests, and verifying coverage. |
| **`web-performance-auditor`**| Web Speed & Core Web Vitals | Optimizing rendering, bundle size, caching, and network waterfall. |
| **`ml-research-engineer`** | Machine Learning & MLOps | Auditing data leakage, verifying Karpathy NN recipes, evaluating metrics. |
| **`academic-paper-writer`** | Academic LaTeX & Paper Drafting | Writing IMRaD sections, LaTeX tables, algorithms, and BibTeX citations. |

## Delegation Rules

1. **Parallel Fan-Out**: When completing a multi-step milestone (e.g. shipping a feature), spawn `code-reviewer`, `security-auditor`, and `test-engineer` concurrently.
2. **Context Isolation**: Run large research queries or deep file audits inside a `research` subagent to keep the main conversation context clean.
3. **Actionable Synthesis**: When subagents return their findings, synthesize their reports into clear, executive summaries for the user.

