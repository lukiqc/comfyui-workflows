#!/usr/bin/env bash
set -e

COMFY_DIR="${1:-$PWD}"

echo "== Downloading models =="
cd "$COMFY_DIR/models"

mkdir -p clip loras vae vae_approx text_encoders diffusion_models latent_upscale_models

# --- Clip ---
wget -c https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/text_encoders/ltx-2-19b-embeddings_connector_dev_bf16.safetensors -P clip/

# --- LoRAs ---
wget -c https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/loras/ltx-2-19b-distilled-lora_resized_dynamic_fro09_avg_rank_175_fp8.safetensors -P loras/
wget -c https://huggingface.co/Lightricks/LTX-2-19b-IC-LoRA-Detailer/resolve/main/ltx-2-19b-ic-lora-detailer.safetensors -P loras/
wget -c https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Static/resolve/main/ltx-2-19b-lora-camera-control-static.safetensors -P loras/

# --- VAE Approx ---
wget -c https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/taeltx_2.safetensors -P vae_approx/

# --- VAE ---
wget -c https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_video_vae_bf16.safetensors -P vae/
wget -c https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_audio_vae_bf16.safetensors -P vae/

# --- Text Encoders ---
wget -c https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors -P text_encoders/

# --- Diffusion Models ---
wget -c https://huggingface.co/QuantStack/LTX-2-GGUF/resolve/main/LTX-2-dev/LTX-2-dev-Q5_K_M.gguf -P diffusion_models/
wget -c https://huggingface.co/Kijai/MelBandRoFormer_comfy/resolve/main/MelBandRoformer_fp16.safetensors -P diffusion_models/

# --- Latent Upscale Models ---
wget -c https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors -P latent_upscale_models/

echo "====================================="
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="