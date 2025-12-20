---
title: "制作macOS系统dmg包及iso可引导镜像"
date: 2023-06-12T10:04:20+08:00
menu:
  sidebar:
    name: "制作macOS系统dmg包及iso可引导镜像"
    identifier: macos-dmg-iso
    weight: 10
tags: ["URL", "MacOS", "dmg", "iso"]
categories: ["URL", "MacOS", "dmg", "iso"]
---

- [制作 macOS 系统 dmg 包及 iso 可引导镜像](https://www.newlearner.site/2019/03/07/macos-dmg-iso.html)

### dmg

1. AppStore ==> search 'install macos' ==> get installer ==> `du -sh /Applications/Install\ macOS\ Mojave.app/`
2. 磁碟工具程式 ==> 檔案 ==> 新增映像檔 ==> 空白映像檔
   1. 大小: installer size
   2. 格式: Mac OS 擴充格式(日誌式)
   3. 分割區: 單一分割區 - GUID 分割區配置表
   4. 映像檔格式: 可讀寫的磁碟映像檔
   5. same as `hdiutil create -o ~/Desktop/macOS\ Mojave -size 6500m -layout SPUD -fs HFS+J`
3. `sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/macOS\ Mojave`

### iso

1. `hdiutil convert ~/Desktop/macOS\ Mojave.dmg -format UDTO -o ~/Desktop/macOS\ Mojave.iso`
2. `mv ~/Desktop/macOS\ Mojave.iso.cdr  ~/Desktop/macOS\ Mojave.iso`
