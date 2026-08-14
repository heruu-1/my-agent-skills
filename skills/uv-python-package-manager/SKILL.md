---
name: uv-python-package-manager
description: >-
  Use this skill when managing Python environments, installing packages, creating virtualenvs, running scripts, or configuring Python dependencies. Enforces using Astral `uv` as the ultra-fast (10-100x), memory-efficient replacement for pip, virtualenv, and poetry.
---

# `uv` Python Package & Environment Management (Astral Standard)

`uv` is an extremely fast Python package and project manager written in Rust. It eliminates pip/conda sluggishness and runs with near-zero RAM overhead.

## Core Commands Quick Reference

### 1. Creating and Managing Virtual Environments
```bash
# Create a virtualenv in .venv (takes ~10ms)
uv venv

# Create virtualenv with a specific Python version
uv venv --python 3.11

# Activate virtualenv (Windows PowerShell)
.venv\Scripts\Activate.ps1
```

### 2. Installing Packages (10-100x faster than pip)
```bash
# Install packages into current environment
uv pip install numpy pandas scikit-learn torch torchvision

# Install from requirements.txt
uv pip install -r requirements.txt

# Freeze exact lockfile
uv pip freeze > requirements.txt
```

### 3. Running Scripts Ephemerally (No installation needed)
```bash
# Run a script with dependencies on-the-fly without polluting environment
uv run --with pandas --with scikit-learn script.py
```

### 4. Modern Project Management
```bash
# Initialize project with pyproject.toml
uv init

# Add dependencies with automatic lockfile resolution
uv add torch scikit-learn pandas
uv add --dev pytest black ruff

# Sync project dependencies
uv sync
```
