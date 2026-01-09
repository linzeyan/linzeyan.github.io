---
title: "ZSH 自动读取 macOS 系统代理配置并设置环境变量"
date: 2021-01-11T14:50:11+08:00
menu:
  sidebar:
    name: "ZSH 自动读取 macOS 系统代理配置并设置环境变量"
    identifier: macos-auto-read-proxy-settings-zsh
    weight: 10
tags: ["URL", "MacOS", "Zsh"]
categories: ["URL", "MacOS", "Zsh"]
---

- [ZSH 自动读取 macOS 系统代理配置并设置环境变量](https://blog.skk.moe/post/macos-auto-read-proxy-settings-zsh/)

```zsh
$ system_profiler SPNetworkDataType # 获取完整网络配置信息

$ networksetup -listallnetworkservices # 列举所有网络设备
$ networksetup -getwebproxy Wi-Fi # 获取特定网络设备的系统代理配置

$ scutil --proxy # 获取当前已启用的代理配置，是对 system_profiler 的封装
```
