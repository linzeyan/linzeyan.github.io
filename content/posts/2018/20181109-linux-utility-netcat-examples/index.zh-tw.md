---
title: "Netcat（Linux nc 指令）網路管理者工具實用範例"
date: 2018-11-09T00:17:47+08:00
menu:
  sidebar:
    name: "Netcat（Linux nc 指令）網路管理者工具實用範例"
    identifier: linux-utility-netcat-examples
    weight: 10
tags: ["URL", "Linux", "netcat"]
categories: ["URL", "Linux", "netcat"]
hero: images/hero/linux.png
---

- [Netcat（Linux nc 指令）網路管理者工具實用範例](https://blog.gtwang.org/linux/linux-utility-netcat-examples/)

#### 傳送測試用的 UDP 封包到遠端伺服器

下面這行指令會傳送 UDP 的測試封包到指定的機器與連接埠，`-w1` 參數是指定 timeout 的時間為 1 秒。

`echo -n "foo" | nc -u -w1 192.168.1.8 5000`

#### 開啟 UDP 連接埠接收資料

`nc -lu localhost 5000`

#### 遠端機器的連接埠掃描（Port Scanning）

這行指令會掃描指定機器 1 ~ 1000 與 2000 ~ 3000 這兩個範圍的 TCP 連接埠，看看哪些埠號有開啟。

`nc -vnz -w 1 192.168.233.208 1-1000 2000-3000`

這行則是掃描 UDP 的連接埠

`nc -vnzu 192.168.1.8 1-65535`

#### 在兩台主機之間複製檔案

假設現在有兩台主機，分別為 A 主機與 B 主機，若要將一個檔案從 A 主機複製到 B 主機，可以先在 B 主機（檔案接收者）上執行：

`nc -l 5000 > my.jpg`

然後在 A 主機（檔案傳送者）上執行：

`nc hostB.com 5000 < my.jpg`

這樣就可以把 my.jpg 這個檔案從 A 主機複製到 B 主機上了。 雖然這個方式跟 scp 指令比起來可能不是最方便的，但是它的特點是不需要登入的動作（也就是說不需要任何帳號與密碼），假設你碰到兩台主機無法互相登入的時候，就可以使用這樣的方式處理。

#### 手動送出 HTTP 請求

`echo -ne "GET / HTTP/1.0\r\n\r\n" | nc www.google.com 80`

#### 透過代理伺服器（Proxy）連線

這指令會使用 10.2.3.4:8080 這個代理伺服器，連線至 host.example.com 的 42 連接埠。

`nc -x10.2.3.4:8080 -Xconnect host.example.com 42`

#### 使用 Unix Domain Socket

這行指令會建立一個 Unix Domain Socket，並接收資料：

`nc -lU /var/tmp/dsocket`
