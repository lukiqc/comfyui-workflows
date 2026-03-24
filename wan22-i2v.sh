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

git clone https://github.com/city96/ComfyUI-GGUF.git || true
git clone https://github.com/kijai/comfyui-kjnodes.git || true
git clone https://github.com/chrisgoringe/cg-use-everywhere.git || true
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git || true
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git || true

echo "== Installing pip requirements =="
cd "$COMFY_DIR"

find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading models =="

# --- GGUF Models (I2V 14B) ---
dl "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/HighNoise/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf" \
   "$COMFY_DIR/models/unet/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf"
dl "https://huggingface.co/QuantStack/Wan2.2-I2V-A14B-GGUF/resolve/main/LowNoise/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf" \
   "$COMFY_DIR/models/unet/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf"

# --- LoRAs ---
dl "https://huggingface.co/lightx2v/Wan2.1-I2V-14B-480P-StepDistill-CfgDistill-Lightx2v/resolve/main/loras/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors" \
   "$COMFY_DIR/models/loras/WAN 2/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors"
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2.1_I2V_14B_FusionX_LoRA.safetensors" \
   "$COMFY_DIR/models/loras/WAN 2/Wan2.1_I2V_14B_FusionX_LoRA.safetensors"

# --- Text Encoders ---
dl "https://huggingface.co/Comfy-Org/Wan_2.1_ComfyUI_repackaged/resolve/main/split_files/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors" \
   "$COMFY_DIR/models/text_encoders/umt5_xxl_fp8_e4m3fn_scaled.safetensors"

# --- VAE ---
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/wan_2.1_vae.safetensors" \
   "$COMFY_DIR/models/vae/wan_2.1_vae.safetensors"
dl "https://huggingface.co/Comfy-Org/Wan_2.2_ComfyUI_Repackaged/resolve/main/split_files/vae/wan2.2_vae.safetensors" \
   "$COMFY_DIR/models/vae/wan2.2_vae.safetensors"

# --- Diffusion Models ---
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/wan2.2_ti2v_5B_fp16.safetensors" \
   "$COMFY_DIR/models/diffusion_models/WAN/wan2.2_ti2v_5B_fp16.safetensors"

echo "====================================="
echo "✔ Nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="
