---
title: "Route notes"
date: 2017-09-16T15:00:00+08:00
menu:
  sidebar:
    name: "Route notes"
    identifier: network-route-notes
    weight: 10
tags: ["Network"]
categories: ["Network"]
hero: images/hero/network.png
---

Router - 善於運算路由表的機器，L3 的設備。

Routing Table

- 一張網卡綁了一個 IP，天生就有了 2 筆 route，不能被改變。192.168.1.1/24
  - 自己本身。Local route / Host route：192.168.1.1/32
  - 整個網段。Direct route / Connect route：192.168.1.0/24
- Static route 想設幾個就設幾個。
  - 172.10.10.10/24 -> 192.168.1.2
  - 2.2.2.2/26 -> 192.168.1.9
  - ...
- Default route - gateway 只有一個。
  - 0.0.0.0/0 -> 192.168.1.10
- 小數優先 - 優先走範圍小的 route。
- BGPv4
