---
title: "在 macOS 中檢視 Web Views"
date: 2022-12-02T13:51:24+08:00
menu:
  sidebar:
    name: "在 macOS 中檢視 Web Views"
    identifier: macOS-inspecting-web-views-in-macos
    weight: 10
tags: ["Links", "macOS"]
categories: ["Links", "macOS"]
---

- [在 macOS 中檢視 Web Views](https://blog.jim-nielsen.com/2022/inspecting-web-views-in-macos/)

```bash
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
defaults write -g WebKitDeveloperExtras -bool YES
```
