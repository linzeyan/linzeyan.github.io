---
title: "Inspecting Web Views in macOS"
date: 2022-12-02T13:51:24+08:00
menu:
  sidebar:
    name: "Inspecting Web Views in macOS"
    identifier: macOS-inspecting-web-views-in-macos
    weight: 10
tags: ["URL", "macOS"]
categories: ["URL", "macOS"]
---

- [Inspecting Web Views in macOS](https://blog.jim-nielsen.com/2022/inspecting-web-views-in-macos/)

```bash
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true
defaults write -g WebKitDeveloperExtras -bool YES
```
