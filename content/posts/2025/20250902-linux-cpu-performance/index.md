---
title: "Dedicated Server CPU Frequency Maximization Guide"
date: 2025-09-02T08:24:00+08:00
menu:
  sidebar:
    name: "Dedicated Server CPU Frequency Maximization Guide"
    identifier: linux-cpu-performance
    weight: 10
tags: ["Links", "Linux", "CPU"]
categories: ["Links", "Linux", "CPU"]
hero: images/hero/linux.png
---

- [Dedicated Server CPU Frequency Maximization Guide](https://blog.ibytebox.com/archives/02cf4c4a-0af7-43f1-bb65-ccdb54a52306)

## Check which CPU mode is in use

Prerequisites
System: Linux (Debian, Ubuntu, Proxmox, etc.)

Privileges: root

CPU: supports dynamic frequency scaling (Intel Xeon, AMD EPYC / Ryzen, etc.)

### governor

`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor`

- powersave: low-power mode (locked low frequency, power-saving but weak)
- ondemand: on-demand boost (only boosts when needed, may respond a bit slowly)
- performance: full performance (this is what we want)

### Check which driver the kernel uses (Intel / AMD)

`cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_driver`

## Temporarily max out performance

```bash
for cpu in /sys/devices/system/cpu/cpu[0-9]*; do
  echo performance > $cpu/cpufreq/scaling_governor
done
```

## Keep performance after reboot

### Option A: most stable recommendation

```bash
apt install cpufrequtils -y

echo 'GOVERNOR="performance"' >/etc/default/cpufrequtils
systemctl enable cpufrequtils
systemctl start cpufrequtils

```

### Option B: custom systemd service

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
