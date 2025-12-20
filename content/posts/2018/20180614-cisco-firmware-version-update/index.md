---
title: "Switch版本更新"
date: 2018-06-14T12:28:29+08:00
menu:
  sidebar:
    name: "Switch版本更新"
    identifier: switch-cisco-firmware-version-update
    weight: 10
tags: ["Switch", "Cisco"]
categories: ["Switch", "Cisco"]
---

#### 事前準備:

插 console

將更新檔丟到 usb 裡

**_使用前可先使用 `show version` 查看當前版本_**

#### 更新 SOP:

1. 將裝有更新檔的 usb 插入要更新版本的 Switch 上，此時畫面會顯示偵測到 device name
2. 將 usb 裡的更新檔複製到 switch 的 flash 裡面: `copy usbflash0(device name):更新檔 flash:`
   1. 此時按 enter 後他會問你檔名是否要用這個，再按一次 enter 即可，看到一堆 ccccccccc 就代表有在複製
3. 複製完後，`dir flash` 查看底下有沒有剛剛複製過去的更新檔
4. `conf t` 進入編輯模式，`boot system flash:更新檔` ，指定 Switch 使用新版的 IOS 來開機
5. `exit` 離開編輯模式，`show boot`，確定是否使用新版的 IOS 來開機
6. `write memory`，套用設定至 Running-Config
7. reload
8. 大概會跑 15~20 分鐘左右，等他跑完就可以查看版本是否升級成功

```
copy usbflash0:cat.bin flash:
copy usbflash0:cat.bin flash0-2:
software install file flash:cat.bin switch 1-2
software clean
```
