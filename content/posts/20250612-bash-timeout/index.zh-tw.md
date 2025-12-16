---
title: "TIL: timeout in Bash scripts"
date: 2025-06-12T09:04:00+08:00
menu:
  sidebar:
    name: "TIL: timeout in Bash scripts"
    identifier: bash-timeout
    weight: 10
tags: ["URL", "BASH", "timeout", "HTTP"]
categories: ["URL", "BASH", "timeout", "HTTP"]
---

[TIL: timeout in Bash scripts](https://heitorpb.github.io/bla/timeout/)

- `timeout 1m ./until.sh`
- wrap
```bash
timeout 1m bash -c "until curl --silent --fail-with-body 10.0.0.1:8080/health; do
	sleep 1
done"
```