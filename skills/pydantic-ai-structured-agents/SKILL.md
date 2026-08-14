---
name: pydantic-ai-structured-agents
description: Use when building production-ready, type-safe AI agents with strict schema validation, structured output models, dependency injection, and tool calling.
---

# PydanticAI Type-Safe Agent Engineering

PydanticAI guarantees that LLM outputs adhere strictly to Pydantic schemas, eliminating parsing hallucinations and ensuring production robustness.

## Core Architecture Pattern

```python
from pydantic import BaseModel, Field
from pydantic_ai import Agent, RunContext
from dataclasses import dataclass

# 1. Define Typed Dependencies
@dataclass
class DatabaseContext:
    db_connection: any
    user_id: int

# 2. Define Structured Output Schema
class AnalysisResult(BaseModel):
    summary: str = Field(description="Executive summary of the analysis")
    confidence_score: float = Field(ge=0.0, le=1.0, description="Confidence score between 0 and 1")
    recommended_actions: list[str] = Field(description="Actionable next steps")

# 3. Create Type-Safe Agent
agent = Agent(
    'google-gla:gemini-1.5-pro',
    deps_type=DatabaseContext,
    result_type=AnalysisResult,
    system_prompt="You are a senior data analysis and decision intelligence assistant."
)

# 4. Define Type-Safe Tool
@agent.tool
async def fetch_user_metrics(ctx: RunContext[DatabaseContext], metric_name: str) -> dict:
    """Fetch specific user metrics from database securely."""
    return {"metric": metric_name, "value": 42.0}

# 5. Run & Receive Validated Pydantic Object
# result = await agent.run("Analyze user activity", deps=my_deps)
# print(result.data.confidence_score) # Fully typed and validated!
```

## Best Practices
- **Explicit Field Descriptions**: Always supply detailed `Field(description=...)` to guide model parameter generation.
- **Dependency Injection**: Pass database connections, API clients, and auth tokens via `deps_type` rather than global state.
- **Dynamic System Prompts**: Use `@agent.system_prompt` functions to inject runtime context dynamically.

