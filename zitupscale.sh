#!/usr/bin/env bash
set -e

COMFY_DIR="${1:-$PWD}"
echo "== Using ComfyUI dir: $COMFY_DIR"

echo "== Installing required custom nodes =="
cd "$COMFY_DIR/custom_nodes"

git clone https://github.com/kijai/ComfyUI-SeedVR2-VideoUpscaler.git || true
git clone https://github.com/chrisgoringe/cg-use-everywhere.git || true
git clone https://github.com/rgthree/rgthree-comfy.git || true

echo "== Installing pip requirements from nodes =="
cd "$COMFY_DIR"
find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading ZitUpscale models =="
cd "$COMFY_DIR/models"

mkdir -p diffusion_models text_encoders vae

# --- Z Image Turbo ---
wget -c https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/diffusion_models/z_image_turbo_bf16.safetensors -P diffusion_models/
wget -c "https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/text_encoders/qwen_3_4b.safetensors?download=true" -P text_encoders/
wget -c https://huggingface.co/Comfy-Org/z_image_turbo/resolve/main/split_files/vae/ae.safetensors -P vae/

echo "== Downloading SEEDVR2 models required =="
# --- SEEDVR2 models ---
wget -c https://huggingface.co/numz/SeedVR2_comfyUI/resolve/main/ema_vae_fp16.safetensors -P diffusion_models/
wget -c https://huggingface.co/cmeka/SeedVR2-GGUF/resolve/main/seedvr2_ema_3b-Q4_K_M.gguf -P diffusion_models/

echo "========================================="
echo "✔ ZitUpscale nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo "You may now start ComfyUI and run the ZitUpscale workflow."
echo "========================================="