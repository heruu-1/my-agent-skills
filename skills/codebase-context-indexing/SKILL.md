---
name: codebase-context-indexing
description: Use when managing large codebases, optimizing agent token consumption, building local vector search indexes, or retrieving pinpoint code context and relevant files for AI agents.
---

# Codebase Context Indexing & Token Optimization

Inspired by Zilliz Claude-Context, this skill provides strategies for token-efficient semantic search and local retrieval across multi-file repositories.

## Workflow Principles

### 1. Vector Indexing vs Raw Dumps
- Never dump entire repository directories into prompt context.
- Split files into logical AST chunks (functions, classes, modules).
- Embed chunks using lightweight local embeddings (or vector DBs like Milvus/Chroma/Faiss).

### 2. Progressive Context Loading (2-Tier Retrieval)
1. **Tier 1 (Dense / Semantic Search)**: Match user question to top-5 most relevant code snippets or symbol names.
2. **Tier 2 (Targeted View)**: Read only the matched lines and immediate dependencies (imports/callers).

### 3. Context Budget Management
- Reserve at least 40% of context window for model reasoning and generation.
- Strip comments, test fixtures, and binary data before sending context to LLM.

