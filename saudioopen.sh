#!/usr/bin/env bash
  set -euo pipefail

  COMFY_DIR="${COMFY_DIR:-/workspace/ComfyUI}"
  NODE_DIR="$COMFY_DIR/custom_nodes/ComfyUI-StableAudioSampler"
  TOOLS_DIR="$COMFY_DIR/custom-extensions/stable-audio-tools"
  MODEL_DIR="$COMFY_DIR/models/audio_checkpoints"
  MODEL_REPO="stabilityai/stable-audio-open-1.0"

  echo "== Using ComfyUI dir: $COMFY_DIR"
  [ -d "$COMFY_DIR" ] || { echo "ERROR: ComfyUI dir not found: $COMFY_DIR"; exit 1; }

  # venv activation

  if [ -f "$COMFY_DIR/venv/bin/activate" ]; then
  echo "== Activating ComfyUI venv =="

  # shellcheck disable=SC1091

  source "$COMFY_DIR/venv/bin/activate"
  else
  echo "== No ComfyUI venv found, using system python =="
  fi

  PYTHON_BIN="${PYTHON_BIN:-python}"
  PIP_BIN="${PIP_BIN:-pip}"

  echo "== Python =="; $PYTHON_BIN --version
  echo "== Upgrading pip/setuptools/wheel =="
  $PYTHON_BIN -m pip install --upgrade pip setuptools wheel

  # stable-audio-tools: local clone (preferred)

  echo "== Ensuring local stable-audio-tools clone =="
  mkdir -p "$COMFY_DIR/custom-extensions"
  if [ -d "$TOOLS_DIR/.git" ]; then
  git -C "$TOOLS_DIR" pull --ff-only
  elif [ -d "$TOOLS_DIR" ]; then
  echo "Found $TOOLS_DIR (non-git). Leaving as-is."
  else
  git clone https://github.com/Stability-AI/stable-audio-tools.git "$TOOLS_DIR"
  fi

  # Minimal runtime extras for inference

  echo "== Installing minimal runtime deps =="
  $PIP_BIN install -U \
  einops safetensors aeiou "numpy<2.0" packaging \
  k-diffusion ftfy regex tqdm huggingface_hub \
  "git+https://github.com/openai/CLIP.git"

  # Install/update this node

  echo "== Installing ComfyUI-StableAudioSampler node =="
  mkdir -p "$COMFY_DIR/custom_nodes"
  if [ -d "$NODE_DIR/.git" ]; then
  git -C "$NODE_DIR" pull --ff-only
  else
  git clone https://github.com/lukiqc/ComfyUI-StableAudioSampler.git "$NODE_DIR"
  fi
  if [ -f "$NODE_DIR/requirements.txt" ]; then
  echo "== Installing node requirements =="
  $PIP_BIN install -r "$NODE_DIR/requirements.txt"
  fi

  # Optional: Hugging Face (skip if using local model files)

  if [ -n "${HF_TOKEN:-}" ]; then
  echo "== Logging into Hugging Face CLI =="
  $PIP_BIN install -U "huggingface_hub[cli]" || true
  if command -v hf >/dev/null 2>&1; then
      hf auth login --token "$HF_TOKEN" || true
  else
      huggingface-cli login --token "$HF_TOKEN" || true
  fi

  echo "== Downloading Stable Audio Open 1.0 model files =="
  mkdir -p "$MODEL_DIR"
  hf download "$MODEL_REPO" model.safetensors --local-dir "$MODEL_DIR" || \
  huggingface-cli download "$MODEL_REPO" model.safetensors --local-dir "$MODEL_DIR"
  hf download "$MODEL_REPO" model_config.json --local-dir "$MODEL_DIR" || \
  huggingface-cli download "$MODEL_REPO" model_config.json --local-dir "$MODEL_DIR"
  else
  echo "NOTE: HF_TOKEN not set. Skip download. Place model files in $MODEL_DIR."
  fi

  echo
  echo "========================================="
  echo "Stable Audio Open setup complete."
  echo "Node repo:   $NODE_DIR"
  echo "Model files: $MODEL_DIR/model.safetensors (if downloaded)"
  echo "             $MODEL_DIR/model_config.json (if downloaded)"
  echo "========================================="