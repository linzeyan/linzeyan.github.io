---
title: "【筆記】在GCP上建立可Remote dekstop的Ubuntu環境"
date: 2021-10-20T16:14:47+08:00
menu:
  sidebar:
    name: "【筆記】在GCP上建立可Remote dekstop的Ubuntu環境"
    identifier: linux-using-vnc-connection
    weight: 10
tags: ["URL", "Linux", "VNC"]
categories: ["URL", "Linux", "VNC"]
hero: images/hero/linux.png
---

- [【筆記】在 GCP 上建立可 Remote dekstop 的 Ubuntu 環境](https://medium.com/@huiqinng/%E7%AD%86%E8%A8%98-%E5%9C%A8gcp%E4%B8%8A%E5%BB%BA%E7%AB%8B%E5%8F%AFremote-dekstop%E7%9A%84ubuntu%E7%92%B0%E5%A2%83-e56fdbd3a4f2)

#### install

```bash
# dependency
sudo apt-get install ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal

# VNC Server
sudo apt-get install vnc4server

# 安裝完成後先執行vncserver，會先跳出password設定的選項
vncserver
```

#### modify `~/.vnc/xstartup`

```shell
#!/bin/sh

# Uncomment the following two lines for normal desktop:
# unset SESSION_MANAGER
# exec /etc/X11/xinit/xinitrc

[ -x /etc/vnc/xstartup ] && exec /etc/vnc/xstartup
[ -r $HOME/.Xresources ] && xrdb $HOME/.Xresources
xsetroot -solid grey
vncconfig -iconic &
x-terminal-emulator -geometry 80x24+10+10 -ls -title "$VNCDESKTOP Desktop" &
x-window-manager &

gnome-panel &
gnome-settings-daemon &
metacity &
nautilus &
```

#### exec

```bash
# 殺掉目前執行的vncserver 然後重新執行
vncserver -kill :1
# vncserver預設是執行在port 5900上，如果在後面加上：1 就是5901以此類推
vncserver :1
```

#### 設定 reboot 的時候自動執行 vncserver

```bash
@reboot /usr/bin/vncserver :1
```
