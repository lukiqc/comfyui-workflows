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

echo "== Installing required custom nodes =="
mkdir -p "$COMFY_DIR/custom_nodes"
cd "$COMFY_DIR/custom_nodes"

git clone https://github.com/kijai/ComfyUI-SeedVR2-VideoUpscaler.git || true
git clone https://github.com/chrisgoringe/cg-use-everywhere.git || true
git clone https://github.com/rgthree/rgthree-comfy.git || true

echo "== Installing pip requirements from nodes =="
cd "$COMFY_DIR"
find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading ZitUpscale models =="

# --- Z Image Turbo ---
dl "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors" \
   "$COMFY_DIR/models/diffusion_models/z_image_turbo_bf16.safetensors"
dl "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors" \
   "$COMFY_DIR/models/text_encoders/qwen_3_4b.safetensors"
dl "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors" \
   "$COMFY_DIR/models/vae/ae.safetensors"

# --- SEEDVR2 models ---
dl "https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors" \
   "$COMFY_DIR/models/diffusion_models/ema_vae_fp16.safetensors"
dl "https://huggingface.co/cmeka/SeedVR2-GGUF/resolve/main/seedvr2_ema_3b-Q4_K_M.gguf" \
   "$COMFY_DIR/models/diffusion_models/seedvr2_ema_3b-Q4_K_M.gguf"

echo "========================================="
echo "✔ ZitUpscale nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo "You may now start ComfyUI and run the ZitUpscale workflow."
echo "========================================="
