#!/usr/bin/env bash
set -e

COMFY_DIR="${1:-$PWD}"

echo "====================================="
echo " Installing Qwen3 TTS (Voices to Dialogue) for ComfyUI"
echo "====================================="

cd "$COMFY_DIR"

echo "== Installing Python dependencies =="
pip install -U huggingface_hub qwen-tts onnxruntime soundfile

echo "== Installing ComfyUI-Qwen-TTS node =="
cd custom_nodes

if [ ! -d "ComfyUI-Qwen-TTS" ]; then
    git clone https://github.com/flybirdxx/ComfyUI-Qwen-TTS.git
fi

cd ComfyUI-Qwen-TTS
pip install -r requirements.txt

cd "$COMFY_DIR/models"

echo "== Creating model directory =="
mkdir -p qwen-tts
cd qwen-tts

echo "== Downloading Qwen TTS models =="

huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-Base \
--local-dir ./Qwen3-TTS-12Hz-1.7B-Base

huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-CustomVoice \
--local-dir ./Qwen3-TTS-12Hz-1.7B-CustomVoice

huggingface-cli download Qwen/Qwen3-TTS-12Hz-1.7B-VoiceDesign \
--local-dir ./Qwen3-TTS-12Hz-1.7B-VoiceDesign

huggingface-cli download Qwen/Qwen3-TTS-Tokenizer-12Hz \
--local-dir ./Qwen3-TTS-Tokenizer-12Hz

echo "====================================="
echo "✔ Qwen TTS (Dialogue) installation complete"
echo "Restart ComfyUI before running workflow"
echo "====================================="
