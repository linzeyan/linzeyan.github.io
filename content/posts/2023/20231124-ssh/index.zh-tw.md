---
title: "使用終端機與 SSH 連線到遠端主機"
date: 2023-11-24T22:22:00+08:00
menu:
  sidebar:
    name: 使用終端機與 SSH 連線到遠端主機
    identifier: terminal-ssh
    weight: 10
tags: ["SSH", "terminal"]
categories: ["SSH", "terminal"]
---

# 使用終端機與 SSH 連線到遠端主機

## 1. 現代終端機

- [Hyper](https://github.com/vercel/hyper)
- [iTerm2](https://iterm2.com/)
- [Tabby](https://github.com/Eugeny/tabby)
- [Warp](https://www.warp.dev/)
- [Wez's Terminal](https://github.com/wez/wezterm)
- [WindTerm](https://github.com/kingToolbox/WindTerm)

## 2. 在 macOS 開啟終端機

1. 按 `⌘ + space` 開啟 Spotlight
   ![](pics/auto_20231124_222253.png)
2. 搜尋 terminal.app
   ![](pics/auto_20231124_222316.png)
3. 按下 `↩`
   ![](pics/auto_20231124_222410.png)

## 3. 使用 SSH 連線到遠端主機

1. 確認私鑰檔案路徑。
2. 在終端機輸入指令：`ssh -i /path/to/private_key.pem ubuntu@ubuntu.host.com`
