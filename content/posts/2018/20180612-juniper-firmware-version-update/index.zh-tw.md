---
title: "防火牆更新"
date: 2018-06-12T07:48:48+08:00
menu:
  sidebar:
    name: "防火牆更新"
    identifier: firewall-juniper-firmware-version-update
    weight: 10
tags: ["Firewall", "Juniper"]
categories: ["Firewall", "Juniper"]
---

#### 事前準備:

插 console

將更新檔丟到 usb 裡

**_使用前可先使用 `show version` 查看當前版本_**

#### 更新 SOP:

1. `start shell`
2. `su成root身分`
3. `建資料夾mkdir /var/tmp/usb(名字可自取)`
4. 插入 USB，這邊要注意 da 後面的數字，目前是 da1
5. 掛載 `mount -t msdos /dev/da1s1 /var/tmp/usb` (如果是 da0，就要變成 da0s1，以此類推)
6. 跑完後 `cd /cf/var/tmp/usb/da2s1/` (usb)
   1. `ls` (junos-srxsme-15.1X49-D120.3-domestic.tgz)
7. cli 切換成 operational mode
   1. `request system software add /var/tmp/usb/da2s1/junos-srxsme-15.1X49-D120.3-domestic.tgz`
8. `request system reboot`
9. `show version`
