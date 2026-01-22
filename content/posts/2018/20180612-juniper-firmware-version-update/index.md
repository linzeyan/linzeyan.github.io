---
title: "Firewall Update"
date: 2018-06-12T07:48:48+08:00
menu:
  sidebar:
    name: "Firewall Update"
    identifier: firewall-juniper-firmware-version-update
    weight: 10
tags: ["Firewall", "Juniper"]
categories: ["Firewall", "Juniper"]
---

#### Preparation:

Plug in the console.

Copy the update file to the USB drive.

**_Before starting, use `show version` to check the current version_**

#### Update SOP:

1. `start shell`
2. `su` to root
3. Create a directory: `mkdir /var/tmp/usb` (name can be anything)
4. Insert the USB. Note the number after `da`, currently `da1`.
5. Mount it: `mount -t msdos /dev/da1s1 /var/tmp/usb` (if `da0`, then use `da0s1`, etc.)
6. After it finishes, `cd /cf/var/tmp/usb/da2s1/` (usb)
   1. `ls` (junos-srxsme-15.1X49-D120.3-domestic.tgz)
7. Switch the CLI to operational mode
   1. `request system software add /var/tmp/usb/da2s1/junos-srxsme-15.1X49-D120.3-domestic.tgz`
8. `request system reboot`
9. `show version`
