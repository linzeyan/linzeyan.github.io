---
title: "獨立伺服器 CPU 頻率最大化配置指南"
date: 2025-09-02T08:24:00+08:00
menu:
  sidebar:
    name: "獨立伺服器 CPU 頻率最大化配置指南"
    identifier: linux-cpu-performance
    weight: 10
tags: ["Links", "Linux", "CPU"]
categories: ["Links", "Linux", "CPU"]
hero: images/hero/linux.png
---

- [獨立伺服器 CPU 頻率最大化配置指南](https://blog.ibytebox.com/archives/02cf4c4a-0af7-43f1-bb65-ccdb54a52306)

## 看看 CPU 現在用哪種模式

前提條件
系統：Linux（Debian、Ubuntu、Proxmox 等都行）

權限：root

CPU：支援動態調頻（Intel Xeon、AMD EPYC / Ryzen 等）

### governor

`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

- powersave：省電小綿羊（頻率鎖低，省電但沒力）
- ondemand：按需加速（要用時才升頻，可能反應慢半拍）
- performance：全程高能（我們要的就是它！💪）

### 確認核心到底用哪種驅動（Intel / AMD）

`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver`

## 暫時拉滿效能

```bash
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
  echo performance > $cpu/cpufreq/scaling_governor
done
```

## 重啟後也保持高能

### 方案 A：最穩妥推薦

```bash
apt install cpufrequtils -y

echo 'GOVERNOR="performance"' >/etc/default/cpufrequtils
systemctl enable cpufrequtils
systemctl start cpufrequtils

```

### 方案 B：systemd 自訂服務

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
