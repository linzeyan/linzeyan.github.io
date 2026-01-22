---
title: "用 WUD 取代 Watchtower：打造可控的 Docker 自動更新方案"
date: 2026-01-11T15:22:11+08:00
menu:
  sidebar:
    name: "用 WUD 取代 Watchtower：打造可控的 Docker 自動更新方案"
    identifier: docker-replace-watchtower-with-wud
    weight: 10
tags: ["Links", "Docker"]
categories: ["Links", "Docker"]
hero: images/hero/docker.jpeg
---

- [用 WUD 取代 Watchtower：打造可控的 Docker 自動更新方案](https://blog.ibytebox.com/archives/TKFPS2tq)

WUD（What's Up Docker）

```yaml
services:
  wud:
    image: getwud/wud:latest
    container_name: wud
    restart: unless-stopped
    ports:
      - "3000:3000"
    volumes:
      - /var/run/docker.sock:/var/run/docker.sock
      - ./store:/store
    environment:
      - TZ=Asia/Shanghai

      # 本机 Docker watcher
      - WUD_WATCHER_LOCAL_SOCKET=/var/run/docker.sock

      # 关键：默认不监控任何容器
      - WUD_WATCHER_LOCAL_WATCHBYDEFAULT=false

      # 每 12 小时扫描一次
      - WUD_WATCHER_LOCAL_CRON=0 */12 * * *

      # 自动更新 + 更新后清理旧镜像
      - WUD_TRIGGER_DOCKER_AUTO_PRUNE=true # 效果等同于 `watchtower --cleanup`
```

#### 只監控（不自動更新）

```yaml
labels:
  - "wud.watch=true"
```

- 會出現在 WUD UI
- 會提示有更新
- 不會自動重啟

#### 監控 + 自動更新（等同 Watchtower）

```yaml
labels:
  - "wud.watch=true"
  - "wud.trigger.include=docker.auto"
```
