---
title: "[Notes] Build an Ubuntu remote desktop environment on GCP"
date: 2021-10-20T16:14:47+08:00
menu:
  sidebar:
    name: "[Notes] Build an Ubuntu remote desktop environment on GCP"
    identifier: linux-using-vnc-connection
    weight: 10
tags: ["Links", "Linux", "VNC"]
categories: ["Links", "Linux", "VNC"]
hero: images/hero/linux.png
---

- [[Notes] Build an Ubuntu remote desktop environment on GCP](https://medium.com/@huiqinng/%E7%AD%86%E8%A8%98-%E5%9C%A8gcp%E4%B8%8A%E5%BB%BA%E7%AB%8B%E5%8F%AFremote-dekstop%E7%9A%84ubuntu%E7%92%B0%E5%A2%83-e56fdbd3a4f2)

#### Install

```bash
# dependency
sudo apt-get install ubuntu-desktop gnome-panel gnome-settings-daemon metacity nautilus gnome-terminal

# VNC Server
sudo apt-get install vnc4server

# After install, run vncserver and set the password when prompted
vncserver
```

#### Modify `~/.vnc/xstartup`

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

#### Execute

```bash
# Kill the current vncserver and restart
vncserver -kill :1
# vncserver defaults to port 5900; :1 is 5901, and so on
vncserver :1
```

#### Start vncserver on reboot

```bash
@reboot /usr/bin/vncserver :1
```
