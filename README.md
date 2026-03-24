# comfyui-workflows

My custom automated ComfyUI workflow installers for generative AI on [vast.ai](https://vast.ai) GPU instances. Each workflow is a paired `.sh` installer and `.json` ComfyUI workflow file.

## Quick Start (in vast.ai terminal)

```bash
cd ComfyUI
git clone https://github.com/lukiqc/comfyui-workflows.git
bash comfyui-workflows/install.sh
(when prompted, input or press Enter for default ComfyUI directory)
```

`install.sh` auto-discovers all available workflows, presents an interactive numbered menu, and installs your selections. After installation, all workflow JSON files are copied to your ComfyUI user workflows directory.

**Selection examples:** `1`, `1,3,5`, `1-4`, `all`

### HuggingFace Token

Some models are gated and require a HuggingFace token with accepted licenses:

```bash
export HF_TOKEN=hf_xxxxxxxxxxxx
```

Required for: Stable Audio Open 1.0, FLUX.2 Klein

---

## Workflows

### Image

#### Qwen Image Edit 2511
**`qwen2511.sh`** — Image editing using the Qwen 2.5 VL 7B model with a 4-step Lightning LoRA for fast inference. Supports text-guided image editing and image comparison.

Models: `qwen_image_edit_2511_fp8_e4m3fn.safetensors`, `qwen_2.5_vl_7b_fp8_scaled.safetensors`, `qwen_image_vae.safetensors`, `Qwen-Image-Lightning-4steps-V2.0.safetensors`

#### FLUX.2 Klein Inpainting
**`klein-impaint.sh`** — Image inpainting and outpainting using FLUX.2 Klein 9B with a Qwen 3 8B text encoder. Includes the LanPaint node for mask-based editing. Requires HF token + accepted FLUX.2 Klein license.

Models: `flux-2-klein-9b.safetensors`, `qwen_3_8b_fp8mixed.safetensors`, `flux2-vae.safetensors`

---

### Video

#### LTX-2 Text-to-Video
**`ltx2.sh` + `ltx2-t2v.json`** — Generate video from a text prompt using LTX-2 19B (Q5_K_M GGUF). Gemma 3 12B handles text encoding.

#### LTX-2 Image-to-Video
**`ltx2.sh` + `ltx2-i2v.json`** — Animate a still image into video using LTX-2 19B.

#### LTX-2 Image+Audio-to-Video
**`ltx2.sh` + `ltx2-ia2v.json`** — Generate video conditioned on both an image and an audio track.

#### LTX-2 Text+Audio-to-Video
**`ltx2.sh` + `ltx2-ta2v.json`** — Generate video conditioned on both a text prompt and audio.

> All four LTX-2 variants share `ltx2.sh` for model downloads. Models include the LTX-2 dev GGUF, video/audio VAEs, Gemma 3 12B text encoder, distilled/camera-control LoRAs, and a 2x spatial upscaler.

#### Wan2.2 Animate
**`wan22animate.sh`** — Character animation and motion synthesis using the Wan2.2 14B model (FP8). Uses YOLOv10 for object detection and ViTPose for wholebody pose estimation. Supports relight, physics, and image-to-video LoRAs.

Models: `Wan2_2-Animate-14B_fp8_e4m3fn_scaled_KJ.safetensors`, `umt5-xxl-enc-bf16.safetensors`, `Wan2_1_VAE_bf16.safetensors`, `clip_vision_h.safetensors`

#### Wan2.2 Image-to-Video
**`wan22-i2v.sh`** — Image-to-video generation using Wan2.2 I2V 14B (GGUF Q4_K_S, both HighNoise and LowNoise variants) plus a 5B TI2V diffusion model for a second-pass upscale. Includes Lightx2v distilled LoRA for fast inference and FusionX LoRA for quality enhancement.

Models: `Wan2.2-I2V-A14B-HighNoise-Q4_K_S.gguf`, `Wan2.2-I2V-A14B-LowNoise-Q4_K_S.gguf`, `wan2.2_ti2v_5B_fp16.safetensors`, `Wan21_I2V_14B_lightx2v_cfg_step_distill_lora_rank64.safetensors`, `Wan2.1_I2V_14B_FusionX_LoRA.safetensors`, `umt5_xxl_fp8_e4m3fn_scaled.safetensors`, `wan_2.1_vae.safetensors`, `wan2.2_vae.safetensors`

#### SeedVR2 Video Upscale
**`seedvr2upscale.sh`** — Upscale low-resolution video using the SeedVR2 7B diffusion transformer (FP16).

Models: `seedvr2_ema_7b_sharp_fp16.safetensors`, `ema_vae_fp16.safetensors`

#### ZiT Upscale (Image + Video)
**`zitupscale.sh`** — Combined image and video upscaling in one workflow. Uses Z Image Turbo (BF16) for images and a lighter SeedVR2 3B (GGUF Q4_K_M) for video, with Qwen 3 4B as text encoder.

Models: `z_image_turbo_bf16.safetensors`, `seedvr2_ema_3b-Q4_K_M.gguf`, `qwen_3_4b.safetensors`, `ae.safetensors`, `ema_vae_fp16.safetensors`

---

### Audio

#### Stable Audio Open 1.0
**`saudioopen.sh`** — Text-to-audio generation for ambient sounds, music, and sound effects using Stability AI's Stable Audio Open model. Requires HF token + accepted license.

Models: `model.safetensors`, `model_config.json`

#### Qwen3 TTS
**`qwen3tts.sh`** — Text-to-speech synthesis using Qwen3-TTS 1.7B. Supports base synthesis, custom voice cloning, and voice design/modification.

Models: `Qwen3-TTS-12Hz-1.7B-Base`, `Qwen3-TTS-12Hz-1.7B-CustomVoice`, `Qwen3-TTS-12Hz-1.7B-VoiceDesign`, `Qwen3-TTS-Tokenizer-12Hz`

#### Audio Voice Cloning
**`audio2voice.sh`** — Clone a voice from a reference audio clip and synthesize new speech with it. Pipeline: reference audio → MelBandRoFormer separation → Resemble Enhance → Qwen3 TTS.

Models: `MelBandRoformer_fp16.safetensors` + Qwen3-TTS Base + CustomVoice

#### Voice Dialogue
**`voices2dialogue.sh`** — Generate multi-speaker dialogue with distinct TTS voices from a script. Built on Qwen3-TTS with all voice variants.

Models: Full Qwen3-TTS suite (Base, CustomVoice, VoiceDesign, Tokenizer)

---

## Model Summary

| Workflow | Model | Size | Quantization |
|---|---|---|---|
| Qwen Image Edit | Qwen 2.5 VL 7B | ~5 GB | FP8 |
| FLUX.2 Klein Inpaint | FLUX.2 Klein 9B | ~6.6 GB | BF16 |
| LTX-2 (all variants) | LTX-2 19B | ~6.5 GB | GGUF Q5_K_M |
| Wan2.2 Animate | Wan2.2 14B | ~4 GB | FP8 |
| Wan2.2 I2V | Wan2.2 I2V 14B + TI2V 5B | ~7 GB | GGUF Q4_K_S / FP16 |
| SeedVR2 Upscale | SeedVR2 7B | ~3 GB | FP16 |
| ZiT Upscale | SeedVR2 3B + Z Image Turbo | ~3 GB | GGUF Q4_K_M / BF16 |
| Stable Audio Open | Stable Audio Open 1.0 | ~5 GB | FP32 |
| Qwen3 TTS | Qwen3-TTS 1.7B | ~1.7 GB | Standard |
| Audio Voice Cloning | MelBandRoFormer + Qwen3-TTS | ~2 GB | FP16 |
| Voice Dialogue | Qwen3-TTS 1.7B | ~1.7 GB | Standard |

---

## Requirements

- ComfyUI installed and accessible
- Python 3.10+
- CUDA-capable GPU (vast.ai recommended)
- `git` available in PATH
- HuggingFace token for gated models
