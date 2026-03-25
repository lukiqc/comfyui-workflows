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

echo "== Installing nodes =="
mkdir -p "$COMFY_DIR/custom_nodes"
cd "$COMFY_DIR/custom_nodes"

git clone https://github.com/kijai/comfyui-kjnodes.git || true
git clone https://github.com/chrisgoringe/cg-use-everywhere.git || true
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git || true
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git || true

echo "== Installing pip requirements =="
cd "$COMFY_DIR"

find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading models =="

# --- Diffusion Models ---
dl "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v2.0.safetensors" \
   "$COMFY_DIR/models/diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_high_lighting_v2.0.safetensors"
dl "https://huggingface.co/FX-FeiHou/wan2.2-Remix/resolve/main/NSFW/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v2.0.safetensors" \
   "$COMFY_DIR/models/diffusion_models/Wan2.2_Remix_NSFW_i2v_14b_low_lighting_v2.0.safetensors"

# --- Text Encoders ---
dl "https://huggingface.co/NSFW-API/NSFW-Wan-UMT5-XXL/resolve/main/nsfw_wan_umt5-xxl_fp8_scaled.safetensors" \
   "$COMFY_DIR/models/text_encoders/nsfw_wan_umt5-xxl_fp8_scaled.safetensors"

# --- VAE ---
dl "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan_2.1_vae.safetensors" \
   "$COMFY_DIR/models/vae/wan_2.1_vae.safetensors"

# --- LoRAs ---
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors" \
   "$COMFY_DIR/models/loras/Wan2.2-Lightning_I2V-A14B-4steps-lora_HIGH_fp16.safetensors"
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22-Lightning/old/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors" \
   "$COMFY_DIR/models/loras/Wan2.2-Lightning_I2V-A14B-4steps-lora_LOW_fp16.safetensors"

echo "====================================="
echo "✔ Nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="
