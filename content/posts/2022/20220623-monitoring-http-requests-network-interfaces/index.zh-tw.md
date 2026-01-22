---
title: "即時監控網路介面上的 HTTP 請求"
date: 2022-06-23T16:48:42+08:00
menu:
  sidebar:
    name: "即時監控網路介面上的 HTTP 請求"
    identifier: linux-monitoring-http-requests-network-interfaces
    weight: 10
tags: ["Links", "Linux", "command line", "HTTP", "Network"]
categories: ["Links", "Linux", "command line", "HTTP", "Network"]
hero: images/hero/linux.png
---

- [即時監控網路介面上的 HTTP 請求](https://www.baeldung.com/linux/monitoring-http-requests-network-interfaces)

### tcpflow

> `apt/dnf install tcpflow`

```bash
$ sudo tcpflow -p -c -i wlp0s20f3 port 80 | grep -oE '(GET|POST) .* HTTP/1.[01]|Host: .*'
reportfilename: ./report.xml
tcpflow: listening on wlp0s20f3
GET /alexlarsson/flatpak/ubuntu/dists/focal/InRelease HTTP/1.1

GET /mirrors.txt HTTP/1.1
```

- `-p` 停用混雜模式
- `-c` 只輸出到主控台，不建立檔案
- `-i` 指定網路介面
  grep 會接收 tcpflow 的輸出
- `-o` 只顯示符合樣式的那一段
- `-E` 表示樣式是延伸正則表示式（ERE）

### httpry

> `https://github.com/jbittel/httpry.git`

```bash
sudo httpry -i wlp0s20f3
httpry version 0.1.8 -- HTTP logging and information retrieval tool
Copyright (c) 2005-2014 Jason Bittel <jason.bittel@gmail.com>
Starting capture on wlp0s20f3 interface
2022-06-22 16:38:12.166	192.168.1.24	172.217.17.238	>	GET	google.com	/	HTTP/1.1	-	-
2022-06-22 16:38:12.199	172.217.17.238	192.168.1.24	<	-	-	-	HTTP/1.0	400	Bad Request
2022-06-22 16:38:23.090	192.168.1.24	172.217.17.238	>	POST	google.com	/	HTTP/1.1	-	-
2022-06-22 16:38:23.163	172.217.17.238	192.168.1.24	<	-	-	-	HTTP/1.1	405	Method Not Allowed
```
