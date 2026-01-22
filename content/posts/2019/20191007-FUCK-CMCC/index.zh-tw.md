---
title: "再戰營運商快取：使用 iptables 對付快取劫持"
date: 2019-10-07T10:41:08+08:00
menu:
  sidebar:
    name: "再戰營運商快取：使用 iptables 對付快取劫持"
    identifier: linux-network-iptables-cache-hijack-FUCK-CMCC
    weight: 10
tags: ["Links", "Network", "Linux", "Iptables"]
categories: ["Links", "Network", "Linux", "Iptables"]
hero: images/hero/linux.png
---

- [再戰營運商快取：使用 iptables 對付快取劫持](https://v2c.tech/Article/FUCK-CMCC)

##### 起因

與移動的快取問題進行鬥爭要追溯到兩年前，那時因為移動竟然連 cnpm 的資料都進行快取。更離譜的是：移動的快取伺服器不但速度慢到堪比萬年王八跑馬拉松，還經常當機，導致我只想安安靜靜寫程式卻不得不面對一片鮮紅的報錯。

##### 解決

`iptables -I FORWARD -p tcp -m tcp -m ttl --ttl-gt 20 -m ttl --ttl-lt 30 -j DROP`

考慮到可能還真的有其他伺服器送來的正常封包 TTL 也在 20-30 的區間，應該再加一層判斷。對比移動的 302 劫持封包和正常的 302 跳轉封包後，發現移動的劫持封包狀態位包含 FIN、PSH、ACK，而正常的 302 跳轉封包通常不會這三個都有。

因此在 iptables 規則中加入是否包含 FIN、PSH、ACK 的判斷：

`iptables -I FORWARD -p tcp -m tcp -m ttl --ttl-gt 20 -m ttl --ttl-lt 30 --tcp-flags ALL FIN,PSH,ACK -j DROP`

這樣應能在丟棄劫持封包的同時，盡可能降低誤傷正常封包的可能性。
