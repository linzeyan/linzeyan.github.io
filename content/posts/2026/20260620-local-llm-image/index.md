---
title: "Local LLM on MacBookPro - Image"
date: 2026-06-20T22:55:33+08:00
menu:
  sidebar:
    name: "Local LLM on MacBookPro - Image"
    identifier: local-llm-on-macbookpro-image
    weight: 10
tags: ["macOS", "LLM", "Image", "MLX"]
categories: ["macOS", "LLM", "Image", "MLX"]
---

- https://huggingface.co/mlx-community
- https://github.com/filipstrand/mflux
- https://github.com/lpalbou/mlx-gen
- https://huggingface.co/AbstractFramework

#### Install

```shell
uv tool install --upgrade mflux
uv tool install --upgrade --force mlx-gen
```

#### Download Model

```shell
# mlx-community/FLUX.2-klein-9B
# AbstractFramework/z-image-turbo-8bit
# AbstractFramework/qwen-image-edit-2511-8bit
HF_HUB_DISABLE_XET=1 hf download mlx-community/FLUX.2-klein-9B --local-dir FLUX.2-klein-9B --max-workers 1
```

#### Run

##### FLUX.2-klein-9B

```shell
mflux-generate-flux2 \
	--model "/Users/ricky/git/mlx/FLUX.2-klein-9B" \
	--prompt 'Charmander from Pokemon, a specific Nintendo character, iconic appearance, very clean large eyes, friendly wide smile, smooth round belly, long distinct tail with simple flame outlines' \
	--steps 6 \
	--seed 42 \
	--width 1240 \
	--height 1754 \
	--output pics/charmander.png
```

##### z-image-turbo-8bit

```shell
mlxgen generate \
	--model /Users/ricky/git/mlx/z-image-turbo-8bit \
	--prompt '哆啦Ａ夢使用竹蜻蜓飛在天空中' \
	--steps 6 \
	--seed 42 \
	--width 1240 \
	--height 1754 \
	--output pics/doramon.png
```

##### qwen-image-edit-2511-8bit

```shell
mlxgen generate \
	--model /Users/ricky/git/mlx/qwen-image-edit-2511-8bit \
	--prompt '哆啦Ａ夢使用竹蜻蜓飛在天空中，旁邊有大雄' \
	--steps 6 \
	--seed 42 \
	--width 1240 \
	--height 1754 \
	--image-path pics/doramon.png \
	--output pics/doramon1.png
```
