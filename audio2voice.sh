#!/usr/bin/env bash
set -e

COMFY_DIR="${1:-$PWD}"

echo "====================================="
echo " Installing Audio-to-Voice Clone for ComfyUI"
echo " (MelBandRoFormer + ResembleEnhance + Qwen3 TTS)"
echo "====================================="

cd "$COMFY_DIR"

echo "== Installing Python dependencies =="
pip install -U huggingface_hub qwen-tts onnxruntime soundfile einops rotary_embedding_torch omegaconf

echo "== Installing custom nodes =="
cd custom_nodes

if [ ! -d "ComfyUI-MelBandRoFormer" ]; then
    git clone https://github.com/kijai/ComfyUI-MelBandRoFormer.git
fi

if [ ! -d "resemble-enhance-comfyui" ]; then
    git clone https://github.com/EuphoricPenguin/resemble-enhance-comfyui.git
fi

if [ ! -d "ComfyUI-Qwen-TTS" ]; then
    git clone https://github.com/flybirdxx/ComfyUI-Qwen-TTS.git
fi

echo "== Installing node requirements =="
find "$COMFY_DIR/custom_nodes/ComfyUI-MelBandRoFormer" -name "requirements.txt" -exec pip install -r {} \;
find "$COMFY_DIR/custom_nodes/resemble-enhance-comfyui" -name "requirements.txt" -exec pip install -r {} \;
find "$COMFY_DIR/custom_nodes/ComfyUI-Qwen-TTS" -name "requirements.txt" -exec pip install -r {} \;

cd "$COMFY_DIR/models"

echo "== Downloading MelBandRoFormer model =="
mkdir -p diffusion_models
huggingface-cli download Kijai/MelBandRoFormer_comfy \
    MelBandRoformer_fp16.safetensors \
    --local-dir ./diffusion_models

echo "== Downloading Qwen TTS models =="
mkdir -p qwen-tts
cd qwen-tts

huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-Base \
    --local-dir ./Qwen3-TTS-12Hz-1.7B-Base

huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice \
    --local-dir ./Qwen3-TTS-12Hz-1.7B-CustomVoice

huggingface-cli download Qwen/Qwen3-TTS-Tokenizer-12Hz \
    --local-dir ./Qwen3-TTS-Tokenizer-12Hz

echo "====================================="
echo "✔ MelBandRoFormer node installed"
echo "✔ ResembleEnhance node installed"
echo "✔ Qwen3 TTS node installed"
echo "✔ Models downloaded"
echo "Restart ComfyUI before running workflow"
echo "====================================="
