---
name: agent-memory-and-instincts
description: >-
  Use this skill when enforcing persistent architectural habits, distilling agent lessons, managing long-term agent memory, and avoiding repeated coding mistakes across conversation turns.
---

# Agent Memory, Instincts & Harness System (ECC Standard)

Ensures coding agents maintain strong architectural compliance, retain lessons from corrections, and avoid regressions across large multi-turn sessions.

## 3 Pillars of Agent Memory

### 1. Instincts (Automated Quality Reflexes)
- **Zero Hallucinated Imports**: Validate package existence before adding imports.
- **Never Break Existing Contracts**: Check dependent callers before modifying public function signatures.
- **Single Source of Truth**: Keep configuration in environment variables or central config files, never hardcoded in logic.

### 2. Learnings & Distillation (`/learn` workflow)
- When a user corrects a bug or clarifies a tricky convention, immediately distill it into a reusable rule in `.agents/rules/` or local `GEMINI.md`.
- Keep rules concise (max 3-5 sentences per rule) to preserve context.

### 3. Verification Gates before Handover
- Always execute dry-runs, linter checks, and unit tests before marking any task as complete.
