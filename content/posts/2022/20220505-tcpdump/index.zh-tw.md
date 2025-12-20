---
title: "Tcpdump 使用总结"
date: 2022-05-05T13:39:10+08:00
menu:
  sidebar:
    name: "Tcpdump 使用总结"
    identifier: network-command-tcpdump
    weight: 10
tags: ["URL", "Network", "tcpdump", "command line"]
categories: ["URL", "Network", "tcpdump", "command line"]
hero: images/hero/network.png
---

- [Tcpdump 使用总结](https://markrepo.github.io/commands/2018/06/23/tcpdump/)

## 命令使用

tcpdump 采用命令行方式，它的命令格式为：

```bash
tcpdump [ -AdDeflLnNOpqRStuUvxX ] [ -c count ]
           [ -C file_size ] [ -F file ]
           [ -i interface ] [ -m module ] [ -M secret ]
           [ -r file ] [ -s snaplen ] [ -T type ] [ -w file ]
           [ -W filecount ]
           [ -E spi@ipaddr algo:secret, ...  ]
           [ -y datalinktype ] [ -Z user ]
           [ expression ]
```

### tcpdump 的简单选项介绍

- `-E spi@ipaddr algo:secret , ...`，可通过`spi@ipaddr algo:secret` 来解密 IPsec ESP 包。secret 为用于 ESP 的密钥，使用 ASCII 字符串方式表达。 如果以 `0x` 开头，该密钥将以 16 进制方式读入。 除了以上的语法格式(指`spi@ipaddr algo:secret`)， 还可以在后面添加一个语法输入文件名字供 tcpdump 使用(即把 spi@ipaddr algo:secret, … 中…换成一个语法文件名)。 在接收到第一个 ESP 包时会打开此文件， 所以最好此时把赋予 tcpdump 的一些特权取消(可理解为，这样防范之后，当该文件为恶意编写时，不至于造成过大损害)。
- `-T type` 强制 tcpdump 按 type 指定的协议所描述的包结构来分析收到的数据包。 目前已知的 type 可取的协议为:
  - `aodv` (Ad-hoc On-demand Distance Vector protocol， 按需距离向量路由协议，在 Ad hoc(点对点模式)网络中使用)，
  - `cnfp` (Cisco NetFlow protocol)
  - `rpc`(Remote Procedure Call)
  - `rtp` (Real-Time Applications protocol)
  - `rtcp` (Real-Time Applications con-trol protocol)
  - `snmp` (Simple Network Management Protocol)
  - `tftp` (Trivial File Transfer Protocol， 碎文件协议)
  - `vat` (Visual Audio Tool， 可用于在 internet 上进行电视电话会议的应用层协议)
  - `wb` (distributed White Board， 可用于网络会议的应用层协议)

### 实用命令实例

**截获主机 210.27.48.1 和主机 210.27.48.2 或 210.27.48.3 的通信**

- `tcpdump host 210.27.48.1 and \( 210.27.48.2 or 210.27.48.3 \)`

**监视所有送到主机 hostname 的数据包**

- `tcpdump -i eth0 dst host hostname`

**获取主机 210.27.48.1 接收或发出的 telnet 包**

- `tcpdump tcp port 23 and host 210.27.48.1`

**打印 TCP 会话中的的开始和结束数据包, 并且数据包的源或目的不是本地网络上的主机.(nt: localnet, 实际使用时要真正替换成本地网络的名字)**

- `tcpdump 'tcp[tcpflags] & (tcp-syn|tcp-fin) != 0 and not src and dst net localnet'`

**打印所有源或目的端口是 80, 网络层协议为 IPv4, 并且含有数据,而不是 SYN,FIN 以及 ACK-only 等不含数据的数据包**

- `tcpdump 'tcp port 80 and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)'`
  > (可理解为, ip[2:2]表示整个 ip 数据包的长度, (ip[0]&0xf)«2)表示 ip 数据包包头的长度(ip[0]&0xf 代表包中的 IHL 域, 而此域的单位为 32bit, 要换算成字节数需要乘以 4,　即左移 2.　(tcp[12]&0xf0)»4 表示 tcp 头的长度, 此域的单位也是 32bit,　换算成比特数为 ((tcp[12]&0xf0) » 4)　«　２,　即 ((tcp[12]&0xf0)»2).　((ip[2:2] - ((ip[0]&0xf)«2)) - ((tcp[12]&0xf0)»2)) != 0 　表示:整个 ip 数据包的长度减去 ip 头的长度,再减去 tcp 头的长度不为 0, 这就意味着,ip 数据包中确实是有数据.对于 ipv6 版本只需考虑 ipv6 头中的'Payload Length' 与 'tcp 头的长度'的差值, 并且其中表达方式'ip[]'需换成'ip6[]'.)

**抓取 HTTP 包**

- `tcpdump  -XvvennSs 0 -i eth0 tcp[20:2]=0x4745 or tcp[20:2]=0x4854`
  > 0x4745 为"GET"前两个字母"GE",0x4854 为"HTTP"前两个字母"HT"。
