---
title: "如何在Surface Go 2安裝Fedora Linux，提昇低階平板效能"
date: 2025-12-11T10:18:47+08:00
menu:
  sidebar:
    name: "如何在Surface Go 2安裝Fedora Linux，提昇低階平板效能"
    identifier: install-linux-on-surface-go-2
    weight: 10
tags: ["URL", "Linux"]
categories: ["URL", "Linux"]
hero: images/hero/linux.png
---

- [如何在 Surface Go 2 安裝 Fedora Linux，提昇低階平板效能](https://ivonblog.com/posts/install-linux-on-surface-go-2/)
  > Surface Go 2 (Intel Pentium 4425Y，4G/64G) Wifi 版
  >
  > 關於 Surface Go 2 的硬體支援程度，參閱 Github 的這個表格：[Supported Devices and Features](https://github.com/linux-surface/linux-surface/wiki/Supported-Devices-and-Features#feature-matrix)

### 製作 Linux 開機碟

- 到 [Fedora KDE](https://www.fedoraproject.org/kde/) 官網下載 ISO
- 然後用 [Ventoy](https://ivonblog.com/posts/ventoy-linux-installation/) 製作開機碟。
- 因為 Surface Go 2 的連接埠只有 Type-C，你可能要準備擴充基座。它不能夠從 SD 卡開機。

### 安裝 Linux

- 將 Surface Go 2 關機。
- 長按開機鍵與音量上鍵，進入 UEFI。這個界面是可以觸控的，不用接上鍵盤，但之後安裝 Linux 可能還是需要使用實體鍵盤操作。
- 雖然 Fedora 支援 Secure Boot，還是建議關閉 Secure Boot，免得安裝驅動需要手動簽名。
- 將開機順序設定為隨身碟
- 開機，依照畫面指示安裝。選擇清除整個磁碟，安裝 Fedora。
- 關於中文輸入法，請安裝 Fcitx5
  - `sudo dnf install fcitx5 fcitx5-chewing fcitx5-gtk3 fcitx5-gtk4 fcitx5-qt fcitx5-qt6 fcitx5-configtool`
- 小技巧：Fedora 預設啟用 zRAM，如果 Surface Go 的 RAM 太小，編輯 `/etc/systemd/zram-generator.conf` 提高 SWAP 數值，增加可用的 RAM，單位為 MB。
  - `[zram0]`
  - `zram-size = 8192`

### 加裝 linux-surface 核心

- 依照 [Github](https://github.com/linux-surface/linux-surface/wiki/Installation-and-Setup) 指示安裝。Fedora 的作法是新增 linux-surface 團隊經營的套件庫到系統
  - `sudo dnf config-manager addrepo --from-repofile=https://pkg.surfacelinux.com/fedora/linux-surface.repo`
- 安裝 linux-surface 核心，重開機
  - `sudo dnf install --allowerasing kernel-surface iptsd libwacom-surface`
- `uname -a` 確認目前的核心是否切換成功，應該會顯示 `linux-surface`
- 由於 Fedora 系統核心更新頻率比較高，新版核心可能會覆蓋 linux-surface 的核心。故安裝 linux-surface 套件之後會自動啟用 `linux-surface-default-watchdog.path` 服務，確保開機啟動的都是 linux-surface 核心。

### KDE 桌面的虛擬鍵盤使用方式

在系統設定 → 鍵盤 → 虛擬鍵盤啟用。需要注意的是這個鍵盤無法跟 Fcitx5 一起使用。

如果想要純觸控操作，建議加裝 plasma-mobile 的桌面環境: `sudo dnf install plasma-mobile` (Plasma 行動」的桌面環境可以在開機登入畫面切換)
