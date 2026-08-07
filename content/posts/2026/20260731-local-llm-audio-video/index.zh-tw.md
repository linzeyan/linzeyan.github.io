---
title: "Local LLM on MacBookPro - Audio/Video"
date: 2026-07-31T10:46:55+08:00
menu:
  sidebar:
    name: "Local LLM on MacBookPro - Audio/Video"
    identifier: local-llm-on-macbookpro-audio-video
    weight: 10
tags: ["macOS", "LLM", "Video", "MLX", "Audio", "STT", "TTS"]
categories: ["macOS", "LLM", "Video", "MLX", "Audio", "STT", "TTS"]
---

### Video

- https://huggingface.co/Wan-AI
- https://github.com/Wan-Video/Wan2.2
- https://github.com/Blaizzy/mlx-video
- https://huggingface.co/fishaudio/s2-pro

#### Install

```shell
uv tool install git+https://github.com/Blaizzy/mlx-video.git
```

#### Download Model

```shell
HF_HUB_DISABLE_XET=1 hf download Wan-AI/Wan2.2-TI2V-5B --local-dir Wan2.2-TI2V-5B --max-workers 1
HF_HUB_DISABLE_XET=1 hf download Wan-AI/Wan2.2-T2V-A14B --local-dir Wan2.2-T2V-A14B --max-workers 1
```

#### Convert

```shell
~/.local/share/uv/tools/mlx-video/bin/python -m mlx_video.models.wan_2.convert \
		--checkpoint-dir models/Wan-AI/Wan2.2-TI2V-5B \
		--output-dir models/Wan-AI/Wan2.2-TI2V-5B-mlx
~/.local/share/uv/tools/mlx-video/bin/python -m mlx_video.models.wan_2.convert \
		--checkpoint-dir models/Wan-AI/Wan2.2-T2V-A14B \
		--output-dir models/Wan-AI/Wan2.2-T2V-A14B-mlx \
		--dtype bfloat16
```

#### Run

##### Wan2.2-TI2V-5B

###### t2v

```shell
mlx_video.wan_2.generate \
		--model-dir models/Wan-AI/Wan2.2-TI2V-5B-mlx \
		--prompt 'A cinematic aerial shot of the Great Wall of China at sunrise' \
		--width 1280 \
		--height 704 \
		--num-frames 81 \
		--steps 40 \
		--guide-scale 5.0 \
		--shift 5.0 \
		--scheduler unipc \
		--seed 3478 \
		--output-path video/great_wall1.mp4
```

###### i2v

```shell
mlx_video.wan_2.generate \
		--model-dir models/Wan-AI/Wan2.2-TI2V-5B-mlx \
		--prompt 'A cat is boating on the river' \
		--image models/Wan-AI/Wan2.2-TI2V-5B/examples/i2v_input.JPG \
		--width 1280 \
		--height 704 \
		--num-frames 81 \
		--steps 40 \
		--guide-scale 5.0 \
		--shift 5.0 \
		--scheduler unipc \
		--seed 13633 \
		--output-path video/cat.mp4
```

##### Wan2.2-T2V-A14B

```shell
mlx_video.wan_2.generate \
		--model-dir models/Wan-AI/Wan2.2-T2V-A14B-mlx \
		--prompt 'A cinematic aerial shot of the Great Wall of China at sunrise' \
		--width 1280 \
		--height 720 \
		--num-frames 81 \
		--steps 40 \
		--guide-scale 3.0,4.0 \
		--shift 12.0 \
		--scheduler unipc \
		--seed 11846 \
		--output-path video/great_wall2.mp4
```

#### Upload

```shell
HF_HUB_DOWNLOAD_TIMEOUT=120 HF_HUB_DISABLE_XET=1 hf upload-large-folder rickylin20260522/Wan2.2-TI2V-5B-mlx models/Wan-AI/Wan2.2-TI2V-5B-mlx --repo-type model --num-workers 2
```

---

### Audio

- https://huggingface.co/MediaTek-Research

#### Install

```shell
brew install ffmpeg
uv pip install mlx mlx-audio
```

#### Convert

##### model

```shell
python -m mlx_audio.convert \
	--hf-path models/MediaTek-Research/Breeze-ASR-25 \
	--mlx-path models/MediaTek-Research/Breeze-ASR-25-mlx \
	--dtype bfloat16 \
	--model-domain stt
```

##### audio

```shell
ffmpeg \
	-i ~/Downloads/talk.m4a \
	-ar 16000 \
	-ac 1 \
	-c:a pcm_s16le \
	~/Downloads/talk.wav
```

#### Run

**STT**

##### Breeze-ASR-25

```shell
python -m mlx_audio.stt.generate \
		--model models/MediaTek-Research/Breeze-ASR-25-mlx \
		--audio ~/Downloads/talk.wav \
		--output-path talk_text \
		--format json \
		--language zh \
		--verbose
```

**TTS**

##### fish-audio-s2-pro

```shell
# [excited]
# [sad]
# [angry]
# [whisper]
# [laughing]
python -m mlx_audio.tts.generate \
		--model models/mlx-community/fish-audio-s2-pro-bf16 \
		--text "[excited] Hello, this is a test." \
		--output_path ~/Downloads/s2pro_out
```

```shell
python -m mlx_audio.tts.generate \
		--model models/mlx-community/fish-audio-s2-pro-bf16 \
		--ref_audio ~/Downloads/talk.wav \
		--file_prefix cloned \
		--text "今天天氣真好，我們一起去散步吧！" \
		--output_path ~/Downloads/s2pro_ref_out
```

#### Upload

```shell
hf upload-large-folder rickylin20260522/Breeze-ASR-25-mlx model/MediaTek-Research/Breeze-ASR-25-mlx --repo-type model --num-workers 1
```
