---
name: applied-ml-system-design
description: >-
  Use this skill when designing machine learning architectures, choosing between heuristics vs classical ML vs deep learning vs LLMs, designing inference pipelines, or setting up end-to-end ML systems.
---

# Applied ML System Design Guidelines

## 1. Problem Formulation & Simplicity Hierarchy
Always evaluate the problem in increasing order of complexity:
1. **Rule-based heuristic / SQL query**: Can simple rules solve 80% of the problem?
2. **Classical ML (Scikit-Learn, XGBoost, LightGBM)**: For tabular, structured, or fast inference requirements.
3. **Deep Learning / Pretrained Foundations (PyTorch, Hugging Face)**: For unstructured data (computer vision, NLP, audio, multi-modal).
4. **LLMs / Agentic Systems**: When semantic reasoning, complex text understanding, or conversational generation is required.

## 2. Offline vs Online Metrics
- **Offline**: F1-score, NDCG@K, ROC-AUC, RMSE, Latency (p95, p99 ms), Memory (VRAM/RAM).
- **Online**: Conversion rate, Click-Through Rate (CTR), User engagement, System throughput (QPS).

## 3. Serving & Inference Best Practices
- Cache repetitive queries.
- Batch incoming requests where possible.
- Use ONNX Runtime or TensorRT for low-latency production deployment.
