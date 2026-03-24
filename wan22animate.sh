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

git clone https://github.com/kijai/ComfyUI-WanVideoWrapper.git || true
git clone https://github.com/kijai/ComfyUI-WanAnimatePreprocess.git || true
git clone https://github.com/kijai/comfyui-kjnodes.git || true
git clone https://github.com/kijai/comfyui-videohelpersuite.git || true
git clone https://github.com/kijai/ComfyUI-segment-anything-2.git || true

echo "== Installing pip requirements =="
cd "$COMFY_DIR"

# install all custom node requirements if they exist
find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading models =="

# --- Detection ---
dl "https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx" \
   "$COMFY_DIR/models/detection/yolov10m.onnx"
dl "https://huggingface.co/Kijai/vitpose_comfy/resolve/ae68f4e542151cebec0995b8469c70b07b8c3df4/onnx/vitpose_h_wholebody_model.onnx" \
   "$COMFY_DIR/models/detection/vitpose_h_wholebody_model.onnx"
dl "https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin" \
   "$COMFY_DIR/models/detection/vitpose_h_wholebody_data.bin"

# --- Diffusion ---
dl "https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/Wan22Animate/Wan2_2-Animate-14B_fp8_e4m3fn_scaled_KJ.safetensors" \
   "$COMFY_DIR/models/diffusion_models/Wan2_2-Animate-14B_fp8_e4m3fn_scaled_KJ.safetensors"

# --- LoRAs ---
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22_relight/WanAnimate_relight_lora_fp16.safetensors" \
   "$COMFY_DIR/models/loras/WanAnimate_relight_lora_fp16.safetensors"
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors" \
   "$COMFY_DIR/models/loras/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors"
dl "https://huggingface.co/Kutches/UncensoredV2/resolve/main/Insta-Girls-LOW-14B.safetensors" \
   "$COMFY_DIR/models/loras/Insta-Girls-LOW-14B.safetensors"
dl "https://huggingface.co/june19925/wan/resolve/main/BoobPhysics_WAN_v7.safetensors" \
   "$COMFY_DIR/models/loras/BoobPhysics_WAN_v7.safetensors"

# --- Clip Vision ---
dl "https://huggingface.co/Kutches/UncensoredV2/resolve/main/clip_vision_h.safetensors" \
   "$COMFY_DIR/models/clip_vision/clip_vision_h.safetensors"

# --- VAE ---
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors" \
   "$COMFY_DIR/models/vae/Wan2_1_VAE_bf16.safetensors"

# --- Text Encoder ---
dl "https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors" \
   "$COMFY_DIR/models/text_encoders/umt5-xxl-enc-bf16.safetensors"

echo "====================================="
echo "✔ Nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="
