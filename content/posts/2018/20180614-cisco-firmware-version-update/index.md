---
title: "Switch Firmware Update"
date: 2018-06-14T12:28:29+08:00
menu:
  sidebar:
    name: "Switch Firmware Update"
    identifier: switch-cisco-firmware-version-update
    weight: 10
tags: ["Switch", "Cisco"]
categories: ["Switch", "Cisco"]
---

#### Preparation:

Plug in the console.

Copy the update file to the USB drive.

**_Before starting, use `show version` to check the current version_**

#### Update SOP:

1. Insert the USB with the update file into the switch. The screen will show the detected device name.
2. Copy the update file from USB to the switch flash: `copy usbflash0(device name):<update-file> flash:`
   1. Press Enter and confirm the file name, then press Enter again. A stream of `ccccccccc` means it is copying.
3. After it finishes, use `dir flash` to verify the update file exists.
4. `conf t` to enter config mode, then `boot system flash:<update-file>` to set the new IOS image.
5. `exit` config mode, then `show boot` to confirm the new IOS is selected.
6. `write memory` to apply settings to the running config.
7. Run `reload`.
8. It takes about 15-20 minutes. After it finishes, check the version to confirm the upgrade.

```
copy usbflash0:cat.bin flash:
copy usbflash0:cat.bin flash0-2:
software install file flash:cat.bin switch 1-2
software clean
```
