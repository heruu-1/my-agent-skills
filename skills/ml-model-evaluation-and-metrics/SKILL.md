---
name: ml-model-evaluation-and-metrics
description: >-
  Use this skill when evaluating machine learning models, calculating metrics, analyzing confusion matrices, error analysis, or establishing model performance benchmarks. Follows Eugene Yan and Hamel Husain evaluation-driven development standards.
---

# ML Model Evaluation & Metrics (Eugene Yan Standard)

Model accuracy alone is rarely sufficient. A robust evaluation framework reveals model strengths, edge-case failure modes, and performance trade-offs.

## Evaluation Protocol

### 1. Classification Metrics (Beyond Raw Accuracy)
- **Imbalanced Classes**:
  - Always report Precision, Recall, Macro/Weighted F1-Score, and ROC-AUC / PR-AUC.
  - Plot Confusion Matrix to inspect per-class false positives and false negatives.
- **Threshold Calibration**:
  - Do not default blindly to threshold 0.5. Plot Precision-Recall curves to select optimal operating threshold based on cost of False Positives vs False Negatives.

### 2. Regression Metrics
- Report RMSE, MAE, and $R^2$ / Adjusted $R^2$.
- Plot Residuals ($y - \hat{y}$) against predicted values to detect heteroscedasticity or non-linear patterns.

### 3. Slicing & Subgroup Analysis
- Never look only at aggregate metrics across the whole test set.
- Evaluate metrics across slices/subgroups (e.g. demographic, category, rare cases) to uncover hidden regression.

### 4. Error Analysis
- Extract the top 20 worst misclassifications / highest residual errors.
- Categorize error causes: (a) noisy ground truth labels, (b) ambiguous input, (c) edge-case outliers, (d) feature omission.
