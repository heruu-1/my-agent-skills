---
name: langgraph-stateful-agent-design
description: Use when designing, implementing, or debugging multi-agent workflows, state machines, cyclical agent loops, human-in-the-loop validation, and persistent agent checkpoints.
---

# LangGraph Stateful Multi-Agent Design

LangGraph is the industry standard for creating stateful, resilient, and cyclic multi-agent architectures.

## Core Concepts

1. **State**: The single source of truth passed between all nodes (defined with `TypedDict` or `Pydantic`).
2. **Nodes**: Python functions or runnable tools that receive the state, perform computation, and return updated state fields.
3. **Edges & Conditional Routing**: Direct or dynamic routing determining the next node based on state values.
4. **Checkpointers**: Persistence layers (`MemorySaver`, `SqliteSaver`, `PostgresSaver`) enabling state time-travel, replayability, and human approval gates.

## Standard Multi-Agent Architecture Pattern

```python
from typing import TypedDict, Annotated, Sequence
import operator
from langgraph.graph import StateGraph, END
from langchain_core.messages import BaseMessage

class AgentState(TypedDict):
    messages: Annotated[Sequence[BaseMessage], operator.add]
    next_step: str
    is_approved: bool

# Initialize Graph
workflow = StateGraph(AgentState)

# Add Nodes
workflow.add_node("researcher", research_node)
workflow.add_node("coder", coder_node)
workflow.add_node("human_review", human_review_node)

# Add Edges & Conditional Routing
workflow.set_entry_point("researcher")
workflow.add_edge("researcher", "coder")
workflow.add_edge("coder", "human_review")

def route_after_review(state: AgentState):
    if state["is_approved"]:
        return END
    return "coder"

workflow.add_conditional_edges("human_review", route_after_review)
app = workflow.compile(checkpointer=checkpointer)
```

## Best Practices
- **Never mutate state directly in-place**: Return clean dictionary updates.
- **Fail-Safe Fallbacks**: Always add maximum iteration counters to prevent infinite loops in cyclic graphs.
- **Human-in-the-Loop**: Use `interrupt_before=["human_review"]` to pause execution before destructive actions (database writes, API deployments).

