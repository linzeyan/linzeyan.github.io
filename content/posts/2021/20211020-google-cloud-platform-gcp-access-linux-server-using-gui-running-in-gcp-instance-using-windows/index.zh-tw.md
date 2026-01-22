---
title: "Google Cloud Platform(GCP)：透過 Windows 遠端桌面存取 GCP 執行個體上的 Linux GUI"
date: 2021-10-20T16:15:48+08:00
menu:
  sidebar:
    name: "Google Cloud Platform(GCP)：透過 Windows 遠端桌面存取 GCP 執行個體上的 Linux GUI"
    identifier: linux-using-windows-remote-desktop-connection
    weight: 10
tags: ["Links", "Linux", "RDP"]
categories: ["Links", "Linux", "RDP"]
hero: images/hero/linux.png
---

- [Google Cloud Platform(GCP)：透過 Windows 遠端桌面存取 GCP 執行個體上的 Linux GUI](https://medium.com/tech-guides/google-cloud-platform-gcp-access-linux-server-using-gui-running-in-gcp-instance-using-windows-201e315925a6)

```bash
# This will install GUI and make it as a default startup option and then restart the machine.
$ sudo yum install xrdp tigervnc-server

~# sudo su
~# passwd
~# systemctl enable --now xrdp

~# netstat -antup | grep xrdp
tcp        0      0 0.0.0.0:3389            0.0.0.0:*               LISTEN      10202/xrdp
tcp        0      0 127.0.0.1:3350          0.0.0.0:*               LISTEN      10201/xrdp-sesman
```
