---
title: "Monitoring HTTP Requests on a Network Interface in Real Time"
date: 2022-06-23T16:48:42+08:00
menu:
  sidebar:
    name: "Monitoring HTTP Requests on a Network Interface in Real Time"
    identifier: linux-monitoring-http-requests-network-interfaces
    weight: 10
tags: ["URL", "Linux", "command line", "HTTP", "Network"]
categories: ["URL", "Linux", "command line", "HTTP", "Network"]
hero: images/hero/linux.png
---

- [Monitoring HTTP Requests on a Network Interface in Real Time](https://www.baeldung.com/linux/monitoring-http-requests-network-interfaces)

### tcpflow

> `apt/dnf install tcpflow`

```bash
$ sudo tcpflow -p -c -i wlp0s20f3 port 80 | grep -oE '(GET|POST) .* HTTP/1.[01]|Host: .*'
reportfilename: ./report.xml
tcpflow: listening on wlp0s20f3
GET /alexlarsson/flatpak/ubuntu/dists/focal/InRelease HTTP/1.1

GET /mirrors.txt HTTP/1.1
```

- `-p` disables promiscuous mode
- `-c` means only print the output to the console and don't create files
- `-i` specifies the network interface
  grep receives the output of tcpflow
- `-o` means show only the matching parts of the lines that match the pattern
- `-E` means the pattern is an extended regular expression (ERE)

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
