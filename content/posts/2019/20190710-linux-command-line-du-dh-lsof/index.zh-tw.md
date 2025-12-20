---
title: "linux磁碟空間沒釋放的解決方法"
date: 2019-07-10T09:57:33+08:00
menu:
  sidebar:
    name: "linux磁碟空間沒釋放的解決方法"
    identifier: linux-command-line-du-dh-lsof
    weight: 10
tags: ["URL", "Linux"]
categories: ["URL", "Linux"]
hero: images/hero/linux.png
---

- [linux 磁碟空間沒釋放的解決方法](https://www.itread01.com/content/1542767890.html)

##### 用 `df -ah` 命令 `du -h --max-depth=1`

`du` 之和遠遠小於 `df` 得到的總量

程序使用的檔案資源被刪除後，程序還活著，導致檔案未被真正刪除，無法釋放磁碟空間，卻並不能被統計到。

`lsof |grep delete`
