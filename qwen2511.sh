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
    wget -c "$url" -O "$out"
  else
    curl -L --fail --retry 5 --retry-delay 2 -C - -o "$out" "$url"
  fi
}

echo "== Installing custom nodes required by workflow =="
mkdir -p "$COMFY_DIR/custom_nodes"
cd "$COMFY_DIR/custom_nodes"

# Required by workflow:
# - rgthree nodes (Any Switch, Image Comparer, Fast Groups Muter)
git clone https://github.com/rgthree/rgthree-comfy.git || true

# - KJNodes (ImageResizeKJv2, TorchCompileModelQwenImage)
git clone https://github.com/kijai/ComfyUI-KJNodes.git || true

# - Easy Use (easy cleanGpuUsed)
git clone https://github.com/yolain/ComfyUI-Easy-Use.git || true

echo "== Installing pip requirements from custom nodes (if any) =="
cd "$COMFY_DIR"
python3 -m pip install -U pip
while IFS= read -r req; do
  echo "Installing: $req"
  python3 -m pip install -r "$req"
done < <(find "$COMFY_DIR/custom_nodes" -maxdepth 3 -name "requirements.txt" | sort || true)

echo "== Downloading Qwen Image Edit 2511 models =="
mkdir -p "$COMFY_DIR/models/diffusion_models"
mkdir -p "$COMFY_DIR/models/text_encoders"
mkdir -p "$COMFY_DIR/models/vae"
mkdir -p "$COMFY_DIR/models/loras"

# UNet / diffusion model (workflow expects this exact filename)
dl "https://huggingface.co/xms991/Qwen-Image-Edit-2511-fp8-e4m3fn/resolve/main/qwen_image_edit_2511_fp8_e4m3fn.safetensors" \
   "$COMFY_DIR/models/diffusion_models/qwen_image_edit_2511_fp8_e4m3fn.safetensors"

# Text encoder (this URL is embedded in your workflow)
dl "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors" \
   "$COMFY_DIR/models/text_encoders/qwen_2.5_vl_7b_fp8_scaled.safetensors"

# VAE (this URL is embedded in your workflow)
dl "https://huggingface.co/Comfy-Org/Qwen-Image_ComfyUI/resolve/main/split_files/vae/qwen_image_vae.safetensors" \
   "$COMFY_DIR/models/vae/qwen_image_vae.safetensors"

# Lightning LoRA (workflow expects this exact filename)
dl "https://huggingface.co/lightx2v/Qwen-Image-Lightning/resolve/main/Qwen-Image-Lightning-4steps-V2.0.safetensors" \
   "$COMFY_DIR/models/loras/Qwen-Image-Lightning-4steps-V2.0.safetensors"

echo "====================================="
echo "✔ Custom nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo ""
echo "Next steps:"
echo "1) Restart ComfyUI"
echo "2) Load workflow: qwen-image-edit-2511-4steps.json"
echo "3) If TorchCompileModelQwenImage errors, bypass/disable it (optimization only)."
echo "====================================="