---
title: "独立服务器 CPU 频率最大化配置指南"
date: 2025-09-02T08:24:00+08:00
menu:
  sidebar:
    name: "独立服务器 CPU 频率最大化配置指南"
    identifier: linux-cpu-performance
    weight: 10
tags: ["URL", "Linux", "CPU"]
categories: ["URL", "Linux", "CPU"]
hero: images/hero/linux.png
---

- [独立服务器 CPU 频率最大化配置指南](https://blog.ibytebox.com/archives/02cf4c4a-0af7-43f1-bb65-ccdb54a52306)

## 看看 CPU 现在混哪种模式

前提条件
系统：Linux（Debian、Ubuntu、Proxmox 等都行）

权限：root

CPU：支持动态调频（Intel Xeon、AMD EPYC / Ryzen 等）

### governor

`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

- powersave：节能小绵羊（频率锁低，省电但废武功）
- ondemand：按需加速（要用时才升频，可能反应慢半拍）
- performance：全程高能（我们要的就是它！💪）

### 确认内核到底用的哪种驱动（Intel / AMD）

`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver`

## 临时拉满性能

```bash
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
  echo performance > $cpu/cpufreq/scaling_governor
done
```

## 重启后也保持高能

### 方案 A：最稳妥推荐

```bash
apt install cpufrequtils -y

echo 'GOVERNOR="performance"' >/etc/default/cpufrequtils
systemctl enable cpufrequtils
systemctl start cpufrequtils

```

### 方案 B：systemd 自定义服务

```bash
# /etc/systemd/system/cpu-performance.service
[Unit]
Description=Set CPU governor to performance
After=multi-user.target

[Service]
Type=oneshot
ExecStart=/bin/bash -c 'for cpu in /sys/devices/system/cpu/cpu[0-9]*; do echo performance > $cpu/cpufreq/scaling_governor; done'

[Install]
WantedBy=multi-user.target
```

```bash
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable --now cpu-performance.service
```
