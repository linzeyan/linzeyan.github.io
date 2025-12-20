---
title: "Arp notes"
date: 2017-09-03T15:00:00+08:00
menu:
  sidebar:
    name: "Arp notes"
    identifier: network-arp-notes
    weight: 10
tags: ["Network"]
categories: ["Network"]
hero: images/hero/network.png
---

封包出去前

- 對 Arp Table 找 IP 對應的 MAC
  - 有 MAC - 封裝
  - 無 MAC - 廣播
    - 同網段 - OK
    - 不同網段 - 對 Arp Table 找 Router 的 MAC
      - 有 - OK
      - 無 - 廣播
