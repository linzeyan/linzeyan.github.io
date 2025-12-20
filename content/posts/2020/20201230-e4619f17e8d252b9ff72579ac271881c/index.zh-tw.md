---
title: "WSL 2 的 .wslconfig 設定檔說明"
date: 2020-12-30T21:24:12+08:00
menu:
  sidebar:
    name: "WSL 2 的 .wslconfig 設定檔說明"
    identifier: windows-wsl2-configuration-explain-e4619f17e8d252b9ff72579ac271881c
    weight: 10
tags: ["URL", "Windows", "WSL"]
categories: ["URL", "Windows", "WSL"]
hero: images/hero/microsoft_windows.png
---

- [WSL 2 的 .wslconfig 設定檔說明](https://gist.github.com/doggy8088/e4619f17e8d252b9ff72579ac271881c)
- [Release Notes for Windows Subsystem for Linux | Microsoft Docs - Build 18945](https://docs.microsoft.com/en-us/windows/wsl/release-notes#build-18945)
- [在 Windows 10 環境上安裝 WSL 2](https://www.huanlintalk.com/2020/02/wsl-2-installation.html)
- [使用 WSL 2 打造優質的多重 Linux 開發環境](https://blog.miniasp.com/post/2020/07/26/Multiple-Linux-Dev-Environment-build-on-WSL-2#google_vignette)

---

安裝 WSL 2 的步驟：

- 加入 Windows Insider Program（此步驟不可省略）
- 啟用 WSL 必要元件
- 安裝 Linux 發行版本
- 設定 WSL 2 支援的 Linux 發行版本
- WSL 2 問題排除：啟用壓縮功能的虛擬磁碟檔案無法轉換成 WSL 2 架構
- 安裝及啟動 Docker
- 安裝 Docker Desktop v2.2.1.0

```powershell
# 啟用 WSL 必要元件
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# 設定 WSL 2 支援的 Linux 發行版本
wsl --set-version ubuntu 2
wsl --set-default-version 2
```

---

- 編輯 `%UserProfile%\.wslconfig` 檔案

  - Command Prompt

    ```sh
    notepad %UserProfile%\.wslconfig
    ```

  - Windows PowerShell

    ```ps1
    notepad $env:USERPROFILE\.wslconfig
    ```

- 設定內容說明

  ```ini
  [wsl2]
  kernel=<path>              # An absolute Windows path to a custom Linux kernel.
  memory=<size>              # How much memory to assign to the WSL2 VM.
  processors=<number>        # How many processors to assign to the WSL2 VM.
  swap=<size>                # How much swap space to add to the WSL2 VM. 0 for no swap file.
  swapFile=<path>            # An absolute Windows path to the swap vhd.
  localhostForwarding=<bool> # Boolean specifying if ports bound to wildcard or localhost in the WSL2 VM should be connectable from the host via localhost:port (default true).

  # <path> entries must be absolute Windows paths with escaped backslashes, for example C:\\Users\\Ben\\kernel
  # <size> entries must be size followed by unit, for example 8GB or 512MB
  ```

- 相關連結

  - [Release Notes for Windows Subsystem for Linux | Microsoft Docs - Build 18945](https://docs.microsoft.com/en-us/windows/wsl/release-notes#build-18945)
