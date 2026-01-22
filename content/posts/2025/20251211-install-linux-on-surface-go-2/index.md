---
title: "How to Install Fedora Linux on Surface Go 2 to Boost Entry-Level Tablet Performance"
date: 2025-12-11T10:18:47+08:00
menu:
  sidebar:
    name: "How to Install Fedora Linux on Surface Go 2 to Boost Entry-Level Tablet Performance"
    identifier: install-linux-on-surface-go-2
    weight: 10
tags: ["Links", "Linux"]
categories: ["Links", "Linux"]
hero: images/hero/linux.png
---

- [How to Install Fedora Linux on Surface Go 2 to Boost Entry-Level Tablet Performance](https://ivonblog.com/posts/install-linux-on-surface-go-2/)
  > Surface Go 2 (Intel Pentium 4425Y, 4G/64G) WiFi edition
  >
  > For Surface Go 2 hardware support, see this GitHub table: [Supported Devices and Features](https://github.com/linux-surface/linux-surface/wiki/Supported-Devices-and-Features#feature-matrix)

### Create a Linux boot drive

- Download the ISO from the [Fedora KDE](https://www.fedoraproject.org/kde/) official site.
- Use [Ventoy](https://ivonblog.com/posts/ventoy-linux-installation/) to create a boot drive.
- Surface Go 2 only has Type-C ports, so you may need a hub. It cannot boot from an SD card.

### Install Linux

- Shut down the Surface Go 2.
- Hold the power button and volume up to enter UEFI. The interface is touch-capable, but you may still need a physical keyboard for installation.
- Fedora supports Secure Boot, but it is recommended to disable it to avoid manual signing when installing drivers.
- Set the boot order to the USB drive.
- Boot and follow the installer. Choose to wipe the disk and install Fedora.
- For Chinese input, install Fcitx5:
  - `sudo dnf install fcitx5 fcitx5-chewing fcitx5-gtk3 fcitx5-gtk4 fcitx5-qt fcitx5-qt6 fcitx5-configtool`
- Tip: Fedora enables zRAM by default. If the Surface Go has limited RAM, edit `/etc/systemd/zram-generator.conf` to increase SWAP size (MB).
  - `[zram0]`
  - `zram-size = 8192`

### Install the linux-surface kernel

- Follow the [GitHub](https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup) instructions. On Fedora, add the linux-surface repo to the system:
  - `sudo dnf config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo`
- Install the linux-surface kernel and reboot:
  - `sudo dnf install --allowerasing kernel-surface iptsd libwacom-surface`
- Use `uname -a` to verify the kernel is switched; it should show `linux-surface`.
- Fedora updates kernels frequently, so new kernels may override the linux-surface kernel. After installing the linux-surface packages, the `linux-surface-default-watchdog.path` service is enabled automatically to ensure linux-surface is used on boot.

### Using the virtual keyboard on KDE

Enable it in System Settings → Keyboard → Virtual Keyboard. Note that this keyboard cannot be used with Fcitx5.

If you want a touch-only setup, install Plasma Mobile: `sudo dnf install plasma-mobile` (You can switch to the Plasma Mobile desktop on the login screen).
