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

git clone https://github.com/scraed/LanPaint.git || true
git clone https://github.com/rgthree/rgthree-comfy.git || true

echo "== Installing pip requirements from custom nodes =="
cd "$COMFY_DIR"
python3 -m pip install -U pip

while IFS= read -r req; do
  echo "Installing: $req"
  python3 -m pip install -r "$req"
done < <(find "$COMFY_DIR/custom_nodes" -maxdepth 3 -name "requirements.txt" | sort || true)

echo "== Preparing model folders =="
mkdir -p "$COMFY_DIR/models/diffusion_models"
mkdir -p "$COMFY_DIR/models/text_encoders"
mkdir -p "$COMFY_DIR/models/vae"
mkdir -p "$COMFY_DIR/models/loras"

echo "== Downloading models =="

# FLUX.2 klein 9B base model
# Official source is gated. You must accept the model terms on Hugging Face first.
# Then export HF_TOKEN before running:
#   export HF_TOKEN=hf_xxxxx
dl "https://huggingface.co/black-forest-labs/FLUX.2-klein-9B/resolve/main/flux-2-klein-9b.safetensors" \
   "$COMFY_DIR/models/diffusion_models/flux-2-klein-9b.safetensors"

# Text encoder
dl "https://huggingface.co/Comfy-Org/vae-text-encorder-for-flux-klein-9b/resolve/main/split_files/text_encoders/qwen_3_8b_fp8mixed.safetensors" \
   "$COMFY_DIR/models/text_encoders/qwen_3_8b_fp8mixed.safetensors"

# VAE
dl "https://huggingface.co/Comfy-Org/flux2-dev/resolve/main/split_files/vae/flux2-vae.safetensors" \
   "$COMFY_DIR/models/vae/flux2-vae.safetensors"

# LoRA used by this workflow
# Source file appears on HF with a slightly different uploaded filename in one repo,
# but we save it under the exact filename your workflow expects.
dl "https://huggingface.co/Estebandidoooi/NSFW/resolve/main/Flux%20Klein%20-%20NSFW%20v2%20%281%29.safetensors" \
   "$COMFY_DIR/models/loras/Flux Klein - NSFW v2.safetensors"

echo "====================================="
echo "✔ Custom nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo ""
echo "If the base model download fails:"
echo "1) log in to Hugging Face"
echo "2) accept the FLUX.2 klein 9B license"
echo "3) export HF_TOKEN=hf_xxxxx"
echo "4) rerun this script"
echo "====================================="