---
name: ml-data-preprocessing-and-leakage-prevention
description: Use when preparing datasets, handling missing values, feature scaling, encoding categorical variables, or splitting data for machine learning.
---

# ML Data Preprocessing & Data Leakage Prevention (Chip Huyen Standard)

Data leakage is the most common cause of high offline validation scores that fail drastically in real-world / testing environments.

## Golden Rules for Splitting & Preprocessing

### 1. Split BEFORE Any Transformation
- **Rule**: Never fit scalers (`StandardScaler`, `MinMaxScaler`), encoders (`OneHotEncoder`, `TargetEncoder`), or imputation models on the entire dataset.
- **Correct Flow**:
  1. Split dataset into Train, Validation, and Test sets (or use Stratified K-Fold).
  2. `fit()` transformers ONLY on the Training set (`scaler.fit(X_train)`).
  3. `transform()` on Validation and Test sets (`scaler.transform(X_val)`, `scaler.transform(X_test)`).

### 2. Time-Series & Sequential Data Integrity
- For temporal datasets, NEVER use random k-fold or random train_test_split.
- Use `TimeSeriesSplit` or split chronologically (train on past, evaluate on future) to prevent look-ahead bias.

### 3. Group Leakage Guard
- If data contains multiple entries per entity (e.g. multiple transactions per customer, multiple images per patient), use `GroupKFold` or `GroupShuffleSplit` so that the same entity never appears in both train and test splits.

### 4. Target Leakage Prevention
- Inspect features that may contain information created *after* the target event occurred.
- Drop any feature correlated with target proxies that will not be available at inference time.

### 5. Reproducibility Checklist
- Pin all random states across NumPy, Pandas, Scikit-Learn, and PyTorch.
- Store preprocessing pipelines using `sklearn.pipeline.Pipeline` or `ColumnTransformer` to guarantee zero leakage during inference.

