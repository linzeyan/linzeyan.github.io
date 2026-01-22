---
title: "WSL 2 .wslconfig configuration explained"
date: 2020-12-30T21:24:12+08:00
menu:
  sidebar:
    name: "WSL 2 .wslconfig configuration explained"
    identifier: windows-wsl2-configuration-explain-e4619f17e8d252b9ff72579ac271881c
    weight: 10
tags: ["Links", "Windows", "WSL"]
categories: ["Links", "Windows", "WSL"]
hero: images/hero/microsoft_windows.png
---

- [WSL 2 .wslconfig configuration explained](https://gist.github.com/doggy8088/e4619f17e8d252b9ff72579ac271881c)
- [Release Notes for Windows Subsystem for Linux | Microsoft Docs - Build 18945](https://docs.microsoft.com/en-us/windows/wsl/release-notes#build-18945)
- [Install WSL 2 on Windows 10](https://www.huanlintalk.com/2020/02/wsl-2-installation.html)
- [Build a multi-Linux development environment with WSL 2](https://blog.miniasp.com/post/2020/07/26/Multiple-Linux-Dev-Environment-build-on-WSL-2#google_vignette)

---

Steps to install WSL 2:

- Join the Windows Insider Program (required)
- Enable required WSL components
- Install a Linux distribution
- Set the Linux distribution to use WSL 2
- WSL 2 troubleshooting: compressed virtual disk files cannot be converted to the WSL 2 architecture
- Install and start Docker
- Install Docker Desktop v2.2.1.0

```powershell
# Enable required WSL components
dism.exe /online /enable-feature /featurename:Microsoft-Windows-Subsystem-Linux /all /norestart
dism.exe /online /enable-feature /featurename:VirtualMachinePlatform /all /norestart

# Set the Linux distribution to WSL 2
wsl --set-version ubuntu 2
wsl --set-default-version 2
```

---

- Edit `%UserProfile%\.wslconfig`

  - Command Prompt

    ```sh
    notepad %UserProfile%\.wslconfig
    ```

  - Windows PowerShell

    ```ps1
    notepad $env:USERPROFILE\.wslconfig
    ```

- Configuration reference

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

- Related links

  - [Release Notes for Windows Subsystem for Linux | Microsoft Docs - Build 18945](https://docs.microsoft.com/en-us/windows/wsl/release-notes#build-18945)
