---
title: "Fixing Disk Space Not Freed on Linux"
date: 2019-07-10T09:57:33+08:00
menu:
  sidebar:
    name: "Fixing Disk Space Not Freed on Linux"
    identifier: linux-command-line-du-dh-lsof
    weight: 10
tags: ["Links", "Linux"]
categories: ["Links", "Linux"]
hero: images/hero/linux.png
---

- [Fixing Disk Space Not Freed on Linux](https://www.itread01.com/content/1542767890.html)

##### Use `df -ah` and `du -h --max-depth=1`

The total from `du` is far smaller than the total reported by `df`.

When a process deletes files but keeps running, the files are not actually removed, so disk space is not freed, and those files are not counted.

`lsof |grep delete`
