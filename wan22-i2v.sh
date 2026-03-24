#!/usr/bin/env bash
set -e

COMFY_DIR="${1:-$PWD}"

echo "== Installing nodes =="
cd "$COMFY_DIR/custom_nodes"

git clone https://github.com/city96/ComfyUI-GGUF.git || true
git clone https://github.com/kijai/comfyui-kjnodes.git || true
git clone https://github.com/chrisgoringe/cg-use-everywhere.git || true
git clone https://github.com/chflame163/ComfyUI_LayerStyle.git || true
git clone https://github.com/Kosinkadink/ComfyUI-VideoHelperSuite.git || true

echo "== Installing pip requirements =="
cd "$COMFY_DIR"

# install all custom node requirements if they exist
find custom_nodes -name "requirements.txt" -exec pip install -r {} \;

echo "== Downloading models =="
cd "$COMFY_DIR/models"

mkdir -p unet "loras/WAN 2" text_encoders vae "diffusion_models/WAN"

# --- GGUF Models (I2V 14B) ---
wget -c https://huggingface.co/city96/Wan2.2-I2V-A14B-HighNoise-GGUF/resolve/main/Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf -P unet/
wget -c https://huggingface.co/city96/Wan2.2-I2V-A14B-LowNoise-GGUF/resolve/main/Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf -P unet/

# --- LoRAs ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Lightx2v/Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors -P "loras/WAN 2/"
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/Wan2.1_I2V_14B_FusionX_LoRA.safetensors -P "loras/WAN 2/"

# --- Text Encoders ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/umt5_xxl_fp8_e4m3fn_scaled.safetensors -P text_encoders/

# --- VAE ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/wan_2.1_vae.safetensors -P vae/
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/wan2.2_vae.safetensors -P vae/

# --- Diffusion Models ---
wget -c https://huggingface.co/Kijai/WanVideo_comfy/resolve/main/wan2.2_ti2v_5B_fp16.safetensors -P "diffusion_models/WAN/"

echo "====================================="
echo "✔ Nodes installed"
echo "✔ Pip requirements installed"
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="
