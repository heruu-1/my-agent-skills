---
name: smolagents-code-first-agents
description: >-
  Use this skill when building ultra-lightweight, code-first AI agents that 'think in code' using Hugging Face smolagents. Generates pure Python execution blocks instead of verbose JSON tool-calling loops, achieving 10x faster execution and minimum RAM footprint.
---

# Hugging Face `smolagents` (CodeAgent Architecture)

`smolagents` is Hugging Face's official library (~1,000 lines of code) implementing the CodeAct / Programmatic agent pattern. Instead of exchanging verbose JSON blobs, the agent generates and executes Python code directly.

## Quick Start Example

```python
from smolagents import CodeAgent, HfApiModel, DuckDuckGoSearchTool

# 1. Initialize Lightweight Model & Tools
model = HfApiModel()
tools = [DuckDuckGoSearchTool()]

# 2. Instantiate CodeAgent
agent = CodeAgent(tools=tools, model=model, add_base_tools=True)

# 3. Execute Pure Python Agent Loop
result = agent.run("Analyze the dataset and calculate class imbalance statistics.")
print(result)
```

## Why It's Superior
- **Think in Code**: Natural handling of loops, branching, and data transformations in a single turn.
- **Ultra Lightweight**: Only ~1,000 lines of source code; zero bloated abstractions.
- **Secure Sandbox**: Includes authorized module imports and local execution guards.
