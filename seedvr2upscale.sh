#!/usr/bin/env bash
set -e

COMFY_DIR="${1:-$PWD}"

echo "== Installing SEEDVR2 required nodes =="
cd "$COMFY_DIR/custom_nodes"

git clone https://github.com/kijai/ComfyUI-SeedVR2-VideoUpscaler.git || true
git clone https://github.com/rgthree/rgthree-comfy.git || true
git clone https://github.com/kijai/comfyui-videohelpersuite.git || true

echo "== Installing pip requirements =="
cd "$COMFY_DIR"
find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading required SEEDVR2 models =="
cd "$COMFY_DIR/models"

mkdir -p diffusion_models

# VAE
wget -c https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors -P diffusion_models/

# 7B Sharp DiT
wget -c https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/seedvr2_ema_7b_sharp_fp16.safetensors -P diffusion_models/

echo "====================================="
echo "✔ Nodes installed"
echo "✔ Pip requirements installed"
echo "✔ 7B SEEDVR2 models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="