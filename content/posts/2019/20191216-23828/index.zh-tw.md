---
title: "golang服务的文件句柄超出系统限制(too many open files)"
date: 2019-12-16T10:14:33+08:00
menu:
  sidebar:
    name: "golang服务的文件句柄超出系统限制(too many open files)"
    identifier: golang-service-has-exceeded-the-system-limit-for-file-handles-too-many-open-files
    weight: 10
tags: ["URL", "Go"]
categories: ["URL", "Go"]
hero: images/hero/go.svg
---

- [golang 服务的文件句柄超出系统限制(too many open files)](https://studygolang.com/articles/23828)

1. 查看系统的配置 `ulimit -a | grep open`，发现系统的配置正常。

2. 查看程序服务的打开文件限制，`cat /proc/40636/limits`，发现服务的限制并没有继承系统设置的，还是系统默认的 1024 限制。

3. 查看程序服务打开文件数（连接数）情况，`lsof -p 40636 | wc -l`，发现已经超出限制，所以报错。

4. 再看看程序服务打开了哪些连接，`lsof -p 40636 > openfiles.log`，发现很多 http 连接打开没有关闭，看 ip 是报警服务的接口，于是顺着这条线索，终于找到了原因，因为程序中读取到的配置解析时报错给报警服务，大量的报警服务连接后未关闭，才导致的 too many open files，这是问题的关键，但是程序为什么没有继承系统设置的最大配置限制，还需要继续查看。

5. 最终原因找到，因为程序服务是 supervisor 管理的，supervisor 启动服务默认的 minfds 配置是 1024，也就是打开文件限制是 1024，在 supervisor 的配置中加入 `minfds=81920`; 重启 `supervisorctl reload`。
