---
name: hyper-efficient-agent-architecture
description: Use when orchestrating the 4-Engine Hyper-Efficient Agent Architecture (CodeAct, Actor-Critic, LangGraph Stateful Pipelines, and Speculative Drafting).
---

# The 4-Engine Hyper-Efficient Agent Architecture Blueprint

This skill formalizes the definitive architectural strategy for autonomous software engineering, machine learning research, and academic publishing.

## The 4 Pillars

### 1. CodeAct + Compound AI Engine (Direct Programmatic Execution)
- Instead of multiple verbose JSON tool-call rounds, generate and execute self-contained Python scripts via `uv` (`uv run script.py`).
- Eliminates context token bloat by 60% and guarantees mathematically exact computations.

### 2. Actor-Critic with Neuro-Symbolic Verification
- **Actor Phase**: Generate clean, modular implementations following senior design patterns.
- **Critic Phase**: Delegate immediately to specialized subagents (`code-reviewer`, `security-auditor`, `ml-research-engineer`) to audit syntax, data leakage, and security before merging.

### 3. Graph-Stateful Pipeline (LangGraph)
- Manage end-to-end workflows (Data Ingestion -> Preprocessing -> Model Training -> Multi-Metric Evaluation -> LaTeX Report Generation) as a state machine with deterministic checkpoints and human-in-the-loop approval.

### 4. Speculative Drafting (Fast Tier to Frontier Polish)
- Utilize lightweight, ultra-fast generation for initial code scaffolds, focusing compute budgets on targeted verification and diff patches.

