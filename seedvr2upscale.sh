#!/usr/bin/env bash
set -euo pipefail

COMFY_DIR="${1:-$PWD}"
echo "== ComfyUI dir: $COMFY_DIR =="

have_cmd() { command -v "$1" >/dev/null 2>&1; }

dl() {
  local url="$1"
  local out="$2"
  mkdir -p "$(dirname "$out")"
  if [[ -f "$out" ]]; then
    echo "✔ exists: $out"
    return 0
  fi
  echo "↓ $url"
  if have_cmd wget; then
    if [[ -n "${HF_TOKEN:-}" ]]; then
      wget --header="Authorization: Bearer $HF_TOKEN" -c "$url" -O "$out"
    else
      wget -c "$url" -O "$out"
    fi
  else
    if [[ -n "${HF_TOKEN:-}" ]]; then
      curl -L --fail --retry 5 --retry-delay 2 -C - \
        -H "Authorization: Bearer $HF_TOKEN" \
        -o "$out" "$url"
    else
      curl -L --fail --retry 5 --retry-delay 2 -C - \
        -o "$out" "$url"
    fi
  fi
}

echo "== Installing SEEDVR2 required nodes =="
mkdir -p "$COMFY_DIR/custom_nodes"
cd "$COMFY_DIR/custom_nodes"

git clone https://github.com/kijai/ComfyUI-SeedVR2-VideoUpscaler.git || true
git clone https://github.com/rgthree/rgthree-comfy.git || true
git clone https://github.com/kijai/comfyui-videohelpersuite.git || true

echo "== Installing pip requirements =="
cd "$COMFY_DIR"
find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading required SEEDVR2 models =="

# VAE
dl "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors" \
   "$COMFY_DIR/models/diffusion_models/ema_vae_fp16.safetensors"

# 7B Sharp DiT
dl "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/seedvr2_ema_7b_sharp_fp16.safetensors" \
   "$COMFY_DIR/models/diffusion_models/seedvr2_ema_7b_sharp_fp16.safetensors"

echo "====================================="
echo "✔ Nodes installed"
echo "✔ Pip requirements installed"
echo "✔ 7B SEEDVR2 models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="
