---
title: "Run llama3"
date: 2024-04-25T10:14:00+08:00
menu:
  sidebar:
    name: Run llama3
    identifier: ollama
    weight: 10
tags: ["Go", "URL", "ollama"]
categories: ["Go", "URL", "ollama"]
hero: images/hero/go.svg
---

- [ollama/ollama](https://github.com/ollama/ollama)
- [Ollama ＋ Open WebUI，快捷部署 AI 大型語言模型到你的電腦，離線執行](https://ivonblog.com/posts/ollama-llm/)

### Docker-compose

```yaml
version: "3.8"

services:
  ollama:
    image: ollama/ollama:latest
    container_name: ollama
    restart: unless-stopped
    volumes:
      - ./ollama/ollama:/root/.ollama
    tty: true
    ports:
      - 11434:11434
    networks:
      - ollama-docker
    # deploy:
    #   resources:
    #     reservations:
    #       devices:
    #         - driver: nvidia
    #           count: 1
    #           capabilities: [gpu]
  ollama-webui:
    image: ghcr.io/ollama-webui/ollama-webui:main
    container_name: ollama-webui
    restart: unless-stopped
    volumes:
      - ./ollama/ollama-webui:/app/backend/data
    ports:
      - 8080:8080
    environment:
      - "/ollama/api=http://ollama:11434/api"
    extra_hosts:
      - host.docker.internal:host-gateway
    networks:
      - ollama-docker

networks:
  ollama-docker:
```

### Setup

```bash
# Run docker-compose
docker-compose up -d

# Pull model(https://ollama.com/library)
docker exec -it ollama /bin/bash
ollama pull llama3
```

### Chat with Web-UI

> port defined in docker-compose.yml ollama-webui.ports

[http://localhost:8080](http://localhost:8080)
