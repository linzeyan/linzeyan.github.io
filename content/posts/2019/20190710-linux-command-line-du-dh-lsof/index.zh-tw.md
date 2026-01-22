---
title: "Linux 磁碟空間未釋放的解決方法"
date: 2019-07-10T09:57:33+08:00
menu:
  sidebar:
    name: "Linux 磁碟空間未釋放的解決方法"
    identifier: linux-command-line-du-dh-lsof
    weight: 10
tags: ["Links", "Linux"]
categories: ["Links", "Linux"]
hero: images/hero/linux.png
---

- [Linux 磁碟空間未釋放的解決方法](https://www.itread01.com/content/1542767890.html)

##### 使用 `df -ah` 命令 `du -h --max-depth=1`

`du` 的總和遠小於 `df` 得到的總量。

程式使用的檔案資源被刪除後，程式仍在執行，導致檔案未真正刪除，無法釋放磁碟空間，也無法被統計到。

`lsof |grep delete`
