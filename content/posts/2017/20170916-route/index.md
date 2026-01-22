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

Router - a device that is good at computing routing tables, an L3 device.

Routing Table

- A NIC with one IP naturally has two routes and they cannot be changed. 192.168.1.1/24
  - Itself. Local route / Host route: 192.168.1.1/32
  - The whole subnet. Direct route / Connect route: 192.168.1.0/24
- You can add as many static routes as you want.
  - 172.10.10.10/24 -> 192.168.1.2
  - 2.2.2.2/26 -> 192.168.1.9
  - ...
- Default route - only one gateway.
  - 0.0.0.0/0 -> 192.168.1.10
- More specific routes take precedence.
- BGPv4
