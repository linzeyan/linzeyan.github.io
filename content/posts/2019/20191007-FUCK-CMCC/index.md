---
title: "再战运营商缓存之 使用 iptables 对付死 X 缓存劫持"
date: 2019-10-07T10:41:08+08:00
menu:
  sidebar:
    name: "再战运营商缓存之 使用 iptables 对付死 X 缓存劫持"
    identifier: linux-network-iptables-cache-hijack-FUCK-CMCC
    weight: 10
tags: ["URL", "Network", "Linux", "Iptables"]
categories: ["URL", "Network", "Linux", "Iptables"]
hero: images/hero/linux.png
---

- [再战运营商缓存之 使用 iptables 对付死 X 缓存劫持](https://v2c.tech/Article/FUCK-CMCC)

##### 起因

与移动的缓存问题进行斗争要追溯到两年前，那时候因为移动竟然连 cnpm 的数据都进行缓存。并且令人喷饭的是：移动的缓存服务器不但经常速度慢到堪比万年王八跑马拉松，甚至还经常宕机，导致我只想安安静静的写个代码却不得不面对一片鲜红的报错

##### 解决

`iptables -I FORWARD -p tcp -m tcp -m ttl --ttl-gt 20 -m ttl --ttl-lt 30 -j DROP`

考虑到可能还真的有其他幺蛾子服务器发来的真实数据包的 TTL 也在 20-30 的区间范围内，应该再加一层判断。对比了移动的 302 劫持包和正常的 302 跳转包的报文后，发现移动的劫持包的状态位包含 FIN, PSH, ACK 而正常的 302 跳转包一般不会这三个都有

那么就在 iptables 规则里加上状态位是否包含 FIN, PSH, ACK 的判断：

`iptables -I FORWARD -p tcp -m tcp -m ttl --ttl-gt 20 -m ttl --ttl-lt 30 --tcp-flags ALL FIN,PSH,ACK -j DROP`

这样应该就能在丢弃移动劫持包的同时尽可能减少误伤正常数据包的可能。
