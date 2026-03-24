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

echo "== Downloading models =="

# --- Clip ---
dl "https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/text_encoders/ltx-2-19b-embeddings_connector_dev_bf16.safetensors" \
   "$COMFY_DIR/models/clip/ltx-2-19b-embeddings_connector_dev_bf16.safetensors"

# --- LoRAs ---
dl "https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/loras/ltx-2-19b-distilled-lora_resized_dynamic_fro09_avg_rank_175_fp8.safetensors" \
   "$COMFY_DIR/models/loras/ltx-2-19b-distilled-lora_resized_dynamic_fro09_avg_rank_175_fp8.safetensors"
dl "https://huggingface.co/Lightricks/LTX-2-19b-IC-LoRA-Detailer/resolve/main/ltx-2-19b-ic-lora-detailer.safetensors" \
   "$COMFY_DIR/models/loras/ltx-2-19b-ic-lora-detailer.safetensors"
dl "https://huggingface.co/Lightricks/LTX-2-19b-LoRA-Camera-Control-Static/resolve/main/ltx-2-19b-lora-camera-control-static.safetensors" \
   "$COMFY_DIR/models/loras/ltx-2-19b-lora-camera-control-static.safetensors"

# --- VAE Approx ---
dl "https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/taeltx_2.safetensors" \
   "$COMFY_DIR/models/vae_approx/taeltx_2.safetensors"

# --- VAE ---
dl "https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_video_vae_bf16.safetensors" \
   "$COMFY_DIR/models/vae/LTX2_video_vae_bf16.safetensors"
dl "https://huggingface.co/Kijai/LTXV2_comfy/resolve/main/VAE/LTX2_audio_vae_bf16.safetensors" \
   "$COMFY_DIR/models/vae/LTX2_audio_vae_bf16.safetensors"

# --- Text Encoders ---
dl "https://huggingface.co/Comfy-Org/ltx-2/resolve/main/split_files/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors" \
   "$COMFY_DIR/models/text_encoders/gemma_3_12B_it_fp4_mixed.safetensors"

# --- Diffusion Models ---
dl "https://huggingface.co/QuantStack/LTX-2-GGUF/resolve/main/LTX-2-dev/LTX-2-dev-Q5_K_M.gguf" \
   "$COMFY_DIR/models/diffusion_models/LTX-2-dev-Q5_K_M.gguf"
dl "https://huggingface.co/Kijai/MelBandRoFormer_comfy/resolve/main/MelBandRoformer_fp16.safetensors" \
   "$COMFY_DIR/models/diffusion_models/MelBandRoformer_fp16.safetensors"

# --- Latent Upscale Models ---
dl "https://huggingface.co/Lightricks/LTX-2/resolve/main/ltx-2-spatial-upscaler-x2-1.0.safetensors" \
   "$COMFY_DIR/models/latent_upscale_models/ltx-2-spatial-upscaler-x2-1.0.safetensors"

echo "====================================="
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow."
echo "====================================="
