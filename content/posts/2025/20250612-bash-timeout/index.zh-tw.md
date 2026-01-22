---
title: "TIL：Bash 腳本的 timeout"
date: 2025-06-12T09:04:00+08:00
menu:
  sidebar:
    name: "TIL：Bash 腳本的 timeout"
    identifier: bash-timeout
    weight: 10
tags: ["Links", "BASH", "timeout", "HTTP"]
categories: ["Links", "BASH", "timeout", "HTTP"]
---

- [TIL：Bash 腳本的 timeout](https://heitorpb.github.io/bla/timeout/)

- `timeout 1m ./until.sh`
- 包一層

```bash
timeout 1m bash -c "until curl --silent --fail-with-body 10.0.0.1:8080/health; do
	sleep 1
done"
```
