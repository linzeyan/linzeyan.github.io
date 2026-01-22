---
title: "Create macOS DMG and Bootable ISO"
date: 2023-06-12T10:04:20+08:00
menu:
  sidebar:
    name: "Create macOS DMG and Bootable ISO"
    identifier: macos-dmg-iso
    weight: 10
tags: ["Links", "macOS", "dmg", "iso"]
categories: ["Links", "macOS", "dmg", "iso"]
---

- [Create macOS DMG and Bootable ISO](https://www.newlearner.site/2019/03/07/macos-dmg-iso.html)

### dmg

1. AppStore ==> search 'install macos' ==> get installer ==> `du -sh /Applications/Install\ macOS\ Mojave.app/`
2. Disk Utility ==> File ==> New Image ==> Blank Image
   1. Size: installer size
   2. Format: Mac OS Extended (Journaled)
   3. Partition: Single partition - GUID Partition Map
   4. Image Format: read/write disk image
   5. same as `hdiutil create -o ~/Desktop/macOS\ Mojave -size 6500m -layout SPUD -fs HFS+J`
3. `sudo /Applications/Install\ macOS\ Mojave.app/Contents/Resources/createinstallmedia --volume /Volumes/macOS\ Mojave`

### iso

1. `hdiutil convert ~/Desktop/macOS\ Mojave.dmg -format UDTO -o ~/Desktop/macOS\ Mojave.iso`
2. `mv ~/Desktop/macOS\ Mojave.iso.cdr  ~/Desktop/macOS\ Mojave.iso`
