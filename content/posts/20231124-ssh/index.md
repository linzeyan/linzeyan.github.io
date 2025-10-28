---
title: "Use terminal and SSH to remote host"
date: 2023-11-24T22:22:00+08:00
menu:
  sidebar:
    name: Use terminal and SSH to remote host
    identifier: terminal-ssh
    weight: 10
tags: ["SSH", "terminal"]
categories: ["SSH", "terminal"]
---

# Use terminal and SSH to remote host

## 1. Modern Terminals

- [Hyper](https://github.com/vercel/hyper)
- [iTerm2](https://iterm2.com/)
- [Tabby](https://github.com/Eugeny/tabby)
- [Warp](https://www.warp.dev/)
- [Wez's Terminal](https://github.com/wez/wezterm)
- [WindTerm](https://github.com/kingToolbox/WindTerm)

## 2. Open terminal in macOS

1. `⌘ + space` open Spotlight
   ![](pics/auto_20231124_222253.png)
2. search terminal.app
   ![](pics/auto_20231124_222316.png)
3. press `↩`
   ![](pics/auto_20231124_222410.png)

## 3. SSH to remote host

1. ensure the private key file path.
2. enter the command in the terminal: `ssh -i /path/to/private_key.pem ubuntu@ubuntu.host.com`
