---
title: "用 WUD 替代 Watchtower：构建可控的 Docker 自动更新方案"
date: 2026-01-11T15:22:11+08:00
menu:
  sidebar:
    name: "用 WUD 替代 Watchtower：构建可控的 Docker 自动更新方案"
    identifier: docker-replace-watchtower-with-wud
    weight: 10
tags: ["URL", "Docker"]
categories: ["URL", "Docker"]
hero: images/hero/docker.jpeg
---

- [用 WUD 替代 Watchtower：构建可控的 Docker 自动更新方案](https://blog.ibytebox.com/archives/TKFPS2tq)

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

#### 只监控（不自动更新）

```yaml
labels:
  - "wud.watch=true"
```

- 出现在 WUD UI
- 有更新提示
- 不会自动重启

#### 监控 + 自动更新（Watchtower 的等价替代）

```yaml
labels:
  - "wud.watch=true"
  - "wud.trigger.include=docker.auto"
```
