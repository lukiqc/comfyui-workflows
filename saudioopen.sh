#!/usr/bin/env bash
set -euo pipefail

# =========================================
# Stable Audio Open 1.0 setup for ComfyUI
# Tested concept: VastAI / Linux / ComfyUI
# =========================================

COMFY_DIR="${COMFY_DIR:-/workspace/ComfyUI}"
NODE_DIR="$COMFY_DIR/custom_nodes/ComfyUI-StableAudioSampler"
MODEL_DIR="$COMFY_DIR/models/audio_checkpoints"
MODEL_REPO="stabilityai/stable-audio-open-1.0"

echo "== Using ComfyUI dir: $COMFY_DIR"

if [ ! -d "$COMFY_DIR" ]; then
  echo "ERROR: ComfyUI dir not found at $COMFY_DIR"
  exit 1
fi

# -----------------------------
# Activate venv if present
# -----------------------------
if [ -f "$COMFY_DIR/venv/bin/activate" ]; then
  echo "== Activating ComfyUI venv =="
  # shellcheck disable=SC1091
  source "$COMFY_DIR/venv/bin/activate"
else
  echo "== No ComfyUI venv found, using system python =="
fi

PYTHON_BIN="${PYTHON_BIN:-python}"
PIP_BIN="${PIP_BIN:-pip}"

echo "== Python =="
$PYTHON_BIN --version

# -----------------------------
# Basic tooling
# -----------------------------
echo "== Upgrading pip/setuptools/wheel =="
$PYTHON_BIN -m pip install --upgrade pip setuptools wheel

echo "== Installing core Stable Audio deps =="
# Pre-install pandas with a wheel to avoid source-building pandas==2.0.2
# (which fails on Python 3.12 due to missing pkg_resources in the build env)
$PIP_BIN install -U "pandas>=2.1.0"

# stable-audio-tools is the official Stability package
# PyTorch must already be installed in your ComfyUI env
$PIP_BIN install -U \
  stable-audio-tools \
  huggingface_hub \
  soundfile \
  safetensors \
  einops \
  einops-exts \
  ema-pytorch \
  k-diffusion \
  prefigure \
  aeiou \
  vector-quantize-pytorch \
  v-diffusion-pytorch \
  alias-free-torch \
  transformers \
  accelerate

# -----------------------------
# Install/update ComfyUI node
# -----------------------------
echo "== Installing ComfyUI-StableAudioSampler node =="
mkdir -p "$COMFY_DIR/custom_nodes"

if [ -d "$NODE_DIR/.git" ]; then
  echo "== Node already exists, pulling latest =="
  git -C "$NODE_DIR" pull --ff-only
else
  git clone https://github.com/lks-ai/ComfyUI-StableAudioSampler.git "$NODE_DIR"
fi

if [ -f "$NODE_DIR/requirements.txt" ]; then
  echo "== Installing node requirements =="
  $PIP_BIN install -r "$NODE_DIR/requirements.txt"
fi

# -----------------------------
# Hugging Face auth check
# -----------------------------
if [ -z "${HF_TOKEN:-}" ]; then
  echo
  echo "ERROR: HF_TOKEN is not set."
  echo "Set it first, for example:"
  echo "  export HF_TOKEN=hf_xxxxxxxxxxxxxxxxx"
  echo
  echo "Also make sure you accepted the model terms on:"
  echo "  https://huggingface.co/$MODEL_REPO"
  exit 1
fi

# Login non-interactively
echo "== Logging into Hugging Face CLI =="
$PIP_BIN install -U "huggingface_hub[cli]"
hf auth login --token "$HF_TOKEN" || true

# -----------------------------
# Download model files
# -----------------------------
echo "== Downloading Stable Audio Open 1.0 model files =="
mkdir -p "$MODEL_DIR"

# This node expects the model + config in models/audio_checkpoints
hf download "$MODEL_REPO" model.safetensors --local-dir "$MODEL_DIR"
hf download "$MODEL_REPO" model_config.json --local-dir "$MODEL_DIR"

# -----------------------------
# Final summary
# -----------------------------
echo
echo "========================================="
echo "Stable Audio Open 1.0 setup complete."
echo "========================================="
echo "Node repo:   $NODE_DIR"
echo "Model files: $MODEL_DIR/model.safetensors"
echo "             $MODEL_DIR/model_config.json"
echo
echo "Next steps:"
echo "1) Restart ComfyUI"
echo "2) Search for StableAudio nodes"
echo "3) Load the model from models/audio_checkpoints"
echo
echo "If ComfyUI is already running, restart it now."