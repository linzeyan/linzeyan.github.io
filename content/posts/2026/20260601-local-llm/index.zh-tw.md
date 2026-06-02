---
title: "Local LLM on MacBookPro"
date: 2026-06-01T10:58:17+08:00
menu:
  sidebar:
    name: "Local LLM on MacBookPro"
    identifier: local-llm-on-macbookpro
    weight: 10
tags: ["macOS", "LLM", "litellm", "MLX", "agent-code"]
categories: ["macOS", "LLM", "litellm", "MLX", "agent-code"]
---

- https://huggingface.co/mlx-community
- https://github.com/ml-explore/mlx-lm
- https://github.com/jundot/omlx

#### Install

```shell
# install hf
uv tool install "huggingface_hub" --with hf-xet --upgrade
hf auth login
hf auth whoami

# install mlx_lm
uv tool install --force \
  --from 'git+https://github.com/ml-explore/mlx-lm.git@refs/pull/1192/head' mlx-lm \
  --with 'transformers @ git+https://github.com/huggingface/transformers.git'

# install mlx-openai-server
uv pip install git+https://github.com/cubist38/mlx-openai-server.git --system

# install [litellm](https://github.com/BerriAI/litellm)
uv tool install 'litellm[proxy]'

# install [claw-code](https://github.com/ultraworkers/claw-code)
cargo install agent-code
```

#### Download Model

```shell
HF_HUB_DISABLE_XET=1 hf download mlx-community/DeepSeek-V4-Flash-4bit \
  --local-dir deepseekV4 --repo-type model
```

#### Run Server

```shell
mlx_lm.server --model /Users/ricky/git/mlx/deepseekV4 --port 8080
```

**or**

```shell
mlx-openai-server launch \
	--model-type lm \
	--model-path /Users/ricky/git/mlx/deepseekV4 \
	--context-length 8192 \
	--decode-concurrency 4 \
	--prompt-concurrency 1 \
	--prefill-step-size 256 \
	--max-tokens 2048 \
	--prompt-cache-size 1 \
	--max-bytes 2147483648 \
	--kv-bits 4 \
	--kv-group-size 64 \
	--quantized-kv-start 0 \
	--port 8080
```

#### Run litellm

```shell
litellm --config config.yaml --port 4000
```

**config.yaml**

```yaml
model_list:
  - model_name: deepseek
    litellm_params:
      model: openai//Users/ricky/git/mlx/deepseekV4
      api_base: http://127.0.0.1:8080/v1
      api_key: token
```

#### Run agent-code

```shell
ANTHROPIC_BASE_URL=http://127.0.0.1:4000 ANTHROPIC_AUTH_TOKEN=token ANTHROPIC_MODEL=deepseek CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 CLAUDE_CODE_ATTRIBUTION_HEADER=0 agent
```

##### Run [oMLX](https://github.com/jundot/omlx/releases/download/v0.3.12/oMLX-0.3.12-macos26-tahoe.dmg) directly, skipping the execution server and execution litellm

```shell
ANTHROPIC_BASE_URL=http://127.0.0.1:8000/v1 ANTHROPIC_AUTH_TOKEN=token ANTHROPIC_MODEL=deepseek CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC=1 CLAUDE_CODE_ATTRIBUTION_HEADER=0 agent
```
