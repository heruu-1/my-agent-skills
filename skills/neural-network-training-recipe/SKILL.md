---
name: neural-network-training-recipe
description: Use when developing, training, debugging, or optimizing neural networks and deep learning models in PyTorch or TensorFlow.
---

# Neural Network Training Recipe (Andrej Karpathy Standard)

This skill enforces the battle-tested, systematic approach to training neural networks without silent bugs.

## Core Principles

1. **Neural net training is a leaky abstraction**: Errors fail silently (code runs and loss decreases, but to suboptimal plateaus).
2. **Start trivial and build complexity gradually**: Never write a complex model and large training loop in one go.

---

## The 5-Phase Training Recipe

### Phase 1: Inspect and Become One with the Data
- Always visualize input data (images, token sequences, tabular distributions) after DataLoader / transforms.
- Check distribution of target labels for severe class imbalance.
- Search for label errors, duplicate samples, and outliers before modeling.

### Phase 2: Set up End-to-End Skeleton & Constant Baseline
- Build a minimal, working end-to-end pipeline with fixed random seeds (`torch.manual_seed(42)`).
- Verify loss at initialization:
  - For classification with $C$ classes, initial loss must be approximately $-\ln(1/C)$.
  - If initial loss is wildly different, check output activation vs. loss function (e.g. `nn.CrossEntropyLoss` expects raw logits, not `nn.Softmax`).
- Establish a constant baseline (predicting majority class or mean target value) and ensure the simplest model beats it.

### Phase 3: Overfit a Single Batch First
- Take exactly 1-4 training samples and train the model for 50-100 iterations.
- Verify that training loss drops to ~0.0 and predicted outputs match the ground truth exactly.
- If it cannot overfit 1 batch, stop immediately: check tensor shapes, gradient zeroing (`optimizer.zero_grad()`), and learning rate.

### Phase 4: Regularize and Scale
- Increase dataset to full training split.
- Monitor both Training Loss and Validation Loss:
  - If underfitting: Increase model capacity, add layers, tune learning rate, remove early regularization.
  - If overfitting: Add Dropout, Weight Decay ($L_2$), Data Augmentation, or Early Stopping.

### Phase 5: Hyperparameter Tuning
- Use learning rate finder or coarse-to-fine random search on learning rates ($10^{-5}$ to $10^{-1}$).
- Use AdamW or SGD with Cosine Annealing learning rate schedule.
- Validate gradient norms (`torch.nn.utils.clip_grad_norm_`).

