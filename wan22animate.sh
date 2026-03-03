#!/usr/bin/env bash
set -e

COMFY_DIR="${1:-$PWD}"

echo "== Installing nodes =="
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
cd "$COMFY_DIR/models"

mkdir -p detection diffusion_models loras clip_vision vae text_encoders

# --- Detection ---
wget -c https://huggingface.co/Wan-AI/Wan2.2-Animate-14B/resolve/main/process_checkpoint/det/yolov10m.onnx -P detection/
wget -c https://huggingface.co/Kijai/vitpose_comfy/resolve/ae68f4e542151cebec0995b8469c70b07b8c3df4/onnx/vitpose_h_wholebody_model.onnx -P detection/
wget -c https://huggingface.co/Kijai/vitpose_comfy/resolve/main/onnx/vitpose_h_wholebody_data.bin -P detection/

# --- Diffusion ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy_fp8_scaled/resolve/main/Wan22Animate/Wan2_2-Animate-14B_fp8_e4m3fn_scaled_KJ.safetensors -P diffusion_models/

# --- LoRAs ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/LoRAs/Wan22_relight/WanAnimate_relight_lora_fp16.safetensors -P loras/
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/lightx2v_I2V_14B_480p_cfg_step_distill_rank256_bf16.safetensors -P loras/
wget -c https://huggingface.co/Kutches/UncensoredV2/resolve/main/Insta-Girls-LOW-14B.safetensors -P loras/
wget -c https://huggingface.co/june19925/wan/resolve/main/BoobPhysics_WAN_v7.safetensors -P loras/

# --- Clip Vision ---
wget -c https://huggingface.co/Kutches/UncensoredV2/resolve/main/clip_vision_h.safetensors -P clip_vision/

# --- VAE ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2_1_VAE_bf16.safetensors -P vae/

# --- Text Encoder ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5-xxl-enc-bf16.safetensors -P text_encoders/

echo "====================================="
echo "✔ Nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="