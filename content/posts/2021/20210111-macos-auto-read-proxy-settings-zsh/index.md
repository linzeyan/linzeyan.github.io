---
title: "Let Zsh read macOS system proxy settings and set env vars"
date: 2021-01-11T14:50:11+08:00
menu:
  sidebar:
    name: "Let Zsh read macOS system proxy settings and set env vars"
    identifier: macos-auto-read-proxy-settings-zsh
    weight: 10
tags: ["Links", "macOS", "Zsh"]
categories: ["Links", "macOS", "Zsh"]
---

- [Let Zsh read macOS system proxy settings and set env vars](https://blog.skk.moe/post/macos-auto-read-proxy-settings-zsh/)

```zsh
$ system_profiler SPNetworkDataType # get full network configuration

$ networksetup -listallnetworkservices # list all network services
$ networksetup -getwebproxy Wi-Fi # get system proxy settings for a specific service

$ scutil --proxy # get enabled proxy settings (wrapper for system_profiler)
```
