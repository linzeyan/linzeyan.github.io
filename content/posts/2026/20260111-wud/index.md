---
title: "Replace Watchtower with WUD: Build a Controlled Docker Auto-Update Plan"
date: 2026-01-11T15:22:11+08:00
menu:
  sidebar:
    name: "Replace Watchtower with WUD: Build a Controlled Docker Auto-Update Plan"
    identifier: docker-replace-watchtower-with-wud
    weight: 10
tags: ["Links", "Docker"]
categories: ["Links", "Docker"]
hero: images/hero/docker.jpeg
---

- [Replace Watchtower with WUD: Build a Controlled Docker Auto-Update Plan](https://blog.ibytebox.com/archives/TKFPS2tq)

WUD (What's Up Docker)

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

      # Local Docker watcher
      - WUD_WATCHER_LOCAL_SOCKET=/var/run/docker.sock

      # Key: do not watch any containers by default
      - WUD_WATCHER_LOCAL_WATCHBYDEFAULT=false

      # Scan every 12 hours
      - WUD_WATCHER_LOCAL_CRON=0 */12 * * *

      # Auto update + prune old images after update
      - WUD_TRIGGER_DOCKER_AUTO_PRUNE=true # Equivalent to `watchtower --cleanup`
```

#### Monitor only (no auto update)

```yaml
labels:
  - "wud.watch=true"
```

- Appears in the WUD UI
- Shows update hints
- Does not auto-restart

#### Monitor + auto update (Watchtower equivalent)

```yaml
labels:
  - "wud.watch=true"
  - "wud.trigger.include=docker.auto"
```
